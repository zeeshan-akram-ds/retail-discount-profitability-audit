-- Business Question:
-- Do discounted transactions generate higher revenue at the expense of profitability efficiency?

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
    ) AS margin_pct
FROM base
GROUP BY discount_flag;

-- Insight:
-- Discounted transactions generate higher total revenue and profit due to higher volume (~61% of order lines).
-- However, they are less efficient, with lower profit per order line (~508 vs ~605) and lower margin (~54% vs ~58%).
-- This indicates that while discounts drive sales volume, they reduce profitability efficiency,
-- suggesting potential margin leakage.

-- Assumption:
-- Discount is defined as UnitPrice != NetPrice at transaction level.

