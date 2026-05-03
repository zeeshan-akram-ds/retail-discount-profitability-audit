-- Business Question:
-- Which product categories contribute most to high-discount (10–20%) transactions?

WITH discount_analysis AS (
    SELECT
        productkey,
        ROUND((unitprice - netprice) / NULLIF(unitprice, 0) * 100, 2) AS discount_depth_pct
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

-- Insight:
-- High-discount transactions are concentrated in a few categories, with Computers (~24%) and Cell Phones (~22%) alone contributing nearly half of all high-discount volume.
-- The top three categories account for over 60% of high-discount order lines, indicating a strong category-level skew in discounting behavior.
-- This concentration suggests that discount-driven sales are not evenly distributed, but heavily driven by specific high-volume categories.



-- Business Question:
-- Which product categories experience the greatest margin compression when moving
-- from low discount (<5%) to high discount (10–20%) levels?

WITH discounted_transactions AS (
    SELECT
        p.categoryname,
        ROUND((orw.unitprice - orw.netprice) / NULLIF(orw.unitprice, 0) * 100, 2) AS discount_depth_pct,
        ROUND((orw.netprice - orw.unitcost) / NULLIF(orw.netprice, 0) * 100, 2) AS margin_pct
    FROM orderrows orw
    JOIN product p
        ON p.productkey = orw.productkey
    WHERE orw.unitprice != orw.netprice
)

SELECT
    categoryname,
    ROUND(AVG(CASE WHEN discount_depth_pct < 5 THEN margin_pct END), 2) AS low_discount_margin,
    ROUND(AVG(CASE WHEN discount_depth_pct >= 10 AND discount_depth_pct < 20 THEN margin_pct END), 2) AS high_discount_margin,
    ROUND(
        AVG(CASE WHEN discount_depth_pct < 5 THEN margin_pct END)
        -
        AVG(CASE WHEN discount_depth_pct >= 10 AND discount_depth_pct < 20 THEN margin_pct END),
    2) AS margin_drop
FROM discounted_transactions
GROUP BY categoryname
HAVING 
    AVG(CASE WHEN discount_depth_pct < 5 THEN margin_pct END) IS NOT NULL
    AND
    AVG(CASE WHEN discount_depth_pct >= 10 AND discount_depth_pct < 20 THEN margin_pct END) IS NOT NULL
ORDER BY margin_drop DESC;

-- Insight:
-- Margin compression is consistent across all categories, with a drop of ~4.4 to ~5.2 percentage points
-- when moving from low to high discount levels.
-- Categories such as Cameras and Camcorders, Games and Toys, and Home Appliances exhibit the highest
-- margin sensitivity to discounting, indicating stronger profitability impact when discounts deepen.
-- However, the margin drop is relatively uniform across categories, suggesting that discount-driven
-- margin compression is a systemic pricing effect rather than isolated to specific categories.

-- Assumptions:
-- Margin (%) = (NetPrice - UnitCost) / NetPrice
-- Discount depth (%) = (UnitPrice - NetPrice) / UnitPrice
-- Comparison is restricted to categories that have observations in both low and high discount tiers
-- Analysis is performed at order line level

-- Business Question:
-- Which product categories contribute the most to overall margin compression,
-- considering both the depth of discount impact and the volume of high-discount transactions?

WITH discounted_transactions AS (
    SELECT
        p.categoryname,
        ROUND((orw.unitprice - orw.netprice) / NULLIF(orw.unitprice, 0) * 100, 2) AS discount_depth_pct,
        ROUND((orw.netprice - orw.unitcost) / NULLIF(orw.netprice, 0) * 100, 2) AS margin_pct
    FROM orderrows orw
    JOIN product p
        ON p.productkey = orw.productkey
    WHERE orw.unitprice != orw.netprice
)
SELECT
    categoryname,

    COUNT(CASE WHEN discount_depth_pct >= 10 AND discount_depth_pct < 20 THEN 1 END)
        AS high_discount_order_lines,

    ROUND(AVG(CASE WHEN discount_depth_pct < 5 THEN margin_pct END), 2)
        AS avg_low_margin,

    ROUND(AVG(CASE WHEN discount_depth_pct >= 10 AND discount_depth_pct < 20 THEN margin_pct END), 2)
        AS avg_high_margin,

    ROUND(
        AVG(CASE WHEN discount_depth_pct < 5 THEN margin_pct END)
        - AVG(CASE WHEN discount_depth_pct >= 10 AND discount_depth_pct < 20 THEN margin_pct END),
    2) AS margin_drop,

    ROUND(
        (
            AVG(CASE WHEN discount_depth_pct < 5 THEN margin_pct END)
            - AVG(CASE WHEN discount_depth_pct >= 10 AND discount_depth_pct < 20 THEN margin_pct END)
        )
        * COUNT(CASE WHEN discount_depth_pct >= 10 AND discount_depth_pct < 20 THEN 1 END),
    2) AS estimated_margin_impact_score

FROM discounted_transactions
GROUP BY categoryname
HAVING
    AVG(CASE WHEN discount_depth_pct < 5 THEN margin_pct END) IS NOT NULL
    AND
    AVG(CASE WHEN discount_depth_pct >= 10 AND discount_depth_pct < 20 THEN margin_pct END) IS NOT NULL
ORDER BY estimated_margin_impact_score DESC;

-- Insight:
-- Categories such as Computers and Cell Phones drive the highest margin impact,
-- not because they have the largest margin drop, but due to their significantly higher
-- volume of high-discount transactions.
-- While margin compression is relatively consistent across categories (~4.5–5.2%),
-- the overall impact is amplified in high-volume categories, making them the primary
-- contributors to margin erosion at the business level.
-- This shows that profit leakage is driven more by scale than by extreme discounting behavior
-- in any single category.

-- Assumptions:
-- Margin (%) = (NetPrice - UnitCost) / NetPrice
-- Discount depth (%) = (UnitPrice - NetPrice) / UnitPrice
-- High discount tier is defined as 10%–20%
-- Estimated impact score combines margin drop (%) with high-discount volume to rank relative impact
-- Metric is comparative and not a direct monetary loss calculation