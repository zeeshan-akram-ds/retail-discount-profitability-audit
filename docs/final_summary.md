# Discounting Strategy: Profitability Impact Analysis
Contoso Retail | Order Line Level | Full-Stack Audit (SQL, Python, Power BI)

**Executive Summary:** About 61% of order lines are sold below list price, at a steady rate in every year, product category and sales location. The discounts total $13.8M, which is 6.3% of revenue and 11.3% of profit. Whether they pay for themselves depends on how many discounted sales would be lost without them. The break-even is 16.5%, and this dataset cannot show which side of it the business is on.


## 1. Objective

Evaluate whether the company's discounting is a controlled pricing mechanism or a standing practice, what it costs, and where its cost sits across transactions, product categories, customers, locations and time.


## 2. Dataset and Scope

**Tables used:** `orderrows` (transaction grain), `orders` (order header), `customer`, `product`, `store`, `date_dim`

**Grain:** Order line. Each row is one product within one order. 223,974 order lines, 93,470 orders, 52,189 customers.

**Period:** 2016 to 2025.

**Locations:** 64 sales locations that recorded sales: 63 stores plus the online channel (93,550 lines, 42% of all lines). Store lifecycle fields (closed status) were not used to filter transactions.

**Currency:** List prices are one common currency across all currency codes. For example, product 1 is priced 9.74 in CAD, EUR and USD in the same period, and 10.65 across AUD, CAD, EUR, GBP and USD in a later period. Prices change over time, not by currency. No conversion was needed. Monetary values are shown in USD (assumed base currency; the data shows only that the currency is common).

**Scale:** Revenue $218.8M, profit $122.3M, blended margin 55.9%.

**Margin basis:** Every margin in this document is blended: `SUM(profit) / SUM(revenue)`, with revenue = quantity x net price and profit = quantity x (net price - unit cost), at order-line level.


## 3. Analytical Approach

1. **Data integrity validation.** Confirmed no null prices, zero-cost anomalies or division-by-zero exposure across key financial fields. Established that `UnitPrice != NetPrice` is a reliable signal for discount presence.
2. **Financial baseline.** Revenue, cost and profit at order-line level using quantity-adjusted values.
3. **Discounted vs full-price performance.** Blended margin for discounted and full-price lines.
4. **Discount cost.** Total discount dollars, `SUM(quantity x (UnitPrice - NetPrice))`, as a share of revenue and profit, and a break-even test for what the discounts must earn.
5. **Margin by discount tier.** Discounted lines split by depth, `(UnitPrice - NetPrice) / UnitPrice`, into under 5%, 5 to under 10%, 10 to under 20%, and 20%+. Observed margins were compared with what a price cut alone would produce.
6. **Category-level view.** Per category: share of lines discounted, discount dollars, discount as a share of revenue, and margin in the low-discount tier against the high-discount tier.
7. **Customer-level check.** Whether discount rates differ between customers once enough lines per customer are observed.
8. **Location-level view.** Whether discount rate varies by store beyond what chance would produce.
9. **Trend validation.** Discount rate and blended margin by year.


## 4. Key Findings

**Prevalence and cost**
- 136,913 of 223,974 order lines (61.1%) are sold below list price. No line is discounted by 20% or more.
- Blended margin is about 54% on discounted lines and 58.4% on full-price lines.
- Discounts total $13,787,101: about $101 per discounted line, 6.3% of revenue, 11.3% of profit.

**Margin by discount tier**

| Tier | Order lines | Share of discounted lines | Avg discount | Blended margin | Profit |
|---|---|---|---|---|---|
| Under 5% | 14,008 | 10% | 2.48% | 57.54% | $8.23M |
| 5 to under 10% | 39,280 | 29% | 7.68% | 55.01% | $20.33M |
| 10 to under 20% | 83,625 | 61% | 11.83% | 53.11% | $41.09M |

Margin falls with depth by the amount a price cut predicts. Taking the 58.4% full-price margin, holding cost fixed and applying each tier's average discount gives about 57.4%, 55.0% and 52.8%. The observed margins are within 0.3 points of that, so discounted sales carry no hidden extra cost.

