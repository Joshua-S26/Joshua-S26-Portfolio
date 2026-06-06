-- ============================================================================
-- 01_dimensions.sql  ·  SQL mirror of the Power Query (M) dimension logic.
-- Engine: DuckDB (reads the CSVs directly). No prerequisites.
-- USAGE:  open DuckDB in the folder that holds the 9 Olist CSVs, then:
--           .read sql/01_dimensions.sql
--         or replace ./data/ below with your CSV folder path.
-- These CREATE VIEW statements reproduce the same tables the TMDL model builds,
-- so the model can be reasoned about / validated in plain SQL.
-- ============================================================================

-- Dim_Customer : one row per customer_id (conformed dimension)
CREATE OR REPLACE VIEW Dim_Customer AS
SELECT
    customer_id,
    customer_unique_id,
    customer_city  AS "Customer City",
    customer_state AS "Customer State"
FROM read_csv_auto('./data/olist_customers_dataset.csv');

-- Dim_Product : one row per product_id, English category
CREATE OR REPLACE VIEW Dim_Product AS
SELECT
    p.product_id,
    -- english name if present, else portuguese, else 'unknown'; underscores -> spaces.
    -- (The TMDL/Power Query model additionally title-cases this via Text.Proper; casing is
    --  cosmetic and does not affect any numeric metric, so the SQL mirror leaves it lower-case.)
    REPLACE(
        COALESCE(NULLIF(t.product_category_name_english, ''),
                 NULLIF(p.product_category_name, ''), 'unknown'),
        '_', ' ') AS "Category"
FROM read_csv_auto('./data/olist_products_dataset.csv') p
LEFT JOIN read_csv_auto('./data/product_category_name_translation.csv') t
       ON p.product_category_name = t.product_category_name;

-- Dim_Seller : one row per seller_id
CREATE OR REPLACE VIEW Dim_Seller AS
SELECT
    seller_id,
    seller_city  AS "Seller City",
    seller_state AS "Seller State"
FROM read_csv_auto('./data/olist_sellers_dataset.csv');

-- Dim_Date : one contiguous row per day across the order history
CREATE OR REPLACE VIEW Dim_Date AS
WITH bounds AS (
    SELECT  make_date(year(min(order_purchase_timestamp::TIMESTAMP)), 1, 1)   AS start_date,
            make_date(year(max(order_purchase_timestamp::TIMESTAMP)), 12, 31) AS end_date
    FROM read_csv_auto('./data/olist_orders_dataset.csv')
),
days AS (
    SELECT UNNEST(generate_series(start_date::TIMESTAMP, end_date::TIMESTAMP, INTERVAL 1 DAY)) AS ts
    FROM bounds
)
SELECT
    CAST(ts AS DATE)                   AS "Date",
    year(ts)                           AS "Year",
    'Q' || quarter(ts)                 AS "Quarter",
    month(ts)                          AS "Month Number",
    strftime(ts, '%b')                 AS "Month",
    strftime(ts, '%b %Y')              AS "Month Year",
    year(ts) * 100 + month(ts)         AS "Month Year Sort"
FROM days;
