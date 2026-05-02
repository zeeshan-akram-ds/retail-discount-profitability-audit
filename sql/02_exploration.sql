-- Business Question:
-- What is the overall scale of the business, its financial baseline, 
-- and how prevalent discounting is across transactions?

-- Scale
SELECT COUNT(*) AS total_orders FROM orders;

SELECT COUNT(*) AS total_order_lines FROM orderrows;

SELECT COUNT(*) AS total_customers FROM customer;

SELECT COUNT(*) AS total_products FROM product;


-- Financial baseline
SELECT
    SUM(Quantity * NetPrice) AS total_revenue,
    SUM(Quantity * UnitCost) AS total_cost,
    SUM(Quantity * (NetPrice - UnitCost)) AS total_profit
FROM orderrows;


-- Discount presence
SELECT
    ROUND(
        100.0 * SUM(CASE WHEN UnitPrice != NetPrice THEN 1 ELSE 0 END) / COUNT(*),
        2
    ) AS discount_pct
FROM orderrows;

-- Insight:
-- The dataset contains ~223K transaction lines across ~93K orders, indicating multi-line purchasing behavior.
-- Total revenue (~218.8M) and profit (~122.3M) show strong overall profitability at an aggregate level.
-- However, ~61% of transactions involve discounts, suggesting discounting is a dominant pricing strategy
-- and a key driver to investigate for potential margin leakage.

-- Assumption:
-- Revenue, cost, and profit are calculated at transaction level using Quantity-adjusted values.

