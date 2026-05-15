-- ==============================================================================
-- SCRIPT: 02_mockaroo_cleaning.sql
-- PURPOSE: Resolving referential and logical anomalies in synthetic data
-- ==============================================================================

-- ------------------------------------------------------------------------------
-- 1. REFERENTIAL INTEGRITY: Fixing invalid Issue & Specialization combinations
-- ------------------------------------------------------------------------------
INSERT INTO contact_history (
	company_id,
	issue_id,
	specialization_id,
	contact_date,
	recontact_date,
	contact_status,
	communication_note
)
SELECT
	t.company_id,
	v.issue_id,
	v.specialization_id,
	t.contact_date,
	t.recontact_date,
	t.contact_status,
	t.communication_note
FROM temp_contact_import t
CROSS JOIN LATERAL (
	SELECT issue_id, specialization_id
	FROM issue_specialization
	ORDER BY random () + (t.company_id * 0)
	LIMIT 1
) v;

INSERT INTO issue_content (
	issue_id,
	section_id,
	company_id,
	catalog_item_id,
	author_id,
	specialization_id,
	content_description,
	materials_delivered,
	is_approved,
	posted_on_fb,
	applied_list_price,
	applied_discount_pct,
	agency_provision_pct
)
SELECT
	v.issue_id,
	t.section_id,
	t.company_id,
	t.catalog_item_id,
	t.author_id,
	v.specialization_id,
	t.content_description,
	t.materials_delivered,
	t.is_approved,
	t.posted_on_fb,
	t.applied_list_price,
	t.applied_discount_pct,
	t.agency_provision_pct
FROM temp_contact_import t
CROSS JOIN LATERAL (
	SELECT issue_id, specialization_id
	FROM issue_specialization
	ORDER BY random () + (t.company_id * 0)
	LIMIT 1
) v;

-- ------------------------------------------------------------------------------
-- 2. BUSINESS LOGIC (STATUSES): Aligning contact history with actual ad content
-- ------------------------------------------------------------------------------
UPDATE contact_history ch
SET contact_status = 'ACCEPTED'
FROM issue_content ic
WHERE ic.issue_id = ch.issue_id
  AND ic.company_id = ch.company_id;

UPDATE contact_history ch
SET contact_status = 
    CASE floor(random() * 4)
        WHEN 0 THEN 'REJECTED'::contact_status_enum
        WHEN 1 THEN 'CONTACTED'::contact_status_enum
        WHEN 2 THEN 'CONTACTED_AGAIN'::contact_status_enum
        ELSE 'NO_RESPONSE'::contact_status_enum
    END
WHERE ch.contact_status = 'ACCEPTED'
  AND NOT EXISTS (
      SELECT 1
      FROM issue_content ic
      WHERE ic.issue_id = ch.issue_id
        AND ic.company_id = ch.company_id
  );

-- ------------------------------------------------------------------------------
-- 3. CHRONOLOGICAL CONSISTENCY: Aligning contact dates with issue deadlines
-- ------------------------------------------------------------------------------
UPDATE contact_history ch
SET contact_date = i.deadline_date - (random() * 23 + 7)::int
FROM issue i
WHERE ch.issue_id = i.issue_id;

UPDATE contact_history ch
SET recontact_date = contact_date + (random() * 7 + 7)::int
WHERE ch.contact_status IN ('CONTACTED', 'NO_RESPONSE', 'CONTACTED_AGAIN');

UPDATE contact_history ch
SET recontact_date = NULL
WHERE ch.contact_status IN ('ACCEPTED', 'REJECTED');

-- ------------------------------------------------------------------------------
-- 4. CARDINALITY VIOLATIONS: Resolving duplicate placements in exclusive sections
-- ------------------------------------------------------------------------------
WITH deduplication_cte AS (
    SELECT
        ic.content_id,
        ROW_NUMBER() OVER (
            PARTITION BY ic.issue_id, ic.section_id 
            ORDER BY random()
        ) AS numbered_rows
    FROM issue_content ic
    WHERE ic.section_id IN (1, 2, 3, 4, 16, 17, 18)
)
UPDATE issue_content ic
SET section_id = 21
FROM deduplication_cte cte
WHERE cte.content_id = ic.content_id 
  AND cte.numbered_rows > 1;

UPDATE issue_content ic 
SET catalog_item_id = CASE 
    WHEN ic.section_id = 1 THEN 15  -- Title page
    WHEN ic.section_id = 16 THEN 12 -- Cover wrap
    WHEN ic.section_id = 17 THEN 13 -- Fold out cover
    WHEN ic.section_id = 18 THEN 14 -- Front cover flap
    ELSE ic.catalog_item_id
END
WHERE ic.section_id IN (1, 16, 17, 18);

-- ------------------------------------------------------------------------------
-- 5. ATTRIBUTE LOGIC: Aligning authors and pricing
-- ------------------------------------------------------------------------------
UPDATE issue_content ic
SET author_id = NULL 
FROM catalog_item ci 
WHERE ic.catalog_item_id = ci.item_id
  AND ci.item_category <> 'ED_ARTICLE';

UPDATE issue_content ic
SET applied_discount_pct = c.default_discount
FROM company c
WHERE ic.company_id = c.company_id;