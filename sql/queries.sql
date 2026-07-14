
--YRKESCO TEST Queries 

-- Tester

-- 1 
SELECT 
    'Test: Personuppgifter separerade' AS test_name,
    COUNT(DISTINCT p.person_id) AS number_of_persons,
    COUNT(DISTINCT pd.person_id) AS number_of_person_details,
    CASE 
        WHEN COUNT(DISTINCT p.person_id) = COUNT(DISTINCT pd.person_id) THEN 'OK'
        ELSE 'FEL'
    END AS result
FROM person p
LEFT JOIN person_details pd ON p.person_id = pd.person_id; 

-- 2
SELECT 
    'Test: Personroller' AS test_name,
    SUM(CASE WHEN person_type = 'student' THEN 1 ELSE 0 END) AS students,
    SUM(CASE WHEN person_type = 'educator' THEN 1 ELSE 0 END) AS educators,
    SUM(CASE WHEN person_type = 'education_leader' THEN 1 ELSE 0 END) AS education_leaders,
    SUM(CASE WHEN person_type = 'consultant' THEN 1 ELSE 0 END) AS consultants,
    CASE 
        WHEN SUM(CASE WHEN person_type = 'student' THEN 1 ELSE 0 END) > 0
         AND SUM(CASE WHEN person_type = 'educator' THEN 1 ELSE 0 END) > 0
         AND SUM(CASE WHEN person_type = 'education_leader' THEN 1 ELSE 0 END) > 0
         AND SUM(CASE WHEN person_type = 'consultant' THEN 1 ELSE 0 END) > 0
        THEN 'OK'
        ELSE 'FEL'
    END AS result
FROM person;

-- 3
SELECT 
    'Test: Site/anläggningar' AS test_name,
    COUNT(*) AS number_of_sites,
    CASE 
        WHEN COUNT(*) >= 2 THEN 'OK'
        ELSE 'För få platser'
    END AS result
FROM site;

-- 4 
SELECT 
    'Test: Fristående kurser' AS test_name,
    COUNT(*) AS number_of_standalone_courses,
    CASE 
        WHEN COUNT(*) > 0 THEN 'OK'
        ELSE 'FEL'
    END AS result
FROM course
WHERE is_standalone = TRUE;

-- 5 
SELECT 
    'Test: Program har iterationer' AS test_name,
    p.program_name,
    COUNT(DISTINCT c.iteration) AS number_of_iterations,
    CASE 
        WHEN COUNT(DISTINCT c.iteration) = 3 THEN 'OK'
        WHEN COUNT(DISTINCT c.iteration) = 0 THEN 'Inga klasser'
        ELSE CONCAT('Har ', COUNT(DISTINCT c.iteration), ' iterationer')
    END AS result
FROM program p
LEFT JOIN class c ON p.program_id = c.program_id
GROUP BY p.program_id, p.program_name
ORDER BY p.program_name;

-- 6 
SELECT 
    'Test: Utbildningsledare och klasser' AS test_name,
    CONCAT(p.first_name, ' ', p.last_name) AS leader_name,
    COUNT(c.class_id) AS number_of_classes,
    CASE 
        WHEN COUNT(c.class_id) >= 3 THEN 'OK'
        WHEN COUNT(c.class_id) > 0 THEN 'Har några klasser'
        ELSE 'Inga klasser'
    END AS result
FROM education_leader el
JOIN person p ON el.leader_id = p.person_id
LEFT JOIN class c ON el.leader_id = c.leader_id
GROUP BY el.leader_id, p.first_name, p.last_name
ORDER BY number_of_classes DESC;


-- QUERIES FOR TESTING DATA INTEGRITY

-- Q1 Översikt över platser och antal klasser och studenter

SELECT 
    s.site_name,
    s.city,
    COUNT(DISTINCT cl.class_id) AS number_of_classes,
    COUNT(DISTINCT st.student_id) AS number_of_students
FROM site s
LEFT JOIN class cl ON s.site_id = cl.site_id
LEFT JOIN student st ON cl.class_id = st.class_id
GROUP BY 
    s.site_id,
    s.site_name,
    s.city
ORDER BY s.city, s.site_name;

-- Q2 Klassöversikt

SELECT
    c.class_code,
    c.class_name,
    p.program_name,
    CONCAT(per.first_name, ' ', per.last_name) AS leader_name,
    s.site_name,
    s.city,
    c.iteration,
    c.start_date,
    c.end_date,
    c.status,
    COUNT(st.student_id) AS number_of_students,
    c.max_students
FROM class c
JOIN program p ON c.program_id = p.program_id
JOIN education_leader el ON c.leader_id = el.leader_id
JOIN person per ON el.leader_id = per.person_id
JOIN site s ON c.site_id = s.site_id
LEFT JOIN student st ON c.class_id = st.class_id
GROUP BY 
    c.class_id,
    c.class_code,
    c.class_name,
    p.program_name,
    per.first_name,
    per.last_name,
    s.site_name,
    s.city,
    c.iteration,
    c.start_date,
    c.end_date,
    c.status,
    c.max_students
ORDER BY c.start_date, s.city;

-- Q3 Program och deras kurser
SELECT 
    p.program_name,
    co.course_code,
    co.course_name,
    co.credits,
    CASE 
        WHEN pc.is_mandatory THEN 'Obligatorisk'
        ELSE 'Valfri'
    END AS course_type,
    pc.semester
FROM program p
JOIN program_course pc ON p.program_id = pc.program_id
JOIN course co ON pc.course_id = co.course_id
ORDER BY p.program_name, pc.semester, co.course_name;