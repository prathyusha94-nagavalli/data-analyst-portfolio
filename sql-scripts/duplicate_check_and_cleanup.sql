-- Scenario: Deduplicate BOM entries that are exact copies (same material type, usage, and cost) per product

DELETE FROM bill_of_material
WHERE id IN (
    SELECT id FROM (
        SELECT 
            id,
            ROW_NUMBER() OVER (
                PARTITION BY product_id, material_type, material_sub_type, usage, cost_per_unit
                ORDER BY id
            ) AS rn
        FROM bill_of_material
    ) t
    WHERE rn > 1
);
