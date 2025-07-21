-- Remove duplicate customer records
DELETE FROM customers
WHERE customer_id NOT IN (
  SELECT MIN(customer_id)
  FROM customers
  GROUP BY email, phone
);

-- Standardize date format
SELECT
  customer_id,
  full_name,
  DATE_FORMAT(join_date, '%Y-%m-%d') AS clean_join_date
FROM customers;

##Added SQL script for cleaning duplicate customer records.
