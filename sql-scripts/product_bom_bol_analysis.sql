-- Scenario: Analyzing and transforming  product data using product, bill of material (BOM), and bill of labor (BOL) datasets

-- Step 1: View sample data from each table
SELECT * FROM products LIMIT 10;
SELECT * FROM bill_of_materials LIMIT 10;
SELECT * FROM bill_of_labor LIMIT 10;

-- Step 2: Data profiling – checking nulls, duplicates, and data types
-- Null check for critical columns
SELECT COUNT(*) AS null_product_ids FROM products WHERE product_id IS NULL;
SELECT COUNT(*) AS null_bom_ids FROM bill_of_materials WHERE product_id IS NULL OR material_id IS NULL;
SELECT COUNT(*) AS null_bol_ids FROM bill_of_labor WHERE product_id IS NULL OR labor_type IS NULL;

-- Duplicates check (assumes product_id + version should be unique)
SELECT product_id, version, COUNT(*) AS dup_count
FROM products
GROUP BY product_id, version
HAVING COUNT(*) > 1;

-- Step 3: Data wrangling – Clean BOM/BOL to keep only current versions
WITH latest_versions AS (
    SELECT product_id, MAX(version) AS max_version
    FROM products
    GROUP BY product_id
)
SELECT p.product_id, p.product_name, p.version, bom.material_id, bom.quantity, bol.labor_type, bol.hours_required
FROM products p
JOIN latest_versions lv ON p.product_id = lv.product_id AND p.version = lv.max_version
LEFT JOIN bill_of_materials bom ON p.product_id = bom.product_id AND p.version = bom.version
LEFT JOIN bill_of_labor bol ON p.product_id = bol.product_id AND p.version = bol.version;

-- Step 4: Data transformation – Aggregate material and labor costs per product
-- Assume material and labor reference tables exist
WITH material_costs AS (
    SELECT material_id, cost_per_unit FROM material_reference
),
labor_costs AS (
    SELECT labor_type, cost_per_hour FROM labor_reference
),
product_data AS (
    SELECT p.product_id, p.product_name, bom.material_id, bom.quantity, bol.labor_type, bol.hours_required
    FROM products p
    JOIN bill_of_materials bom ON p.product_id = bom.product_id AND p.version = bom.version
    JOIN bill_of_labor bol ON p.product_id = bol.product_id AND p.version = bol.version
)
SELECT 
    pd.product_id,
    pd.product_name,
    SUM(bom.quantity * mc.cost_per_unit) AS total_material_cost,
    SUM(bol.hours_required * lc.cost_per_hour) AS total_labor_cost,
    SUM(bom.quantity * mc.cost_per_unit + bol.hours_required * lc.cost_per_hour) AS total_product_cost
FROM product_data pd
LEFT JOIN material_costs mc ON pd.material_id = mc.material_id
LEFT JOIN labor_costs lc ON pd.labor_type = lc.labor_type
GROUP BY pd.product_id, pd.product_name;
