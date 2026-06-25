CREATE TABLE site (
    site_name VARCHAR(200) NOT NULL,
    site_id SERIAL PRIMARY KEY,
    site_code VARCHAR(15) UNIQUE NOT NULL,
    city VARCHAR(100) NOT NULL,
    address VARCHAR(300) NOT NULL,
    postal_code VARCHAR(10),
    phone VARCHAR(20)
);

CREATE TABLE person (
    person_id SERIAL PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    person_type VARCHAR(50) NOT NULL CHECK (person_type IN ('student','educator','education_leader', 'consultant')),
    birth_date DATE
);

CREATE TABLE program (
    program_name VARCHAR(100) NOT NULL,
    program_id SERIAL PRIMARY KEY,
    program_code VARCHAR(10) NOT NULL UNIQUE,
    total_credits INTEGER NOT NULL,
    duration_weeks INTEGER,
    description TEXT,
    is_active BOOLEAN DEFAULT TRUE
);

CREATE TABLE course (
    course_name VARCHAR(200) NOT NULL,
    course_id SERIAL PRIMARY KEY,   
    course_code VARCHAR(20) NOT NULL UNIQUE,
    credits INTEGER NOT NULL,
    description TEXT,
    is_standalone BOOLEAN DEFAULT FALSE,
    difficulty_level VARCHAR(20) DEFAULT 'basic',
    is_active BOOLEAN DEFAULT TRUE
);