-- Business Question:
-- Which product categories contribute most to high-discount (10–20%) order lines?

-- Depth is NOT rounded here, so the tier edges match 04_profit_leakage.sql exactly.
WITH discount_analysis AS (
    SELECT
        productkey,
        (unitprice - netprice) / NULLIF(unitprice, 0) * 100 AS discount_depth_pct
    FROM orderrows
    WHERE unitprice != netprice
)

SELECT
    p.categoryname,
    COUNT(*) AS order_lines,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS pct_of_high_discount
FROM discount_analysis da
JOIN product p
    ON p.productkey = da.productkey
WHERE da.discount_depth_pct >= 10
  AND da.discount_depth_pct < 20
GROUP BY p.categoryname
ORDER BY order_lines DESC;

-- Result (83,625 high-discount lines):
-- Computers 19,750 (23.62%) | Cell phones 18,200 (21.76%) | Music, Movies and Audio Books 13,890 (16.61%)
-- Games and Toys 8,535 (10.21%) | Home Appliances 6,909 (8.26%) | Audio 5,665 (6.77%)
-- TV and Video 5,412 (6.47%) | Cameras and camcorders 5,264 (6.29%)

-- Insight:
-- Computers and Cell phones hold 45.4% of high-discount order lines, and the top three
-- categories 62.0%. This shows where high-discount volume sits, not that these categories
-- are discounted more heavily: query 3 below shows every category is discounted at the same rate.

-- Note: an earlier version of this query rounded discount depth to 2 decimals before applying
-- the 10% and 20% edges. That moved some lines across tier boundaries and gave counts
-- (e.g. 84,743 high-discount lines) that did not match 04_profit_leakage.sql. It is fixed above.



-- Business Question:
-- Which product categories experience the greatest margin change when moving
-- from low discount (<5%) to high discount (10–20%) levels?

WITH discounted_transactions AS (
    SELECT
        p.categoryname,
        (orw.unitprice - orw.netprice) / NULLIF(orw.unitprice, 0) * 100
            AS discount_depth_pct,
        orw.quantity * (orw.netprice - orw.unitcost) AS line_profit,
        orw.quantity * orw.netprice AS line_revenue
    FROM orderrows orw
    JOIN product p
        ON p.productkey = orw.productkey
    WHERE orw.unitprice != orw.netprice
)

SELECT
    categoryname,

    ROUND(
        100.0 * SUM(CASE WHEN discount_depth_pct < 5
            THEN line_profit ELSE 0 END)
        / NULLIF(SUM(CASE WHEN discount_depth_pct < 5
            THEN line_revenue ELSE 0 END), 0),
        2
    ) AS low_discount_margin,

    ROUND(
        100.0 * SUM(CASE WHEN discount_depth_pct >= 10
            AND discount_depth_pct < 20
            THEN line_profit ELSE 0 END)
        / NULLIF(SUM(CASE WHEN discount_depth_pct >= 10
            AND discount_depth_pct < 20
            THEN line_revenue ELSE 0 END), 0),
        2
    ) AS high_discount_margin,

    ROUND(
        100.0 * SUM(CASE WHEN discount_depth_pct < 5
            THEN line_profit ELSE 0 END)
        / NULLIF(SUM(CASE WHEN discount_depth_pct < 5
            THEN line_revenue ELSE 0 END), 0)
        -
        100.0 * SUM(CASE WHEN discount_depth_pct >= 10
            AND discount_depth_pct < 20
            THEN line_profit ELSE 0 END)
        / NULLIF(SUM(CASE WHEN discount_depth_pct >= 10
            AND discount_depth_pct < 20
            THEN line_revenue ELSE 0 END), 0),
        2
    ) AS margin_drop

FROM discounted_transactions
GROUP BY categoryname
HAVING
    SUM(CASE WHEN discount_depth_pct < 5
        THEN line_revenue ELSE 0 END) <> 0
    AND
    SUM(CASE WHEN discount_depth_pct >= 10
        AND discount_depth_pct < 20
        THEN line_revenue ELSE 0 END) <> 0
