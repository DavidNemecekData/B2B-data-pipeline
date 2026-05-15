WITH issue_content AS (
    SELECT * FROM {{ ref("stg_issue_content") }}
),
catalog_item AS (
    SELECT * FROM {{ ref('stg_catalog_item') }}
),
issue AS (
    SELECT * FROM {{ ref('stg_issue') }}
),
contact_history AS (
    SELECT * FROM {{ ref('stg_contact_history') }}
),

unique_contacts AS (
    SELECT DISTINCT company_id, issue_id
    FROM contact_history
)

SELECT
    ic.content_id,
    ic.issue_id,
    iss.issue_date,
    ic.company_id,
    ic.catalog_item_id,
    cat.ratio AS page_ratio,
    ic.author_id,
    ic.content_specialization_id,
    ic.applied_list_price,
    ic.applied_discount_pct,
    ic.agency_provision_pct,
    ic.final_net_price,
    (ic.applied_list_price - ic.final_net_price) AS absolute_discount,
    {{ calculate_vat('ic.final_net_price', 0.21) }} AS final_net_price_vat,
    CASE 
        WHEN uc.company_id IS NULL THEN 'Inbound'
        ELSE 'Outbound'
    END AS contact_direction,
    CASE 
        WHEN ic.agency_provision_pct IS NOT NULL AND ic.agency_provision_pct > 0 THEN 'Agency'
        ELSE 'Direct'
    END AS sales_channel
FROM issue_content ic
LEFT JOIN unique_contacts uc 
    ON ic.company_id = uc.company_id 
    AND ic.issue_id = uc.issue_id
LEFT JOIN issue iss
    ON ic.issue_id = iss.issue_id
LEFT JOIN catalog_item cat ON ic.catalog_item_id = cat.item_id