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

**Current phase: SQL Analysis — Complete**

| Phase | Status |
|---|---|
| SQL analysis (exploration, discount impact, customer & store behavior, trends) | Complete |
| Python analysis (statistical validation, segmentation modeling) | Pending |
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

---

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
├── python/           # Statistical analysis and modeling scripts (pending)
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

- **Python analysis** — statistical validation of segment differences, correlation analysis between discount depth and margin, and customer lifetime value segmentation
- **Power BI dashboard** — interactive exploration of discount behavior by category, store, customer segment, and time period
- **Possible extensions** — currency-normalized margin comparison across geographies, return rate impact on net profitability, and product-level discount concentration analysis