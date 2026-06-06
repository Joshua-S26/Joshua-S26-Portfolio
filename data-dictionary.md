# Data Dictionary

Semantic model: **OlistDeliveryInsights** · Storage mode: Import · Currency: Brazilian Real (R$)

Source: 9 Olist CSVs loaded via Power Query (M) through the `fnLoadCsv` helper and the `CsvFolder` parameter.
Hidden columns (keys, raw numerics) are marked *hidden*; they exist for relationships and measures but aren't shown
in the field list.

## Dim_Date · *marked as Date table (`dataCategory: Time`)*
Grain: one row per calendar day, spanning the full order history (built in M from the orders' purchase dates).

| Column | Type | Notes |
|---|---|---|
| Date | date | Key. Related to `purchase_date` on both facts. |
| Year | int | |
| Quarter | text | "Q1" to "Q4" |
| Month Number | int | *hidden*, sort key for Month |
| Month | text | "Jan" to "Dec", sorted by Month Number |
| Month Year | text | "Jan 2017", sorted by Month Year Sort |
| Month Year Sort | int | *hidden*, `YYYYMM` sort key |

## Dim_Customer
Grain: one row per `customer_id` (Olist's per-order customer key). Conformed, so it filters both facts.

| Column | Type | Notes |
|---|---|---|
| customer_id | text | *hidden* key |
| customer_unique_id | text | *hidden*, identifies the person across orders (for future cohort analysis) |
| Customer City | text | dataCategory: City |
| Customer State | text | dataCategory: StateOrProvince; 2-letter BR state code; drives geography |

## Dim_Product
Grain: one row per `product_id`. Relates to `Fact_OrderItems` only.

| Column | Type | Notes |
|---|---|---|
| product_id | text | *hidden* key |
| Category | text | English category, title-cased; joined from `product_category_name_translation`, underscores removed |

## Dim_Seller
Grain: one row per `seller_id`. Relates to `Fact_OrderItems` only.

| Column | Type | Notes |
|---|---|---|
| seller_id | text | *hidden* key |
| Seller City | text | dataCategory: City |
| Seller State | text | dataCategory: StateOrProvince |

## Fact_OrderItems · *order-line grain (revenue)*
Grain: one row per order line (an order may have several items).

| Column | Type | Notes |
|---|---|---|
| order_id | text | *hidden* degenerate key; TREATAS target for Revenue at Risk |
| product_id | text | *hidden* FK to Dim_Product |
| seller_id | text | *hidden* FK to Dim_Seller |
| customer_id | text | *hidden* FK to Dim_Customer (denormalised from order header) |
| purchase_date | date | *hidden* FK to Dim_Date (denormalised from order header) |
| price | decimal | *hidden*; item price (R$); summed by [Total Sales] |
| freight_value | decimal | *hidden*; shipping charged (R$); summed by [Total Freight] |

## Fact_Orders · *order-header grain (delivery & satisfaction)*
Grain: one row per `order_id`.

| Column | Type | Notes |
|---|---|---|
| order_id | text | *hidden* key |
| customer_id | text | *hidden* FK to Dim_Customer |
| purchase_date | date | *hidden* FK to Dim_Date |
| Order Status | text | delivered / shipped / canceled / etc. |
| review_score | int | 1 to 5; latest review per order; blank if none |
| delivery_days | int | `delivered_customer_date` minus `purchase_timestamp`, in days; blank if undelivered |
| is_late | boolean | `delivered_customer_date > estimated_delivery_date`; blank if undelivered |
| Delivered Date | date | actual delivery date |
| Estimated Date | date | promised delivery date |

## _Measures · *measures-only table*
A one-row calculated table holding the measure library (keeps the field list clean). Display folders in brackets.

| Measure | Format | Definition (short) |
|---|---|---|
| Total Sales `[1 Sales]` | R$ | `SUM(Fact_OrderItems[price])` |
| Total Freight `[1 Sales]` | R$ | `SUM(Fact_OrderItems[freight_value])` |
| Order Items `[1 Sales]` | #,##0 | `COUNTROWS(Fact_OrderItems)` |
| Total Orders `[1 Sales]` | #,##0 | `COUNTROWS(Fact_Orders)` |
| AOV `[1 Sales]` | R$ | `DIVIDE([Total Sales],[Total Orders])` |
| Freight % of Sales `[1 Sales]` | % | `DIVIDE([Total Freight],[Total Sales])` |
| Sales PY `[2 Time]` | R$ | `CALCULATE([Total Sales], SAMEPERIODLASTYEAR(Dim_Date[Date]))` |
| Sales YoY % `[2 Time]` | % | `DIVIDE([Total Sales]-[Sales PY],[Sales PY])` |
| Sales YTD `[2 Time]` | R$ | `TOTALYTD([Total Sales], Dim_Date[Date])` |
| % Sales of Total `[3 Category]` | % | share vs `ALL(Dim_Product[Category])` |
| Category Rank `[3 Category]` | #,##0 | `RANKX(ALL(Dim_Product[Category]),[Total Sales],,DESC)` |
| Avg Delivery Days `[4 Delivery]` | 0.0 | `AVERAGE(Fact_Orders[delivery_days])` |
| Delivered Orders `[4 Delivery]` | #,##0 | orders with a delivery time |
| Late Orders `[4 Delivery]` | #,##0 | `is_late = TRUE()` |
| % Late `[4 Delivery]` | % | `DIVIDE([Late Orders],[Delivered Orders])` |
| On-Time % `[4 Delivery]` | % | `1 - [% Late]` |
| Avg Review Score `[4 Delivery]` | 0.00 | `AVERAGE(Fact_Orders[review_score])` |
| Avg Review (Late) / (On-Time) `[4 Delivery]` | 0.00 | avg review split by the `is_late` flag |
| % Low Reviews `[4 Delivery]` | % | share of reviewed orders rated 2 or below |
| Revenue at Risk `[5 Risk]` | R$ | line-level sales of late or low-rated orders via `TREATAS` |
| % Revenue at Risk `[5 Risk]` | % | `DIVIDE([Revenue at Risk],[Total Sales])` |
| Insight Narrative `[5 Risk]` | text | dynamic sentence for the key-insight bar (rebuilds with slicers) |
| Total Orders PY / AOV PY / On-Time % PY `[6 vs PY]` | varies | `SAMEPERIODLASTYEAR` prior-year comparisons |
| Orders YoY % / AOV YoY % / On-Time % YoY (pp) `[6 vs PY]` | % / pp | year-over-year deltas |
| Orders YTD / AOV YTD / On-Time % YTD / Revenue at Risk YTD `[8 KPI]` | varies | `TOTALYTD` indicators driving the KPI tiles |
| Sales / Orders / AOV / On-Time / Revenue at Risk **YTD PY** `[8 KPI]` | varies | prior-year YTD (KPI comparison) |
| Sales / Orders / AOV / On-Time / Revenue at Risk **Target** `[9 Targets]` | varies | editable goal constants for each KPI tile's target |

## Relationships (all single-direction, one to many)

| From (many) | To (one) | Notes |
|---|---|---|
| Fact_Orders[purchase_date] | Dim_Date[Date] | conformed |
| Fact_OrderItems[purchase_date] | Dim_Date[Date] | conformed |
| Fact_Orders[customer_id] | Dim_Customer[customer_id] | conformed |
| Fact_OrderItems[customer_id] | Dim_Customer[customer_id] | conformed |
| Fact_OrderItems[product_id] | Dim_Product[product_id] | line grain |
| Fact_OrderItems[seller_id] | Dim_Seller[seller_id] | line grain |
