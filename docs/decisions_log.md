# Decisions Log

## 1. Repository Structure

The repository is organized to reflect the lifecycle of analytical work rather than tools.

- `data/raw/` stores immutable source data to preserve original state and ensure reproducibility.
- `data/processed/` contains cleaned and transformed datasets used for analysis.

This separation ensures:
- No accidental overwriting of source data
- Clear traceability from raw input to analytical output

## 2. SQL Layer Separation

SQL is divided into staged scripts instead of a single file to isolate responsibilities:

- Exploration: understand data quality and structure before transformation
- Preparation: create a unified, analysis-ready dataset
- Discount Logic: explicitly define how discounts are identified and classified
- Aggregations: produce business-level summaries for downstream analysis

This prevents mixing data validation, business logic, and reporting logic in one place.

## 3. Business-First Analysis Design

All Python notebooks are structured around business questions, not technical methods.

Each analysis step must:
- Start with a clearly defined question
- Include only transformations relevant to that question
- End with a directly interpretable business finding

Any analysis not contributing to the core problem (discount profitability) is excluded.

## 4. Transaction Table Selection (Source of Truth)

Two tables (`ORDERROWS` and `SALES`) represent the same underlying business event at the same grain (OrderKey, LineNumber).

- `ORDERROWS` is a base transactional table containing product-level line items.
- `SALES` is a pre-joined, denormalized version that includes customer, store, currency, and exchange rate information.

Despite `SALES` being more convenient, it is not used as the primary source for analysis.

### Decision
`ORDERROWS` is selected as the base table for all downstream transformations.

### Rationale

- **Control Over Logic**
  Using `ORDERROWS` ensures that all joins, transformations, and derived metrics (e.g., revenue, discount, margin) are explicitly defined rather than implicitly inherited from a prebuilt table.

- **Transparency & Auditability**
  Since the project's goal is to audit discount profitability, all calculations must be traceable and defensible. Relying on a pre-aggregated or pre-joined table introduces hidden assumptions.

- **Avoiding Duplication Risk**
  Both tables represent the same transactions. Combining or inconsistently using them would lead to duplicate records and inflated metrics (e.g., revenue, profit, quantity).

- **Consistency Across Analysis Layers**
  A single, well-defined base table prevents discrepancies across SQL, Python, and reporting layers.

### Implication

All required attributes (customer, store, currency, etc.) are explicitly joined to `ORDERROWS` during the data preparation stage. This establishes a controlled, analysis-ready dataset as the single source of truth.

## 5. Currency Handling

### Decision
No currency conversion is applied. List prices were checked and are already in one common currency.

### Evidence
For the same product and period, `UnitPrice` is identical across currency codes. Product 1, for example, is 9.74 in CAD, EUR and USD in 2016 to 2018, and 10.65 across AUD, CAD, EUR, GBP and USD in 2019 to 2020. Prices change over time (9.74, 10.65, 11.69, 12.99), not by currency.

### Implication
Dollar figures (revenue, profit, discount dollars) can be summed across orders without conversion and are reported in USD. The data shows the currency is common; USD is assumed as the base currency. The currency exchange table is not needed for this audit.

### Earlier approach (superseded)
Normalization was first deferred on the assumption that ratio-based metrics made currency scale irrelevant. That reasoning did not cover dollar totals, which is why the common-currency check was run.

## 6. Data Loading Strategy

Raw CSV files are loaded directly into PostgreSQL without preprocessing in external tools.

### Rationale
- Keeps data pipeline transparent and reproducible
- Ensures all transformations are handled within the database layer
- Avoids hidden data manipulation steps outside version-controlled SQL

## 7. Constraint Strategy Adjustment

Primary and foreign key constraints were not enforced during initial data loading.

### Rationale
- Bulk loading with constraints introduced repeated failures and slowed progress
- For analytical workflows, constraints are not strictly required for query execution
- Data validation is instead performed through explicit SQL checks

