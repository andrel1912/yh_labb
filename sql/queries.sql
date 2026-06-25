
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
