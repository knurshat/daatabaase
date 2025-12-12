

START TRANSACTION;
UPDATE library_books SET copies = copies - 1
WHERE title = 'Clean Code';
SAVEPOINT before_member_update;
UPDATE members SET books_borrowed = books_borrowed + 1
WHERE name = 'Liam';
--ROLLBACK TO before_member_update;
COMMIT;

--TASK 2

-- Oliver - 0
-- Emma   - -
-- Liam   - 5
-- Sophia - -



--TASK 3
-- C
-- B
-- A

-- TASK 4
-- 5
-- Yes
--
-- copies + 1