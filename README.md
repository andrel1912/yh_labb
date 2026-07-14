# YrkesCo School Management Database

## Overview

YrkesCo is a relational database for a vocational school administration platform. 
The database is designed to manage students, programs, courses, classes, educators, education leaders and school sites.
The database is built with PostgreSQL 16 and runs in Docker.

---

## Technical Specs
- **Engine:** *PostgreSQL 16*
- **Environment:** *Docker and Docker Compose*
- **Access:** *pgAdmin 4*
- **Database Model:** *Third Normal Form (3NF)*
---

## Architectural Features
---

## 1. Database Normalization (3NF)
The database is organized using Third Normal Form (3NF). 
The goal is to reduce repeated information and make the data easier to maintain.

**First Normal Form (1NF)**  
Each table has a primary key, and every column stores a single value. There are no repeating groups or multiple values in the same field.

**Second Normal Form (2NF)**  
The data is divided into separate tables so that each attribute belongs to the correct entity. Relationships between tables are handled with foreign keys instead of storing the same information multiple times.

**Third Normal Form (3NF)**  
Information that belongs together is stored in its own table. For example, details about a school site are kept in the ***site*** table, while classes only store a reference to the site. 
Personal information is also separated into ***person*** and ***person_details***, making it easier to update data without creating duplicates.

## 2. Person Structure 
The ***person*** table stores general information about each person. Role-specific information is stored in separate tables.

- **student** – Student information.
- **educator** – Educator information.
- **education_leader** – Education leader information.
- **person_details** – Social security number and email.

This structure keeps the database organized and reduces duplicated information.

## 3. Security
Sensitive information is stored separately from general person data. Personal numbers and email addresses are kept in the ***person_details*** table, while names and basic information remain in the ***person*** table. This reduces duplicated data and makes personal information easier to manage.

---

## Setup

Start the Docker containers: docker compose up -d
Connect to PostgreSQL:

**bash**
`docker exec -it yrkesco_postgres psql -U yrkesco_user -d yrkesco_db`

Run the SQL files in this order:
**sql**
`\i /docker-entrypoint-initdb.d/create_tables.sql`
`\i /docker-entrypoint-initdb.d/insert_data.sql`
`\i /docker-entrypoint-initdb.d/queries.sql`
---