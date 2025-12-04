SELECT
    d.dept_name,
    COUNT(DISTINCT e.emp_id) AS employee_count,
    COUNT(DISTINCT p.project_id) AS project_count,
    CASE
        WHEN COUNT(DISTINCT p.project_id) = 0 THEN 0
        ELSE ROUND(COUNT(DISTINCT e.emp_id)::numeric / COUNT(DISTINCT p.project_id), 2)
    END AS employees_per_project
FROM departments d
LEFT JOIN employees e ON d.dept_id = e.dept_id
LEFT JOIN projects p ON d.dept_id = p.dept_id
GROUP BY d.dept_id, d.dept_name
HAVING COUNT(DISTINCT p.project_id) > 0
ORDER BY employee_count ASC;