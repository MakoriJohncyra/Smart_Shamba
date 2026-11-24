-- Smart Shamba PostgreSQL schema
-- Run this file against an empty smart_shamba database.
-- Table and column names use lowercase snake_case for PostgreSQL compatibility.

CREATE TABLE farm (
  farm_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  farm_name VARCHAR(150) NOT NULL,
  location TEXT,
  contact_phone VARCHAR(30),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE "user" (
  user_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  farm_id BIGINT REFERENCES farm(farm_id) ON DELETE SET NULL,
  full_name VARCHAR(150) NOT NULL,
  email VARCHAR(255) NOT NULL UNIQUE,
  phone VARCHAR(30),
  password_hash TEXT NOT NULL,
  role VARCHAR(30) NOT NULL CHECK (role IN
    ('ADMINISTRATOR','FARM_OWNER','FARM_MANAGER','FARM_WORKER','VET_OFFICER')),
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE animal (
  animal_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  farm_id BIGINT NOT NULL REFERENCES farm(farm_id) ON DELETE CASCADE,
  tag_number VARCHAR(60) NOT NULL,
  name VARCHAR(100),
  species VARCHAR(80) NOT NULL DEFAULT 'Cattle',
  breed VARCHAR(100),
  sex VARCHAR(10) CHECK (sex IN ('MALE','FEMALE','UNKNOWN')),
  date_of_birth DATE,
  status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (farm_id, tag_number)
);

CREATE TABLE calf (
  calf_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  farm_id BIGINT NOT NULL REFERENCES farm(farm_id) ON DELETE CASCADE,
  animal_id BIGINT UNIQUE REFERENCES animal(animal_id) ON DELETE SET NULL,
  mother_animal_id BIGINT REFERENCES animal(animal_id) ON DELETE SET NULL,
  father_animal_id BIGINT REFERENCES animal(animal_id) ON DELETE SET NULL,
  birth_date DATE NOT NULL,
  birth_weight_kg NUMERIC(8,2),
  notes TEXT
);

CREATE TABLE milk_record (
  milk_record_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  animal_id BIGINT NOT NULL REFERENCES animal(animal_id) ON DELETE CASCADE,
  recorded_by BIGINT REFERENCES "user"(user_id) ON DELETE SET NULL,
  record_date DATE NOT NULL DEFAULT CURRENT_DATE,
  session VARCHAR(20) CHECK (session IN ('MORNING','EVENING','OTHER')),
  quantity_litres NUMERIC(10,2) NOT NULL CHECK (quantity_litres >= 0),
  notes TEXT
);

CREATE TABLE feed_record (
  feed_record_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  farm_id BIGINT NOT NULL REFERENCES farm(farm_id) ON DELETE CASCADE,
  animal_id BIGINT REFERENCES animal(animal_id) ON DELETE SET NULL,
  recorded_by BIGINT REFERENCES "user"(user_id) ON DELETE SET NULL,
  feed_type VARCHAR(120) NOT NULL,
  quantity NUMERIC(10,2) NOT NULL CHECK (quantity >= 0),
  unit VARCHAR(30) NOT NULL,
  cost NUMERIC(12,2) CHECK (cost >= 0),
  recorded_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE breeding_event (
  breeding_event_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  animal_id BIGINT NOT NULL REFERENCES animal(animal_id) ON DELETE CASCADE,
  event_type VARCHAR(30) NOT NULL CHECK (event_type IN ('HEAT','SERVICE','PREGNANCY_CHECK','CALVING','OTHER')),
  event_date DATE NOT NULL,
  sire_reference VARCHAR(120),
  expected_due_date DATE,
  outcome TEXT,
  recorded_by BIGINT REFERENCES "user"(user_id) ON DELETE SET NULL,
  notes TEXT
);

CREATE TABLE health_record (
  health_record_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  animal_id BIGINT NOT NULL REFERENCES animal(animal_id) ON DELETE CASCADE,
  attended_by BIGINT REFERENCES "user"(user_id) ON DELETE SET NULL,
  visit_date DATE NOT NULL DEFAULT CURRENT_DATE,
  symptoms TEXT,
  diagnosis TEXT,
  treatment TEXT,
  follow_up_date DATE,
  notes TEXT
);

CREATE TABLE vaccination_record (
  vaccination_record_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  animal_id BIGINT NOT NULL REFERENCES animal(animal_id) ON DELETE CASCADE,
  vaccine_name VARCHAR(150) NOT NULL,
  vaccination_date DATE NOT NULL,
  next_due_date DATE,
  administered_by BIGINT REFERENCES "user"(user_id) ON DELETE SET NULL,
  batch_number VARCHAR(100),
  notes TEXT
);

CREATE TABLE growth_record (
  growth_record_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  animal_id BIGINT NOT NULL REFERENCES animal(animal_id) ON DELETE CASCADE,
  measured_on DATE NOT NULL DEFAULT CURRENT_DATE,
  weight_kg NUMERIC(9,2) CHECK (weight_kg > 0),
  height_cm NUMERIC(9,2) CHECK (height_cm > 0),
  notes TEXT
);

CREATE TABLE financial_transaction (
  transaction_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  farm_id BIGINT NOT NULL REFERENCES farm(farm_id) ON DELETE CASCADE,
  transaction_type VARCHAR(20) NOT NULL CHECK (transaction_type IN ('INCOME','EXPENSE')),
  category VARCHAR(100) NOT NULL,
  amount NUMERIC(12,2) NOT NULL CHECK (amount >= 0),
  transaction_date DATE NOT NULL DEFAULT CURRENT_DATE,
  description TEXT,
  recorded_by BIGINT REFERENCES "user"(user_id) ON DELETE SET NULL
);

CREATE TABLE sale (
  sale_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  farm_id BIGINT NOT NULL REFERENCES farm(farm_id) ON DELETE CASCADE,
  animal_id BIGINT REFERENCES animal(animal_id) ON DELETE SET NULL,
  product_description VARCHAR(180) NOT NULL,
  quantity NUMERIC(10,2) NOT NULL CHECK (quantity > 0),
  unit VARCHAR(30) NOT NULL,
  unit_price NUMERIC(12,2) NOT NULL CHECK (unit_price >= 0),
  total_amount NUMERIC(12,2) NOT NULL CHECK (total_amount >= 0),
  buyer_name VARCHAR(150),
  sale_date DATE NOT NULL DEFAULT CURRENT_DATE,
  recorded_by BIGINT REFERENCES "user"(user_id) ON DELETE SET NULL
);

CREATE TABLE notification (
  notification_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  user_id BIGINT REFERENCES "user"(user_id) ON DELETE CASCADE,
  farm_id BIGINT REFERENCES farm(farm_id) ON DELETE CASCADE,
  title VARCHAR(180) NOT NULL,
  message TEXT NOT NULL,
  channel VARCHAR(20) NOT NULL DEFAULT 'IN_APP' CHECK (channel IN ('IN_APP','SMS','EMAIL')),
  is_read BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE audit_log (
  audit_log_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  user_id BIGINT REFERENCES "user"(user_id) ON DELETE SET NULL,
  farm_id BIGINT REFERENCES farm(farm_id) ON DELETE SET NULL,
  action VARCHAR(100) NOT NULL,
  entity_name VARCHAR(100),
  entity_id BIGINT,
  details JSONB,
  ip_address INET,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Frequently used lookup indexes
CREATE INDEX idx_animal_farm ON animal(farm_id);
CREATE INDEX idx_milk_animal_date ON milk_record(animal_id, record_date);
CREATE INDEX idx_health_animal_date ON health_record(animal_id, visit_date);
CREATE INDEX idx_vaccination_due ON vaccination_record(next_due_date);
CREATE INDEX idx_notification_user_read ON notification(user_id, is_read);
CREATE INDEX idx_audit_farm_created ON audit_log(farm_id, created_at);
