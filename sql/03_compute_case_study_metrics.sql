-- ============================================================================
-- 03_compute_case_study_metrics.sql
-- Produces every number used in case-study.md and docs/index.html (the [FILL]s).
-- Engine: DuckDB.  Prereqs:  .read sql/01_dimensions.sql  then  .read sql/02_facts.sql
-- Then:  .read sql/03_compute_case_study_metrics.sql
-- These SQL results should match the DAX measures in the model (a cross-check).
-- ============================================================================

-- Headline KPIs --------------------------------------------------------------
SELECT 'Total Sales (R$)'      AS metric, ROUND(SUM(price),0)            AS value FROM Fact_OrderItems
UNION ALL SELECT 'Total Orders',          (SELECT COUNT(*) FROM Fact_Orders)
UNION ALL SELECT 'Order Items',           (SELECT COUNT(*) FROM Fact_OrderItems)
UNION ALL SELECT 'AOV (R$)',              (SELECT ROUND(SUM(price),2) FROM Fact_OrderItems)
                                          / (SELECT COUNT(*) FROM Fact_Orders)
UNION ALL SELECT 'Avg Review Score',      (SELECT ROUND(AVG(review_score),2) FROM Fact_Orders)
UNION ALL SELECT 'Avg Delivery Days',     (SELECT ROUND(AVG(delivery_days),1) FROM Fact_Orders)
UNION ALL SELECT 'Delivered Orders',      (SELECT COUNT(*) FROM Fact_Orders WHERE delivery_days IS NOT NULL)
UNION ALL SELECT '% Late (of delivered)',
       ROUND(100.0 * (SELECT COUNT(*) FROM Fact_Orders WHERE is_late)
                    / (SELECT COUNT(*) FROM Fact_Orders WHERE delivery_days IS NOT NULL), 1)
UNION ALL SELECT '% Low Reviews (<=2 of reviewed)',
       ROUND(100.0 * (SELECT COUNT(*) FROM Fact_Orders WHERE review_score <= 2)
                    / (SELECT COUNT(*) FROM Fact_Orders WHERE review_score IS NOT NULL), 1)
UNION ALL SELECT 'Freight % of Sales',
       ROUND(100.0 * (SELECT SUM(freight_value) FROM Fact_OrderItems)
                    / (SELECT SUM(price) FROM Fact_OrderItems), 1);

-- Revenue at Risk (cross-grain via order_id) ---------------------------------
WITH risky AS (
    SELECT order_id FROM Fact_Orders WHERE is_late = TRUE OR review_score <= 2
)
SELECT 'Revenue at Risk (R$)' AS metric,
       ROUND(SUM(oi.price), 0) AS value,
       ROUND(100.0 * SUM(oi.price) / (SELECT SUM(price) FROM Fact_OrderItems), 1) AS pct_of_sales
FROM Fact_OrderItems oi
WHERE oi.order_id IN (SELECT order_id FROM risky);

-- Average review: on-time vs late --------------------------------------------
SELECT CASE WHEN is_late THEN 'Late' ELSE 'On-time' END AS delivery_bucket,
       COUNT(*) AS orders,
       ROUND(AVG(review_score), 2) AS avg_review
FROM Fact_Orders
WHERE delivery_days IS NOT NULL AND review_score IS NOT NULL
GROUP BY 1 ORDER BY 1;

-- Worst states by % late (min 200 delivered orders) --------------------------
SELECT c."Customer State" AS state,
       COUNT(*) AS delivered_orders,
       ROUND(100.0 * SUM(CASE WHEN o.is_late THEN 1 ELSE 0 END) / COUNT(*), 1) AS pct_late,
       ROUND(AVG(o.delivery_days), 1) AS avg_delivery_days,
       ROUND(AVG(o.review_score), 2)  AS avg_review
FROM Fact_Orders o
JOIN Dim_Customer c ON o.customer_id = c.customer_id
WHERE o.delivery_days IS NOT NULL
GROUP BY 1
HAVING COUNT(*) >= 200
ORDER BY pct_late DESC
LIMIT 10;

-- Top categories by sales + their share --------------------------------------
SELECT p."Category" AS category,
       ROUND(SUM(oi.price), 0) AS sales,
       ROUND(100.0 * SUM(oi.price) / (SELECT SUM(price) FROM Fact_OrderItems), 1) AS pct_of_sales,
       ROUND(100.0 * SUM(oi.freight_value) / NULLIF(SUM(oi.price),0), 1) AS freight_pct
FROM Fact_OrderItems oi
JOIN Dim_Product p ON oi.product_id = p.product_id
GROUP BY 1 ORDER BY sales DESC LIMIT 10;
