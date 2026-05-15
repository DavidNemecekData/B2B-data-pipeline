WITH raw_issue AS (
    SELECT * FROM {{ source('raw_presentation', 'issue') }}
)

SELECT
    issue_id,
    issue_year,
    issue_month,
    MAKE_DATE(issue_year, issue_month, 1) AS issue_date,
    issue_label,
    is_special AS contain_special_part,
    deadline_date,
    distribution_date
FROM raw_issue