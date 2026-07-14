
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

-- Q3 Program och kurser
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

-- Q4 Specifik student information
SELECT
    st.student_number,
    CONCAT(per.first_name, ' ', per.last_name) AS student_name,
    p.program_name,
    c.class_name,
    COUNT(se.enrollment_id) AS number_of_course_enrollments
FROM student st
JOIN person per ON st.student_id = per.person_id
JOIN program p ON st.program_id = p.program_id
JOIN class c ON st.class_id = c.class_id
LEFT JOIN student_enrollment se ON st.student_id = se.student_id
WHERE st.class_id = 1
GROUP BY 
    st.student_id,
    st.student_number,
    per.first_name,
    per.last_name,
    p.program_name,
    c.class_name
ORDER BY per.last_name;

-- Q5 Kurser i en klass
SELECT
    c.class_name,
    co.course_code,
    co.course_name,
    co.credits,
    co.difficulty_level,
    ca.start_date AS course_start,
    ca.end_date AS course_end,
    CONCAT(per.first_name, ' ', per.last_name) AS educator_name,
    CASE 
        WHEN e.is_permanent THEN 'Fast anställd'
        ELSE 'Konsult/visstid'
    END AS employment_type
FROM course_assignment ca
JOIN class c ON ca.class_id = c.class_id
JOIN course co ON ca.course_id = co.course_id
JOIN educator e ON ca.educator_id = e.educator_id
JOIN person per ON e.educator_id = per.person_id
WHERE ca.class_id = 1
ORDER BY ca.start_date;

-- Q6 Utbildningsledare och deras klasser
SELECT 
    CONCAT(p.first_name, ' ', p.last_name) AS leader_name,
    el.department,
    COUNT(cl.class_id) AS number_of_classes
FROM education_leader el
JOIN person p ON el.leader_id = p.person_id
LEFT JOIN class cl ON el.leader_id = cl.leader_id
GROUP BY 
    el.leader_id,
    p.first_name,
    p.last_name,
    el.department
ORDER BY number_of_classes DESC;

-- Q7 Utbildare
SELECT 
    CONCAT(per.first_name, ' ', per.last_name) AS educator_name,
    CASE 
        WHEN e.is_permanent THEN 'Fast anställd'
        ELSE 'Konsult/visstid'
    END AS employment_type,
    e.hourly_rate,
    COUNT(DISTINCT ca.assignment_id) AS number_of_course_assignments
FROM educator e
JOIN person per ON e.educator_id = per.person_id
LEFT JOIN course_assignment ca ON e.educator_id = ca.educator_id
GROUP BY 
    e.educator_id,
    per.first_name,
    per.last_name,
    e.is_permanent,
    e.hourly_rate
ORDER BY number_of_course_assignments DESC, educator_name;

-- Q8 fristående kurser

SELECT 
    co.course_code,
    co.course_name,
    co.credits,
    cl.class_name,
    CONCAT(per.first_name, ' ', per.last_name) AS educator_name,
    ca.start_date,
    ca.end_date,
    s.site_name,
    s.city
FROM course co
JOIN course_assignment ca ON co.course_id = ca.course_id
JOIN class cl ON ca.class_id = cl.class_id
JOIN educator e ON ca.educator_id = e.educator_id
JOIN person per ON e.educator_id = per.person_id
JOIN site s ON cl.site_id = s.site_id
WHERE co.is_standalone = TRUE
ORDER BY ca.start_date;

-- Q9

SELECT 
    p.program_name,
    s.city,
    cl.iteration,
    COUNT(st.student_id) AS number_of_students,
    cl.max_students
FROM program p
JOIN class cl ON p.program_id = cl.program_id
JOIN site s ON cl.site_id = s.site_id
LEFT JOIN student st ON cl.class_id = st.class_id
GROUP BY 
    p.program_name,
    s.city,
    cl.iteration,
    cl.max_students
ORDER BY p.program_name, s.city, cl.iteration;

-- Q10 

SELECT 
    st.student_number,
    CONCAT(student_person.first_name, ' ', student_person.last_name) AS student_name,
    co.course_name,
    se.grade,
    se.status,
    CONCAT(educator_person.first_name, ' ', educator_person.last_name) AS educator_name
FROM student_enrollment se
JOIN student st ON se.student_id = st.student_id
JOIN person student_person ON st.student_id = student_person.person_id
JOIN course_assignment ca ON se.assignment_id = ca.assignment_id
JOIN course co ON ca.course_id = co.course_id
JOIN educator e ON ca.educator_id = e.educator_id
JOIN person educator_person ON e.educator_id = educator_person.person_id
WHERE se.grade IS NOT NULL
ORDER BY student_person.last_name, co.course_name;