**Categories.** Every category is discounted the same way: 60.6% to 61.5% of lines, and 6.2% to 6.4% of revenue.

| Category | Order lines | Lines discounted | Discount $ | % of category revenue | Share of all discount $ |
|---|---|---|---|---|---|
| Computers | 52,427 | 61.2% | $5.97M | 6.3% | 43.3% |
| Cell phones | 48,287 | 61.0% | $2.25M | 6.3% | 16.3% |
| Home Appliances | 18,674 | 60.9% | $1.77M | 6.2% | 12.9% |
| TV and Video | 14,846 | 61.0% | $1.40M | 6.3% | 10.1% |
| Cameras and camcorders | 14,091 | 61.5% | $1.16M | 6.3% | 8.4% |
| Music, Movies and Audio Books | 36,645 | 61.4% | $0.76M | 6.2% | 5.5% |
| Audio | 16,103 | 60.6% | $0.36M | 6.3% | 2.6% |
| Games and Toys | 22,901 | 61.2% | $0.12M | 6.4% | 0.8% |

Computers and Cell phones are 45% of order lines and 59% of revenue, and they hold 60% of discount dollars. Their share of discounting follows their size. In the high-discount tier, Computers hold 23.6% of lines, Cell phones 21.8%, and the top three categories (adding Music, Movies and Audio Books) 62.0%.

Margin in the low-discount tier against the high-discount tier, by category (blended): Games and Toys 54.36% to 49.11%, Audio 56.64% to 51.85%, Cameras and camcorders 59.66% to 55.05%, Cell phones 55.46% to 50.94%, Computers 57.58% to 53.17%, Home Appliances 56.95% to 52.57%, Music, Movies and Audio Books 59.97% to 55.92%, TV and Video 58.65% to 54.63%. The drop is 4.0 to 5.3 points, in line with similar discount depth everywhere.

**Locations.** Discount rates run from 58.3% to 64.7% across the 64 locations. The spread is what chance alone would produce, so no location discounts differently from the rest. Online is 61.0% discounted at a 55.97% blended margin.

**Time.** The share of lines discounted is between 60.9% and 61.9% in every year from 2016 to 2025. Blended margin is between 55.8% and 56.1%. There is no worsening or improving trend.

**Break-even.** Discounted sales earn $69.65M of profit. The discounts given on them are $13.79M. If discounts were removed and every sale stayed, profit on those sales would be $83.44M. Removing discounts therefore pays off if more than 83.5% of discounted sales stay, and discounts pay for themselves only if removing them would lose more than 16.5% of discounted sales (about 1 in 6). This is arithmetic, not a demand finding. It assumes a lost sale loses all its profit and ignores repeat purchases, returns and overhead.


## 5. Synthesis

Discounting here is a standing practice, not a targeted tool. It touches about 61% of lines at a steady rate across years, categories and locations, and it costs $13.8M. The margin loss is the price cut itself. The open question is whether the discounts win enough extra sales to justify that cost, and this dataset has no demand or before-and-after data to answer it.


## 6. Business Interpretation

**Discounting is applied as a standing practice.** None of category, store, customer or year explains which sales get a discount. Product, quantity and the promotion calendar were not tested. In a real business, finding what drives a discount would be the first thing to chase down.

**The margin loss is the price cut.** Observed tier margins match what a price cut with unchanged cost predicts, so discounted sales are no costlier to make or sell. The cost of discounting is the $13.8M of price given up.

**Category concentration is scale.** Computers and Cell phones hold most discount dollars because they hold most revenue. They are discounted at the same rate and depth as every other category, so a category-specific cut has no support in this data.

**Customers are not split into discount groups.** Customers with 10 or more order lines show discount rates clustered around the average (see section 9). There is no group of customers who always, or never, get a discount.

**Whether the discounts pay off is unknown.** They are worthwhile only if removing them would lose more than about 1 in 6 discounted sales. The data cannot say whether that holds.


