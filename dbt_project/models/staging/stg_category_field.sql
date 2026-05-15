WITH category_field AS (
    SELECT * FROM {{ source('raw_presentation', 'category_field') }}
)


SELECT
    field_id,
    CASE
        WHEN field_name::TEXT = 'ANIMAL_HUSBANDRY' THEN 'Animal Husbandry'
        WHEN field_name::TEXT = 'PLANT_PRODUCTION' THEN 'Plant Production'
        WHEN field_name::TEXT = 'MECHANIZATION' THEN 'Mechanization'
        WHEN field_name::TEXT = 'OTHER' THEN 'Other'
        ELSE field_name::TEXT
    END::TEXT AS field_name
FROM category_field