ORDER BY margin_drop DESC;

-- Result (low-discount margin, high-discount margin, drop):
-- Games and Toys 54.36 / 49.11 / 5.25 | Audio 56.64 / 51.85 / 4.79 | Cameras and camcorders 59.66 / 55.05 / 4.61
-- Cell phones 55.46 / 50.94 / 4.52 | Computers 57.58 / 53.17 / 4.41 | Home Appliances 56.95 / 52.57 / 4.39
-- Music, Movies and Audio Books 59.97 / 55.92 / 4.04 | TV and Video 58.65 / 54.63 / 4.02

-- Insight:
-- The margin drop is 4.0 to 5.3 percentage points in every category. This is what a similar
-- price cut produces on similar cost ratios, so it does not point to any category being priced
-- differently. Games and Toys shows the largest drop and TV and Video the smallest.

-- Assumptions:
-- Margin (%) is blended: SUM(profit) / SUM(revenue)
-- Discount depth (%) = (UnitPrice - NetPrice) / UnitPrice * 100
-- Comparison is restricted to categories that have observations in both low and high discount tiers
-- Analysis is performed at order line level



-- Business Question:
-- Is any category discounted more often, or more heavily, than the others?
-- Compares share of lines discounted, discount dollars, and discount as a share of revenue.

SELECT
    p.categoryname,
    COUNT(*) AS order_lines,
    SUM(CASE WHEN orw.unitprice != orw.netprice THEN 1 ELSE 0 END) AS discounted_lines,
    ROUND(
        100.0 * SUM(CASE WHEN orw.unitprice != orw.netprice THEN 1 ELSE 0 END) / COUNT(*),
        1
    ) AS pct_lines_discounted,
    ROUND(SUM(orw.quantity * (orw.unitprice - orw.netprice)), 2) AS discount_dollars,
    ROUND(SUM(orw.quantity * orw.netprice), 2) AS revenue,
    ROUND(SUM(orw.quantity * (orw.netprice - orw.unitcost)), 2) AS profit,
    ROUND(
        100.0 * SUM(orw.quantity * (orw.unitprice - orw.netprice))
        / NULLIF(SUM(orw.quantity * orw.netprice), 0),
        2
    ) AS discount_pct_of_revenue,
    ROUND(
        100.0 * SUM(orw.quantity * (orw.unitprice - orw.netprice))
        / SUM(SUM(orw.quantity * (orw.unitprice - orw.netprice))) OVER (),
        1
    ) AS pct_of_all_discount_dollars
FROM orderrows orw
JOIN product p
    ON p.productkey = orw.productkey
GROUP BY p.categoryname
ORDER BY discount_dollars DESC;

-- Result:
-- Computers 52,427 lines, 61.2% discounted, 5.97M discount, 43.3% of discount dollars
-- Cell phones 48,287, 61.0%, 2.25M, 16.3% | Home Appliances 18,674, 60.9%, 1.77M, 12.9%
-- TV and Video 14,846, 61.0%, 1.40M, 10.1% | Cameras and camcorders 14,091, 61.5%, 1.16M, 8.4%
-- Music, Movies and Audio Books 36,645, 61.4%, 0.76M, 5.5% | Audio 16,103, 60.6%, 0.36M, 2.6%
-- Games and Toys 22,901, 61.2%, 0.12M, 0.8%

-- Insight:
-- Every category has 60.6% to 61.5% of lines discounted and gives up 6.2% to 6.4% of its revenue
-- to discounts. Computers and Cell phones are 45% of order lines and 59% of revenue, and hold
-- 60% of discount dollars. Category discount totals follow category revenue: no category is
-- discounted more often or more deeply than the rest.

-- Assumptions:
-- Discount dollars = SUM(Quantity x (UnitPrice - NetPrice)), zero on full-price lines
-- Prices are in one common currency (checked in 09_discount_cost_and_checks.sql)
-- Category comes from the product table
