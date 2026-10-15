-- Business Question:
-- Has discounting changed over time, and has profitability changed with it?

SELECT
    d.year,

    ROUND(
        100.0 * SUM(
            CASE WHEN orw.netprice != orw.unitprice
                 THEN 1.0 ELSE 0.0 END
        ) / COUNT(*),
        2
    ) AS discount_pct,

    ROUND(
        100.0 * SUM(
            orw.quantity * (orw.netprice - orw.unitcost)
        ) / NULLIF(
            SUM(orw.quantity * orw.netprice), 0
        ),
        2
    ) AS blended_margin_pct

FROM orders o
JOIN orderrows orw
    ON o.orderkey = orw.orderkey
JOIN date_dim d
    ON o.orderdate = d.date
GROUP BY d.year
ORDER BY d.year;

-- Result (discount_pct, blended_margin_pct):
-- 2016 61.93 / 56.04 | 2017 61.71 / 56.09 | 2018 61.29 / 55.76 | 2019 60.92 / 55.81 | 2020 61.18 / 55.76
-- 2021 61.09 / 56.03 | 2022 61.06 / 55.95 | 2023 61.09 / 55.87 | 2024 61.28 / 55.93 | 2025 60.91 / 55.98

-- Insight:
-- The share of lines discounted stays between 60.9% and 61.9% in every year from 2016 to 2025,
-- and blended margin between 55.8% and 56.1%. Discounting has neither intensified nor eased,
-- and there is no progressive margin erosion at the aggregate level.
-- A rate that has not moved in ten years looks like a default and not a decision.

-- Assumptions:
-- Discount (%) = proportion of order lines where UnitPrice != NetPrice
-- Margin (%) is blended: SUM(profit) / SUM(revenue)
-- Aggregation is performed at yearly level to remove seasonal noise
-- OrderDate is used as the reference for time-based analysis
