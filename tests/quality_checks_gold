/*
===============================================================================
Quality Checks
===============================================================================
Script Purpose:
    This script performs quality checks to validate the integrity, consistency, 
    and accuracy of the Gold Layer. These checks ensure:
    - Uniqueness of surrogate keys in dimension tables.
    - Referential integrity between fact and dimension tables.
    - Validation of relationships in the data model for analytical purposes.

Usage Notes:
    - Investigate and resolve any discrepancies found during the checks.
===============================================================================
*/

-- ====================================================================
-- Checking 'gold.dim_customers'
-- ====================================================================
-- Check for Uniqueness of Customer Key in gold.dim_customers
-- Expectation: No results 
SELECT 
    work_id,
    COUNT(*) AS duplicate_count
FROM gold.dim_books
GROUP BY work_id
HAVING COUNT(*) > 1;

-- ====================================================================
-- Checking 'gold.fact_all_reviews_summary'
-- ====================================================================
-- Check the data model connectivity between fact and dimension
SELECT * 
FROM gold.fact_all_reviews_summary a
LEFT JOIN gold.dim_books b
ON a.work_id = b.work_id
WHERE a.work_id IS NULL

-- ====================================================================
-- Checking 'gold.fact_normal_reviews_summary'
-- ====================================================================
-- Check the data model connectivity between fact and dimension
SELECT * 
FROM gold.fact_normal_reviews_summary n
LEFT JOIN gold.dim_books b
ON n.work_id = b.work_id
WHERE n.work_id IS NULL

-- ====================================================================
-- Checking 'gold.fact_authors'
-- ====================================================================
-- Check the data model connectivity between fact and dimension
SELECT * 
FROM gold.fact_authors a
LEFT JOIN gold.dim_books b
ON a.work_id = b.work_id
WHERE a.work_id IS NULL

-- ====================================================================
-- Checking 'gold.fact_satisfaction'
-- ====================================================================
-- Check the data model connectivity between fact and dimension
SELECT * 
FROM gold.fact_satisfaction s
LEFT JOIN gold.dim_books b
ON s.work_id = b.work_id
WHERE s.work_id IS NULL

-- ====================================================================
-- Checking 'gold.bridge_genres'
-- ====================================================================
-- Check the data model connectivity between fact and dimension
SELECT * 
FROM gold.bridge_genres g
LEFT JOIN gold.dim_books b
ON g.work_id = b.work_id
WHERE g.work_id IS NULL
