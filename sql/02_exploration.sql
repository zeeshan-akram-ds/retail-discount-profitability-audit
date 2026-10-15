-- Business Question:
-- What is the overall scale of the business, its financial baseline,
-- and how prevalent is discounting across transactions?

-- Scale
SELECT COUNT(DISTINCT orderkey) AS total_orders FROM orders;

SELECT COUNT(*) AS total_order_lines FROM orderrows;

SELECT COUNT(DISTINCT customerkey) AS customers_with_orders FROM orders;

SELECT COUNT(*) AS total_products FROM product;


-- Period and sales locations
SELECT
    MIN(orderdate) AS first_order_date,
    MAX(orderdate) AS last_order_date
FROM orders;

SELECT COUNT(DISTINCT storekey) AS sales_locations FROM orders;


-- Financial baseline (blended margin = total profit / total revenue)
SELECT
    SUM(Quantity * NetPrice) AS total_revenue,
    SUM(Quantity * UnitCost) AS total_cost,
    SUM(Quantity * (NetPrice - UnitCost)) AS total_profit,
    ROUND(
        100.0 * SUM(Quantity * (NetPrice - UnitCost))
        / NULLIF(SUM(Quantity * NetPrice), 0),
        2
    ) AS blended_margin_pct
FROM orderrows;


-- Discount presence
SELECT
    SUM(CASE WHEN UnitPrice != NetPrice THEN 1 ELSE 0 END) AS discounted_lines,
    COUNT(*) AS total_order_lines,
    ROUND(
        100.0 * SUM(CASE WHEN UnitPrice != NetPrice THEN 1 ELSE 0 END) / COUNT(*),
        2
    ) AS discount_pct
FROM orderrows;

-- Insight:
-- The dataset has 223,974 order lines across 93,470 orders and 52,189 customers with orders,
-- from 2016 to 2025. 64 sales locations recorded sales: 63 stores plus the online channel
-- (storekey 999999), which accounts for about 42% of order lines.
-- Revenue is about 218.8M, profit about 122.3M, and blended margin about 55.9%.
-- 136,913 order lines (61.1%) are sold below list price, so discounting is the majority
-- pricing condition and not a limited promotional tactic.
-- What this discounting costs is measured in 03_discount_impact.sql and 09_discount_cost_and_checks.sql.

-- Assumptions:
-- Revenue, cost, and profit are calculated at order-line level using Quantity-adjusted values.
-- Blended margin = SUM(profit) / SUM(revenue). This is the margin basis used in every file.
-- Monetary values are in one common currency (checked in 09_discount_cost_and_checks.sql).
