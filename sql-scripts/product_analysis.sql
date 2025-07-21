WITH product_data AS (
    -- Extract product data from Snowflake
    SELECT 
        product_id,
        season,
        color,
        style,
        factory
    FROM snowflake_db.product_master
    WHERE season IS NOT NULL
),

bom_data AS (
    -- Extract BOM data from Teradata
    SELECT 
        product_id,
        material_id,
        material_type,
        sub_type,
        weight_grams,
        usage_percent,
        waste_percent,
        material_cost_usd
    FROM teradata_db.bom_materials
    WHERE material_type IS NOT NULL
),

cleaned_bom AS (
    -- Clean BOM data and handle nulls
    SELECT 
        TRIM(product_id) AS product_id,
        TRIM(material_type) AS material_type,
        TRIM(sub_type) AS sub_type,
        COALESCE(weight_grams, 0) AS weight_grams,
        COALESCE(usage_percent, 0) AS usage_percent,
        COALESCE(waste_percent, 0) AS waste_percent,
        COALESCE(material_cost_usd, 0) AS material_cost_usd
    FROM bom_data
),

joined_data AS (
    -- Join product and BOM datasets
    SELECT 
        p.product_id,
        p.season,
        p.color,
        p.style,
        p.factory,
        b.material_type,
        b.sub_type,
        b.weight_grams,
        b.usage_percent,
        b.waste_percent,
        b.material_cost_usd
    FROM product_data p
    LEFT JOIN cleaned_bom b ON p.product_id = b.product_id
),

final_aggregated_view AS (
    -- Aggregate to generate summary metrics
    SELECT 
        season,
        factory,
        style,
        material_type,
        COUNT(DISTINCT product_id) AS total_products,
        ROUND(AVG(weight_grams), 2) AS avg_material_weight,
        ROUND(AVG(usage_percent), 2) AS avg_usage_pct,
        ROUND(AVG(waste_percent), 2) AS avg_waste_pct,
        ROUND(SUM(material_cost_usd), 2) AS total_material_cost
    FROM joined_data
    GROUP BY 
        season, factory, style, material_type
)

-- Final result set
SELECT * FROM final_aggregated_view
ORDER BY season, factory, style;
