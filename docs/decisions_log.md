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