/*
===============================================================================
Reader Satisfaction Score Analysis
===============================================================================
Purpose:
    - To calculate Author Performance Index.
    - To track performance of authors.
    - Useful for identifying long-term reader Loyalty.

SQL Functions Used:
    - Window Functions: PERCENTILE_CONT() OVER(), AVG() OVER()
===============================================================================
*/
WITH CTE_RSS AS
(
SELECT DISTINCT
b.title,
c.total_ratings_count,
c.total_average_rating,
AVG(c.total_average_rating) OVER() AS overall_average,
PERCENTILE_CONT(0.75)
    WITHIN GROUP (ORDER BY c.total_ratings_count)
    OVER () AS minimum_rating_threshold
FROM gold.dim_books b
LEFT JOIN gold.fact_controversy c
ON b.work_id = c.work_id
WHERE publication_year <= 2017
 )
 SELECT
 title,
 ROUND((total_ratings_count/(total_ratings_count + minimum_rating_threshold)) * total_average_rating + 
 (minimum_rating_threshold/(total_ratings_count + minimum_rating_threshold)) * overall_average, 2) AS reader_satisfaction_score
 FROM CTE_RSS
 ORDER BY reader_satisfaction_score DESC
