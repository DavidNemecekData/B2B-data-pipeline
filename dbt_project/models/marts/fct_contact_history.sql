WITH staging_contacts AS (
    SELECT * FROM {{ ref('stg_contact_history') }}
),
issue AS (
    SELECT * FROM {{ ref('stg_issue') }}
)

SELECT
    c.contact_id,
    c.company_id,
    c.issue_id,
    c.specialization_id,
    c.contact_date,
    c.recontact_date,
    (c.recontact_date - c.contact_date) AS lead_time_days,
    i.issue_date,
    (i.deadline_date - c.contact_date) AS days_before_deadline,
    CASE 
        WHEN c.contact_status = 'ACCEPTED' THEN 1 
        ELSE 0 
    END AS is_win_flag,
    c.contact_status_renamed AS contact_status,
    c.communication_note
FROM staging_contacts c
LEFT JOIN issue i 
    ON c.issue_id = i.issue_id