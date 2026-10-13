USE DATABASE YOUR_DATABASE_NAME;
USE SCHEMA ECOM_DW;

TRUNCATE TABLE fact_shipments;

INSERT INTO fact_shipments (
    shipment_id,
    customer_key,
    warehouse_key,
    shipment_mode_key,
    product_importance_key,
    cost_of_product,
    discount_offered,
    weight_gms,
    customer_rating,
    is_on_time,
    source_customer_id
)
SELECT
    ROW_NUMBER() OVER (ORDER BY s.id) AS shipment_id,

    c.customer_key,
    w.warehouse_key,
    m.shipment_mode_key,
    p.product_importance_key,

    s.cost_of_the_product,
    s.discount_offered,
    s.weight_in_gms,
    s.customer_rating,

    CASE
        WHEN s.reached_on_time_yn = 0 THEN TRUE
        WHEN s.reached_on_time_yn = 1 THEN FALSE
        ELSE NULL
    END AS is_on_time,

    s.id AS source_customer_id

FROM stg_shipping_raw AS s

INNER JOIN dim_customer AS c
    ON s.id = c.customer_id

INNER JOIN dim_warehouse AS w
    ON s.warehouse_block = w.warehouse_block

INNER JOIN dim_shipment_mode AS m
    ON s.mode_of_shipment = m.mode_of_shipment

INNER JOIN dim_product_importance AS p
    ON s.product_importance = p.product_importance;
