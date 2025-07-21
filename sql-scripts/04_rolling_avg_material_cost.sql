WITH product_bom_cost AS (
    SELECT 
        p.factory,
        p.season,
        p.product_id,
        SUM((bom.usage + bom.waste) * bom.cost_per_unit) AS product_bom_cost
    FROM product p
    JOIN bill_of_material bom ON p.product_id = bom.product_id
    GROUP BY p.factory, p.season, p.product_id
),
rolling_costs AS (
    SELECT *,
           AVG(product_bom_cost) OVER (
               PARTITION BY factory, season ORDER BY product_id ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
           ) AS rolling_avg_cost
    FROM product_bom_cost
)
SELECT * FROM rolling_costs;