### Implication
Data integrity is ensured via post-load validation queries (duplicate checks, orphan detection, and logical consistency checks) rather than database-enforced constraints.

## 8. Analysis Grain

All analysis is performed at the order line level (OrderKey, LineNumber).

### Rationale
- Revenue, cost, and profit are computed using quantity-adjusted line values
- Prevents distortion that can occur when aggregating at order level
- Aligns with how discounts are applied (per product line, not per order)

## 9. Discount Definition

A transaction is classified as discounted when:

UnitPrice != NetPrice

### Rationale
- Validated across the dataset
- Captures all price reductions without relying on an explicit discount column
- Ensures consistent classification across all analysis steps

## 10. Discount Definition Validation

Throughout the project, a transaction is classified as discounted when `netprice != unitprice`.

Prior to analysis, it was confirmed that no transactions exist where `netprice > unitprice`, meaning the alternative definition `netprice < unitprice` produces an identical result set. Both conditions are therefore equivalent in this dataset.

The stricter form (`netprice < unitprice`) was validated and could be used interchangeably, but `!=` is retained for semantic clarity: a discounted transaction is one where the actual selling price differs from the listed price.

## 11. Dashboard Design Philosophy

The Power BI dashboard is structured as an audit narrative rather than an exploratory BI tool.

### Decision
Two pages, each answering one specific business question, with no slicers or drill-through interactions required to read the findings. A third page on customer behaviour was dropped when the customer segmentation was set aside (decision 17).

### Rationale
The project's output is a profitability audit, not a self-service reporting layer. Interaction-heavy dashboards shift interpretive responsibility to the viewer. Since the findings are definitive rather than exploratory, the dashboard should deliver conclusions directly rather than require the reader to construct them through filtering.

### Implication
Every visual earns its place by serving the page's central question. Visuals with no direct tie to the audit finding are excluded regardless of analytical interest.

## 12. DAX String Measures for Labelled Metric Display

### Decision
Where a card needs several labelled metrics, they are exposed as formatted string measures rather than numeric measures.

### Rationale
The new Power BI card visual is designed for a single primary numeric measure. The multi-row card visual supports multiple measures but produced inconsistent layout alignment within the available card space. Embedding the label directly into the DAX measure resolves both constraints without introducing additional text boxes or layout elements.

### Implication
These measures are UI layer constructs, not analytical measures. They should not be used in calculations or aggregations elsewhere in the model.

## 13. Recommendations Deferred Until Full Evidence Is Complete

### Decision
No formal recommendations were written until all analytical phases (SQL, Python, Power BI) were complete and reconciled.

### Rationale
Recommendations derived from partial evidence risk being accurate in isolation but misleading in aggregate. The later checks changed the framing of earlier findings: the customer layer was re-examined (decision 17), the category layer was rebuilt around discount dollars and penetration (decision 18), and the cost of discounting was measured directly in dollars (decision 16). A recommendation written after the first SQL pass would have rested on conclusions that did not survive these checks.

### Implication
Each recommendation references the specific finding that supports it and states the conditions under which it would not hold. Recommendations are framed as budgets, tracking and a controlled test, because the data contains no demand information to support a confident price change.

## 14. Margin Basis: Blended Everywhere

### Decision
Every margin in the SQL layer, report and dashboard is blended: `SUM(profit) / SUM(revenue)`. Average-of-line-margin is not used for reported figures.

### Rationale
Early outputs mixed the two bases. Headline margins were profit over revenue, while tier tables averaged line margins, so the discounted average (about 54%) could not be reconciled with tier margins that all sat below it. A single basis removes that contradiction, and blended margin matches how a founder reads profit over revenue.

### Implication
Average line margin is kept only where a distribution of individual lines is shown. Python notebooks that report average line margins must be re-run on the blended basis before their figures are compared with SQL.

## 15. Discount Depth and Tier Definition

