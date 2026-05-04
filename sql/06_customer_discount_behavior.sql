-- Business Question:
-- How does customer discount dependency relate to profitability and purchasing behavior?

WITH customer_metrics AS (
    SELECT
        c.customerkey,
        COUNT(*) AS total_order_lines,
        ROUND(
            SUM(CASE WHEN netprice != unitprice THEN 1.0 ELSE 0.0 END)
            / COUNT(*) * 100, 2) AS discount_pct,
        ROUND(AVG((netprice - unitcost) / NULLIF(netprice, 0)) * 100, 2) AS avg_margin
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
    COUNT(*)                        AS customer_count,
    ROUND(AVG(discount_pct), 2)     AS avg_discount_pct,
    ROUND(AVG(avg_margin), 2)       AS avg_margin,
    ROUND(AVG(total_order_lines), 2) AS avg_order_lines
FROM segmented
GROUP BY discount_segment
ORDER BY avg_discount_pct DESC;

-- Insight:
-- Customers with higher discount dependency exhibit lower average margins,
-- with high-discount customers (~93% discounted transactions) generating the lowest margin (~50.5%),
-- compared to low-discount customers (~54.0%).
-- This indicates a clear inverse relationship between discount reliance and profitability.
-- Additionally, medium-discount customers show the highest purchasing activity (~5.4 order lines on average),
-- suggesting that moderate discounting may balance volume and profitability more effectively than extreme discount reliance.

-- Assumptions:
-- Discount (%) is defined as the proportion of order lines where UnitPrice != NetPrice
-- Margin (%) = (NetPrice - UnitCost) / NetPrice
-- Customer segmentation is based on discount dependency thresholds:
--   High (≥75%), Medium (50–75%), Low (<50%)
-- Analysis is performed at order line level aggregated to customer level

