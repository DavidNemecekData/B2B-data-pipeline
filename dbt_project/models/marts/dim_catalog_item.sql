WITH catalog_item AS (
    SELECT * FROM {{ ref('stg_catalog_item') }}
)

SELECT
    item_id AS catalog_item_id,
    item_category_name,
    type_name,
    list_price AS catalog_list_price,
    width_mm,
    height_mm,
    has_bleed,
    CASE 
        WHEN is_bonus = TRUE THEN 'Bonus'
        ELSE 'Paid'
    END AS bonus_status
FROM catalog_item