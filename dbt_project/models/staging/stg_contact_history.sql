WITH raw_contact_history AS (
    SELECT * FROM {{ source('raw_presentation', 'contact_history') }}
)

SELECT
    contact_id,
    company_id,
    issue_id,
    specialization_id,
    contact_date,
    recontact_date,
    contact_status,
    CASE 
        WHEN contact_status::TEXT = 'CONTACTED' THEN 'Contacted'
        WHEN contact_status::TEXT = 'CONTACTED_AGAIN' THEN 'Contacted Again'
        WHEN contact_status::TEXT = 'ACCEPTED' THEN 'Accepted'
        WHEN contact_status::TEXT = 'REJECTED' THEN 'Rejected'
        WHEN contact_status::TEXT = 'NO_RESPONSE' THEN 'No Response'
        ELSE contact_status::TEXT
    END::TEXT AS contact_status_renamed,
    communication_note
FROM raw_contact_history