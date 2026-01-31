USE sakila; 

-- Step 1: Create a View
DROP VIEW IF EXISTS v_customer_rental_summary;
CREATE VIEW v_customer_rental_summary AS
SELECT
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    c.email,
    COUNT(r.rental_id) AS rental_count
FROM customer AS c
LEFT JOIN rental AS r
    ON c.customer_id = r.customer_id
GROUP BY
    c.customer_id,
    c.first_name,
    c.last_name,
    c.email;


-- Step 2: Create a Temporary Table
DROP TEMPORARY TABLE IF EXISTS tmp_customer_payment_summary;

CREATE TEMPORARY TABLE tmp_customer_payment_summary AS
SELECT
    v.customer_id,
    ROUND(SUM(p.amount), 2) AS total_paid
FROM v_customer_rental_summary AS v
LEFT JOIN payment AS p
    ON v.customer_id = p.customer_id
GROUP BY
    v.customer_id;

-- Step 3: Create a CTE and the Customer Summary Report
WITH customer_summary AS (
    SELECT
        v.customer_name,
        v.email,
        v.rental_count,
        t.total_paid
    FROM v_customer_rental_summary AS v
    JOIN tmp_customer_payment_summary AS t
        ON v.customer_id = t.customer_id
)
SELECT
    customer_name,
    email,
    rental_count,
    total_paid,
    ROUND(total_paid / NULLIF(rental_count, 0), 2) AS average_payment_per_rental
FROM customer_summary
ORDER BY total_paid DESC, rental_count DESC;