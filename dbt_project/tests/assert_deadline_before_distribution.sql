SELECT
    issue_id,
    issue_label,
    deadline_date,
    distribution_date
FROM {{ ref('stg_issue') }}
WHERE deadline_date > distribution_date