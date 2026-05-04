-- Business Question:
-- Do stores differ in discounting behavior and profitability, or is pricing strategy consistent across locations?

WITH store_metrics AS (
    SELECT
        s.storekey,
        s.countryname,
        s.status,
        ROUND(
            SUM(CASE WHEN orw.netprice != orw.unitprice THEN 1.0 ELSE 0.0 END)
            / COUNT(*) * 100, 2
        ) AS discount_pct,
        ROUND(
            AVG((orw.netprice - orw.unitcost) / NULLIF(orw.netprice, 0)) * 100, 2
        ) AS avg_margin,
        COUNT(*) AS total_order_lines
    FROM orderrows orw
    JOIN orders o ON orw.orderkey = o.orderkey
    JOIN store s ON o.storekey = s.storekey
    GROUP BY s.storekey, s.countryname, s.status
),
ranked AS (
    SELECT
        *,
        RANK() OVER (ORDER BY discount_pct DESC) AS discount_rank,
        CASE
            WHEN discount_pct >= 75 THEN 'High'
            WHEN discount_pct >= 50 THEN 'Medium'
            ELSE 'Low'
        END AS discount_segment
    FROM store_metrics
)
SELECT *
FROM ranked
ORDER BY discount_rank;

-- Insight:
-- Discounting and margin levels are highly consistent across all stores, with minimal variation.
-- No store significantly deviates in pricing behavior or profitability.
-- This indicates that discounting is centrally controlled rather than driven by store-level decisions.
-- Store performance differences are unlikely to be explained by pricing strategy.

-- Assumption:
-- Store-level aggregation assumes sufficient transaction volume to represent stable behavior.