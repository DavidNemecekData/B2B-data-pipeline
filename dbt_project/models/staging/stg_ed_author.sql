WITH ed_author AS (
    SELECT * FROM {{ source('raw_presentation', 'ed_author') }}
)

SELECT
    author_id,
    author_name
FROM ed_author