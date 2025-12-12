-- ========================================
-- KAZFINANCE BANK - COMPLETE DATABASE SYSTEM
-- Bonus Laboratory Work - Advanced Database Programming
-- ========================================

-- ========================================
-- CLEANUP: DROP EXISTING OBJECTS
-- ========================================
DROP MATERIALIZED VIEW IF EXISTS salary_batch_summary CASCADE;
DROP VIEW IF EXISTS suspicious_activity_view CASCADE;
DROP VIEW IF EXISTS daily_transaction_report CASCADE;
DROP VIEW IF EXISTS customer_balance_summary CASCADE;
DROP FUNCTION IF EXISTS process_salary_batch CASCADE;
DROP FUNCTION IF EXISTS process_transfer CASCADE;
DROP TABLE IF EXISTS audit_log CASCADE;
DROP TABLE IF EXISTS transactions CASCADE;
DROP TABLE IF EXISTS exchange_rates CASCADE;
DROP TABLE IF EXISTS accounts CASCADE;
DROP TABLE IF EXISTS customers CASCADE;

-- ========================================
-- SECTION 1: TABLE CREATION
-- ========================================

-- TABLE 1: Customers
CREATE TABLE customers (
    customer_id SERIAL PRIMARY KEY,
    iin CHAR(12) UNIQUE NOT NULL CHECK (iin ~ '^\d{12}$'),
    full_name VARCHAR(100) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'blocked', 'frozen')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    daily_limit_kzt DECIMAL(15,2) DEFAULT 10000000.00
);

-- TABLE 2: Accounts
CREATE TABLE accounts (
    account_id SERIAL PRIMARY KEY,
    customer_id INT NOT NULL REFERENCES customers(customer_id),
    account_number CHAR(20) UNIQUE NOT NULL,
    currency CHAR(3) NOT NULL CHECK (currency IN ('KZT', 'USD', 'EUR', 'RUB')),
    balance DECIMAL(15,2) DEFAULT 0.00 CHECK (balance >= 0),
    is_active BOOLEAN DEFAULT true,
    opened_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    closed_at TIMESTAMP
);

-- TABLE 3: Transactions
CREATE TABLE transactions (
    transaction_id SERIAL PRIMARY KEY,
    from_account_id INT REFERENCES accounts(account_id),
    to_account_id INT REFERENCES accounts(account_id),
    amount DECIMAL(15,2) NOT NULL CHECK (amount > 0),
    currency CHAR(3) NOT NULL,
    exchange_rate DECIMAL(10,6) DEFAULT 1.000000,
    amount_kzt DECIMAL(15,2) NOT NULL,
    type VARCHAR(20) NOT NULL CHECK (type IN ('transfer', 'deposit', 'withdrawal')),
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'completed', 'failed', 'reversed')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP,
    description TEXT
);

-- TABLE 4: Exchange Rates
CREATE TABLE exchange_rates (
    rate_id SERIAL PRIMARY KEY,
    from_currency CHAR(3) NOT NULL,
    to_currency CHAR(3) NOT NULL,
    rate DECIMAL(10,6) NOT NULL CHECK (rate > 0),
    valid_from TIMESTAMP NOT NULL,
    valid_to TIMESTAMP,
    UNIQUE(from_currency, to_currency, valid_from)
);

-- TABLE 5: Audit Log
CREATE TABLE audit_log (
    log_id SERIAL PRIMARY KEY,
    table_name VARCHAR(50) NOT NULL,
    record_id INT NOT NULL,
    action VARCHAR(10) NOT NULL CHECK (action IN ('INSERT', 'UPDATE', 'DELETE')),
    old_values JSONB,
    new_values JSONB,
    changed_by VARCHAR(100) DEFAULT CURRENT_USER,
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ip_address INET
);

-- ========================================
-- SECTION 2: SAMPLE DATA INSERTION
-- ========================================

-- Insert Customers (10 records)
INSERT INTO customers (iin, full_name, phone, email, status, daily_limit_kzt) VALUES
('123456789012', 'Nurlan Aitzhanov', '+77017778899', 'nurlan.a@example.kz', 'active', 15000000.00),
('234567890123', 'Asel Bekova', '+77013334455', 'asel.b@example.kz', 'active', 10000000.00),
('345678901234', 'Dias Kozhakhmetov', '+77019876543', 'dias.k@example.kz', 'active', 20000000.00),
('456789012345', 'Zhanna Suleimenova', '+77011112233', 'zhanna.s@example.kz', 'blocked', 5000000.00),
('567890123456', 'Marat Tulegenov', '+77015556677', 'marat.t@example.kz', 'active', 12000000.00),
('678901234567', 'Aigerim Nurgaliyeva', '+77012223344', 'aigerim.n@example.kz', 'active', 8000000.00),
('789012345678', 'Baurzhan Ospanov', '+77014445566', 'baurzhan.o@example.kz', 'frozen', 10000000.00),
('890123456789', 'Saule Mukhametzhanova', '+77016667788', 'saule.m@example.kz', 'active', 25000000.00),
('901234567890', 'Timur Akhmetov', '+77018889900', 'timur.a@example.kz', 'active', 30000000.00),
('012345678901', 'Laura Zhakupova', '+77010001122', 'laura.z@example.kz', 'active', 7000000.00);