## 7. Decision Levers

**A discount budget and an owner.** The rate has not moved in ten years, which looks like a default rather than a decision. A ceiling expressed as a share of revenue (currently 6.3%), with discount rate, average depth and margin reported weekly beside sales, turns a passive outcome into a managed one.

**A reason code on every discount.** Without one, discounts that win a sale cannot be separated from discounts that only give margin away.

**A controlled test on the 10 to 20% tier.** This tier holds 61% of discounted lines and has a blended margin of 53.1% against 58.4% at full price. Locations are near-identical in discount rate and margin, so randomly assigned test and control locations are a fair comparison, and online (42% of lines) is the easiest place to randomize. Fix the pass mark before the test: full removal breaks even at 16.5% of discounted sales lost, and a partial cap breaks even at a smaller figure that should be worked out first.

**Not supported by this data:** category-specific discount cuts, and customer-level discount tiers.


## 8. Limitations and Assumptions

- **Synthetic dataset.** Contoso Retail does not represent a real business. Patterns reflect how the data was generated, and the findings should not be applied to real pricing decisions without validation on actual business data.
- **No demand data.** There is no before-and-after or demand information, so the revenue contribution of discounting cannot be separated from its cost. The break-even test shows what a test would have to show.
- **No discount drivers.** There is no promotion, campaign or reason field. Product, quantity and promotion calendar were not tested as drivers.
- **Line-level margin only.** Margin is `(NetPrice - UnitCost) / NetPrice` aggregated as profit over revenue. Overhead, returns, shipping and marketing cost are not captured.
- **No loss-making transactions.** No rows have unit cost above net price. A real dataset would need separate handling.
- **Discount tier boundaries are analytically defined.** The 5%, 10% and 20% edges were chosen for pattern detection, not taken from internal pricing policy.
- **Closed stores were not filtered out.** Store lifecycle fields were not used.


## 9. Customer-Level Check

An earlier customer segmentation (Low, Medium, High by share of lines discounted) is not used as evidence. Customers average about 4.3 lines, so a customer with one to three lines can only show discount rates of 0%, 33%, 50%, 67% or 100%. Segment differences in margin and order count follow from that, and segmenting by discount usage and then showing lower margin is circular.

The check that holds: among the 3,826 customers with 10 or more order lines, the share of lines discounted is spread around the 61% average.

| Share of customer's lines discounted | Customers |
|---|---|
| Under 10% | 0 |
| 10 to 20% | 5 |
| 20 to 30% | 43 |
| 30 to 40% | 162 |
| 40 to 50% | 405 |
| 50 to 60% | 924 |
| 60 to 70% | 1,080 |
| 70 to 80% | 718 |
| 80 to 90% | 368 |
| 90 to under 100% | 108 |
| Exactly 100% | 13 |

71% of these customers sit between 50% and 80%. Only 13 (0.3%) were discounted on every line and none on fewer than 10%. The spread is about what independent line-by-line discounting at 61% produces for customers with this many lines, so discount rate does not identify a group of discount-dependent customers.


## 10. Executive Dashboard: Audit Visualisation

The findings are presented in a two-page Power BI dashboard built to be read as an answer, not explored as a tool. It asks one question: what do the discounts cost, and do they pay for themselves?

### Page 1: The Answer
KPI cards for discount dollars, share of revenue, share of profit and share of order lines discounted. A margin-by-discount-depth chart (full price against the three tiers). The break-even card ("1 in 6") with profit on discounted sales today and the same sales with no discount and none lost.

### Page 2: Same Everywhere
Category share of revenue against share of discount dollars, share of order lines discounted by year, customers with 10 or more order lines by share of their lines discounted, and the number of sales locations with the lowest-to-highest discount rate.


## 11. Figure Basis

All figures in this document come from the final SQL layer using blended margin. The dashboard recalculates the same figures in DAX from the raw price and quantity columns. The Python notebooks currently report average line margins, so their margin figures will differ until they are re-run on the blended basis.
