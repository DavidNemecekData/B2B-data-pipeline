WITH sales AS (
    SELECT * FROM {{ ref('fct_sales_performance') }}
),
catalog_item AS (
    SELECT * FROM {{ ref('dim_catalog_item') }}
)

SELECT
    s.content_id,
    s.catalog_item_id,
    c.item_category_name,
    c.bonus_status,
    s.final_net_price
FROM sales s
JOIN catalog_item c ON s.catalog_item_id = c.catalog_item_id
WHERE c.bonus_status = 'Bonus'
  AND s.final_net_price > 0