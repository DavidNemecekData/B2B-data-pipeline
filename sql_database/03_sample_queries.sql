-- ==============================================================================
-- SCRIPT: 03_sample_queries.sql
-- PURPOSE: Day-to-day database operations, analytical queries, and reporting
-- ==============================================================================

-- ------------------------------------------------------------------------------
-- 1. ANALYTICAL QUERIES & REPORTING
-- ------------------------------------------------------------------------------
SELECT 
    i.issue_year AS year,
    i.issue_month AS month,
    ic.final_net_price AS final_price,
    c.company_name,
    (
        SELECT string_agg(s2.spec_name, ', ')
        FROM company_specialization cs2
        JOIN specialization s2 USING (specialization_id)
        WHERE cs2.company_id = c.company_id
    ) AS company_specializations,
    CASE
        WHEN EXISTS (
            SELECT 1 FROM issue_content ic2 
            WHERE ic2.issue_id = 90 AND ic2.company_id = c.company_id
        ) THEN 'Yes'
        ELSE 'No'
    END AS already_advertising_in_target_issue,
    CASE
        WHEN EXISTS (
            SELECT 1 FROM contact_history ch 
            WHERE ch.issue_id = 90 AND ch.company_id = c.company_id
        ) THEN 'Yes'
        ELSE 'No'
    END AS already_contacted
FROM issue_content ic
JOIN company c USING (company_id)
JOIN issue i USING (issue_id)
WHERE i.issue_id IN (
    SELECT ispec.issue_id 
    FROM issue_specialization ispec
    JOIN specialization s USING (specialization_id)
    WHERE s.spec_name IN ('Feed production', 'Storage', 'Cereals', 'Sowing machines', 'Combine harvester')
)
ORDER BY year DESC, month DESC;

SELECT
    s.spec_name AS specialization,
    c.company_name,
    c.email_1,
    COALESCE(c.email_2, 'No') AS email_2,
    CASE
        WHEN COUNT(*) OVER (PARTITION BY c.company_id) > 1 THEN 'Yes'
        ELSE 'No'
    END AS has_multiple_entries,
    CASE 
        WHEN c.is_personal_contact = TRUE THEN 'Yes'
        ELSE 'No'
    END AS is_personal_contact	
FROM company c
JOIN company_specialization cs USING (company_id)
JOIN specialization s USING (specialization_id)
WHERE s.spec_name IN ('Winter rapeseed', 'Swine breeding', 'Fodder harvest machines', 'Presses balers')
  AND c.is_active IS TRUE
  AND c.can_be_contacted IS TRUE
ORDER BY has_multiple_entries DESC, is_personal_contact, specialization;

SELECT
    c.company_name,
    SUM(ic.final_net_price) AS total_net_revenue
FROM issue_content ic
JOIN issue_section isec USING (section_id)
JOIN company c USING (company_id)
WHERE isec.section_name = 'CROP_THEME'
  AND ic.issue_id IN (
      SELECT ispec.issue_id
      FROM issue_specialization ispec
      JOIN specialization s USING (specialization_id)
      WHERE spec_name = 'Winter rapeseed'
  )
GROUP BY c.company_name 
ORDER BY total_net_revenue DESC;

SELECT c.company_name
FROM issue_content ic 
JOIN company c USING (company_id)
WHERE issue_id = (SELECT issue_id FROM issue WHERE issue_label = '4/2025')
EXCEPT  
SELECT c.company_name
FROM issue_content ic 
JOIN company c USING (company_id)
WHERE issue_id = (SELECT issue_id FROM issue WHERE issue_label = '4/2026');

SELECT
    company_name,
    (SELECT count(*) 
     FROM contact_history ch 
     WHERE c.company_id = ch.company_id) AS contact_count,
    (SELECT count(*) 
     FROM contact_history ch 
     WHERE c.company_id = ch.company_id AND contact_status = 'ACCEPTED') AS accepted_count
FROM company c
ORDER BY accepted_count DESC;
-- ------------------------------------------------------------------------------
-- 2. PIPELINE PREPARATION & TEMPORARY WORKFLOWS
-- ------------------------------------------------------------------------------
DROP TABLE IF EXISTS target_issue_06_2026;
CREATE TEMP TABLE target_issue_06_2026 AS 
SELECT
    s.specialization_id AS spec_id,
    c.company_id
FROM company c
JOIN company_specialization cs USING (company_id)
JOIN specialization s USING (specialization_id)
WHERE s.spec_name IN ('Feed production', 'Storage', 'Cereals', 'Sowing machines', 'Combine harvester')
  AND c.is_active IS TRUE
  AND c.can_be_contacted IS TRUE
  AND company_id NOT IN (
      SELECT company_id 
      FROM issue_content 
      WHERE issue_id = 90
  );

INSERT INTO contact_history (
    company_id,
    issue_id,
    contact_date,
    contact_status,
    specialization_id
)
SELECT 
    company_id,
    90,
    CURRENT_DATE,
    'CONTACTED'::contact_status_enum,
    spec_id
FROM pg_temp.target_issue_06_2026
RETURNING *;


-- ------------------------------------------------------------------------------
-- 3. UPDATES & DATABASE MAINTENANCE
-- ------------------------------------------------------------------------------
UPDATE issue_content ic 
SET is_approved = TRUE
WHERE issue_id = 88
  AND company_id IN (
      SELECT c.company_id
      FROM company c
      WHERE c.company_name ILIKE ANY (ARRAY[
          'agroing%', 'austro%', 'corteva%', 'KÄRCHER%',
          'kverneland%', 'tecnoma%', 'selgen%', 'seed service%'
      ])
  )
RETURNING *;

UPDATE issue_content ic
SET section_id = 9
FROM company c
WHERE ic.company_id = c.company_id
  AND c.company_name ILIKE 'kamír%'
  AND ic.issue_id = 88;

UPDATE issue_content ic
SET section_id = 6,
    catalog_item_id = 19,
    applied_list_price = 0,
    applied_discount_pct = 0,
    content_description = 'Bank PR Content'
FROM company c, issue i
WHERE ic.company_id = c.company_id
  AND ic.issue_id = i.issue_id
  AND c.company_name ILIKE '%banka%'
  AND i.issue_year = 2026
  AND i.issue_month = 4;

UPDATE contact_history ch
SET contact_status = 'REJECTED'
WHERE ch.contact_status = 'ACCEPTED'
  AND NOT EXISTS (
      SELECT 1 
      FROM issue_content ic
      WHERE ic.company_id = ch.company_id 
        AND ic.issue_id = ch.issue_id
  )
RETURNING *;