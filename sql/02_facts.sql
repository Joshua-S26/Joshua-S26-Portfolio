-- ============================================================================
-- 02_facts.sql  ·  SQL mirror of the Power Query (M) fact logic.
-- Engine: DuckDB. Prerequisite: none (reads CSVs directly).
-- Reproduces Fact_Orders (order grain) and Fact_OrderItems (line grain),
-- including the derived delivery_days / is_late fields and the latest review.
-- ============================================================================

-- latest review score per order (one review per order; keep most recent)
CREATE OR REPLACE VIEW _latest_review AS
SELECT order_id, review_score
FROM (
    SELECT order_id,
           CAST(review_score AS INTEGER) AS review_score,
           ROW_NUMBER() OVER (PARTITION BY order_id
                              ORDER BY review_creation_date::TIMESTAMP DESC) AS rn
    FROM read_csv_auto('./data/olist_order_reviews_dataset.csv')
) WHERE rn = 1;

-- Fact_Orders : one row per order_id
CREATE OR REPLACE VIEW Fact_Orders AS
SELECT
    o.order_id,
    o.customer_id,
    o.order_purchase_timestamp::TIMESTAMP::DATE                 AS purchase_date,
    o.order_status                                              AS "Order Status",
    r.review_score                                             AS review_score,
    CASE WHEN o.order_delivered_customer_date IS NOT NULL
         THEN date_diff('day', o.order_purchase_timestamp::TIMESTAMP,
                               o.order_delivered_customer_date::TIMESTAMP) END AS delivery_days,
    CASE WHEN o.order_delivered_customer_date IS NOT NULL
          AND o.order_estimated_delivery_date IS NOT NULL
         THEN o.order_delivered_customer_date::TIMESTAMP
              > o.order_estimated_delivery_date::TIMESTAMP END  AS is_late,
    o.order_delivered_customer_date::TIMESTAMP::DATE            AS "Delivered Date",
    o.order_estimated_delivery_date::TIMESTAMP::DATE           AS "Estimated Date"
FROM read_csv_auto('./data/olist_orders_dataset.csv') o
LEFT JOIN _latest_review r ON o.order_id = r.order_id;

-- Fact_OrderItems : one row per order line; customer_id & purchase_date denormalised
CREATE OR REPLACE VIEW Fact_OrderItems AS
SELECT
    i.order_id,
    i.product_id,
    i.seller_id,
    o.customer_id,
    o.order_purchase_timestamp::TIMESTAMP::DATE  AS purchase_date,
    CAST(i.price AS DOUBLE)                       AS price,
    CAST(i.freight_value AS DOUBLE)              AS freight_value
FROM read_csv_auto('./data/olist_order_items_dataset.csv') i
JOIN read_csv_auto('./data/olist_orders_dataset.csv') o ON i.order_id = o.order_id;