-- Insert Accounts (15 records)
INSERT INTO accounts (customer_id, account_number, currency, balance, is_active) VALUES
(1, 'KZ01125KZT0000001234', 'KZT', 5000000.00, true),
(1, 'KZ02125USD0000001234', 'USD', 10000.00, true),
(2, 'KZ03125KZT0000005678', 'KZT', 3000000.00, true),
(2, 'KZ04125EUR0000005678', 'EUR', 5000.00, true),
(3, 'KZ05125KZT0000009012', 'KZT', 15000000.00, true),
(4, 'KZ06125KZT0000003456', 'KZT', 500000.00, false),
(5, 'KZ07125USD0000007890', 'USD', 25000.00, true),
(5, 'KZ08125RUB0000007890', 'RUB', 500000.00, true),
(6, 'KZ09125KZT0000001111', 'KZT', 2000000.00, true),
(7, 'KZ10125EUR0000002222', 'EUR', 8000.00, true),
(8, 'KZ11125KZT0000003333', 'KZT', 10000000.00, true),
(9, 'KZ12125USD0000004444', 'USD', 50000.00, true),
(9, 'KZ13125KZT0000004444', 'KZT', 20000000.00, true),
(10, 'KZ14125KZT0000005555', 'KZT', 1500000.00, true),
(10, 'KZ15125EUR0000005555', 'EUR', 3000.00, true);

-- Insert Exchange Rates (12 records)
INSERT INTO exchange_rates (from_currency, to_currency, rate, valid_from, valid_to) VALUES
('USD', 'KZT', 460.50, '2024-01-01', NULL),
('EUR', 'KZT', 505.75, '2024-01-01', NULL),
('RUB', 'KZT', 5.20, '2024-01-01', NULL),
('KZT', 'USD', 0.00217, '2024-01-01', NULL),
('KZT', 'EUR', 0.00198, '2024-01-01', NULL),
('KZT', 'RUB', 0.19231, '2024-01-01', NULL),
('USD', 'EUR', 0.91, '2024-01-01', NULL),
('EUR', 'USD', 1.10, '2024-01-01', NULL),
('USD', 'RUB', 88.50, '2024-01-01', NULL),
('RUB', 'USD', 0.01130, '2024-01-01', NULL),
('EUR', 'RUB', 97.35, '2024-01-01', NULL),
('RUB', 'EUR', 0.01027, '2024-01-01', NULL);

-- Insert Initial Transactions (10 records)
INSERT INTO transactions (from_account_id, to_account_id, amount, currency, exchange_rate, amount_kzt, type, status, completed_at, description) VALUES
(1, 3, 100000.00, 'KZT', 1.000000, 100000.00, 'transfer', 'completed', CURRENT_TIMESTAMP, 'Payment for services'),
(2, 7, 50.00, 'USD', 460.50, 23025.00, 'transfer', 'completed', CURRENT_TIMESTAMP, 'International transfer'),
(5, 1, 500000.00, 'KZT', 1.000000, 500000.00, 'transfer', 'completed', CURRENT_TIMESTAMP, 'Rent payment'),
(7, 9, 100.00, 'USD', 460.50, 46050.00, 'transfer', 'completed', CURRENT_TIMESTAMP, 'Business payment'),
(9, 11, 50000.00, 'KZT', 1.000000, 50000.00, 'transfer', 'completed', CURRENT_TIMESTAMP, 'Salary advance'),
(11, 13, 200000.00, 'KZT', 1.000000, 200000.00, 'transfer', 'completed', CURRENT_TIMESTAMP, 'Monthly payment'),
(13, 14, 75000.00, 'KZT', 1.000000, 75000.00, 'transfer', 'completed', CURRENT_TIMESTAMP, 'Personal transfer'),
(4, 10, 100.00, 'EUR', 505.75, 50575.00, 'transfer', 'completed', CURRENT_TIMESTAMP, 'Euro transfer'),
(8, 1, 10000.00, 'RUB', 5.20, 52000.00, 'transfer', 'completed', CURRENT_TIMESTAMP, 'Ruble payment'),
(12, 2, 200.00, 'USD', 460.50, 92100.00, 'transfer', 'failed', NULL, 'Insufficient balance test');

-- ========================================
-- SECTION 3: TASK 1 - PROCESS_TRANSFER FUNCTION
-- ========================================

CREATE OR REPLACE FUNCTION process_transfer(
    p_from_account_number VARCHAR,
    p_to_account_number VARCHAR,
    p_amount DECIMAL,
    p_currency VARCHAR,
    p_description TEXT
) RETURNS TABLE (
    success BOOLEAN,
    error_code VARCHAR,
    error_message TEXT,
    transaction_id INT
) AS $$
DECLARE
    v_from_account_id INT;
    v_to_account_id INT;
    v_from_customer_id INT;
    v_from_balance DECIMAL;
    v_from_currency VARCHAR;
    v_to_currency VARCHAR;
    v_customer_status VARCHAR;
    v_daily_limit DECIMAL;
    v_today_total DECIMAL;
    v_exchange_rate DECIMAL;
    v_amount_kzt DECIMAL;
    v_converted_amount DECIMAL;
    v_transaction_id INT;
    v_from_is_active BOOLEAN;
    v_to_is_active BOOLEAN;
