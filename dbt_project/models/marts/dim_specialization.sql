WITH specialization AS (
    SELECT * FROM {{ ref("stg_specialization")}}
),

category_field AS (
    SELECT * FROM {{ ref('stg_category_field') }}
)

SELECT
    s.specialization_id,
    s.specialization_name,
    s.field_id,
    cf.field_name
FROM specialization s
LEFT JOIN category_field cf 
    ON s.field_id = cf.field_id