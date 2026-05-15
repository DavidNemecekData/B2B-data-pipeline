WITH issue_section AS (
    SELECT * FROM {{ source('raw_presentation', 'issue_section') }}
)

SELECT
    section_id AS issue_section_id,
    section_name
FROM issue_section