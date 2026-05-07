# Retail Discounting — Profitability Audit
**Full analysis:** See `docs/final_summary.md`

Structured SQL audit evaluating whether discounting is a controlled pricing mechanism or a structural source of margin compression.

---

## Problem Statement

Discounting is one of the most common levers in retail pricing, but its impact on profitability is rarely measured with precision. This project investigates:

- How prevalent discounting is across transactions, categories, customers, and stores
- Whether discount depth correlates with margin compression
- Whether the pattern is stable or worsening over time

Understanding this matters because volume-driven discounting can mask profitability problems that are invisible at the aggregate revenue level.

---

## Project Scope

**Current phase: Python Analysis — Notebooks 1 and 2 Complete**

| Phase | Status |
|---|---|
| SQL analysis (exploration, discount impact, customer & store behavior, trends) | Complete |
| Python analysis (data validation, category analysis, customer segmentation) | Notebooks 1–2 Complete · Notebook 3 Pending |
| Dashboard (Power BI) | Pending |
| Final reporting | Partially complete |

---

## Dataset Overview

**Source:** Contoso Retail (synthetic dataset)

**Grain:** Order line level — each row is a single product within a single order

**Scale:** ~223,000 order lines across ~93,000 orders

**Tables used:**

| Table | Role |
|---|---|
| `orderrows` | Primary transaction grain — prices, costs, quantities |
| `orders` | Order header — date, store, customer linkage |
| `customer` | Customer dimension |
| `product` | Product and category dimension |
| `store` | Store location and status |
| `date_dim` | Time dimension for trend analysis |
| `currency_exchange` | Present in schema; not applied in this phase |

---

## Analytical Approach

The SQL analysis follows a structured sequence. Each file addresses a distinct business question.

- Establish scale and financial baseline across all transactions
- Measure the margin and profit efficiency gap between discounted and full-price transactions
- Segment discounted transactions by discount depth tier and measure margin compression at each level
- Identify which product categories drive the highest volume of high-discount transactions and the greatest margin impact
- Profile customer discount dependency and link it to average margin by segment
- Examine store-level discount behavior to determine whether pricing is centrally governed or location-driven
- Validate discount rate and margin trends year over year

---

## Key Findings

- ~61% of all order lines are transacted below the listed unit price.
- Discounted transactions produce ~4 percentage points lower margin and ~97 lower profit per order line than full-price transactions
- Margin compresses consistently as discount depth increases, from ~54% at low levels to ~49% at the 10–20% tier; no transactions exceed 20% discount depth
- Computers and Cell Phones account for ~46% of all high-discount volume and drive the largest aggregate margin impact due to transaction scale
- High-discount customers (75%+ of transactions discounted) produce measurably lower average margins than low-discount customers
- Discount rates and margin levels are uniform across all store locations, indicating centrally governed pricing rather than store-level discretion
- No worsening trend is observed year over year; the pattern is structural and stable
- Correlation between discount depth and margin is -0.37, confirming a moderate but systematic negative relationship; the pattern holds consistently across tiers and is not attributable to any single category
- Margin compression is uniform in rate across all product categories (~4.9 to 5.3 percentage points), confirming a standardised discount structure rather than category-level pricing optimisation
- Estimated margin loss is volume-driven: Computers and Cell Phones account for the greatest aggregate impact not because their discounts are deeper, but because their transaction volume amplifies a system-wide pricing pattern
- Margin compression persists at the customer level: Low-dependency customers generate ~53.5% average margin, Medium-dependency ~51.7%, and High-dependency ~50.4% — a monotonic decline consistent with the transaction-level pattern
- Customer engagement follows an inverted-U pattern: Medium-discount customers produce the highest purchase frequency (6.23 average order lines), nearly double the High-discount group (3.20), confirming that deeper discounting does not generate proportional volume gain
- 24.2% of customers transact at ≥90% discount dependency, while only 11% operate near full price — ruling out selective targeting as the primary explanation and confirming that discounting is structurally embedded in customer purchasing behaviour
- High-discount customers are the least commercially efficient segment: they generate the lowest margins without compensating through higher activity, making them the primary source of customer-level margin erosion

---

## Visualizations

The following charts were produced during the Python validation phase. Full-resolution versions are available in `exports/`.

**Discount Depth Distribution**
![Discount Distribution](exports/discount_distribution.png)
Discount depth is tightly concentrated between 5% and 14%, confirming that the business operates within a controlled discounting band with no extreme price reductions.

