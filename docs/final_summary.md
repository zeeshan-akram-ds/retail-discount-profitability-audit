# Discounting Strategy — Profitability Impact Analysis
Contoso Retail | Order Line Level | Full-Stack Audit (SQL · Python · Power BI)

**Executive Summary:** The business operates a structurally embedded discounting 
model affecting ~61% of transactions, resulting in consistent margin compression 
across all analytical dimensions — transactions, categories, customers, stores, 
and time — with no evidence of deterioration or targeted application.


## 1. Objective

Evaluate whether the company's discounting strategy is a controlled pricing mechanism or a structural driver of margin compression across transactions, product categories, customers, stores, and time.


## 2. Dataset and Scope

**Tables used:** `orderrows` (transaction grain), `orders` (order header), `customer`, `product`, `store`, `date_dim`

**Grain:** Order line level. Each row represents a single product within a single order. The dataset contains ~223,000 order lines across ~93,000 orders.

**Currency:** Monetary values are used as-is without explicit normalization. Since the analysis focuses on relative metrics such as margin percentages and discount rates, the impact of currency differences is limited for the purposes of this audit.

**Scale:** Total revenue of ~218.8M and total profit of ~122.3M indicate a profitable business at the aggregate level. The audit examines whether this profitability holds under discounting pressure across all analytical dimensions.


## 3. Analytical Approach

The analysis followed a structured eight-step methodology designed to move from data validation to business conclusion without skipping layers of evidence.

1. **Data integrity validation** — confirmed no null prices, zero-cost anomalies, or division-by-zero exposure across key financial fields. Established that `UnitPrice != NetPrice` is a reliable and consistent signal for discount presence.
2. **Financial baseline** — computed revenue, cost, and profit at the order line level using quantity-adjusted values to establish the business's overall financial profile before segmenting by behavior.
3. **Discounted vs. non-discounted performance** — compared margin percentage and profit per order line between discounted and full-price transactions to measure the efficiency cost of discounting.
4. **Margin compression across discount tiers** — segmented discounted transactions by discount depth into four tiers (below 5%, 5–10%, 10–20%, 20%+) and measured how margin degrades as depth increases.
5. **Category-level impact** — identified which product categories concentrate the highest volume of high-discount transactions and which experience the greatest margin compression when moving from low to high discount levels. Combined both dimensions into a volume-weighted impact score.
6. **Customer-level behavior** — profiled each customer by discount dependency and average margin, then segmented into High, Medium, and Low tiers using data-driven percentile thresholds (P33 = 50%, P66 = 75%) derived from the actual distribution.
7. **Store-level behavior** — examined whether discount rates and margin vary meaningfully across store locations, and whether store-level decisions contribute to the pattern or reflect centrally imposed pricing.
8. **Trend validation** — examined discount rate and margin behavior year over year to determine whether the current pattern is stable, worsening, or improving.


## 4. Key Findings

- ~61% of all order lines are sold below the listed unit price. Discounting is the majority pricing behavior, not a promotional exception.
- Discounted transactions produce a margin of ~54% compared to ~58% for full-price transactions — a 4-percentage-point efficiency gap. Profit per order line falls from ~605 to ~508 when a discount is applied.
- Margin compresses consistently as discount depth increases, declining from ~54% at low discount levels (below 5%) to ~49% at high discount levels (10–20%). The relationship is directional and holds across all observed tiers.
- No transactions in the dataset exceed a 20% discount depth. The entire margin compression effect is driven by mid-range discounts, with the 10–20% tier accounting for the majority of discounted volume.
- High-discount volume is concentrated in two categories. Computers account for ~24% and Cell Phones ~22% of all high-discount order lines — together, nearly half of all high-discount activity. The top three categories combined exceed 60%.
- Margin compression of 4.4 to 5.2 percentage points is observed consistently across all categories. Computers and Cell Phones generate the highest total margin impact because their transaction volume amplifies the per-unit compression effect, not because their per-unit drop is more severe.
- Customers in the High discount segment — those transacting at a discount 75% or more of the time — produce an average margin of ~50.5%, compared to ~54.0% for Low-segment customers. The inverse relationship between discount dependency and profitability holds across all observed segments.
- Medium-discount customers show the highest average order line volume at ~5.4 lines per customer, suggesting that moderate discounting correlates with more active purchasing without the same margin penalty seen in the High segment.
- Discount behavior and margin levels are highly consistent across all store locations, with no meaningful deviation observed between stores. This indicates that pricing is centrally governed rather than driven by store-level decisions.
- Discount rate has remained stable at ~61% across all years in the dataset. Average margin has held within a narrow band of 51.8% to 52.2%. There is no worsening trend.


