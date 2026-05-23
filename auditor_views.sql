-- Karoo Organics Phase 2
-- Supplier Risk & Compliance Auditor

-- This view combines supplier, certification,
-- order, and harvest information into one monitoring view.

CREATE OR REPLACE VIEW v_supplier_health AS

SELECT
    s.supplier_id,
    s.farm_name,
    s.region,
    s.status,

    c.certification_name,
    c.cert_expiry_date,

    CASE
        WHEN c.cert_expiry_date IS NULL THEN 'Unknown'

        WHEN c.cert_expiry_date < CURRENT_DATE
            THEN 'Expired'

        WHEN c.cert_expiry_date <= CURRENT_DATE + INTERVAL '30 days'
            THEN 'Expiring Soon'

        ELSE 'Valid'
    END AS cert_status,

    (
        SELECT COUNT(*)
        FROM Orders o
        WHERE o.supplier_id = s.supplier_id
        AND o.order_date >= CURRENT_DATE - INTERVAL '90 days'
    ) AS orders_90d,

    h.harvest_date,

    h.yield_kg AS latest_yield,

    AVG(h.yield_kg) OVER (
        PARTITION BY s.supplier_id
        ORDER BY h.harvest_date
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ) AS rolling_avg_yield

FROM Suppliers s

LEFT JOIN Certifications c
    ON s.supplier_id = c.supplier_id

LEFT JOIN Harvest_Log h
    ON s.supplier_id = h.supplier_id;

-- Risk-flagging query
-- This identifies suppliers that need to be reviewed.

-- Risk-flagging query
-- DISTINCT ON keeps only one row per supplier.

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