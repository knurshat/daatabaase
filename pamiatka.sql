-- =====================================================
-- Lecture 10: Stored Procedures - Solutions
-- Database: dvdrental
-- =====================================================

-- =====================================================
-- Task 1: Basic Function Creation
-- =====================================================

-- Exercise 1.1: Simple Calculation Function
CREATE OR REPLACE FUNCTION calculate_discount(
    original_price NUMERIC,
    discount_percent NUMERIC
)
RETURNS NUMERIC
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN original_price - (original_price * discount_percent / 100);
END;
$$;

-- Test Task 1
SELECT calculate_discount(100, 15);     -- Should return 85
SELECT calculate_discount(250.50, 20);  -- Should return 200.40


-- =====================================================
-- Task 2: Working with OUT Parameters
-- =====================================================

-- Exercise 2.1: Film Statistics Function
CREATE OR REPLACE FUNCTION film_stats(
    p_rating VARCHAR,
    OUT total_films INTEGER,
    OUT avg_rental_rate NUMERIC
)
LANGUAGE plpgsql
AS $$
BEGIN
    SELECT
        COUNT(*)::INTEGER,
        AVG(rental_rate)::NUMERIC(5,2)
    INTO
        total_films,
        avg_rental_rate
    FROM
        film
    WHERE
        rating = p_rating;
END;
$$;

-- Test Task 2
SELECT * FROM film_stats('PG');
SELECT * FROM film_stats('R');


-- =====================================================
-- Task 3: Function Returning a Table
-- =====================================================

-- Exercise 3.1: Customer Rental History
CREATE OR REPLACE FUNCTION get_customer_rentals(p_customer_id INTEGER)
RETURNS TABLE(
    rental_date DATE,
    film_title VARCHAR,
    return_date DATE
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT
        r.rental_date::DATE,
        f.title::VARCHAR,
        r.return_date::DATE
    FROM
        rental r
        INNER JOIN inventory i ON r.inventory_id = i.inventory_id
        INNER JOIN film f ON i.film_id = f.film_id
    WHERE
        r.customer_id = p_customer_id
    ORDER BY
        r.rental_date DESC;
END;
$$;

-- Test Task 3
SELECT * FROM get_customer_rentals(1);
SELECT * FROM get_customer_rentals(5) LIMIT 5;


-- =====================================================
-- Task 4: Challenge - Function Overloading
-- =====================================================

-- Exercise 4.1: Overloaded Film Search
-- Version 1: Search by title pattern only
CREATE OR REPLACE FUNCTION search_films(p_title_pattern VARCHAR)
RETURNS TABLE(
    title VARCHAR,
    release_year INTEGER
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT
        f.title::VARCHAR,
        f.release_year::INTEGER
    FROM
        film f
    WHERE
        f.title LIKE p_title_pattern
    ORDER BY
        f.title;
END;
$$;

-- Version 2: Search by title pattern AND rating
CREATE OR REPLACE FUNCTION search_films(
    p_title_pattern VARCHAR,
    p_rating VARCHAR
)
RETURNS TABLE(
    title VARCHAR,
    release_year INTEGER,
    rating VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT
        f.title::VARCHAR,
        f.release_year::INTEGER,
        f.rating::VARCHAR
    FROM
        film f
    WHERE
        f.title LIKE p_title_pattern
        AND f.rating = p_rating
    ORDER BY
        f.title;
END;
$$;

-- Test Task 4
SELECT * FROM search_films('A%');
SELECT * FROM search_films('A%', 'PG');


-- =====================================================
-- Additional Test Queries
-- =====================================================

-- Show all created functions
SELECT
    routine_name,
    routine_type,
    data_type
FROM
    information_schema.routines
WHERE
    routine_schema = 'public'
    AND routine_name IN (
        'calculate_discount',
        'film_stats',
        'get_customer_rentals',
        'search_films'
    )
ORDER BY
    routine_name;


-- =====================================================
-- Drop functions if needed (for cleanup)
-- =====================================================
/*
DROP FUNCTION IF EXISTS calculate_discount(NUMERIC, NUMERIC);
DROP FUNCTION IF EXISTS film_stats(VARCHAR);
DROP FUNCTION IF EXISTS get_customer_rentals(INTEGER);
DROP FUNCTION IF EXISTS search_films(VARCHAR);
DROP FUNCTION IF EXISTS search_films(VARCHAR, VARCHAR);
*/