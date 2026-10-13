USE DATABASE ECOMMERCE_ANALYTICS;
USE SCHEMA ECOM_DW;

CREATE OR REPLACE TABLE dim_customer (
    customer_key         INT PRIMARY KEY,
    customer_id          INT,
    gender               VARCHAR(10),
    customer_care_calls  INT,
    prior_purchases      INT,
    CONSTRAINT uk_customer_id UNIQUE (customer_id)
);

CREATE OR REPLACE TABLE dim_warehouse (
    warehouse_key      INT PRIMARY KEY,
    warehouse_block    VARCHAR(15)
);

CREATE OR REPLACE TABLE dim_shipment_mode (
    shipment_mode_key   INT PRIMARY KEY,
    mode_of_shipment    VARCHAR(10)
);

CREATE OR REPLACE TABLE dim_product_importance (
    product_importance_key INT PRIMARY KEY,
    product_importance     VARCHAR(10)
);

CREATE OR REPLACE TABLE fact_shipments (
    shipment_id              INT PRIMARY KEY,
    customer_key             INT,
    warehouse_key            INT,
    shipment_mode_key        INT,
    product_importance_key   INT,
    cost_of_product          DECIMAL(10, 2),
    discount_offered         DECIMAL(5, 2),
    weight_gms               INT,
    customer_rating          INT,
    is_on_time               BOOLEAN,
    source_customer_id       INT,

    FOREIGN KEY (customer_key)
        REFERENCES dim_customer(customer_key),

    FOREIGN KEY (warehouse_key)
        REFERENCES dim_warehouse(warehouse_key),

    FOREIGN KEY (shipment_mode_key)
        REFERENCES dim_shipment_mode(shipment_mode_key),

    FOREIGN KEY (product_importance_key)
        REFERENCES dim_product_importance(product_importance_key)
);
