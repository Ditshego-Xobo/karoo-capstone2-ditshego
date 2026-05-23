# Karoo Organics Phase 2 – Supplier Risk & Compliance Auditor

## Project Overview

This project was created for Phase 2 of the Karoo Organics Capstone Project.

The purpose of the project is to monitor supplier compliance and automatically identify suppliers that may create operational, reputational, or regulatory risk for the company.

The system combines supplier, certification, order, and harvest data into a monitoring view. Python is then used to automatically flag risky suppliers and update their database status to "Review".

---

# Technologies Used

- PostgreSQL
- Python
- psycopg2
- VS Code
- pgAdmin 4

---

# Files Included

## auditor_views.sql
This file creates the supplier monitoring view and contains the risk-flagging query.

## audit_suppliers.py
This Python script checks suppliers for risk conditions and updates supplier status to "Review".

## test_data.sql
This file adds extra columns and test data needed for the auditing process.

## README.md
Project explanation and setup instructions.

---

# Monitoring View

The project creates a monitoring view called:

```sql
v_supplier_health
```

The view combines information from:

- Suppliers
- Orders
- Certifications
- Harvest_Log

The following calculated fields are included:

- cert_status
- orders_90d
- latest_yield
- rolling_avg_yield

---

# Risk Logic Used

A supplier is flagged for review if at least one of the following conditions is true:

## 1. Certification Risk

The supplier certification is:
- expired
- expiring within 30 days

## 2. Engagement Risk

The supplier has:
- zero orders in the last 90 days

## 3. Yield Risk

The latest harvest yield is:
- less than 80% of the supplier's rolling 3-harvest average

---

# Features Implemented

- SQL monitoring view
- CASE statements
- Rolling average calculations using window functions
- Risk-flagging SQL query
- Parameterised UPDATE statements
- Automatic supplier status updates
- Transaction handling
- Error handling
- Rollback protection using conn.rollback()
- Connection cleanup using conn.close()

---

# How to Run the Project

## 1. Use the existing karoo_capstone database

Open pgAdmin and connect to the database.

## 2. Run test_data.sql

This adds:
- new columns
- certification expiry dates
- yield data
- additional harvest records

## 3. Run auditor_views.sql

This creates:
- v_supplier_health
- the supplier risk query

## 4. Run the Python auditor

```bash
python audit_suppliers.py
```

---

# Expected Output

The script should print a message similar to:

```text
6 suppliers require review.
Their status has been updated to Review.
Database connection closed.
```

---

# Compliance Considerations

This project helps Karoo Organics reduce supplier-related risk by:

- monitoring certification validity
- identifying inactive suppliers
- detecting sudden drops in agricultural yield
- improving supplier oversight
- supporting regulatory compliance

---

# Author

Ditshego Malepe