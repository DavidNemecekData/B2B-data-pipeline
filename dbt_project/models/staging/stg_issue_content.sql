WITH issue_content AS (
    SELECT * FROM {{ source('raw_presentation', 'issue_content') }}
)
SELECT
    content_id,
    issue_id,
    section_id AS issue_section_id,
    company_id,
    catalog_item_id,
    author_id,
    content_description,
    specialization_id AS content_specialization_id,
    posted_on_fb AS posted_on_facebook,
    applied_list_price,
    applied_discount_pct,
    agency_provision_pct,
    final_net_price
FROM issue_content