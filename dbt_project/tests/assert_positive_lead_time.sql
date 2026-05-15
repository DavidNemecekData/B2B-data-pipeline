SELECT
    contact_id,
    contact_date,
    recontact_date,
    lead_time_days
FROM {{ ref('fct_contact_history') }}
WHERE lead_time_days < 0