## 5. Synthesis

The data points to a stable but margin-dilutive equilibrium. Discounting is not promotional or reactive — it is a structural pricing system operating at full scale, consistently across categories, customers, and store locations, with no sign of escalation or correction over time. The current blended margin is not a deviation from a healthier baseline. It is the baseline, built into the business model through a pricing approach that has become self-reinforcing.


## 6. Business Interpretation

The business operates a volume-driven pricing model in which margin is routinely exchanged for transaction activity. Several behaviors follow from this structure.

Discount dependency has become normalized at the customer level. Customers in the High segment transact at a discount ~93% of the time. At that frequency, the discount is no longer an incentive — it is the effective price. Full-price purchasing is no longer the default expectation for a significant share of the customer base.

The margin floor has shifted. Because discount rates and margins have remained stable across years, the ~52% blended margin is the business's actual operating margin under its current pricing model, not a temporary suppression of a higher one.

Volume concentration in two categories creates asymmetric exposure. A pricing decision in Computers or Cell Phones carries outsized impact on total profitability relative to any other product group. This concentration is simultaneously the primary risk and the primary point of intervention.

Pricing is centrally governed. The uniformity of discount behavior across all store locations rules out store-level discretion as a contributing factor. The 61% discount rate reflects a policy, not a local pattern, which means the solution space is also at the policy level.

Moderate discounting appears to be the most efficient pricing behavior. Medium-segment customers show higher average purchasing volume without the same margin penalty seen in the High segment, suggesting that beyond a certain depth, additional discounting does not generate proportional volume gain.


## 7. Decision Levers

The following variables are within operational control and represent the primary points where strategy can act on the findings of this audit.

**Discount depth limits** represent a direct control over margin compression. The data identifies the 10–20% range as the primary zone of margin impact, where the majority of discounted volume is concentrated.

**Category-level discount policy** is a control point for disproportionate exposure. Because Computers and Cell Phones account for nearly half of all high-discount volume, category-specific pricing rules would isolate the highest-exposure segments without requiring changes across the full catalog.

**Customer segment-based pricing policy** is a control over how discounting is distributed across the customer base. The High, Medium, and Low segments identified in this analysis have measurably different margin profiles, providing a basis for differentiated promotional eligibility or account terms.

**Centralized pricing policy review** is the appropriate lever given store-level uniformity. Because discount behavior does not vary by store, store-level interventions would have no effect. Any change to discounting strategy must be implemented at the policy level and will propagate at full scale.

**Discount rate as a managed metric** converts a passive outcome into a controlled variable. The 61% transaction discount rate is currently observed, not targeted. Defining acceptable ranges would make it an active input into pricing decisions rather than a byproduct of them.


## 8. Limitations and Assumptions

- **Synthetic dataset.** This analysis was conducted on the Contoso retail dataset, which does not represent a real business. Findings reflect patterns within the data as constructed and should not be extrapolated to real-world pricing decisions without validation against actual business data.
- **No loss-making transactions observed.** The dataset contains no rows where unit cost exceeds net price. In a real environment, such rows would require separate handling before margin aggregation, as they would distort average margin calculations.
- **Line-level margin only.** Margin is calculated as `(NetPrice - UnitCost) / NetPrice` at the order line level. Fixed overhead, returns, shipping costs, and promotional budgets are not captured and would affect true profitability at the business level.
- **No demand elasticity data.** The analysis cannot determine whether discounting generates incremental volume or simply reduces price on orders that would have occurred at full price. Without elasticity data, the revenue contribution of discounting cannot be isolated from its cost.
- **Currency normalization not applied.** The currency exchange table was not used in this audit. Margin comparisons across geographies may carry currency distortion that is not visible in the current analysis, though the use of relative metrics limits the severity of this gap.
- **Discount depth thresholds are analytically defined.** Tier boundaries at 5%, 10%, and 20% were set for pattern detection and are not derived from the business's own pricing policy documentation. They should be revisited if actual internal pricing bands differ.
- **Store segmentation has limited discriminatory value here.** Because store-level variation is minimal, the High/Medium/Low store classification does not meaningfully differentiate stores in this dataset. It is retained for methodological consistency but is not a basis for store-level action.