**Margin Distribution — Discounted vs. Full-Price**
![Margin Distribution](exports/margin_distribution.png)
Discounted transactions cluster at a visibly lower margin level, reinforcing the ~4–5 percentage point compression identified in SQL.

**Discount Depth vs. Margin (Transaction-Level Scatter)**
![Discount vs Margin](exports/discount_vs_margin.png)
The negative relationship between discount depth and margin is monotonic — no tier shows margin recovery — confirming that deeper discounts consistently erode profitability without exception.

**Customer Discount Dependency Distribution**
![Customer Discount Distribution](exports/customer_discount_distribution.png)
The distribution is right-skewed with the dominant concentration at 100%, confirming that the largest single customer group transacts almost exclusively on discounted prices. A secondary cluster near 50% reflects mixed purchasing behaviour.

**Average Margin by Customer Discount Segment**
![Customer Segment Margin](exports/customer_segment_margin.png)
Margin declines monotonically across the three segments — Low: 53.5%, Medium: 51.7%, High: 50.4% — confirming at the customer level that discount dependency is directly associated with lower realised profitability.

**Customer Engagement by Discount Segment**
![Customer Segment Engagement](exports/customer_segment_engagement.png)
Medium-discount customers generate the highest average order lines (6.23), nearly double the High-discount group (3.20). This inverted-U pattern confirms that beyond a threshold, additional discount dependency reduces engagement rather than increasing it.

## Repository Structure

```
retail-discount-profitability-audit/
│
├── data/
│   ├── raw/          # Source CSV files (excluded via .gitignore)
│   └── processed/    # Cleaned or transformed outputs (pending)
│
├── docs/
│   ├── decisions_log.md        # Analytical decisions and justifications made during the project
│   ├── final_summary.md        # Full business-ready audit report
│   └── final_summary.pdf       # PDF export of the audit report
│
├── exports/          # Contains exports like screenshots(empty for now)
│
├── powerbi/          # Dashboard files (pending)
│
├── python/           # Discount validation, category-level margin analysis, customer segmentation (Notebooks 1–2 complete)
│
├── sql/
│   ├── 00_schema.sql                    # Table definitions
│   ├── 01_load.sql                      # Data loading
│   ├── 02_exploration.sql               # Scale and financial baseline
│   ├── 03_discount_impact.sql           # Discounted vs. non-discounted performance
│   ├── 04_profit_leakage.sql            # Margin compression by discount tier
│   ├── 05_discount_drivers.sql          # Category-level discount volume and impact
│   ├── 06_customer_discount_behavior.sql # Customer segmentation by discount dependency
│   ├── 07_discount_trend_over_time.sql  # Year-over-year trend analysis
│   └── 08_store_discount_behavior.sql   # Store-level discount and margin comparison
│
├── .gitignore
└── README.md
```

---

## How to Reproduce

**Requirements:** PostgreSQL (tested on v18.3)

1. Create a database and run `00_schema.sql` to set up all tables
2. Place raw CSV files in `data/raw/` and update file paths in `01_load.sql` to match your local directory
3. Run `01_load.sql` to load all source data
4. Run SQL files `02` through `08` in order — each file is self-contained and includes its business question, query, and inline findings

No external dependencies are required for the SQL phase.

---

## Limitations

- **Synthetic data.** The Contoso dataset does not represent a real business. Findings reflect patterns in the data as structured and should not be interpreted as real-world conclusions.
- **Currency normalization not applied.** The analysis uses monetary values as-is. Since the focus is on relative metrics (margin %, discount rates), the impact is limited but not eliminated for absolute comparisons across geographies.
- **Line-level margin only.** Margin is computed as `(NetPrice - UnitCost) / NetPrice` per order line. Fixed costs, returns, and overheads are excluded.
- **No elasticity data.** It is not possible from this dataset to determine whether discounting generates incremental volume or simply applies a price reduction to demand that already existed.
- **Discount tiers are analytically defined.** Tier boundaries (5%, 10%, 20%) are set for pattern detection, not derived from internal pricing policy.

---

## Next Steps

- **Python — Customer Behavior & Discount Dependency** *(next)* — deeper behavioural segmentation of customer discount dependency beyond SQL-level profiling, including lifetime value implications and segment-level margin comparison
- **Power BI dashboard** — interactive exploration of discount behavior by category, store, customer segment, and time period
- **Possible extensions** — currency-normalized margin comparison across geographies, return rate impact on net profitability, and product-level discount concentration analysis