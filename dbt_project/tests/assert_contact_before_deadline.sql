SELECT
    contact_id,
    company_id,
    issue_id,
    contact_date,
    days_before_deadline,
    contact_status
FROM {{ ref('fct_contact_history') }}
WHERE days_before_deadline < 0