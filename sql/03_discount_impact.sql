-- Business Question:
-- How do discounted and full-price order lines compare on revenue, profit and margin?

WITH base AS (
    SELECT
        CASE 
            WHEN UnitPrice != NetPrice THEN 'Discounted'
            ELSE 'Non-Discounted'
        END AS discount_flag,
        Quantity,
        NetPrice,
        UnitCost
    FROM orderrows
)

SELECT
    discount_flag,
    SUM(Quantity * NetPrice) AS revenue,
    SUM(Quantity * UnitCost) AS cost,
    SUM(Quantity * (NetPrice - UnitCost)) AS profit,
    COUNT(*) AS total_order_lines,
    ROUND(SUM(Quantity * (NetPrice - UnitCost)) / COUNT(*), 2) AS profit_per_order_line,
    ROUND(
        SUM(Quantity * (NetPrice - UnitCost)) / 
        NULLIF(SUM(Quantity * NetPrice), 0) * 100, 2
    ) AS blended_margin_pct
FROM base
GROUP BY discount_flag;

-- Insight:
-- Discounted lines are 61.1% of order lines (136,913) and carry more total revenue and profit
-- than full-price lines (87,061) because there are more of them.
-- Per line they are less profitable: about 509 profit per line against about 605 at full price,
-- and a blended margin of about 54% against 58.4%.
-- The per-line profit gap compares different products and baskets, so it is NOT a measure of
-- money lost to discounting. The cost of discounting is measured directly, in discount dollars,
-- in 09_discount_cost_and_checks.sql.

-- Assumptions:
-- Discount is defined as UnitPrice != NetPrice at order-line level.
-- Margin (%) is blended: SUM(profit) / SUM(revenue).