BEGIN
    BEGIN
        -- Validate input parameters
        IF p_amount <= 0 THEN
            RETURN QUERY SELECT false, 'ERR_001', 'Amount must be positive', NULL::INT;
            RETURN;
        END IF;

        IF p_from_account_number = p_to_account_number THEN
            RETURN QUERY SELECT false, 'ERR_002', 'Cannot transfer to the same account', NULL::INT;
            RETURN;
        END IF;

        -- Lock and fetch FROM account
        SELECT a.account_id, a.customer_id, a.balance, a.currency, a.is_active
        INTO v_from_account_id, v_from_customer_id, v_from_balance, v_from_currency, v_from_is_active
        FROM accounts a
        WHERE a.account_number = p_from_account_number
        FOR UPDATE;

        IF v_from_account_id IS NULL THEN
            RETURN QUERY SELECT false, 'ERR_003', 'Source account not found', NULL::INT;
            RETURN;
        END IF;

        IF NOT v_from_is_active THEN
            RETURN QUERY SELECT false, 'ERR_004', 'Source account is not active', NULL::INT;
            RETURN;
        END IF;

        -- Lock and fetch TO account
        SELECT a.account_id, a.currency, a.is_active
        INTO v_to_account_id, v_to_currency, v_to_is_active
        FROM accounts a
        WHERE a.account_number = p_to_account_number
        FOR UPDATE;

        IF v_to_account_id IS NULL THEN
            RETURN QUERY SELECT false, 'ERR_005', 'Destination account not found', NULL::INT;
            RETURN;
        END IF;

        IF NOT v_to_is_active THEN
            RETURN QUERY SELECT false, 'ERR_006', 'Destination account is not active', NULL::INT;
            RETURN;
        END IF;

        -- Check customer status
        SELECT c.status, c.daily_limit_kzt
        INTO v_customer_status, v_daily_limit
        FROM customers c
        WHERE c.customer_id = v_from_customer_id;

        IF v_customer_status != 'active' THEN
            RETURN QUERY SELECT false, 'ERR_007', 'Customer status is ' || v_customer_status || ', not active', NULL::INT;
            RETURN;
        END IF;

        -- Check if amount is in source currency
        IF p_currency != v_from_currency THEN
            RETURN QUERY SELECT false, 'ERR_008', 'Transfer currency must match source account currency', NULL::INT;
            RETURN;
        END IF;

        -- Check sufficient balance
        IF v_from_balance < p_amount THEN
            RETURN QUERY SELECT false, 'ERR_009',
                FORMAT('Insufficient balance. Available: %s %s, Required: %s %s',
                    v_from_balance, v_from_currency, p_amount, p_currency),
                NULL::INT;
            RETURN;
        END IF;

        -- Convert amount to KZT for limit checking
        IF p_currency = 'KZT' THEN
            v_amount_kzt := p_amount;
        ELSE
            SELECT rate INTO v_exchange_rate
            FROM exchange_rates
            WHERE from_currency = p_currency
              AND to_currency = 'KZT'
              AND valid_from <= CURRENT_TIMESTAMP
              AND (valid_to IS NULL OR valid_to > CURRENT_TIMESTAMP)
            LIMIT 1;

            IF v_exchange_rate IS NULL THEN
                RETURN QUERY SELECT false, 'ERR_010', 'Exchange rate not available for ' || p_currency || ' to KZT', NULL::INT;
                RETURN;
            END IF;

            v_amount_kzt := p_amount * v_exchange_rate;
        END IF;

        -- Check daily limit
        SELECT COALESCE(SUM(amount_kzt), 0)
        INTO v_today_total
        FROM transactions
        WHERE from_account_id = v_from_account_id
          AND DATE(created_at) = CURRENT_DATE
          AND status = 'completed';

        IF (v_today_total + v_amount_kzt) > v_daily_limit THEN
            RETURN QUERY SELECT false, 'ERR_011',
                FORMAT('Daily limit exceeded. Limit: %s KZT, Used today: %s KZT, Attempted: %s KZT',
                    v_daily_limit, v_today_total, v_amount_kzt),
                NULL::INT;
            RETURN;
        END IF;

        -- Currency conversion for destination account
        IF v_from_currency != v_to_currency THEN
            SELECT rate INTO v_exchange_rate
            FROM exchange_rates
            WHERE from_currency = v_from_currency
              AND to_currency = v_to_currency
              AND valid_from <= CURRENT_TIMESTAMP
              AND (valid_to IS NULL OR valid_to > CURRENT_TIMESTAMP)
            LIMIT 1;

            IF v_exchange_rate IS NULL THEN
                RETURN QUERY SELECT false, 'ERR_012',
                    'Exchange rate not available for ' || v_from_currency || ' to ' || v_to_currency,
                    NULL::INT;
                RETURN;
            END IF;

            v_converted_amount := p_amount * v_exchange_rate;
        ELSE
            v_exchange_rate := 1.000000;
            v_converted_amount := p_amount;
        END IF;

        -- Create savepoint for transaction record
        SAVEPOINT before_transaction;

        -- Insert transaction record
        INSERT INTO transactions (
            from_account_id, to_account_id, amount, currency,
            exchange_rate, amount_kzt, type, status, description
        ) VALUES (
            v_from_account_id, v_to_account_id, p_amount, p_currency,
            v_exchange_rate, v_amount_kzt, 'transfer', 'pending', p_description
        ) RETURNING transactions.transaction_id INTO v_transaction_id;

        -- Update balances
        UPDATE accounts
        SET balance = balance - p_amount
        WHERE account_id = v_from_account_id;

        UPDATE accounts
        SET balance = balance + v_converted_amount
        WHERE account_id = v_to_account_id;

        -- Mark transaction as completed
        UPDATE transactions
        SET status = 'completed', completed_at = CURRENT_TIMESTAMP
        WHERE transaction_id = v_transaction_id;

        -- Log to audit
        INSERT INTO audit_log (table_name, record_id, action, new_values, ip_address)
        VALUES ('transactions', v_transaction_id, 'INSERT',
                jsonb_build_object(
                    'from_account', p_from_account_number,
                    'to_account', p_to_account_number,
                    'amount', p_amount,
                    'currency', p_currency,
                    'status', 'completed'
                ),
                inet_client_addr());

        RETURN QUERY SELECT true, 'SUCCESS', 'Transfer completed successfully', v_transaction_id;

    EXCEPTION WHEN OTHERS THEN
        ROLLBACK TO SAVEPOINT before_transaction;

        -- Log failed attempt
        INSERT INTO audit_log (table_name, record_id, action, new_values, ip_address)
        VALUES ('transactions', 0, 'INSERT',
                jsonb_build_object(
                    'error', SQLERRM,
                    'from_account', p_from_account_number,
                    'to_account', p_to_account_number,
                    'amount', p_amount,
                    'status', 'failed'
                ),
                inet_client_addr());

        RETURN QUERY SELECT false, 'ERR_999', 'Internal error: ' || SQLERRM, NULL::INT;
    END;
