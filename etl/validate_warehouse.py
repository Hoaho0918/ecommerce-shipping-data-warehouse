import os

import pandas as pd
from dotenv import load_dotenv
from snowflake.sqlalchemy import URL
from sqlalchemy import create_engine, text


load_dotenv()

SNOWFLAKE_ACCOUNT = os.getenv("SNOWFLAKE_ACCOUNT")
SNOWFLAKE_USER = os.getenv("SNOWFLAKE_USER")
SNOWFLAKE_PASSWORD = os.getenv("SNOWFLAKE_PASSWORD")
SNOWFLAKE_DATABASE = os.getenv("SNOWFLAKE_DATABASE")
SNOWFLAKE_SCHEMA = os.getenv("SNOWFLAKE_SCHEMA")
SNOWFLAKE_WAREHOUSE = os.getenv("SNOWFLAKE_WAREHOUSE")
SNOWFLAKE_ROLE = os.getenv("SNOWFLAKE_ROLE")


def get_engine():
    return create_engine(
        URL(
            account=SNOWFLAKE_ACCOUNT,
            user=SNOWFLAKE_USER,
            password=SNOWFLAKE_PASSWORD,
            database=SNOWFLAKE_DATABASE,
            schema=SNOWFLAKE_SCHEMA,
            warehouse=SNOWFLAKE_WAREHOUSE,
            role=SNOWFLAKE_ROLE,
        )
    )


def run_validation(engine, validation_name: str, query: str) -> bool:
    result = pd.read_sql(query, engine)
    failed_rows = int(result.iloc[0]["FAILED_ROWS"])

    if failed_rows == 0:
        print(f"PASS | {validation_name}")
        return True

    print(f"FAIL | {validation_name} | failed_rows={failed_rows}")
    return False


def main() -> None:
    engine = get_engine()

    validations = [
        (
            "Staging and fact row counts match",
            """
            SELECT ABS(
                (SELECT COUNT(*) FROM stg_shipping_raw)
                -
                (SELECT COUNT(*) FROM fact_shipments)
            ) AS failed_rows
            """,
        ),
        (
            "No duplicate shipment IDs",
            """
            SELECT COUNT(*) - COUNT(DISTINCT shipment_id) AS failed_rows
            FROM fact_shipments
            """,
        ),
        (
            "No null dimension keys",
            """
            SELECT COUNT(*) AS failed_rows
            FROM fact_shipments
            WHERE customer_key IS NULL
               OR warehouse_key IS NULL
               OR shipment_mode_key IS NULL
               OR product_importance_key IS NULL
            """,
        ),
        (
            "No null shipment measures",
            """
            SELECT COUNT(*) AS failed_rows
            FROM fact_shipments
            WHERE cost_of_product IS NULL
               OR discount_offered IS NULL
               OR weight_gms IS NULL
               OR customer_rating IS NULL
               OR is_on_time IS NULL
            """,
        ),
        (
            "No unmatched source rows",
            """
            SELECT COUNT(*) AS failed_rows
            FROM stg_shipping_raw AS s
            LEFT JOIN fact_shipments AS f
                ON s.id = f.source_customer_id
            WHERE f.source_customer_id IS NULL
            """,
        ),
        (
            "Valid delivery outcome flag",
            """
            SELECT COUNT(*) AS failed_rows
            FROM fact_shipments
            WHERE is_on_time NOT IN (TRUE, FALSE)
               OR is_on_time IS NULL
            """,
        ),
    ]

    print("Running warehouse validations...\n")

    passed = [run_validation(engine, name, query) for name, query in validations]

    engine.dispose()

    if not all(passed):
        raise SystemExit("\nWarehouse validation failed.")

    print("\nAll warehouse validations passed.")


if __name__ == "__main__":
    main()
