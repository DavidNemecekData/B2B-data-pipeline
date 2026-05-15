SELECT
    content_id,
    company_id,
    issue_id,
    applied_list_price,
    applied_discount_pct,
    final_net_price
FROM {{ ref('fct_sales_performance') }}
WHERE final_net_price < 0