END;
$$ LANGUAGE plpgsql;

-- ========================================
-- SECTION 4: TASK 2 - VIEWS FOR REPORTING
-- ========================================

-- VIEW 1: Customer Balance Summary
CREATE OR REPLACE VIEW customer_balance_summary AS
WITH account_balances AS (
    SELECT
        c.customer_id,
        c.full_name,
        c.iin,
        c.daily_limit_kzt,
        a.account_number,
        a.currency,
        a.balance,
        CASE
            WHEN a.currency = 'KZT' THEN a.balance
            ELSE a.balance * COALESCE(
                (SELECT rate FROM exchange_rates
                 WHERE from_currency = a.currency
                   AND to_currency = 'KZT'
                   AND valid_from <= CURRENT_TIMESTAMP
                   AND (valid_to IS NULL OR valid_to > CURRENT_TIMESTAMP)
                 LIMIT 1), 0)
        END AS balance_kzt
    FROM customers c
    JOIN accounts a ON c.customer_id = a.customer_id
    WHERE a.is_active = true
),
daily_usage AS (
    SELECT
        a.customer_id,
        COALESCE(SUM(t.amount_kzt), 0) AS today_spent_kzt
    FROM accounts a
    LEFT JOIN transactions t ON a.account_id = t.from_account_id
        AND DATE(t.created_at) = CURRENT_DATE
        AND t.status = 'completed'
    GROUP BY a.customer_id
),
customer_totals AS (
    SELECT
        customer_id,
        full_name,
        iin,
        daily_limit_kzt,
        SUM(balance_kzt) AS total_balance_kzt,
        COUNT(*) AS account_count
    FROM account_balances
    GROUP BY customer_id, full_name, iin, daily_limit_kzt
)
SELECT
    ct.customer_id,
    ct.full_name,
    ct.iin,
    ct.account_count,
    ROUND(ct.total_balance_kzt, 2) AS total_balance_kzt,
    ROUND(ct.daily_limit_kzt, 2) AS daily_limit_kzt,
    ROUND(COALESCE(du.today_spent_kzt, 0), 2) AS today_spent_kzt,
    ROUND(
        (COALESCE(du.today_spent_kzt, 0) / NULLIF(ct.daily_limit_kzt, 0)) * 100,
        2
    ) AS daily_limit_utilization_pct,
    ROW_NUMBER() OVER (ORDER BY ct.total_balance_kzt DESC) AS balance_rank,
    RANK() OVER (ORDER BY ct.total_balance_kzt DESC) AS balance_rank_with_ties
FROM customer_totals ct
LEFT JOIN daily_usage du ON ct.customer_id = du.customer_id
ORDER BY ct.total_balance_kzt DESC;

