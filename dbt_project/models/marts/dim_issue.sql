WITH issue AS (
    SELECT * FROM {{ ref("stg_issue")}}
)

SELECT
    issue_id,
    issue_year,
    issue_month,
    issue_date,
    issue_label,
    contain_special_part,
    deadline_date,
    distribution_date
FROM issue