### Decision
Discount depth is `(UnitPrice - NetPrice) / NULLIF(UnitPrice, 0) * 100`. Tiers are:

- Low: under 5%
- Moderate: 5% to under 10%
- High: 10% to under 20%
- Deep: 20% and above (no lines fall here)

### Rationale
Depth is measured against list price, which is how a price reduction is normally read. The tier edges are analytical choices for pattern detection and are not taken from internal pricing policy documentation.

### Implication
Tier counts depend on the denominator and edge handling, so all tables use this single definition. Changing either changes tier counts.

## 16. Cost of Discounting Measured in Dollars, Not as a Profit Gap

### Decision
The headline cost of discounting is total discount dollars, `SUM(quantity x (UnitPrice - NetPrice))`, with a break-even test. The earlier "profit per line gap between discounted and full-price lines" is not used as a loss figure.

### Rationale
The profit gap compares different products and baskets, so it does not measure money lost to discounts. Discount dollars measure the price actually given up. The break-even test, `retained share = profit on discounted sales / (profit on discounted sales + discount dollars)`, states how many discounted sales would have to be won by the discount for it to pay off, without requiring demand data.

### Implication
The break-even is arithmetic, not a demand finding. It assumes a lost sale loses all its profit and ignores repeat purchases, returns and overhead.

## 17. Customer Segmentation Not Used as Evidence

### Decision
Customer segments by discount usage (High at 75% or more, Medium at 50% or more, Low otherwise) are computed but not used as evidence of customer behaviour.

### Rationale
Customers average about 4.3 order lines, so customers with few lines can only show discount rates of 0%, 33%, 50%, 67% or 100%. The resulting spikes, the apparent engagement pattern across segments and the "dependency" reading all follow from small counts. Segmenting by discount usage and then showing lower margin is also circular, because discounted lines have lower margin by definition.

A direct check was run on customers with 10 or more lines (3,826 customers). Their discount rates cluster around the 61% average, with no customers under 10% and only 13 at exactly 100%. This is what independent line-by-line discounting produces, so discount rate does not identify discount-dependent customers.

### Implication
No customer-level pricing recommendation is made. The dependency, polarization and customer-expectation framing is withdrawn.

## 18. Category Analysis by Penetration and Discount Dollars

### Decision
Categories are compared on share of lines discounted, discount dollars and discount as a share of category revenue. The volume-weighted impact score (margin drop x high-discount lines) is dropped.

### Rationale
The impact score restated volume. Penetration and discount dollars show whether any category is discounted differently. None is: every category has 60.6% to 61.5% of lines discounted and gives up 6.2% to 6.4% of revenue.

### Implication
Category totals follow category revenue. Category-specific discount cuts are not supported by this data.

## 19. Sales Locations and Store Scope

### Decision
Location analysis covers the 64 locations that recorded sales: 63 stores plus the online channel. The count of 74 stores in the store table is not used, and closed stores are not filtered out.

### Rationale
Only 64 locations appear in the transaction data. Closed stores still hold historical sales, and removing them would drop real transactions.

### Implication
Location-level uniformity is stated as "no location differs by more than chance", not as proof of central governance. Store-level segmentation adds no information and is not used.

## 20. Dashboard Figures Recalculated in DAX from Raw Columns

### Decision
The dashboard computes revenue, profit, margin, discount dollars, discount bands and customer discount rates in DAX from `quantity`, `unitprice`, `netprice` and `unitcost`. The derived columns exported from the Python notebook (`revenue`, `profit`, `margin_pct`, `discount_pct`, `discount_tier`, `is_discounted`) are hidden and not used.

### Rationale
The Python-derived columns used average line margins and tier edges that differed from the SQL definitions (decisions 14 and 15). Recalculating from raw columns makes the dashboard follow the same definitions as the SQL layer.

### Implication
The dashboard reconciles with the SQL results. Customer-level bands are computed from the fact table, so the dashboard no longer needs `customer_segments.parquet`.

