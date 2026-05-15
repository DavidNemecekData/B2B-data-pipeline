WITH date_series AS (
    SELECT generate_series(
        '2018-01-01'::DATE, 
        '2030-12-31'::DATE, 
        '1 day'::interval
    )::DATE AS date_day
)

SELECT
    date_day,
    EXTRACT(YEAR FROM date_day) AS calendar_year,
    EXTRACT(MONTH FROM date_day) AS calendar_month,
    EXTRACT(DAY FROM date_day) AS calendar_day,
    TO_CHAR(date_day, 'YYYY-MM') AS year_month_label,
    TO_CHAR(date_day, 'Month') AS month_name,
    TO_CHAR(date_day, 'Mon') AS month_name_short,
    EXTRACT(QUARTER FROM date_day) AS quarter

FROM date_series