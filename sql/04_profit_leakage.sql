-- Business Question:
-- How does margin change with discount depth, and is the change more than the price cut itself?

-- 1. Margin by discount tier
WITH discount_analysis AS (
    SELECT
        quantity,
        unitprice,
        netprice,
        unitcost,
        (unitprice - netprice) / NULLIF(unitprice, 0) * 100
            AS discount_depth_pct,
        quantity * (netprice - unitcost) AS line_profit,
        quantity * netprice AS line_revenue
    FROM orderrows
    WHERE unitprice != netprice
)

SELECT
    CASE
        WHEN discount_depth_pct < 5 THEN 'Low Discount (<5%)'
        WHEN discount_depth_pct < 10 THEN 'Moderate Discount (5–10%)'
        WHEN discount_depth_pct < 20 THEN 'High Discount (10–20%)'
        ELSE 'Deep Discount (20%+)'
    END AS discount_tier,
    COUNT(*) AS order_lines,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 1) AS pct_of_discounted_lines,
    ROUND(AVG(discount_depth_pct), 2) AS avg_discount_pct,
    ROUND(
        SUM(line_profit) * 100.0 /
        NULLIF(SUM(line_revenue), 0), 2
    ) AS blended_margin_pct,
    ROUND(SUM(line_profit), 2) AS total_profit
FROM discount_analysis
GROUP BY discount_tier
ORDER BY order_lines DESC;

-- Result:
-- High (10–20%)      83,625 lines  61.1%  avg discount 11.83%  margin 53.11%  profit 41,092,742.16
-- Moderate (5–10%)   39,280 lines  28.7%  avg discount  7.68%  margin 55.01%  profit 20,331,345.53
-- Low (<5%)          14,008 lines  10.2%  avg discount  2.48%  margin 57.54%  profit  8,227,110.35

-- Note: Zero order lines exceed a 20% discount depth in this dataset.


-- 2. Is the margin drop more than the price cut itself?
-- Take the full-price cost ratio (cost / revenue on undiscounted lines), keep cost unchanged,
-- and apply each tier's average discount. If actual margins match, discounted sales carry no
-- hidden extra cost.
WITH full_price AS (
    SELECT
        SUM(quantity * unitcost) / NULLIF(SUM(quantity * netprice), 0) AS cost_ratio
    FROM orderrows
    WHERE unitprice = netprice
),
tiers AS (
    SELECT
        CASE
            WHEN (unitprice - netprice) / NULLIF(unitprice, 0) * 100 < 5 THEN 'Low Discount (<5%)'
            WHEN (unitprice - netprice) / NULLIF(unitprice, 0) * 100 < 10 THEN 'Moderate Discount (5–10%)'
            WHEN (unitprice - netprice) / NULLIF(unitprice, 0) * 100 < 20 THEN 'High Discount (10–20%)'
            ELSE 'Deep Discount (20%+)'
        END AS discount_tier,
        COUNT(*) AS order_lines,
        AVG((unitprice - netprice) / NULLIF(unitprice, 0) * 100) AS avg_discount_pct,
        100.0 * SUM(quantity * (netprice - unitcost))
            / NULLIF(SUM(quantity * netprice), 0) AS actual_margin_pct
    FROM orderrows
    WHERE unitprice != netprice
    GROUP BY 1
)
SELECT
    t.discount_tier,
    t.order_lines,
    ROUND(t.avg_discount_pct, 2) AS avg_discount_pct,
    ROUND(t.actual_margin_pct, 2) AS actual_margin_pct,
    ROUND(100.0 * (1 - f.cost_ratio / (1 - t.avg_discount_pct / 100.0)), 2)
        AS margin_from_price_cut_alone
FROM tiers t
CROSS JOIN full_price f
ORDER BY t.order_lines DESC;

-- Insight:
-- Blended margin falls from 58.4% at full price to 57.5%, 55.0% and 53.1% across the three tiers.
-- Cutting price by each tier's average discount with cost unchanged predicts roughly 57.4%, 55.0%
-- and 52.8%, within about 0.3 points of the actual margins. The margin loss is therefore the
-- price cut itself, and discounted sales carry no hidden extra cost.
-- The 10–20% tier holds 61% of discounted lines, so it is where discount volume sits.

-- Assumptions:
-- Discount depth (%) = (UnitPrice - NetPrice) / UnitPrice * 100
-- Margin (%) is blended: SUM(profit) / SUM(revenue)
-- Analysis in query 1 is restricted to discounted lines (UnitPrice != NetPrice)
-- Discount tiers are analytical choices for pattern detection, not derived from pricing policy
-- Predicted margins are approximate because the tier average discount is a line average
