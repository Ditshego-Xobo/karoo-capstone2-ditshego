# Karoo Organics Phase 2
# Supplier Risk & Compliance Auditor
# This script checks suppliers that may need review
# and updates their status in the database.

import psycopg2


def connect_to_database():
    """Connect to the PostgreSQL database."""
    return psycopg2.connect(
        host="localhost",
        database="karoo_capstone",
        user="postgres",
        password="******",
        port="5432"
    )


def main():
    conn = None

    try:
        conn = connect_to_database()
        cur = conn.cursor()

        risk_query = """
            SELECT DISTINCT ON (supplier_id)
                supplier_id,
                farm_name,
                region,
                cert_status,
                orders_90d,
                latest_yield,
                rolling_avg_yield
            FROM v_supplier_health
            WHERE
                cert_status IN ('Expired', 'Expiring Soon')
                OR orders_90d = 0
                OR latest_yield < (rolling_avg_yield * 0.80)
            ORDER BY supplier_id, harvest_date DESC;
        """

        cur.execute(risk_query)
        flagged_suppliers = cur.fetchall()

        at_risk_ids = [row[0] for row in flagged_suppliers]

        if at_risk_ids:
            update_data = [("Review", supplier_id) for supplier_id in at_risk_ids]

            cur.executemany("""
                UPDATE Suppliers
                SET status = %s,
                    last_audit = CURRENT_DATE
                WHERE supplier_id = %s;
            """, update_data)

            conn.commit()

            print(f"{len(at_risk_ids)} suppliers require review.")
            print("Their status has been updated to Review.")
        else:
            conn.commit()
            print("No suppliers require review today.")

    except psycopg2.OperationalError:
        print("Could not connect to the database. Please check your database name, user, password, or server.")

    except Exception as error:
        if conn is not None:
            conn.rollback()

        print("The audit could not be completed.")
        print("No partial updates were saved.")
        print(error)

    finally:
        if conn is not None:
            conn.close()
            print("Database connection closed.")


if __name__ == "__main__":
    main()
