# Discounting Strategy — Profitability Impact Analysis
Contoso Retail | Order Line Level | SQL Audit

**Executive Summary:** The business operates a structurally embedded discounting model affecting ~61% of transactions, resulting in consistent margin compression without evidence of deterioration over time.


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
