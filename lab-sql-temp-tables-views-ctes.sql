## In this exercise, you will create a customer summary report that summarizes key information about customers in the Sakila database, including their rental history and payment details. The report will be generated using 
## a combination of views, CTEs, and temporary tables.

USE sakila;

## Step 1: Create a View
## First, create a view that summarizes rental information for each customer. The view should include the customer's ID, name, email address, and total number of rentals (rental_count).

CREATE VIEW rental_info AS
SELECT  c.customer_id,
		CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
        c.email,
        COUNT(*) AS No_of_rentals
FROM customer c
JOIN rental r
	ON c.customer_id = r.customer_id
GROUP BY c.customer_id, c.first_name, c.email
ORDER BY No_of_rentals DESC;

## Step 2: Create a Temporary Table
## Next, create a Temporary Table that calculates the total amount paid by each customer (total_paid). The Temporary Table should use the rental summary view created in Step 1 to join with the payment table and 
## calculate the total amount paid by each customer.

CREATE TEMPORARY TABLE total_paid AS
SELECT  r.customer_id AS customer,
		SUM(amount) AS total_paid
FROM rental_info r
JOIN payment p
	ON r.customer_id = p.customer_id
GROUP BY r.customer_id
ORDER BY total_paid DESC;

## Step 3: Create a CTE and the Customer Summary Report
## Create a CTE that joins the rental summary View with the customer payment summary Temporary Table created in Step 2. The CTE should include the customer's name, email address, rental count, and total amount paid.

WITH cte_summary AS(
					SELECT  r.customer_name,
							r.email,
							r.no_of_rentals,
							t.total_paid
					FROM total_paid t
					JOIN rental_info r
						ON r.customer_id = t.customer
)
SELECT * FROM cte_summary;

## Next, using the CTE, create the query to generate the final customer summary report, which should include: customer name, email, rental_count, total_paid and average_payment_per_rental, this last column is a derived column from total_paid and rental_count.

WITH cte_summary AS(
					SELECT  r.customer_name,
							r.email,
							r.no_of_rentals,
							t.total_paid
					FROM total_paid t
					JOIN rental_info r
						ON r.customer_id = t.customer
)
SELECT  *, 
		ROUND(total_paid / no_of_rentals, 2) AS average_payment_per_rental
FROM cte_summary;