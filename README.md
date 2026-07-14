# YrkesCo School Management Database

## Overview

YrkesCo is a relational database for a vocational school administration platform. 
The database is designed to manage students, programs, courses, classes, educators, education leaders and school sites.
The database is built with PostgreSQL 16 and runs in Docker.

---

## Technical Specs
- Engine: PostgreSQL 16
- Environment: Docker and Docker Compose
- Access: pgAdmin 4
- Database Model: Third Normal Form (3NF)

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
Information that belongs together is stored in its own table. For example, details about a school site are kept in the "site" table, while classes only store a reference to the site. 
Personal information is also separated into "person" and "person_details", making it easier to update data without creating duplicates.