WITH contacts AS (
    SELECT * FROM {{ ref('stg_contact_history') }}
),
issue AS (
    SELECT * FROM {{ ref('stg_issue') }}
),
funnel_aggregation AS (
    SELECT
        c.issue_id,
        c.specialization_id,
        i.issue_date,
        COUNT(c.contact_id) AS total_contacts,
        SUM(CASE WHEN c.contact_status = 'ACCEPTED' THEN 1 ELSE 0 END) AS accepted_contacts,
        SUM(CASE WHEN c.contact_status = 'REJECTED' THEN 1 ELSE 0 END) AS rejected_contacts,
        SUM(CASE WHEN c.contact_status = 'NO_RESPONSE' THEN 1 ELSE 0 END) AS no_response_contacts,
        SUM(CASE WHEN c.contact_status IN ('CONTACTED', 'CONTACTED_AGAIN') THEN 1 ELSE 0 END) AS in_progress_contacts
    FROM contacts c
    LEFT JOIN issue i ON c.issue_id = i.issue_id
    GROUP BY 
        c.issue_id,
        c.specialization_id,
        i.issue_date
)

SELECT
    issue_id,
    specialization_id,
    issue_date,
    total_contacts,
    accepted_contacts,
    rejected_contacts,
    no_response_contacts,
    in_progress_contacts,
    ROUND(
        accepted_contacts::NUMERIC / 
        NULLIF(accepted_contacts + rejected_contacts, 0), 
        4
    ) AS win_rate
    
FROM funnel_aggregation