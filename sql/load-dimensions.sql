-- 1) dim_customer
INSERT INTO dim_customer (customer_key, customer_id, gender, customer_care_calls, prior_purchases)
SELECT
    ROW_NUMBER() OVER (ORDER BY id) AS customer_key,
    id AS customer_id,
    gender,
    customer_care_calls,
    prior_purchases
FROM (
    SELECT DISTINCT id, gender, customer_care_calls, prior_purchases
    FROM stg_shipping_raw
) s;

-- 2) dim_warehouse
INSERT INTO dim_warehouse (warehouse_key, warehouse_block)
SELECT
    ROW_NUMBER() OVER (ORDER BY warehouse_block) AS warehouse_key,
    warehouse_block
FROM (
    SELECT DISTINCT warehouse_block
    FROM stg_shipping_raw
) s;

-- 3) dim_shipment_mode
INSERT INTO dim_shipment_mode (shipment_mode_key, mode_of_shipment)
SELECT
    ROW_NUMBER() OVER (ORDER BY mode_of_shipment) AS shipment_mode_key,
    mode_of_shipment
FROM (
    SELECT DISTINCT mode_of_shipment
    FROM stg_shipping_raw
) s;

-- 4) dim_product_importance (optional)
INSERT INTO dim_product_importance (product_importance_key, product_importance)
SELECT
    ROW_NUMBER() OVER (ORDER BY product_importance) AS product_importance_key,
    product_importance
FROM (
    SELECT DISTINCT product_importance
    FROM stg_shipping_raw
) s;