-- VIEW 2: Daily Transaction Report
CREATE OR REPLACE VIEW daily_transaction_report AS
WITH daily_stats AS (
    SELECT
        DATE(created_at) AS transaction_date,
        type AS transaction_type,
        status,
        COUNT(*) AS transaction_count,
        SUM(amount_kzt) AS total_volume_kzt,
        AVG(amount_kzt) AS avg_amount_kzt,
        MIN(amount_kzt) AS min_amount_kzt,
        MAX(amount_kzt) AS max_amount_kzt
    FROM transactions
    WHERE status = 'completed'
    GROUP BY DATE(created_at), type, status
),
running_totals AS (
    SELECT
        transaction_date,
        transaction_type,
        status,
        transaction_count,
        ROUND(total_volume_kzt, 2) AS total_volume_kzt,
        ROUND(avg_amount_kzt, 2) AS avg_amount_kzt,
        ROUND(min_amount_kzt, 2) AS min_amount_kzt,
        ROUND(max_amount_kzt, 2) AS max_amount_kzt,
        SUM(total_volume_kzt) OVER (
            PARTITION BY transaction_type
            ORDER BY transaction_date
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS running_total_kzt,
        LAG(total_volume_kzt) OVER (
            PARTITION BY transaction_type
            ORDER BY transaction_date
        ) AS prev_day_volume_kzt
    FROM daily_stats
)
SELECT
    transaction_date,
    transaction_type,
    status,
    transaction_count,
    total_volume_kzt,
    avg_amount_kzt,
    min_amount_kzt,
    max_amount_kzt,
    ROUND(running_total_kzt, 2) AS running_total_kzt,
    CASE
        WHEN prev_day_volume_kzt IS NULL OR prev_day_volume_kzt = 0 THEN NULL
        ELSE ROUND(
            ((total_volume_kzt - prev_day_volume_kzt) / prev_day_volume_kzt) * 100,
            2
        )
    END AS day_over_day_growth_pct
FROM running_totals
ORDER BY transaction_date DESC, transaction_type;

-- VIEW 3: Suspicious Activity View
CREATE VIEW suspicious_activity_view WITH (security_barrier = true) AS
WITH large_transactions AS (
    SELECT
        t.transaction_id,
        t.from_account_id,
        t.to_account_id,
        t.amount,
        t.currency,
        t.amount_kzt,
        t.created_at,
        c.customer_id,
        c.full_name,
        c.iin,
        'LARGE_TRANSACTION' AS flag_type,
        'Transaction over 5,000,000 KZT' AS flag_reason
    FROM transactions t
    JOIN accounts a ON t.from_account_id = a.account_id
    JOIN customers c ON a.customer_id = c.customer_id
    WHERE t.amount_kzt > 5000000
      AND t.status = 'completed'
),
high_frequency AS (
    SELECT
        t.transaction_id,
        t.from_account_id,
        t.to_account_id,
        t.amount,
        t.currency,
        t.amount_kzt,
        t.created_at,
        c.customer_id,
        c.full_name,
        c.iin,
        'HIGH_FREQUENCY' AS flag_type,
        FORMAT('Customer made %s transactions in 1 hour', txn_count) AS flag_reason
    FROM transactions t
    JOIN accounts a ON t.from_account_id = a.account_id
    JOIN customers c ON a.customer_id = c.customer_id
    JOIN (
        SELECT
            from_account_id,
            DATE_TRUNC('hour', created_at) AS hour_bucket,
            COUNT(*) AS txn_count
        FROM transactions
        WHERE status = 'completed'
        GROUP BY from_account_id, DATE_TRUNC('hour', created_at)
        HAVING COUNT(*) > 10
    ) freq ON t.from_account_id = freq.from_account_id
         AND DATE_TRUNC('hour', t.created_at) = freq.hour_bucket
),
rapid_sequential AS (
    SELECT
        t1.transaction_id,
        t1.from_account_id,
        t1.to_account_id,
        t1.amount,
        t1.currency,
        t1.amount_kzt,
        t1.created_at,
        c.customer_id,
        c.full_name,
        c.iin,
        'RAPID_SEQUENTIAL' AS flag_type,
        FORMAT('Transaction within %s seconds of previous',
            EXTRACT(EPOCH FROM (t1.created_at - t2.created_at))::INT) AS flag_reason
    FROM transactions t1
    JOIN transactions t2 ON t1.from_account_id = t2.from_account_id
        AND t1.transaction_id != t2.transaction_id
        AND t1.created_at > t2.created_at
        AND t1.created_at <= t2.created_at + INTERVAL '1 minute'
    JOIN accounts a ON t1.from_account_id = a.account_id
    JOIN customers c ON a.customer_id = c.customer_id
    WHERE t1.status = 'completed'
      AND t2.status = 'completed'
)
SELECT * FROM large_transactions
UNION ALL
SELECT * FROM high_frequency
UNION ALL
SELECT * FROM rapid_sequential
ORDER BY created_at DESC;

-- ========================================
-- SECTION 5: TASK 3 - INDEXES
-- ========================================

-- INDEX 1: B-tree composite index for transaction lookups
CREATE INDEX idx_transactions_account_date_status
ON transactions(from_account_id, created_at DESC, status)
WHERE status = 'completed';

-- INDEX 2: Hash index for exact account number lookups
CREATE INDEX idx_accounts_number_hash
ON accounts USING HASH (account_number);

-- INDEX 3: Partial index for active accounts only
CREATE INDEX idx_accounts_active_customer
ON accounts(customer_id, currency, balance)
WHERE is_active = true;

-- INDEX 4: Expression index for case-insensitive email search
CREATE INDEX idx_customers_email_lower
ON customers(LOWER(email));

-- INDEX 5: GIN index for JSONB audit log queries
CREATE INDEX idx_audit_log_new_values_gin
ON audit_log USING GIN (new_values);

-- INDEX 6: Covering index for exchange rate lookups
CREATE INDEX idx_exchange_rates_lookup
ON exchange_rates(from_currency, to_currency, valid_from DESC)
INCLUDE (rate);

-- INDEX 7: B-tree index for customer status filtering
CREATE INDEX idx_customers_status_limit
ON customers(status, daily_limit_kzt)
WHERE status = 'active';

-- ========================================
-- SECTION 6: TASK 4 - BATCH PROCESSING
-- ========================================

---
CREATE OR REPLACE FUNCTION process_salary_batch(
    p_company_account_number VARCHAR,
    p_payments JSONB
) RETURNS TABLE (
    success BOOLEAN,
    successful_count INT,
    failed_count INT,
    failed_details JSONB,
    total_processed_kzt DECIMAL,
    message TEXT
) AS $$
DECLARE
    v_company_account_id INT;
    v_company_balance DECIMAL;
    v_company_currency VARCHAR;
    v_total_batch_amount DECIMAL := 0;
    v_payment JSONB;
    v_recipient_iin VARCHAR;
    v_amount DECIMAL;
    v_description TEXT;
    v_recipient_account_id INT;
    v_recipient_account_number VARCHAR;
    v_success_count INT := 0;
    v_fail_count INT := 0;
    v_failed_array JSONB := '[]'::JSONB;
    v_exchange_rate DECIMAL;
    v_amount_kzt DECIMAL;
    v_total_processed_kzt DECIMAL := 0;
    v_lock_key BIGINT;
BEGIN
    BEGIN
        -- Generate advisory lock key from account number hash
        v_lock_key := ('x' || substr(md5(p_company_account_number), 1, 16))::bit(64)::bigint;

        -- Acquire advisory lock to prevent concurrent batch processing
        IF NOT pg_try_advisory_lock(v_lock_key) THEN
            RETURN QUERY SELECT
                false, 0, 0, '[]'::JSONB, 0::DECIMAL,
                'Another batch is currently being processed for this company account';
            RETURN;
        END IF;

        -- Validate company account and lock it
        SELECT a.account_id, a.balance, a.currency
        INTO v_company_account_id, v_company_balance, v_company_currency
        FROM accounts a
        WHERE a.account_number = p_company_account_number
          AND a.is_active = true
        FOR UPDATE;

        IF v_company_account_id IS NULL THEN
            PERFORM pg_advisory_unlock(v_lock_key);
            RETURN QUERY SELECT
                false, 0, 0, '[]'::JSONB, 0::DECIMAL,
                'Company account not found or inactive';
            RETURN;
        END IF;

        -- Calculate total batch amount in company currency
        FOR v_payment IN SELECT * FROM jsonb_array_elements(p_payments)
        LOOP
            v_amount := (v_payment->>'amount')::DECIMAL;

            IF v_company_currency = 'KZT' THEN
                v_total_batch_amount := v_total_batch_amount + v_amount;
            ELSE
                -- Convert to company currency for validation
                SELECT rate INTO v_exchange_rate
                FROM exchange_rates
                WHERE from_currency = 'KZT'
                  AND to_currency = v_company_currency
                  AND valid_from <= CURRENT_TIMESTAMP
                  AND (valid_to IS NULL OR valid_to > CURRENT_TIMESTAMP)
                LIMIT 1;

                IF v_exchange_rate IS NULL THEN
                    PERFORM pg_advisory_unlock(v_lock_key);
                    RETURN QUERY SELECT
                        false, 0, 0, '[]'::JSONB, 0::DECIMAL,
                        'Exchange rate not available for validation';
                    RETURN;
                END IF;

                v_total_batch_amount := v_total_batch_amount + (v_amount * v_exchange_rate);
            END IF;
        END LOOP;

        -- Check if company has sufficient balance
        IF v_company_balance < v_total_batch_amount THEN
            PERFORM pg_advisory_unlock(v_lock_key);
            RETURN QUERY SELECT
                false, 0, 0, '[]'::JSONB, 0::DECIMAL,
                FORMAT('Insufficient balance. Required: %s %s, Available: %s %s',
                    v_total_batch_amount, v_company_currency,
                    v_company_balance, v_company_currency);
            RETURN;
        END IF;

        -- Process each payment
        FOR v_payment IN SELECT * FROM jsonb_array_elements(p_payments)
        LOOP
            SAVEPOINT individual_payment;

            BEGIN
                v_recipient_iin := v_payment->>'iin';
                v_amount := (v_payment->>'amount')::DECIMAL;
                v_description := COALESCE(v_payment->>'description', 'Salary payment');

                -- Find recipient's primary KZT account
                SELECT a.account_id, a.account_number
                INTO v_recipient_account_id, v_recipient_account_number
                FROM accounts a
                JOIN customers c ON a.customer_id = c.customer_id
                WHERE c.iin = v_recipient_iin
                  AND a.currency = 'KZT'
                  AND a.is_active = true
                ORDER BY a.account_id
                LIMIT 1
                FOR UPDATE;

                IF v_recipient_account_id IS NULL THEN
                    RAISE EXCEPTION 'Recipient with IIN % not found or has no active KZT account', v_recipient_iin;
                END IF;

                -- Calculate amount in KZT
                IF v_company_currency = 'KZT' THEN
                    v_amount_kzt := v_amount;
                    v_exchange_rate := 1.000000;
                ELSE
                    SELECT rate INTO v_exchange_rate
                    FROM exchange_rates
                    WHERE from_currency = v_company_currency
                      AND to_currency = 'KZT'
                      AND valid_from <= CURRENT_TIMESTAMP
                      AND (valid_to IS NULL OR valid_to > CURRENT_TIMESTAMP)
                    LIMIT 1;

                    v_amount_kzt := v_amount * v_exchange_rate;
                END IF;

                -- Insert transaction (bypass daily limit for salary)
                INSERT INTO transactions (
                    from_account_id, to_account_id, amount, currency,
                    exchange_rate, amount_kzt, type, status,
                    completed_at, description
                ) VALUES (
                    v_company_account_id, v_recipient_account_id,
                    v_amount, v_company_currency,
                    v_exchange_rate, v_amount_kzt, 'transfer', 'completed',
                    CURRENT_TIMESTAMP, v_description || ' [SALARY_BATCH]'
                );

                -- Update balances
                UPDATE accounts
                SET balance = balance - v_amount
                WHERE account_id = v_company_account_id;

                UPDATE accounts
                SET balance = balance + v_amount_kzt
                WHERE account_id = v_recipient_account_id;

                -- Log successful payment
                INSERT INTO audit_log (table_name, record_id, action, new_values)
                VALUES ('transactions', 0, 'INSERT',
                    jsonb_build_object(
                        'iin', v_recipient_iin,
                        'amount', v_amount,
                        'amount_kzt', v_amount_kzt,
                        'status', 'success',
                        'type', 'salary_batch'
                    ));

                v_success_count := v_success_count + 1;
                v_total_processed_kzt := v_total_processed_kzt + v_amount_kzt;

            EXCEPTION WHEN OTHERS THEN
                ROLLBACK TO SAVEPOINT individual_payment;

                v_fail_count := v_fail_count + 1;
                v_failed_array := v_failed_array || jsonb_build_object(
                    'iin', v_recipient_iin,
                    'amount', v_amount,
                    'error', SQLERRM
                );

                -- Log failed payment
                INSERT INTO audit_log (table_name, record_id, action, new_values)
                VALUES ('transactions', 0, 'INSERT',
                    jsonb_build_object(
                        'iin', v_recipient_iin,
                        'amount', v_amount,
                        'status', 'failed',
                        'error', SQLERRM,
                        'type', 'salary_batch'
                    ));
            END;
        END LOOP;

        -- Release advisory lock
        PERFORM pg_advisory_unlock(v_lock_key);

        -- Return results
        RETURN QUERY SELECT
            true,
            v_success_count,
            v_fail_count,
            v_failed_array,
            v_total_processed_kzt,
            FORMAT('Batch processed: %s successful, %s failed',
                v_success_count, v_fail_count);

    EXCEPTION WHEN OTHERS THEN
        PERFORM pg_advisory_unlock(v_lock_key);
        RAISE;
    END;
END;
$$ LANGUAGE plpgsql;

-- ========================================
-- MATERIALIZED VIEW: Salary Batch Summary
-- ========================================
CREATE MATERIALIZED VIEW salary_batch_summary AS
SELECT
    DATE(changed_at) AS batch_date,
    COUNT(*) FILTER (WHERE new_values->>'status' = 'success') AS successful_payments,
    COUNT(*) FILTER (WHERE new_values->>'status' = 'failed') AS failed_payments,
    SUM((new_values->>'amount_kzt')::DECIMAL) FILTER (WHERE new_values->>'status' = 'success') AS total_paid_kzt,
    COUNT(DISTINCT new_values->>'iin') AS unique_recipients
FROM audit_log
WHERE table_name = 'transactions'
  AND new_values->>'type' = 'salary_batch'
GROUP BY DATE(changed_at)
ORDER BY batch_date DESC
WITH DATA;

CREATE UNIQUE INDEX idx_salary_batch_summary_date
ON salary_batch_summary(batch_date);
```

---

## 6. Test Cases
```sql
-- ========================================
-- TEST CASES
-- ========================================

-- TEST 1: Successful transfer (same currency)
SELECT * FROM process_transfer(
    'KZ01125KZT0000001234',  -- From: Nurlan (KZT account)
    'KZ03125KZT0000005678',  -- To: Asel (KZT account)
    100000.00,
    'KZT',
    'Test transfer - same currency'
);

-- TEST 2: Successful transfer with currency conversion
SELECT * FROM process_transfer(
    'KZ02125USD0000001234',  -- From: Nurlan (USD account)
    'KZ03125KZT0000005678',  -- To: Asel (KZT account)
    100.00,
    'USD',
    'Test transfer - USD to KZT conversion'
);

-- TEST 3: Insufficient balance
SELECT * FROM process_transfer(
    'KZ14125KZT0000005555',  -- From: Laura (low balance)
    'KZ03125KZT0000005678',  -- To: Asel
    5000000.00,
    'KZT',
    'Test - insufficient balance'
);

-- TEST 4: Blocked customer
SELECT * FROM process_transfer(
    'KZ06125KZT0000003456',  -- From: Zhanna (blocked customer)
    'KZ03125KZT0000005678',  -- To: Asel
    10000.00,
    'KZT',
    'Test - blocked customer'
);

-- TEST 5: Daily limit exceeded
-- First, use up most of the daily limit
SELECT * FROM process_transfer(
    'KZ01125KZT0000001234',
    'KZ03125KZT0000005678',
    10000000.00,
    'KZT',
    'Large transfer to test limit'
);
-- Then try another large transfer (should fail)
SELECT * FROM process_transfer(
    'KZ01125KZT0000001234',
    'KZ03125KZT0000005678',
    5000000.00,
    'KZT',
    'Test - exceeds daily limit'
);

-- TEST 6: Non-existent account
SELECT * FROM process_transfer(
    'KZ99999KZT9999999999',  -- Non-existent
    'KZ03125KZT0000005678',
    100000.00,
    'KZT',
    'Test - invalid account'
);

-- TEST 7: Negative amount
SELECT * FROM process_transfer(
    'KZ01125KZT0000001234',
    'KZ03125KZT0000005678',
    -100.00,
    'KZT',
    'Test - negative amount'
);

-- TEST 8: Transfer to same account
SELECT * FROM process_transfer(
    'KZ01125KZT0000001234',
    'KZ01125KZT0000001234',  -- Same account
    100.00,
    'KZT',
    'Test - same account'
);

-- TEST 9: Currency mismatch
SELECT * FROM process_transfer(
    'KZ01125KZT0000001234',  -- KZT account
    'KZ03125KZT0000005678',
    100.00,
    'USD',  -- Trying to send USD from KZT account
    'Test - currency mismatch'
);

-- TEST 10: Successful salary batch
SELECT * FROM process_salary_batch(
    'KZ13125KZT0000004444',  -- Company account (Timur)
    '[
        {"iin": "123456789012", "amount": 500000, "description": "Monthly salary - Nurlan"},
        {"iin": "234567890123", "amount": 450000, "description": "Monthly salary - Asel"},
        {"iin": "678901234567", "amount": 400000, "description": "Monthly salary - Aigerim"}
    ]'::JSONB
);

