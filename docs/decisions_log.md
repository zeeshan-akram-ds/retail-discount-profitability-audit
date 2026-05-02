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

## 5. Currency Normalization

All monetary values are converted into USD for consistent analysis.

### Rationale
- Multiple currencies make revenue and margin non-comparable
- USD is the majority currency in the dataset

### Implementation
- Join `ORDERROWS` -> `ORDERS` to get CurrencyCode and OrderDate
- Join with `CURRENCYEXCHANGE` on (Date, FromCurrency -> USD)
- Apply date-specific exchange rates for conversion

### Notes
- Exchange data is complete and one-to-one per (Date, FromCurrency, ToCurrency)
- Includes identity pairs (e.g., USD -> USD), so no special handling required

## 6. Schema Enforcement

Data types and constraints are enforced during load to ensure data integrity.

### Decisions
- Dates stored as DATE (not text)
- Monetary values stored as NUMERIC(12,2)
- Exchange rates stored as NUMERIC(12,6)
- Primary keys enforced to prevent duplicate transactions

### Rationale
Early enforcement prevents downstream errors in joins, aggregations, and financial calculations.

## 7. Referential Integrity

Foreign key constraints are enforced to maintain consistency across related tables.

### Rationale
- Ensures all transactions reference valid dimensions (customer, product, store)
- Prevents orphan records and unreliable joins

### Note
Foreign keys are used for data integrity, not performance optimization.

## 8. Data Loading Strategy

Raw CSV files are loaded directly into PostgreSQL without preprocessing in external tools.

### Rationale
- Keeps data pipeline transparent and reproducible
- Ensures all transformations are handled within the database layer
- Avoids hidden data manipulation steps outside version-controlled SQL

## 9. Transaction Table Constraints (ORDERROWS)

Critical transactional fields are defined as NOT NULL to ensure reliability of revenue, discount, and margin calculations.

Composite primary key (OrderKey, LineNumber) is used to preserve transaction-level granularity.

## 10. Product Referential Integrity

A foreign key constraint is enforced between orderrows.ProductKey and product.ProductKey.

### Rationale
Ensures all transactions reference valid products and prevents orphan records, supporting reliable downstream analysis.

