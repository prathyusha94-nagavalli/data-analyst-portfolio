-- Scenario: Identify the top 3 most costly materials used per product across all factories and seasons

WITH base_bom AS (
    SELECT 
        bom.product_id,
        p.season,
        p.style,
        p.color,
        p.factory,
        bom.material_type,
        bom.material_sub_type,
        bom.usage,
        bom.waste,
        bom.cost_per_unit,
        (bom.usage + bom.waste) * bom.cost_per_unit AS total_material_cost
    FROM bill_of_material bom
    JOIN product p ON bom.product_id = p.product_id
    WHERE bom.cost_per_unit IS NOT NULL
),
ranked_materials AS (
    SELECT *,
           RANK() OVER (PARTITION BY product_id ORDER BY total_material_cost DESC) AS cost_rank
    FROM base_bom
)
SELECT *
FROM ranked_materials
WHERE cost_rank <= 3
ORDER BY product_id, cost_rank;