-- TEST 11: Batch with insufficient balance
SELECT * FROM process_salary_batch(
    'KZ14125KZT0000005555',  -- Laura's account (low balance)
    '[
        {"iin": "123456789012", "amount": 5000000},
        {"iin": "234567890123", "amount": 5000000}
    ]'::JSONB
);

-- TEST 12: Batch with some invalid recipients
SELECT * FROM process_salary_batch(
    'KZ13125KZT0000004444',
    '[
        {"iin": "123456789012", "amount": 300000, "description": "Valid recipient"},
        {"iin": "999999999999", "amount": 300000, "description": "Invalid IIN"},
        {"iin": "234567890123", "amount": 300000, "description": "Valid recipient"}
    ]'::JSONB
);

-- ========================================
-- VIEW TESTS
-- ========================================

-- Test customer_balance_summary view
SELECT * FROM customer_balance_summary
LIMIT 5;

-- Test daily_transaction_report view
SELECT * FROM daily_transaction_report
WHERE transaction_date >= CURRENT_DATE - INTERVAL '7 days';

-- Test suspicious_activity_view
SELECT * FROM suspicious_activity_view
LIMIT 10;

-- ========================================
-- CONCURRENT TRANSACTION TEST
-- ========================================
/*
Open two psql sessions and run these simultaneously:

-- Session 1:
BEGIN;
SELECT * FROM accounts WHERE account_number = 'KZ01125KZT0000001234' FOR UPDATE;
-- Wait here... (don't commit yet)

-- Session 2 (will wait):
SELECT * FROM process_transfer(
    'KZ01125KZT0000001234',
    'KZ03125KZT0000005678',
    10000.00,
    'KZT',
    'Concurrent test'
);

-- Session 1: Now COMMIT
COMMIT;

-- Session 2 will now proceed
*/

