CREATE TABLE IF NOT EXISTS employees (
    emp_id       SERIAL PRIMARY KEY,
    first_name   VARCHAR(50) NOT NULL,
    last_name    VARCHAR(50) NOT NULL,
    department   VARCHAR(50),
    salary       INTEGER,
    hire_date    DATE,
    status       VARCHAR(20) DEFAULT 'Active'
);

CREATE TABLE IF NOT EXISTS departments (
    dept_id    SERIAL PRIMARY KEY,
    dept_name  VARCHAR(100) NOT NULL UNIQUE,
    budget     INTEGER DEFAULT 0,
    manager_id INTEGER REFERENCES employees(emp_id) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS projects (
    project_id   SERIAL PRIMARY KEY,
    project_name VARCHAR(150) NOT NULL,
    dept_id      INTEGER REFERENCES departments(dept_id) ON DELETE SET NULL,
    start_date   DATE,
    end_date     DATE,
    budget       INTEGER
);

INSERT INTO departments (dept_name, budget)
VALUES
  ('IT', 150000),
  ('Sales', 90000),
  ('HR', 40000)
RETURNING *;

INSERT INTO employees (first_name, last_name, department, salary, hire_date, status)
VALUES
  ('Alice', 'Ivanova', 'IT', 70000, '2018-06-15', 'Active'),
  ('Bob', 'Petrov', 'Sales', 45000, '2021-03-10', 'Active'),
  ('Carol', 'Sidorova', 'HR', 38000, '2023-09-01', 'Active'),
  ('David', 'Smirnov', NULL, 35000, '2024-02-01', 'Inactive'),
  ('Eve', 'Kuznetsova', 'IT', 90000, '2015-11-20', 'Active')
RETURNING *;

INSERT INTO projects (project_name, dept_id, start_date, end_date, budget)
VALUES
  ('Website revamp', (SELECT dept_id FROM departments WHERE dept_name='IT'), '2023-01-10', '2023-12-31', 60000),
  ('Q4 Sales Drive', (SELECT dept_id FROM departments WHERE dept_name='Sales'), '2024-09-01', '2024-11-30', 20000),
  ('Recruitment 2024', (SELECT dept_id FROM departments WHERE dept_name='HR'), '2024-03-01', '2024-05-15', 10000)
RETURNING *;

INSERT INTO employees (first_name, last_name, department)
VALUES ('Frank', 'Orlov', 'Sales')
RETURNING *;

INSERT INTO employees (first_name, last_name, department, hire_date)
VALUES ('Grace', 'Mikhailova', 'Marketing', CURRENT_DATE)
RETURNING *;

INSERT INTO employees (first_name, last_name, department, salary, hire_date)
VALUES ('Hector', 'Belov', 'IT', (50000 * 1.1)::INTEGER, CURRENT_DATE)
RETURNING *;

CREATE TEMP TABLE temp_employees AS
SELECT * FROM employees WHERE department = 'IT';

SELECT * FROM temp_employees;

UPDATE employees
SET salary = CASE WHEN salary IS NOT NULL THEN (salary * 1.10)::INTEGER ELSE NULL END;

UPDATE employees
SET status = 'Senior'
WHERE salary > 60000 AND hire_date < '2020-01-01';

UPDATE employees
SET department = CASE
    WHEN salary > 80000 THEN 'Management'
    WHEN salary BETWEEN 50000 AND 80000 THEN 'Senior'
    ELSE 'Junior'
END;

ALTER TABLE employees ALTER COLUMN department SET DEFAULT 'Unassigned';

UPDATE employees
SET department = DEFAULT
WHERE status = 'Inactive';

UPDATE departments d
SET budget = CEIL((
    SELECT COALESCE(AVG(salary), 0) * 1.20
    FROM employees e
    WHERE e.department = d.dept_name
))::INTEGER;

UPDATE employees
SET salary = (salary * 1.15)::INTEGER,
    status = 'Promoted'
WHERE department = 'Sales';

DELETE FROM employees WHERE status = 'Terminated';

DELETE FROM employees
WHERE salary < 40000
  AND hire_date > '2023-01-01'
  AND department IS NULL;

DELETE FROM departments
WHERE dept_id NOT IN (
  SELECT DISTINCT d.dept_id
  FROM departments d
  LEFT JOIN employees e ON e.department = d.dept_name
  WHERE e.department IS NOT NULL
);

DELETE FROM departments
WHERE dept_name NOT IN (SELECT DISTINCT department FROM employees WHERE department IS NOT NULL);

DELETE FROM projects
WHERE end_date < '2023-01-01'
RETURNING *;

INSERT INTO employees (first_name, last_name, salary, department, hire_date)
VALUES ('Ivan', 'Nullov', NULL, NULL, CURRENT_DATE)
RETURNING *;

UPDATE employees
SET department = 'Unassigned'
WHERE department IS NULL;

DELETE FROM employees
WHERE salary IS NULL OR department IS NULL
RETURNING *;

INSERT INTO employees (first_name, last_name, department, salary, hire_date)
VALUES ('Julia', 'Voronina', 'IT', 65000, CURRENT_DATE)
RETURNING emp_id, (first_name || ' ' || last_name) AS full_name;

WITH updated AS (
  SELECT emp_id, salary AS old_salary
  FROM employees
  WHERE department = 'IT'
)
UPDATE employees e
SET salary = salary + 5000
FROM updated u
WHERE e.emp_id = u.emp_id
RETURNING e.emp_id, u.old_salary AS old_salary, e.salary AS new_salary;

DELETE FROM employees
WHERE hire_date < '2020-01-01'
RETURNING *;

INSERT INTO employees (first_name, last_name, department, salary, hire_date)
SELECT 'Kevin', 'Novikov', 'Sales', 48000, CURRENT_DATE
WHERE NOT EXISTS (
  SELECT 1 FROM employees WHERE first_name = 'Kevin' AND last_name = 'Novikov'
)
RETURNING *;

UPDATE employees e
SET salary = CASE
    WHEN (SELECT budget FROM departments d WHERE d.dept_name = e.department) > 100000 THEN (e.salary * 1.10)::INTEGER
    ELSE (e.salary * 1.05)::INTEGER
END
WHERE e.department IS NOT NULL;

INSERT INTO employees (first_name, last_name, department, salary, hire_date)
VALUES
  ('Lena', 'Gorshkova', 'Sales', 40000, CURRENT_DATE),
  ('Maks', 'Lebedev', 'IT', 55000, CURRENT_DATE),
  ('Nina', 'Orlova', 'HR', 37000, CURRENT_DATE),
  ('Oleg', 'Kovtun', 'IT', 60000, CURRENT_DATE),
  ('Pavel', 'Antonov', 'Sales', 42000, CURRENT_DATE)
RETURNING emp_id;

UPDATE employees
SET salary = (salary * 1.10)::INTEGER
WHERE hire_date = CURRENT_DATE;

CREATE TABLE IF NOT EXISTS employee_archive AS TABLE employees WITH NO DATA;

INSERT INTO employee_archive
SELECT * FROM employees WHERE status = 'Inactive';

DELETE FROM employees WHERE status = 'Inactive';

UPDATE projects p
SET end_date = p.end_date + INTERVAL '30 days'
WHERE p.budget > 50000
  AND (
    SELECT COUNT(*) FROM employees e WHERE e.department = (
      SELECT d.dept_name FROM departments d WHERE d.dept_id = p.dept_id
    )
  ) > 3
RETURNING p.*;

SELECT * FROM departments ORDER BY dept_id;
SELECT * FROM employees ORDER BY emp_id;
SELECT * FROM projects ORDER BY project_id;