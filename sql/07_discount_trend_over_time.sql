-- Business Question:
-- Has discounting increased over time, and has it led to a decline in profitability?

SELECT
    d.year,
    ROUND(
        SUM(CASE WHEN orw.netprice != orw.unitprice THEN 1.0 ELSE 0.0 END)
        / COUNT(*) * 100, 2
    ) AS discount_pct,
    ROUND(
        AVG((orw.netprice - orw.unitcost) / NULLIF(orw.netprice, 0)) * 100,
    2) AS avg_margin
FROM orders o
JOIN orderrows orw
    ON o.orderkey = orw.orderkey
JOIN date_dim d
    ON o.orderdate = d.date
GROUP BY d.year
ORDER BY d.year;

-- Insight:
-- Discounting remains consistently high (~61%) across all years with no clear upward trend.
-- Average margin remains stable in a narrow range (~51.8%–52.2%), showing no meaningful decline over time.
-- This indicates that while discounting is a persistent strategy, it has not intensified nor caused
-- progressive margin erosion at the aggregate level.
-- The impact of discounting on profitability appears structural and stable rather than worsening over time.

-- Assumptions:
-- Discount (%) = proportion of order lines where UnitPrice != NetPrice
-- Margin (%) = (NetPrice - UnitCost) / NetPrice
-- Aggregation is performed at yearly level to remove seasonal noise
-- OrderDate is used as the reference for time-based analysis