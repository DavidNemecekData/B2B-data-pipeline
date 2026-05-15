{% snapshot snp_catalog_item %}

{{
    config(
      target_schema='dbt_snapshots',
      unique_key='item_id',
      strategy='check',
      check_cols=['list_price', 'item_category']
    )
}}

SELECT * FROM {{ source('raw_presentation', 'catalog_item') }}

{% endsnapshot %}