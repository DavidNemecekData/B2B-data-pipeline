WITH sales AS (
    SELECT * FROM {{ ref('fct_sales_performance') }}
),
catalog_item AS (
    SELECT * FROM {{ ref('dim_catalog_item') }}
)

SELECT
    s.content_id,
    s.company_id,
    c.item_category_name,
    s.author_id
FROM sales s
JOIN catalog_item c ON s.catalog_item_id = c.catalog_item_id
WHERE c.item_category_name = 'PR Article'
    AND s.author_id IS NOT NULL