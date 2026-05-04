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
  Since the project’s goal is to audit discount profitability, all calculations must be traceable and defensible. Relying on a pre-aggregated or pre-joined table introduces hidden assumptions.

- **Avoiding Duplication Risk**  
  Both tables represent the same transactions. Combining or inconsistently using them would lead to duplicate records and inflated metrics (e.g., revenue, profit, quantity).

- **Consistency Across Analysis Layers**  
  A single, well-defined base table prevents discrepancies across SQL, Python, and reporting layers.

### Implication

All required attributes (customer, store, currency, etc.) will be explicitly joined to `ORDERROWS` during the data preparation stage. This establishes a controlled, analysis-ready dataset as the single source of truth.

## 5. Currency Normalization Strategy

Currency normalization into USD was initially planned to ensure comparability across transactions.

However, this step was intentionally deferred during the SQL analysis phase for the following reasons:

- The primary objective of this audit is to analyze pricing behavior (discounting and margin patterns), not absolute financial reporting.
- All margin calculations are ratio-based, which reduces sensitivity to currency scale differences.
- Introducing currency joins at this stage would add complexity and risk of join errors without materially affecting directional insights.

This decision keeps the analysis focused and controlled, while leaving normalization available for future extensions (e.g., financial reporting or cross-country comparisons).

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




