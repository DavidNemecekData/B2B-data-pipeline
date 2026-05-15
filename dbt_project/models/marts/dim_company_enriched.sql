WITH companies AS (
    SELECT * FROM {{ ref("stg_company")}}
),
company_spec AS (
    SELECT * FROM {{ ref("stg_company_specialization") }}
),
specializations AS (
    SELECT * FROM {{ ref("stg_specialization")}}
),
aggregated_specs AS (
    SELECT 
        cs.company_id,
        STRING_AGG(s.specialization_name, ', ' ORDER BY s.specialization_name) AS specialization_list
    FROM company_spec cs
    JOIN specializations s USING (specialization_id)
    GROUP BY cs.company_id
)

SELECT
    c.company_id,
    c.company_name,
    c.contact_person_full_name,
    c.primary_email,
    c.secondary_email,
    c.default_discount,
    c.is_personal_contact,
    c.can_be_contacted,
    c.note,
    CASE 
        WHEN c.is_active = TRUE THEN 'Active'
        ELSE 'Inactive'
    END AS company_status,
    COALESCE(agg.specialization_list, 'No specialization') AS specialization_list
FROM companies c
LEFT JOIN aggregated_specs agg ON c.company_id = agg.company_id