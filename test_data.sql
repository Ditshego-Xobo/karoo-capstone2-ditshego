-- Karoo Organics Capstone Phase 2
-- This file prepares sample data for supplier auditing.

-- Add supplier status column
ALTER TABLE Suppliers
ADD COLUMN IF NOT EXISTS status VARCHAR(20) DEFAULT 'Active';

-- Add last audit date column
ALTER TABLE Suppliers
ADD COLUMN IF NOT EXISTS last_audit DATE;

-- Add certification expiry date column
ALTER TABLE Certifications
ADD COLUMN IF NOT EXISTS cert_expiry_date DATE;

-- Add yield column to harvest records
ALTER TABLE Harvest_Log
ADD COLUMN IF NOT EXISTS yield_kg DECIMAL(10,2);



-- =========================================
-- UPDATE CERTIFICATION EXPIRY DATES
-- =========================================

UPDATE Certifications
SET cert_expiry_date = '2026-06-10'
WHERE certification_id = 1;

UPDATE Certifications
SET cert_expiry_date = '2026-05-25'
WHERE certification_id = 2;

UPDATE Certifications
SET cert_expiry_date = '2026-04-15'
WHERE certification_id = 3;



-- =========================================
-- ADD MORE HARVEST DATA
-- =========================================

INSERT INTO Harvest_Log (
    supplier_id,
    crop_name,
    harvest_date,
    quantity_harvested,
    yield_kg
)
VALUES
    (1, 'Lamb', '2026-01-10', 100, 1000),
    (1, 'Lamb', '2026-02-10', 100, 950),
    (1, 'Lamb', '2026-03-10', 100, 600),

    (2, 'Dates', '2026-01-05', 100, 1200),
    (2, 'Dates', '2026-02-05', 100, 1250),
    (2, 'Dates', '2026-03-05', 100, 1240),

    (3, 'Wool', '2026-01-15', 100, 900),
    (3, 'Wool', '2026-02-15', 100, 870),
    (3, 'Wool', '2026-03-15', 100, 500);