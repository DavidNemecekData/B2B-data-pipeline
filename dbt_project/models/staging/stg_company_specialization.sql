WITH raw_company_spec AS (
    SELECT * FROM {{ source('raw_presentation', 'company_specialization') }}
)

SELECT 
    company_id,
    specialization_id
FROM raw_company_spec