-- Business Question:
-- How does discount depth impact margin and profit, and where does margin compression occur?

WITH discount_analysis AS (
    SELECT
        quantity,
        unitprice,
        netprice,
        unitcost,
        ROUND((unitprice - netprice) / NULLIF(unitprice, 0) * 100, 2) AS discount_depth_pct,
        ROUND((netprice - unitcost) / NULLIF(netprice, 0) * 100, 2) AS margin_pct,
        quantity * (netprice - unitcost) AS line_profit
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
    ROUND(AVG(discount_depth_pct), 2) AS avg_discount_pct,
    ROUND(AVG(margin_pct), 2) AS avg_margin_pct,
    ROUND(SUM(line_profit), 2) AS total_profit
FROM discount_analysis
GROUP BY discount_tier
ORDER BY order_lines DESC;

-- Deep Discout check
SELECT COUNT(*)
FROM orderrows
WHERE (UnitPrice - NetPrice) / NULLIF(UnitPrice, 0) * 100 >= 20;

-- Note: Zero transactions exceed a 20% discount depth in this dataset,
-- confirming that deep discounting is not practiced. Margin compression
-- is driven entirely by the high volume of mid-range discounts (10–20%),
-- not by extreme price reductions.

-- Insight:
-- Margin declines consistently as discount depth increases, dropping from ~54% at low discounts to ~49% at higher discount levels.
-- A majority of transactions (~60%+) occur in the high discount tier (10–20%), indicating that the business is heavily reliant on deeper discounts.
-- This suggests that while discounting drives volume, it systematically compresses margins at scale,
-- making high-discount transactions the primary source of potential profit leakage. 

-- Assumptions:
-- Discount depth (%) = (UnitPrice - NetPrice) / UnitPrice
-- Margin (%) = (NetPrice - UnitCost) / NetPrice
-- Analysis focuses only on discounted transactions (UnitPrice != NetPrice)
-- Discount tiers are defined to evaluate margin compression behavior across increasing discount levels
