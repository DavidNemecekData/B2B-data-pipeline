-- ==========================================
-- 1. DATA TYPES (ENUMS)
-- ==========================================
CREATE TYPE contact_status_enum AS ENUM (
  'CONTACTED', 'CONTACTED_AGAIN', 'ACCEPTED', 'REJECTED', 'NO_RESPONSE'
);

CREATE TYPE item_category_enum AS ENUM (
  'ADVERTISEMENT', 'PR_ARTICLE', 'ED_ARTICLE'
);

CREATE TYPE field_enum AS ENUM (
  'ANIMAL_HUSBANDRY', 'PLANT_PRODUCTION', 'MECHANIZATION', 'OTHER'
);

-- ==========================================
-- 2. INDEPENDENT TABLES (Base entities and dimensions)
-- ==========================================
CREATE TABLE company (
  company_id SERIAL PRIMARY KEY,
  company_name VARCHAR(255) NOT NULL UNIQUE, 
  email_1 VARCHAR(255),
  email_2 VARCHAR(255),
  default_discount DECIMAL(5,2),
  is_personal_contact BOOLEAN NOT NULL DEFAULT false,
  can_be_contacted BOOLEAN NOT NULL DEFAULT true,
  note TEXT,
  is_active BOOLEAN NOT NULL DEFAULT true,
  contact_person_firstname VARCHAR(255),
	contact_person_lastname VARCHAR(255)
);

CREATE TABLE category_field (
  field_id SERIAL PRIMARY KEY,
  field_name field_enum NOT NULL
);

CREATE TABLE catalog_item (
  item_id SERIAL PRIMARY KEY,
  item_category item_category_enum NOT NULL,
  type_name VARCHAR(255) NOT NULL,
  list_price DECIMAL(10,2) DEFAULT 0,
  width_mm INTEGER,
  height_mm INTEGER,
  ratio DECIMAL(10,5),
  has_bleed BOOLEAN NOT NULL DEFAULT false,
  is_bonus BOOLEAN NOT NULL DEFAULT false
);

CREATE TABLE ed_author (
  author_id SERIAL PRIMARY KEY,
  author_name VARCHAR(255) NOT NULL
);

CREATE TABLE issue (
  issue_id SERIAL PRIMARY KEY,
  issue_year INTEGER CHECK (issue_year > 1990),
  issue_month INTEGER CHECK (issue_month BETWEEN 1 AND 12),
  issue_label VARCHAR(50),
  is_special BOOLEAN NOT NULL DEFAULT false,
  deadline_date DATE,
  distribution_date DATE
);

CREATE TABLE issue_section (
  section_id SERIAL PRIMARY KEY,
  section_name VARCHAR(255) NOT NULL
);

-- ==========================================
-- 3. DEPENDENT TABLES (Relationships and Fact Tables)
-- ==========================================

CREATE TABLE specialization (
  specialization_id SERIAL PRIMARY KEY,
  field_id INTEGER REFERENCES category_field(field_id),
  spec_name VARCHAR(255) NOT NULL
);

CREATE TABLE issue_specialization (
  issue_id INTEGER REFERENCES issue(issue_id),
  specialization_id INTEGER REFERENCES specialization(specialization_id),
  PRIMARY KEY (issue_id, specialization_id)
);

CREATE TABLE company_specialization (
  company_id INTEGER REFERENCES company(company_id),
  specialization_id INTEGER REFERENCES specialization(specialization_id),
  PRIMARY KEY (company_id, specialization_id)
);

CREATE TABLE contact_history (
  contact_id SERIAL PRIMARY KEY,
  company_id INTEGER REFERENCES company(company_id),
  issue_id INTEGER REFERENCES issue(issue_id),
  specialization_id INTEGER, 
  contact_date DATE,
  recontact_date DATE,
  contact_status contact_status_enum,
  communication_note TEXT,
  CONSTRAINT fk_issue_spec FOREIGN KEY (issue_id, specialization_id) 
    REFERENCES issue_specialization (issue_id, specialization_id)
);

CREATE TABLE issue_content (
  content_id SERIAL PRIMARY KEY,
  issue_id INTEGER REFERENCES issue(issue_id),
  section_id INTEGER REFERENCES issue_section(section_id),
  company_id INTEGER REFERENCES company(company_id),
  catalog_item_id INTEGER REFERENCES catalog_item(item_id),
  author_id INTEGER REFERENCES ed_author(author_id),
  specialization_id INTEGER REFERENCES specialization(specialization_id),
  content_description TEXT,
  materials_delivered BOOLEAN NOT NULL DEFAULT false,
  is_approved BOOLEAN NOT NULL DEFAULT false,
  posted_on_fb BOOLEAN NOT NULL DEFAULT false,
  applied_list_price DECIMAL(10,2),
  applied_discount_pct DECIMAL(5,2),
  agency_provision_pct DECIMAL(5,2),
  final_net_price DECIMAL(10,2) GENERATED ALWAYS AS (
    applied_list_price * (1 - (COALESCE(applied_discount_pct, 0) + COALESCE(agency_provision_pct, 0)) / 100.0)
  ) STORED
);