-- ============================================================
-- E-Commerce Shipping Data Warehouse: Logistics Analysis
-- ============================================================

USE DATABASE YOUR_DATABASE_NAME;
USE SCHEMA ECOM_DW;


-- ============================================================
-- Query 1: Overall shipping performance
-- ============================================================

SELECT
    COUNT(*) AS total_shipments,
    COUNT_IF(is_on_time = TRUE) AS on_time_shipments,
    COUNT_IF(is_on_time = FALSE) AS late_shipments,
    ROUND(
        100.0 * COUNT_IF(is_on_time = TRUE) / COUNT(*),
        2
    ) AS on_time_delivery_rate_pct
FROM fact_shipments;


-- ============================================================
-- Query 2: Shipping performance by shipment mode
-- ============================================================

SELECT
    m.mode_of_shipment,
    COUNT(*) AS total_shipments,
    COUNT_IF(f.is_on_time = TRUE) AS on_time_shipments,
    COUNT_IF(f.is_on_time = FALSE) AS late_shipments,
    ROUND(
        100.0 * COUNT_IF(f.is_on_time = TRUE) / COUNT(*),
        2
    ) AS on_time_delivery_rate_pct,
    ROUND(AVG(f.cost_of_product), 2) AS avg_product_cost,
    ROUND(AVG(f.weight_gms), 2) AS avg_weight_gms
FROM fact_shipments AS f
JOIN dim_shipment_mode AS m
    ON f.shipment_mode_key = m.shipment_mode_key
GROUP BY m.mode_of_shipment
ORDER BY on_time_delivery_rate_pct DESC;


-- ============================================================
-- Query 3: Shipping performance by warehouse block
-- ============================================================

SELECT
    w.warehouse_block,
    COUNT(*) AS total_shipments,
    COUNT_IF(f.is_on_time = TRUE) AS on_time_shipments,
    COUNT_IF(f.is_on_time = FALSE) AS late_shipments,
    ROUND(
        100.0 * COUNT_IF(f.is_on_time = TRUE) / COUNT(*),
        2
    ) AS on_time_delivery_rate_pct,
    ROUND(AVG(f.customer_rating), 2) AS avg_customer_rating,
    ROUND(AVG(f.weight_gms), 2) AS avg_weight_gms
FROM fact_shipments AS f
JOIN dim_warehouse AS w
    ON f.warehouse_key = w.warehouse_key
GROUP BY w.warehouse_block
ORDER BY on_time_delivery_rate_pct DESC;


-- ============================================================
-- Query 4: Delivery performance by product importance
-- ============================================================

SELECT
    p.product_importance,
    COUNT(*) AS total_shipments,
    COUNT_IF(f.is_on_time = TRUE) AS on_time_shipments,
    COUNT_IF(f.is_on_time = FALSE) AS late_shipments,
    ROUND(
        100.0 * COUNT_IF(f.is_on_time = TRUE) / COUNT(*),
        2
    ) AS on_time_delivery_rate_pct,
    ROUND(AVG(f.discount_offered), 2) AS avg_discount_offered,
    ROUND(AVG(f.cost_of_product), 2) AS avg_product_cost
FROM fact_shipments AS f
JOIN dim_product_importance AS p
    ON f.product_importance_key = p.product_importance_key
GROUP BY p.product_importance
ORDER BY on_time_delivery_rate_pct DESC;


-- ============================================================
-- Query 5: Shipment attributes by delivery outcome
-- ============================================================

SELECT
    CASE
        WHEN is_on_time THEN 'On Time'
        ELSE 'Late'
    END AS delivery_status,
    COUNT(*) AS total_shipments,
    ROUND(AVG(discount_offered), 2) AS avg_discount_offered,
    ROUND(AVG(weight_gms), 2) AS avg_weight_gms,
    ROUND(AVG(cost_of_product), 2) AS avg_product_cost,
    ROUND(AVG(customer_rating), 2) AS avg_customer_rating
FROM fact_shipments
GROUP BY is_on_time
ORDER BY delivery_status;


-- ============================================================
-- Query 6: Customer-care calls and delivery outcome
-- ============================================================

SELECT
    c.customer_care_calls,
    COUNT(*) AS total_shipments,
    COUNT_IF(f.is_on_time = TRUE) AS on_time_shipments,
    COUNT_IF(f.is_on_time = FALSE) AS late_shipments,
    ROUND(
        100.0 * COUNT_IF(f.is_on_time = TRUE) / COUNT(*),
        2
    ) AS on_time_delivery_rate_pct
FROM fact_shipments AS f
JOIN dim_customer AS c
    ON f.customer_key = c.customer_key
GROUP BY c.customer_care_calls
ORDER BY c.customer_care_calls;
