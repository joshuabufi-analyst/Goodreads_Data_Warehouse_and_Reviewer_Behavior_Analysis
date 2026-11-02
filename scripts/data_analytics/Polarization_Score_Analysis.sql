/*
===============================================================================
Polarization Score Analysis
===============================================================================
Purpose:
    - To calculate Author Performance Index.
    - To track performance of authors.
    - Useful for identifying long-term reader Loyalty.

SQL Functions Used:
    - Window Functions: STDEV(), LOG()
===============================================================================
*/

WITH CTE_Corr AS
(
SELECT
b.work_id,
b.title,
c.english_total_ratings_count,
e.english_votes_count + e.english_comments_count AS influence_score,
c.english_total_review_length/e.english_review_text_count AS average_letter_per_reviews,

    (
        SELECT CAST(STDEV(v)AS DECIMAL(10,2))
        FROM (VALUES
            (c.english_1_star_ratings_count),
            (c.english_5_star_ratings_count)
        ) AS x(v)
    ) AS maximum_standard_deviation,

c.english_controversy_score
 FROM gold.dim_books b
 LEFT JOIN gold.fact_engagements e
 ON b.work_id = e.work_id
 LEFT JOIN gold.fact_controversy c
 ON b.work_id = c.work_id
 WHERE publication_year <= 2017
 )
 SELECT
 title,
 influence_score,
 average_letter_per_reviews,
 ROUND((english_controversy_score/NULLIF(maximum_standard_deviation, 0)) * LOG(english_total_ratings_count), 2) AS polarization_score
 FROM CTE_Corr
 ORDER BY polarization_score DESC
