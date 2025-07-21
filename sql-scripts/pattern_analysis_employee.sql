-- 1. Identify employees with repeated promotions (more than 1 promotion in 3 years)
SELECT 
    employee_id,
    COUNT(*) AS promotion_count
FROM promotions
WHERE promotion_date >= DATEADD(YEAR, -3, GETDATE())
GROUP BY employee_id
HAVING COUNT(*) > 1;

-- 2. Detect employees with frequent department changes in the past 2 years
SELECT 
    employee_id,
    COUNT(DISTINCT department_id) AS dept_changes
FROM department_history
WHERE change_date >= DATEADD(YEAR, -2, GETDATE())
GROUP BY employee_id
HAVING COUNT(DISTINCT department_id) > 2;

-- 3. Identify employees with consistently high performance ratings over 3 years
SELECT 
    employee_id,
    AVG(performance_score) AS avg_score,
    MIN(performance_score) AS min_score
FROM performance_reviews
WHERE review_date >= DATEADD(YEAR, -3, GETDATE())
GROUP BY employee_id
HAVING MIN(performance_score) >= 4;

-- 4. Find employees with long tenure but stagnant roles
SELECT 
    e.employee_id,
    e.hire_date,
    r.role_title,
    DATEDIFF(YEAR, e.hire_date, GETDATE()) AS years_with_company,
    MAX(promotion_date) AS last_promotion
FROM employees e
LEFT JOIN roles r ON e.current_role_id = r.role_id
LEFT JOIN promotions p ON e.employee_id = p.employee_id
GROUP BY e.employee_id, e.hire_date, r.role_title
HAVING MAX(promotion_date) IS NULL
   AND DATEDIFF(YEAR, e.hire_date, GETDATE()) > 5;

-- 5. Find departments with high employee turnover in the last year
SELECT 
    department_id,
    COUNT(DISTINCT employee_id) AS exits
FROM employee_exit_logs
WHERE exit_date >= DATEADD(YEAR, -1, GETDATE())
GROUP BY department_id
HAVING COUNT(DISTINCT employee_id) > 10;

-- 6. Spot seasonal hiring trends
SELECT 
    DATENAME(MONTH, hire_date) AS hire_month,
    COUNT(*) AS hires
FROM employees
GROUP BY DATENAME(MONTH, hire_date)
ORDER BY COUNT(*) DESC;

-- 7. Identify high-performing teams (average team performance > 4.5)
SELECT 
    t.team_id,
    t.team_name,
    AVG(p.performance_score) AS team_avg_score
FROM teams t
JOIN employees e ON t.team_id = e.team_id
JOIN performance_reviews p ON e.employee_id = p.employee_id
GROUP BY t.team_id, t.team_name
HAVING AVG(p.performance_score) > 4.5;
