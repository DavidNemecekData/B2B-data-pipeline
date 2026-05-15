WITH raw_company AS (
    SELECT * FROM {{ source('raw_presentation', 'company') }}
)

SELECT
    company_id,
    company_name,
    CONCAT_WS(' ', contact_person_firstname, contact_person_lastname) AS contact_person_full_name,
    email_1 AS primary_email,
    email_2 AS secondary_email,
    default_discount,
    is_personal_contact,
    can_be_contacted,
    is_active,
    note
FROM raw_company