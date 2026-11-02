/*
===============================================================================
Most Popular Book Score Analysis
===============================================================================
Purpose:
    - To calculate Most Popular Book Score.
    - To track likeability and familiarity of books.
    - Useful for identifying book discovery features.

SQL Functions Used:
    - Window Functions: SUM() OVER(), AVG() OVER()
===============================================================================
*/

-- Calculate the Most Popular Book Score
SELECT
    b.title,
    ROUND(c.total_average_rating * LOG(1 + c.total_ratings_count) + LOG(1 + e.total_text_reviews_count) + LOG(1 + e.total_interaction_count), 2) AS popular_score,
    ROUND(c.english_average_rating * LOG(1 + c.english_total_ratings_count) + LOG(1 + e.english_votes_count) + LOG(1 + e.english_review_text_count), 2) AS english_popular_score
FROM gold.dim_books b
LEFT JOIN gold.fact_engagements e
ON b.work_id = e.work_id
LEFT JOIN gold.fact_controversy c
ON b.work_id = c.work_id
WHERE publication_year <= 2017
ORDER BY popular_score DESC
