WITH catalog_item AS (
    SELECT * FROM {{ source('raw_presentation', 'catalog_item') }}
)

SELECT
    item_id,
    CASE
        WHEN item_category::TEXT = 'ADVERTISEMENT' THEN 'Advertisement'
        WHEN item_category::TEXT = 'PR_ARTICLE' THEN 'PR Article'
        WHEN item_category::TEXT = 'ED_ARTICLE' THEN 'Editorial Article'
        ELSE item_category::TEXT
    END::TEXT AS item_category_name,
    type_name,
    list_price,
    width_mm,
    height_mm,
    ratio,
    has_bleed,
    is_bonus
FROM catalog_item