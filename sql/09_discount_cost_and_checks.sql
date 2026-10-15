-- Business Question:
-- What does discounting cost in dollars, how many discounted sales must the discount win for it
-- to pay off, and are the dollar figures valid (one common currency)?

-- 1. Discount cost and break-even
WITH t AS (
    SELECT
        SUM(CASE WHEN unitprice != netprice THEN 1 ELSE 0 END) AS discounted_lines,
        SUM(quantity * (unitprice - netprice)) AS discount_dollars,
        SUM(quantity * netprice) AS revenue,
        SUM(quantity * (netprice - unitcost)) AS profit,
        SUM(CASE WHEN unitprice != netprice
                 THEN quantity * (netprice - unitcost) ELSE 0 END) AS discounted_profit
    FROM orderrows
)
SELECT
    discounted_lines,
    ROUND(discount_dollars, 2) AS discount_dollars,
    ROUND(discount_dollars / discounted_lines, 2) AS discount_per_discounted_line,
    ROUND(100.0 * discount_dollars / revenue, 2) AS discount_pct_of_revenue,
    ROUND(100.0 * discount_dollars / profit, 2) AS discount_pct_of_profit,
    ROUND(discounted_profit, 2) AS profit_on_discounted_sales,
    ROUND(100.0 * discounted_profit / (discounted_profit + discount_dollars), 2)
        AS breakeven_retained_pct,
    ROUND(100.0 * discount_dollars / (discounted_profit + discount_dollars), 2)
        AS breakeven_lost_sales_pct
FROM t;

-- Result:
-- 136,913 discounted lines | discount dollars 13,787,100.92 | 100.70 per discounted line
-- 6.30% of revenue | 11.27% of profit | profit on discounted sales 69,651,198.04
-- break-even: 83.48% of discounted sales must stay, so discounts pay for themselves only if
-- removing them would lose more than 16.52% of discounted sales (about 1 in 6).

-- Insight:
-- Discounts cost about 13.8M: 6.3% of revenue and 11.3% of profit. If discounts were removed and
-- every sale stayed, profit on those sales would rise from 69.65M to 83.44M. If a share of sales
-- vanished instead, removal breaks even when 83.5% stay. This is arithmetic, not a finding about
-- demand: it assumes a lost sale loses all of its profit and ignores repeat purchases, returns
-- and overhead. Whether the real loss would be above or below 16.5% needs a controlled test.


-- 2. Discount dollars by tier (not yet recorded in the documentation)
SELECT
    CASE
        WHEN (unitprice - netprice) / NULLIF(unitprice, 0) * 100 < 5 THEN 'Low Discount (<5%)'
        WHEN (unitprice - netprice) / NULLIF(unitprice, 0) * 100 < 10 THEN 'Moderate Discount (5–10%)'
        WHEN (unitprice - netprice) / NULLIF(unitprice, 0) * 100 < 20 THEN 'High Discount (10–20%)'
        ELSE 'Deep Discount (20%+)'
    END AS discount_tier,
    COUNT(*) AS order_lines,
    ROUND(SUM(quantity * (unitprice - netprice)), 2) AS discount_dollars,
    ROUND(
        100.0 * SUM(quantity * (unitprice - netprice))
        / SUM(SUM(quantity * (unitprice - netprice))) OVER (),
        1
    ) AS pct_of_all_discount_dollars
FROM orderrows
WHERE unitprice != netprice
GROUP BY 1
ORDER BY order_lines DESC;


-- 3. Currency check: is UnitPrice already in one common currency?
-- Same product, same price across currency codes means no conversion is needed.
SELECT
    r.productkey,
    o.currencycode,
    r.unitprice,
    MIN(o.orderdate) AS first_order,
    MAX(o.orderdate) AS last_order,
    COUNT(*) AS order_lines
FROM orderrows r
JOIN orders o ON o.orderkey = r.orderkey
WHERE r.productkey IN (1, 2)
GROUP BY 1, 2, 3
ORDER BY 1, 3;

-- Result: product 1 is priced 9.74 in CAD, EUR and USD (2016 to 2018), 10.65 across AUD, CAD, EUR,
-- GBP and USD (2019 to 2020), 11.69 (2021 to 2022) and 12.99 (2023 to 2025). Prices change over
-- time, not by currency, so UnitPrice is one common currency and no conversion is applied.
-- Dollar figures are shown in USD (assumed base currency; the data shows only that it is common).

-- Assumptions:
-- Discount dollars = SUM(Quantity x (UnitPrice - NetPrice))
-- Break-even retained share = profit on discounted sales / (profit on discounted sales + discount dollars)
-- Margin (%) is blended: SUM(profit) / SUM(revenue)
