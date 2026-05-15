WITH specialization AS (
    SELECT * FROM {{ source('raw_presentation', 'specialization') }}
)

SELECT
    specialization_id,
    spec_name AS specialization_name,
    field_id
FROM specialization