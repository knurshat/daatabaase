---------------------------------------------------
-- Setup
---------------------------------------------------
CREATE TABLE accounts (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    balance DECIMAL(10,2)
);

CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    shop VARCHAR(100),
    product VARCHAR(100),
    price DECIMAL(10,2)
);

INSERT INTO accounts (name, balance) VALUES
('Alice', 1000), ('Bob', 500), ('Wally', 750);

INSERT INTO products (shop, product, price) VALUES
('Joe''s Shop', 'Coke', 2.50),
('Joe''s Shop', 'Pepsi', 3.00);

---------------------------------------------------
-- Task 1 COMMIT
---------------------------------------------------
BEGIN;
UPDATE accounts SET balance = balance - 100 WHERE name = 'Alice';
UPDATE accounts SET balance = balance + 100 WHERE name = 'Bob';
COMMIT;

---------------------------------------------------
-- Task 2 ROLLBACK
---------------------------------------------------
BEGIN;
UPDATE accounts SET balance = balance - 500 WHERE name = 'Alice';
ROLLBACK;

---------------------------------------------------
-- Task 3 SAVEPOINT
---------------------------------------------------
BEGIN;
UPDATE accounts SET balance = balance - 100 WHERE name = 'Alice';
SAVEPOINT s1;
UPDATE accounts SET balance = balance + 100 WHERE name = 'Bob';
ROLLBACK TO s1;
UPDATE accounts SET balance = balance + 100 WHERE name = 'Wally';
COMMIT;

---------------------------------------------------
-- Task 4 Isolation READ COMMITTED
-- Terminal 1
BEGIN TRANSACTION ISOLATION LEVEL READ COMMITTED;
SELECT * FROM products WHERE shop = 'Joe''s Shop';
SELECT * FROM products WHERE shop = 'Joe''s Shop';
COMMIT;

-- Terminal 2
BEGIN;
DELETE FROM products WHERE shop = 'Joe''s Shop';
INSERT INTO products (shop, product, price) VALUES ('Joe''s Shop','Fanta',3.50);
COMMIT;

---------------------------------------------------
-- Task 4 SERIALIZABLE
---------------------------------------------------
BEGIN TRANSACTION ISOLATION LEVEL SERIALIZABLE;
SELECT * FROM products WHERE shop = 'Joe''s Shop';
SELECT * FROM products WHERE shop = 'Joe''s Shop';
COMMIT;

---------------------------------------------------
-- Task 5 Phantom Read
-- Terminal 1
BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ;
SELECT MAX(price), MIN(price) FROM products WHERE shop = 'Joe''s Shop';
SELECT MAX(price), MIN(price) FROM products WHERE shop = 'Joe''s Shop';
COMMIT;

-- Terminal 2
BEGIN;
INSERT INTO products (shop, product, price) VALUES ('Joe''s Shop','Sprite',4.00);
COMMIT;

---------------------------------------------------
-- Task 6 Dirty Read
-- Terminal 1
BEGIN TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SELECT * FROM products WHERE shop = 'Joe''s Shop';
SELECT * FROM products WHERE shop = 'Joe''s Shop';
SELECT * FROM products WHERE shop = 'Joe''s Shop';
COMMIT;

-- Terminal 2
BEGIN;
UPDATE products SET price = 99.99 WHERE product = 'Fanta';
ROLLBACK;

---------------------------------------------------
-- Independent Exercise 1
-- Transfer only if sufficient
---------------------------------------------------
BEGIN;
UPDATE accounts SET balance = balance - 200 WHERE name = 'Bob' AND balance >= 200;
UPDATE accounts SET balance = balance + 200 WHERE name = 'Wally';
COMMIT;

---------------------------------------------------
-- Independent Exercise 2 (Two savepoints)
---------------------------------------------------
BEGIN;
INSERT INTO products (shop, product, price) VALUES ('NewShop','Tea',2.00);
SAVEPOINT a;
UPDATE products SET price = 2.50 WHERE product='Tea';
SAVEPOINT b;
DELETE FROM products WHERE product='Tea';
ROLLBACK TO a;
COMMIT;

---------------------------------------------------
-- Independent Exercise 3 (Two users withdrawing)
-- Terminal 1
BEGIN TRANSACTION ISOLATION LEVEL READ COMMITTED;
UPDATE accounts SET balance = balance - 100 WHERE name='Alice';
COMMIT;

-- Terminal 2
BEGIN TRANSACTION ISOLATION LEVEL SERIALIZABLE;
UPDATE accounts SET balance = balance - 100 WHERE name='Alice';
COMMIT;

---------------------------------------------------
-- Independent Exercise 4 MAX < MIN fix with Transaction
---------------------------------------------------
BEGIN;
SELECT MAX(price), MIN(price) FROM products WHERE shop='Joe''s Shop';
COMMIT;

--Ответы по Task 1

--a) После транзакции: у Алисы стало на 100 меньше, у Боба на 100 больше.
--b) Чтобы не получилось, что деньги списались, но не добавились.
--c) Если бы система зависла — часть операции выполнилась бы, а часть нет, и данные стали бы неправильными.

--Ответы по Task 2

--a) После UPDATE баланс уменьшился, но ещё не сохранён.
--b) После ROLLBACK всё вернулось в исходное состояние.
--c) ROLLBACK используют, когда заметили ошибку или неверные данные до сохранения.

--Оnветы по Task 3

--a) У Алисы – меньше на 100, у Боба — без изменений, у Уолли — больше на 100.
--b) Деньги Бобу начислились только временно и были отменены.
--c) SAVEPOINT удобнее, когда нужно отменить не всё, а только часть действий.

--Task 4

--a) READ COMMITTED — сначала старые данные, после коммита — уже обновленные.
--b) SERIALIZABLE — видит только те данные, что были до начала транзакции.
--c) READ COMMITTED позволяет видеть изменения других, SERIALIZABLE — нет, работает безопаснее, но медленнее.

--Task 5

--a) Нет, REPEATABLE READ не показывает новые строки.
--b) Phantom read — когда в выборке появляются новые строки, которых не было.
--c) От фантомных чтений защищает уровень SERIALIZABLE.

--Task 6

--a) Да, можно увидеть ещё незафиксированные данные — и это плохо, потому что они могут отмениться.
--b) Dirty read — это чтение нечистых (неподтверждённых) данных.
--c) READ UNCOMMITTED редко используют, потому что слишком рискованно.

--Self-Assessment (короткие ответы)

--ACID — гарантирует, что операция либо выполнится полностью, либо нет, данные не ломаются и сохраняются даже если что-то упадёт.

--COMMIT — сохранить, ROLLBACK — отменить.

--SAVEPOINT — когда нужно отменить не всё, а только один шаг.

--READ UNCOMMITTED — самый “безопасно-опасный”, SERIALIZABLE — самый безопасный.

--Dirty read — чтение незакоммиченных данных, это позволяет READ UNCOMMITTED.

--Non-repeatable read — когда читаешь второй раз и данные отличаются.

--Phantom read — появляются новые строки; предотвращает SERIALIZABLE.

--READ COMMITTED проще и быстрее, подходит там, где большой трафик.

--Транзакции защищают от конфликтов, когда кто-то меняет данные одновременно.

--Если не сохранено — всё пропадает и возвращается назад.