-- ========================================
-- INDEX PERFORMANCE COMPARISON
-- ========================================

-- Before indexes (disable them temporarily)
DROP INDEX IF EXISTS idx_transactions_account_date_status;
EXPLAIN ANALYZE
SELECT SUM(amount_kzt)
FROM transactions
WHERE from_account_id = 1
  AND DATE(created_at) = CURRENT_DATE
  AND status = 'completed';

-- After indexes (recreate and test)
CREATE INDEX idx_transactions_account_date_status
ON transactions(from_account_id, created_at DESC, status)
WHERE status = 'completed';

EXPLAIN ANALYZE
SELECT SUM(amount_kzt)
FROM transactions
WHERE from_account_id = 1
  AND DATE(created_at) = CURRENT_DATE
  AND status = 'completed';

-- Refresh materialized view
REFRESH MATERIALIZED VIEW salary_batch_summary;

-- Check batch summary
SELECT * FROM salary_batch_summary;
```

---

## 7. Documentation

### Design Decisions

**1. Transaction Isolation & ACID Compliance:**
- Used `SELECT ... FOR UPDATE` to lock account rows and prevent race conditions
- Implemented `SAVEPOINT` for partial rollback in batch processing
- All balance updates happen atomically within a single transaction
- Used advisory locks in batch processing to prevent concurrent processing of same company account

**2. Currency Conversion:**
- Exchange rates stored with validity periods for historical accuracy
- Conversion happens automatically based on account currencies
- All amounts converted to KZT for daily limit checking (regulatory requirement)

**3. Error Handling:**
- Custom error codes (ERR_001, ERR_002, etc.) for programmatic error handling
- Detailed error messages for user feedback
- All errors logged to audit_log including failed attempts
- Batch processing continues on individual failures (using SAVEPOINT)

**4. Security:**
- `suspicious_activity_view` uses `security_barrier = true` to prevent information leakage
- Row-level locking prevents concurrent modification
- Advisory locks prevent batch processing conflicts
- All operations logged with user and IP address

**5. Performance Optimizations:**
- **B-tree composite index**: Speeds up daily limit checks (most frequent query)
- **Hash index**: O(1) lookups for exact account number matches
- **Partial index**: Reduces index size by excluding inactive accounts
- **Expression index**: Enables case-insensitive email search without LOWER() in query
- **GIN index**: Enables fast JSONB queries in audit log
- **Covering index**: Includes rate value to avoid table lookup

**6. View Design:**
- `customer_balance_summary`: Uses CTEs for readability, window functions for ranking
- `daily_transaction_report`: Calculates running totals and day-over-day growth
- `suspicious_activity_view`: Uses UNION ALL to combine different fraud detection rules
- Materialized view for batch summary: Improves reporting performance, refreshed after batch

---

## 8. Expected Results

### Successful Transfer Output: