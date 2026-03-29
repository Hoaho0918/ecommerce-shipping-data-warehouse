import os
import pandas as pd
from snowflake.sqlalchemy import URL
from sqlalchemy import create_engine


# 1) Configure Snowflake connection
SNOWFLAKE_ACCOUNT = "JJYQAVT-UR68042"
SNOWFLAKE_USER = "HOAHO0918"
SNOWFLAKE_PASSWORD = "Hibong1!1!1!1!"
SNOWFLAKE_DATABASE = "SNOWFLAKE"
SNOWFLAKE_SCHEMA = "ECOM_DW"
SNOWFLAKE_WAREHOUSE = "COMPUTE_WH"

engine = create_engine(
    URL(
        account=SNOWFLAKE_ACCOUNT,
        user=SNOWFLAKE_USER,
        password=SNOWFLAKE_PASSWORD,
        database=SNOWFLAKE_DATABASE,
        schema=SNOWFLAKE_SCHEMA,
        warehouse=SNOWFLAKE_WAREHOUSE,
    )
)

print("Connected to Snowflake.")


# 2) Load the CSV
here = os.path.dirname(__file__)
data_path = os.path.join(here, "..", "data", "dataset.csv")

print("CSV loaded from:", data_path)
df = pd.read_csv(data_path)
print("Rows:", df.shape[0])
print("Columns:", df.columns.tolist())


# 3) Load to stg_shipping_raw in Snowflake
df.to_sql(
    "stg_shipping_raw",
    engine,
    if_exists="replace",   # or "append" for incremental
    schema=SNOWFLAKE_SCHEMA,
    index=False
)
print("Loaded raw data into stg_shipping_raw.")


# 4) Validation (fact_shipments vs CSV)
print("\n--- Validating load ---")

df_fact = pd.read_sql("SELECT * FROM fact_shipments", con=engine)
print("Source rows (CSV):", df.shape[0])
print("Target rows (fact_shipments):", df_fact.shape[0])

if df.shape[0] == df_fact.shape[0]:
    print("Row count matches.")
else:
    print("Row count mismatch — check joins / filters.")

print("ETL completed.")
