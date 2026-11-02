/*
===============================================================================
Author Performance Index Analysis
===============================================================================
Purpose:
    - To calculate Author Performance Index.
    - To track performance of authors.
    - Useful for identifying long-term reader Loyalty.

SQL Functions Used:
    - Window Functions: PERCENTILE_CONT() OVER(), LOG()
===============================================================================
*/

-- Calculate the Author Performance Index
WITH CTE_TPI1 AS
(
SELECT
    b.work_id,
    b.author,
    e.total_reader_engagement,
    c.total_average_rating,
    CONVERT(DECIMAL(10,2),
        (c.total_1_star_ratings + c.total_2_star_ratings) * 1.0 /
        NULLIF(
            c.total_5_star_ratings + c.total_4_star_ratings + c.total_3_star_ratings,
            0
        )
    ) AS contention_score
 FROM gold.dim_books b
 LEFT JOIN gold.fact_engagements e
 ON b.work_id = e.work_id
 LEFT JOIN gold.fact_controversy c
 ON b.work_id = c.work_id
 WHERE publication_year <= 2017
)
, CTE_TPI2 AS
(
SELECT
    work_id,
    author,
    LOG(total_reader_engagement *
        ABS((1 - contention_score))
    ) AS performance_index
FROM CTE_TPI1
)
SELECT DISTINCT
    author,
    ROUND(PERCENTILE_CONT(0.5)
    WITHIN GROUP (ORDER BY performance_index)
    OVER (PARTITION BY author), 2) AS total_performance_index
FROM CTE_TPI2
ORDER BY total_performance_index DESC
