import os
import pandas as pd
from snowflake.sqlalchemy import URL
from sqlalchemy import create_engine
from dotenv import load_dotenv

load_dotenv()

# Read from .env
SNOWFLAKE_ACCOUNT  = os.getenv("SNOWFLAKE_ACCOUNT")
SNOWFLAKE_USER     = os.getenv("SNOWFLAKE_USER")
SNOWFLAKE_PASSWORD = os.getenv("SNOWFLAKE_PASSWORD")
SNOWFLAKE_DATABASE = os.getenv("SNOWFLAKE_DATABASE")
SNOWFLAKE_SCHEMA   = os.getenv("SNOWFLAKE_SCHEMA")
SNOWFLAKE_WAREHOUSE= os.getenv("SNOWFLAKE_WAREHOUSE")

import os
from pathlib import Path

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


def main() -> None:
    engine = create_engine(
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

    data_path = Path(__file__).resolve().parents[1] / "data" / "dataset.csv"

    if not data_path.exists():
        raise FileNotFoundError(f"CSV not found: {data_path}")

    df = pd.read_csv(data_path)

    print(f"CSV loaded from: {data_path}")
    print(f"Source rows: {len(df)}")
    print(f"Source columns: {df.columns.tolist()}")

    df.columns = [
        column.strip()
        .lower()
        .replace(" ", "_")
        .replace(".", "_")
        for column in df.columns
    ]

    df.to_sql(
        name="stg_shipping_raw",
        con=engine,
        if_exists="replace",
        schema=SNOWFLAKE_SCHEMA,
        index=False,
    )

    with engine.connect() as connection:
        staging_count = connection.execute(
            text(f"SELECT COUNT(*) FROM {SNOWFLAKE_SCHEMA}.stg_shipping_raw")
        ).scalar_one()

    print(f"Staging rows: {staging_count}")

    if len(df) != staging_count:
        raise ValueError(
            f"Staging validation failed: CSV={len(df)}, staging={staging_count}"
        )

    print("Raw staging load validated successfully.")
    engine.dispose()


if __name__ == "__main__":
    main()
