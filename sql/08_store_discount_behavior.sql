-- Business Question:
-- Do sales locations differ in discounting behavior and profitability, or is the pattern
-- consistent across locations?

-- 1. Discount rate and blended margin by location
WITH store_metrics AS (
    SELECT
        s.storekey,
        s.countryname,
        s.status,

        ROUND(
            100.0 * SUM(
                CASE WHEN orw.netprice != orw.unitprice
                     THEN 1.0 ELSE 0.0 END
            ) / COUNT(*), 2
        ) AS discount_pct,

        ROUND(
            100.0 * SUM(
                orw.quantity * (orw.netprice - orw.unitcost)
            ) / NULLIF(
                SUM(orw.quantity * orw.netprice), 0
            ), 2
        ) AS blended_margin,

        COUNT(*) AS total_order_lines

    FROM orderrows orw
    JOIN orders o ON orw.orderkey = o.orderkey
    JOIN store s ON o.storekey = s.storekey
    GROUP BY s.storekey, s.countryname, s.status
)
SELECT
    *,
    RANK() OVER (ORDER BY discount_pct DESC) AS discount_rank
FROM store_metrics
ORDER BY discount_rank;

-- Result: 64 locations that recorded sales (63 stores plus online, storekey 999999).
-- Discount rate runs from 58.26% to 64.65%. Online has 93,550 lines (42%) at 61.01% discounted
-- and a 55.97% blended margin. The blended margin extremes, 54.81% and 58.83%, belong to two
-- closed stores with only 632 and 115 order lines.


-- 2. Is the spread more than chance would produce?
-- z-score of each location's discount rate against the company rate, given its number of lines.
WITH overall AS (
    SELECT
        SUM(CASE WHEN netprice != unitprice THEN 1.0 ELSE 0.0 END) / COUNT(*) AS p
    FROM orderrows
),
store_rates AS (
    SELECT
        o.storekey,
        COUNT(*) AS n,
        AVG(CASE WHEN orw.netprice != orw.unitprice THEN 1.0 ELSE 0.0 END) AS rate
    FROM orderrows orw
    JOIN orders o ON o.orderkey = orw.orderkey
    GROUP BY o.storekey
),
z AS (
    SELECT
        sr.storekey,
        (sr.rate - ov.p) / SQRT(ov.p * (1 - ov.p) / sr.n) AS z_score
    FROM store_rates sr
    CROSS JOIN overall ov
)
SELECT
    COUNT(*) AS locations,
    SUM(CASE WHEN ABS(z_score) > 2 THEN 1 ELSE 0 END) AS beyond_2_se,
    SUM(CASE WHEN ABS(z_score) > 3 THEN 1 ELSE 0 END) AS beyond_3_se,
    ROUND(MAX(ABS(z_score))::numeric, 2) AS max_abs_z,
    ROUND(SUM(z_score * z_score)::numeric, 1) AS chi_square
FROM z;

-- Result: 64 locations, 1 beyond 2 standard errors (storekey 440, 3,437 lines at 58.71%),
-- none beyond 3, chi-square about 54.8 on 64 locations.

-- Insight:
-- Discount rate and blended margin are very similar across all 64 locations. The spread in
-- discount rate is what chance alone would produce: with 64 locations, about 3 would be expected
-- beyond 2 standard errors and only 1 is, and the chi-square is below its expected value of 64.
-- No location discounts differently from the rest, and store-level differences are unlikely to be
-- explained by pricing decisions. This shows uniformity. It does not by itself show how or where
-- the pricing is governed.

-- Assumptions:
-- Store-level aggregation assumes sufficient order-line volume to represent stable behavior.
-- Closed stores are included (store lifecycle fields are not used to filter transactions).
-- Margin (%) is blended: SUM(profit) / SUM(revenue)