## 9. Python Analysis — Extended Findings

The SQL audit established the structural profile of discounting across transactions, categories, customers, and time. Two Python notebooks extended the analysis to customer-level behaviour and validated that the transaction-level patterns hold when aggregated to individual customer economics.

### 9.1 Transaction-Level Validation

All SQL-phase financial metrics were reproduced in Python and confirmed consistent: total revenue of ~$218.8M, total profit of ~$122.3M, and a discount rate of 61.13%. The correlation between discount depth and margin is −0.37, confirming a moderate but systematic negative relationship that holds across all discount tiers and is not attributable to any single category.

### 9.2 Category-Level Margin Compression

Margin compression is uniform across all product categories, ranging from approximately 4.9 to 5.3 percentage points when comparing low-discount and high-discount transaction tiers. This uniformity confirms a standardised discount structure rather than category-specific pricing optimisation.

The aggregate margin impact is therefore determined by transaction volume rather than by the severity of discounting in any individual category. Computers and Cell Phones account for the greatest total margin erosion — approximately 18,000 and 17,000 high-discount order lines respectively — not because their discounts are deeper, but because their volume amplifies a system-wide pricing pattern.

### 9.3 Customer Segmentation — Discount Dependency

Customers were segmented into three groups by discount dependency: Low (<50% of purchases discounted), Medium (50–75%), and High (≥75%). Across 52,189 unique customers, the margin finding is clear and monotonic:

- **Low segment** (21,336 customers): average discount rate 31%, average margin 53.5%, average order lines 3.77
- **Medium segment** (14,758 customers): average discount rate 66%, average margin 51.7%, average order lines 6.23
- **High segment** (16,095 customers): average discount rate 96%, average margin 50.4%, average order lines 3.20

Margin compression is not an artifact of transaction-level aggregation — it persists when measured at the customer level.

### 9.4 The Engagement Finding

The Medium-discount segment generates the highest purchase frequency of all three groups at 6.23 average order lines per customer — nearly double the High-discount group. This inverted-U pattern indicates that discounting supports engagement up to a threshold, beyond which additional discount dependency reduces activity rather than increasing it.

High-discount customers are therefore commercially inefficient in two dimensions simultaneously: they generate the lowest margins and the lowest purchase frequency. The margin erosion they produce is not compensated by volume.

### 9.5 Structural vs Targeted Discounting

The distribution of customer discount rates is right-skewed, with a mean of 61% and a median of 64%. Approximately 24% of customers operate at ≥90% discount usage, while only 11% transact near full price. This polarised distribution rules out selective targeting as the explanation for high discount prevalence and confirms that discounting is a structural feature of customer purchasing behaviour — not a promotional lever applied to specific segments.

## 10. Executive Dashboard — Audit Visualisation

The analytical findings from the SQL and Python phases were translated into a 
three-page Power BI dashboard designed as a pricing audit deliverable rather than 
a generic reporting interface. The dashboard is structured around one question: 
is discounting a controlled pricing decision, or has it become the operational 
pricing floor?

### Page 1 — Executive Verdict

Presents the headline audit conclusion through five KPI cards (total revenue, 
average line margin, discount penetration, discounted margin, and profit gap), 
a margin-by-discount-tier bar chart with a company average reference line, and 
three structured insight panels. The page closes with a verdict banner stating 
the audit conclusion directly.

### Page 2 — Where the Margin Goes

Isolates the category-level drivers of margin leakage through a dollar-impact 
ranking of categories under high-discount conditions, a bubble scatter confirming 
that margin compression is uniform in rate but amplified by volume, and a tier 
economics reference table. The closing statement confirms that margin loss is 
scale-driven, not caused by extreme discounting in specific categories.

### Page 3 — The Customer Reality

Closes the audit with the behavioral layer. Three segment cards compare Low, 
Medium, and High discount-dependency customers across margin, engagement, and 
discount usage. A customer discount dependency distribution histogram confirms 
the right-skewed, structurally embedded pattern. A store uniformity scatter 
confirms that all stores cluster around the corporate average, ruling out 
location-driven pricing variation. The page closes with the finding that 
discounting has become embedded customer expectation rather than a tactical 
sales mechanism.