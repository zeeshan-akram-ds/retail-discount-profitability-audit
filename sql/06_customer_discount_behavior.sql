-- Business Question:
-- Do customers differ in how often they are discounted, and does discount rate relate to
-- profitability or purchasing activity?

-- 1. Descriptive segmentation by share of lines discounted (NOT used as evidence of behaviour,
--    see the note below and decision 17 in docs/decisions_log.md)
WITH customer_metrics AS (
    SELECT
        c.customerkey,
        COUNT(*) AS total_order_lines,

        100.0 * SUM(
            CASE WHEN netprice != unitprice THEN 1 ELSE 0 END
        ) / COUNT(*) AS discount_pct,

        SUM(orw.quantity * (orw.netprice - orw.unitcost))
            AS total_profit,

        SUM(orw.quantity * orw.netprice)
            AS total_revenue

    FROM customer c
    JOIN orders o ON c.customerkey = o.customerkey
    JOIN orderrows orw ON o.orderkey = orw.orderkey
    GROUP BY c.customerkey
),
segmented AS (
    SELECT
        *,
        CASE
            WHEN discount_pct >= 75 THEN 'High'
            WHEN discount_pct >= 50 THEN 'Medium'
            ELSE 'Low'
        END AS discount_segment
    FROM customer_metrics
)
SELECT
    discount_segment,
    COUNT(*) AS customer_count,
    ROUND(AVG(discount_pct), 2) AS avg_discount_pct,

    ROUND(
        100.0 * SUM(total_profit)
        / NULLIF(SUM(total_revenue), 0),
        2
    ) AS blended_margin_pct,

    ROUND(AVG(total_order_lines), 2) AS avg_order_lines

FROM segmented
GROUP BY discount_segment
ORDER BY avg_discount_pct DESC;

-- Result:
-- High    19,127 customers  avg discount 92.73%  margin 54.81%  3.46 order lines
-- Medium  19,997 customers  avg discount 58.31%  margin 55.95%  5.43 order lines
-- Low     13,065 customers  avg discount 18.84%  margin 57.23%  3.76 order lines

-- Note on query 1:
-- Customers average about 4.3 order lines (223,974 lines / 52,189 customers). A customer with
-- one to three lines can only have a discount rate of 0%, 33%, 50%, 67% or 100%, so the segments
-- mostly reflect how few lines each customer has. The margin gap between segments is also
-- circular: segmenting by share of discounted lines and then finding lower margin follows from
-- discounted lines having lower margin by definition. The engagement pattern (Medium customers
-- have the most lines) follows from the same arithmetic. These results describe the data and are
-- not evidence of discount-dependent customer behaviour.


-- 2. Check that holds: customers with 10 or more order lines
-- Bands of 10 percentage points. band k covers [10(k-1), 10k); band 11 is exactly 100%.
WITH customer_rates AS (
    SELECT
        o.customerkey,
        COUNT(*) AS order_lines,
        AVG(CASE WHEN orw.netprice != orw.unitprice THEN 1.0 ELSE 0.0 END) AS discount_rate
    FROM orders o
    JOIN orderrows orw ON orw.orderkey = o.orderkey
    GROUP BY o.customerkey
)
SELECT
    width_bucket(discount_rate * 100, 0, 100, 10) AS band,
    COUNT(*) AS customers
FROM customer_rates
WHERE order_lines >= 10
GROUP BY 1
ORDER BY 1;

-- Result (3,826 customers with 10+ lines, 7.3% of all customers):
-- band 2 (10-20%): 5 | 3 (20-30%): 43 | 4 (30-40%): 162 | 5 (40-50%): 405 | 6 (50-60%): 924
-- 7 (60-70%): 1,080 | 8 (70-80%): 718 | 9 (80-90%): 368 | 10 (90-100%): 108 | 11 (exactly 100%): 13
-- Band 1 (under 10%) has no customers.

-- Insight:
-- Among customers with enough lines to measure, discount rates cluster around the 61% company
-- average: 71% of them sit between 50% and 80%, only 13 (0.3%) were discounted on every line,
-- and none on fewer than 10%. That is the spread independent line-by-line discounting at about
-- 61% produces for customers with this many lines (spread of about 14 to 15 points).
-- There is no group of customers who always, or never, get a discount, so discount rate does not
-- identify discount-dependent customers.

-- Assumptions:
-- Discount (%) is defined as the proportion of order lines where UnitPrice != NetPrice
-- Margin (%) is blended: SUM(profit) / SUM(revenue)
-- Segment thresholds in query 1: High (>=75%), Medium (50% to under 75%), Low (<50%)
-- Analysis is performed at order line level aggregated to customer level
