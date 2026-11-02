/*
===============================================================================
Quality Checks
===============================================================================
Script Purpose:
    This script performs various quality checks for data consistency, accuracy, 
    and standardization across the 'silver' layer. It includes checks for:
    - Null or duplicate primary keys.
    - Unwanted spaces in string fields.
    - Data standardization and consistency.
    - Invalid date ranges and orders.
    - Data consistency between related fields.

Usage Notes:
    - Run these checks after data loading Silver Layer.
    - Investigate and resolve any discrepancies found during the checks.
===============================================================================
*/

-- Checking for Nulls and Duplicates on Primary Keys
-- Goal: No Results

SELECT
reviews_review_id,
COUNT(*)
FROM silver.goodreads_reviews
GROUP BY reviews_review_id
HAVING COUNT(*) > 1 OR reviews_review_id IS NULL;

SELECT
works_work_id,
COUNT(*)
FROM silver.goodreads_works
GROUP BY works_work_id
HAVING COUNT(*) > 1 OR works_work_id IS NULL

-- Checking for Extra Spaces on Each String Column
-- Goal: No Results
SELECT
reviews_review_id
FROM silver.goodreads_reviews
WHERE reviews_review_id != TRIM(reviews_review_id);

SELECT
reviews_user_id
FROM silver.goodreads_reviews
WHERE reviews_user_id != TRIM(reviews_user_id);

SELECT
reviews_review_text
FROM silver.goodreads_reviews
WHERE reviews_review_text != TRIM(reviews_review_text);

SELECT
works_isbn
FROM silver.goodreads_works
WHERE works_isbn != TRIM(works_isbn);

SELECT
works_original_title
FROM silver.goodreads_works
WHERE works_original_title != TRIM(works_original_title);

SELECT
works_author
FROM silver.goodreads_works
WHERE works_author != TRIM(works_author);

SELECT
works_description
FROM silver.goodreads_works
WHERE works_description != TRIM(works_description);

SELECT
works_image_url
FROM silver.goodreads_works
WHERE works_image_url != TRIM(works_image_url);

SELECT
works_similar_books
FROM silver.goodreads_works
WHERE works_similar_books != TRIM(works_similar_books);

--Check Datefields
--Goal: date_added ≤ started_at ≤ read_at and realistic dates

SELECT
    TRY_CONVERT(DATE, reviews_date_added, 23) AS reviews_date_added,
    TRY_CONVERT(DATE, reviews_started_at, 23) AS reviews_started_at,
    TRY_CONVERT(DATE, reviews_read_at, 23) AS reviews_read_at
FROM silver.goodreads_reviews

SELECT DISTINCT
    TRY_CONVERT(DATETIME2, reviews_date_added, 20) AS reviews_date_added,
    TRY_CONVERT(DATETIME2, reviews_started_at, 20) AS reviews_started_at,
    TRY_CONVERT(DATETIME2, reviews_read_at, 20) AS reviews_read_at
FROM silver.goodreads_reviews

SELECT
    TRY_CONVERT(DATETIME2, reviews_date_added, 20) AS reviews_date_added,
    TRY_CONVERT(DATETIME2, reviews_started_at, 20) AS reviews_started_at,
    TRY_CONVERT(DATETIME2, reviews_read_at, 20) AS reviews_read_at
FROM silver.goodreads_reviews
WHERE
         TRY_CONVERT(DATETIME2, reviews_date_added, 20) >= TRY_CONVERT(DATETIME2, reviews_read_at, 20)
         AND TRY_CONVERT(DATETIME2, reviews_read_at, 20) >= TRY_CONVERT(DATETIME2, reviews_started_at, 20)


SELECT
    TRY_CONVERT(DATETIME2, reviews_date_added, 20) AS reviews_date_added,
    TRY_CONVERT(DATETIME2, reviews_started_at, 20) AS reviews_started_at,
    TRY_CONVERT(DATETIME2, reviews_read_at, 20) AS reviews_read_at
FROM silver.goodreads_reviews
WHERE
         TRY_CONVERT(DATETIME2, reviews_date_added, 20) < TRY_CONVERT(DATETIME2, reviews_read_at, 20)

SELECT
    TRY_CONVERT(DATETIME2, reviews_date_added, 20) AS reviews_date_added,
    TRY_CONVERT(DATETIME2, reviews_started_at, 20) AS reviews_started_at,
    TRY_CONVERT(DATETIME2, reviews_read_at, 20) AS reviews_read_at
FROM silver.goodreads_reviews
WHERE TRY_CONVERT(DATETIME2, reviews_read_at, 20) < TRY_CONVERT(DATETIME2, reviews_started_at, 20)

SELECT
    TRY_CONVERT(DATETIME2, reviews_date_added, 20) AS reviews_date_added,
    TRY_CONVERT(DATETIME2, reviews_started_at, 20) AS reviews_started_at,
    TRY_CONVERT(DATETIME2, reviews_read_at, 20) AS reviews_read_at
FROM silver.goodreads_reviews
WHERE TRY_CONVERT(DATETIME2, reviews_date_added, 20) IS NULL

SELECT
    TRY_CONVERT(DATETIME2, reviews_date_added, 20) AS reviews_date_added,
    TRY_CONVERT(DATETIME2, reviews_started_at, 20) AS reviews_started_at,
    TRY_CONVERT(DATETIME2, reviews_read_at, 20) AS reviews_read_at
FROM silver.goodreads_reviews
WHERE       TRY_CONVERT(DATETIME2, reviews_started_at, 20) IS NULL
        AND TRY_CONVERT(DATETIME2, reviews_read_at, 20) IS NULL

SELECT
    TRY_CONVERT(DATETIME2, reviews_date_added, 20) AS reviews_date_added,
    TRY_CONVERT(DATETIME2, reviews_started_at, 20) AS reviews_started_at,
    TRY_CONVERT(DATETIME2, reviews_read_at, 20) AS reviews_read_at
FROM silver.goodreads_reviews
WHERE       TRY_CONVERT(DATETIME2, reviews_started_at, 20) IS NULL
        AND TRY_CONVERT(DATETIME2, reviews_read_at, 20) IS NOT NULL

SELECT
    TRY_CONVERT(DATETIME2, reviews_date_added, 20) AS reviews_date_added,
    TRY_CONVERT(DATETIME2, reviews_started_at, 20) AS reviews_started_at,
    TRY_CONVERT(DATETIME2, reviews_read_at, 20) AS reviews_read_at
FROM silver.goodreads_reviews
WHERE       TRY_CONVERT(DATETIME2, reviews_started_at, 20) IS NOT NULL
        AND TRY_CONVERT(DATETIME2, reviews_read_at, 20) IS NULL

SELECT
    MAX(TRY_CONVERT(DATETIME2, reviews_read_at, 20)) AS latest_reviews_read_at,
    MIN(TRY_CONVERT(DATETIME2, reviews_read_at, 20)) AS oldest_reviews_read_at,

    MAX(TRY_CONVERT(DATETIME2, reviews_started_at, 20)) AS latest_reviews_started_at,
    MIN(TRY_CONVERT(DATETIME2, reviews_started_at, 20)) AS oldest_reviews_started_at,
    
    MAX(TRY_CONVERT(DATETIME2, reviews_date_added, 20)) AS latest_reviews_date_added,
    MIN(TRY_CONVERT(DATETIME2, reviews_date_added, 20)) AS oldest_reviews_date_added

FROM silver.goodreads_reviews

SELECT
    TRY_CONVERT(DATETIME2, reviews_date_added, 20) AS reviews_date_added,
    TRY_CONVERT(DATETIME2, reviews_started_at, 20) AS reviews_started_at,
    TRY_CONVERT(DATETIME2, reviews_read_at, 20) AS reviews_read_at
FROM silver.goodreads_reviews
WHERE TRY_CONVERT(DATETIME2, reviews_started_at, 20) IS NOT NULL
ORDER BY TRY_CONVERT(DATETIME2, reviews_started_at, 20) DESC

SELECT
    TRY_CONVERT(DATETIME2, reviews_date_added, 20) AS reviews_date_added,
    TRY_CONVERT(DATETIME2, reviews_started_at, 20) AS reviews_started_at,
    TRY_CONVERT(DATETIME2, reviews_read_at, 20) AS reviews_read_at
FROM silver.goodreads_reviews
ORDER BY reviews_date_added DESC

SELECT
    TRY_CONVERT(DATETIME2, reviews_date_added, 20) AS reviews_date_added,
    TRY_CONVERT(DATETIME2, reviews_started_at, 20) AS reviews_started_at,
    TRY_CONVERT(DATETIME2, reviews_read_at, 20) AS reviews_read_at
FROM silver.goodreads_reviews
WHERE TRY_CONVERT(DATETIME2, reviews_read_at, 20) IS NOT NULL
ORDER BY TRY_CONVERT(DATETIME2, reviews_read_at, 20) DESC

--Check for invalid leap year dates
--Results: NONE

SELECT 
TRY_CONVERT(DATE, reviews_started_at, 23) AS reviews_started_at
FROM silver.goodreads_reviews
WHERE MONTH(TRY_CONVERT(DATE, reviews_started_at, 23)) = 2
  AND DAY(TRY_CONVERT(DATE, reviews_started_at, 23)) = 29
  AND NOT (
        (YEAR(TRY_CONVERT(DATE, reviews_started_at, 23)) % 4 = 0 AND YEAR(TRY_CONVERT(DATE, reviews_started_at, 23)) % 100 <> 0)
        OR (YEAR(TRY_CONVERT(DATE, reviews_started_at, 23)) % 400 = 0)
  );

SELECT 
TRY_CONVERT(DATE, reviews_date_added, 23) AS reviews_date_added
FROM silver.goodreads_reviews
WHERE MONTH(TRY_CONVERT(DATE, reviews_date_added, 23)) = 2
  AND DAY(TRY_CONVERT(DATE, reviews_date_added, 23)) = 29
  AND NOT (
        (YEAR(TRY_CONVERT(DATE, reviews_date_added, 23)) % 4 = 0 AND YEAR(TRY_CONVERT(DATE, reviews_date_added, 23)) % 100 <> 0)
        OR (YEAR(TRY_CONVERT(DATE, reviews_date_added, 23)) % 400 = 0)
  );



SELECT 
TRY_CONVERT(DATE, reviews_read_at, 23) AS reviews_read_at
FROM silver.goodreads_reviews
WHERE MONTH(TRY_CONVERT(DATE, reviews_read_at, 23)) = 2
  AND DAY(TRY_CONVERT(DATE, reviews_read_at, 23)) = 29
  AND NOT (
        (YEAR(TRY_CONVERT(DATE, reviews_read_at, 23)) % 4 = 0 AND YEAR(TRY_CONVERT(DATE, reviews_read_at, 23)) % 100 <> 0)
        OR (YEAR(TRY_CONVERT(DATE, reviews_read_at, 23)) % 400 = 0)
  );


SELECT
r.reviews_work_id,
w.works_original_publication_year
FROM silver.goodreads_reviews AS r
LEFT JOIN silver.goodreads_works AS w
ON r.reviews_work_id = w.works_work_id
WHERE works_original_publication_year IS NOT NULL
GROUP BY r.reviews_work_id, w.works_original_publication_year
ORDER BY works_original_publication_year DESC

SELECT
works_original_publication_year
FROM silver.goodreads_works
ORDER BY works_original_publication_year ASC

SELECT
works_original_publication_year
FROM silver.goodreads_works
WHERE works_original_publication_year < 1450

-- Checking for Reviews Count Inconsistency
-- Goal: No Results

SELECT
r.reviews_work_id,
w.works_reviews_count,
COUNT(reviews_review_text) AS reviews_count
FROM silver.goodreads_reviews AS r
LEFT JOIN silver.goodreads_works AS w
ON r.reviews_work_id = w.works_work_id
GROUP BY r.reviews_work_id, w.works_reviews_count
HAVING w.works_reviews_count != COUNT(reviews_review_text)

-- Checking for Reviews Text
SELECT
LEN(reviews_review_text)
FROM silver.goodreads_reviews


-- Checking for Reviews Count Inconsistency
-- Goal: reviews_count = works_text_reviews_count

SELECT
COUNT(*)
FROM silver.goodreads_reviews
-- RESULTS: 1143887

SELECT
COUNT(*)
FROM silver.goodreads_reviews
WHERE reviews_read_at IS NULL 
--112122

SELECT
COUNT(*)
FROM silver.goodreads_reviews
WHERE reviews_started_at IS NULL 
-- 347495

SELECT
COUNT(*)
FROM silver.goodreads_reviews
WHERE reviews_read_at IS NULL AND reviews_started_at IS NULL
-- RESULTS: 99572

SELECT
SUM(works_text_reviews_count)
FROM silver.goodreads_works
-- RESULTS: 27546761

SELECT COUNT(DISTINCT reviews_work_id)
FROM silver.goodreads_reviews;
-- RESULTS:13525

SELECT COUNT(*)
FROM silver.goodreads_works;
-- RESULTS:13525

SELECT
r.reviews_work_id,
COUNT(*) AS reviews_count,
w.works_work_id,
w.works_text_reviews_count
FROM silver.goodreads_reviews AS r
LEFT JOIN silver.goodreads_works AS w ON r.reviews_work_id = w.works_work_id
GROUP BY r.reviews_work_id, w.works_work_id, w.works_text_reviews_count
ORDER BY reviews_count DESC;

SELECT
works_work_id,
works_text_reviews_count
FROM silver.goodreads_works;

SELECT DISTINCT reviews_rating
FROM silver.goodreads_reviews;


SELECT
r.reviews_work_id,
COUNT(*) AS reviews_count,
w.works_text_reviews_count
FROM silver.goodreads_reviews AS r
LEFT JOIN silver.goodreads_works AS w ON r.reviews_work_id = w.works_work_id
GROUP BY r.reviews_work_id, w.works_text_reviews_count

-- Checking for Reviews Count Inconsistency
-- Goal: reviews_n_count != works_4_star_ratings

SELECT
    r.reviews_work_id,

    SUM(CASE WHEN r.reviews_rating = 1 THEN 1 ELSE 0 END) AS rating_1_count,
    w.works_1_star_ratings,
    SUM(CASE WHEN r.reviews_rating = 2 THEN 1 ELSE 0 END) AS rating_2_count,
    w.works_2_star_ratings,
    SUM(CASE WHEN r.reviews_rating = 3 THEN 1 ELSE 0 END) AS rating_3_count,
    w.works_3_star_ratings,
    SUM(CASE WHEN r.reviews_rating = 4 THEN 1 ELSE 0 END) AS rating_4_count,
    w.works_4_star_ratings,
    SUM(CASE WHEN r.reviews_rating = 5 THEN 1 ELSE 0 END) AS rating_5_count,
    w.works_5_star_ratings,

    COUNT(*) AS total_reviews,
    w.works_ratings_count
FROM silver.goodreads_reviews AS r
LEFT JOIN silver.goodreads_works AS w ON r.reviews_work_id = w.works_work_id
GROUP BY r.reviews_work_id, w.works_1_star_ratings, w.works_2_star_ratings, w.works_3_star_ratings, w.works_4_star_ratings, w.works_5_star_ratings, w.works_ratings_count
ORDER BY total_reviews ASC;

-- Checking for Helpful Votes
-- Goal: No Results

SELECT
reviews_work_id,
SUM(reviews_n_votes) AS votes_count,
SUM(reviews_n_comments) AS comments_count
FROM silver.goodreads_reviews
GROUP BY reviews_work_id
ORDER BY votes_count DESC


-- Checking for Ratings Count Inconsistency
-- Goal: No Results

SELECT
works_work_id,
works_ratings_count,
works_1_star_ratings + works_2_star_ratings + works_3_star_ratings + works_4_star_ratings + works_5_star_ratings
FROM silver.goodreads_works
WHERE works_ratings_count != works_1_star_ratings + works_2_star_ratings + works_3_star_ratings + works_4_star_ratings + works_5_star_ratings

-- Genres

SELECT
COUNT(*)
FROM silver.goodreads_works

SELECT DISTINCT
COUNT(works_author)
FROM silver.goodreads_works

SELECT
reviews_work_id,
COUNT(*)
FROM silver.goodreads_reviews
GROUP BY reviews_work_id


SELECT 
COUNT(reviews_review_text) AS reviews_count,
works_original_publication_year
FROM silver.goodreads_reviews 
LEFT JOIN silver.goodreads_works ON reviews_work_id = works_work_id
GROUP BY works_original_publication_year
ORDER BY works_original_publication_year

SELECT DISTINCT
works_work_id,
works_original_publication_year
FROM silver.goodreads_works
WHERE works_original_publication_year > '2017'

SELECT DISTINCT
works_work_id,
works_original_publication_year
FROM silver.goodreads_works
WHERE works_original_publication_year IS NULL

SELECT DISTINCT
SUM(works_reviews_count) AS total_count,
works_original_publication_year
FROM silver.goodreads_works
WHERE works_original_publication_year IS NOT NULL AND works_original_publication_year < '2018'
GROUP BY works_original_publication_year
ORDER BY works_original_publication_year DESC

WITH CTE_cleaned AS
    (
        SELECT
            TRIM(reviews_review_id) AS review_id_cleaned,
            TRIM(reviews_user_id) AS user_id_cleaned,
            reviews_work_id,
            TRY_CONVERT(DATE, reviews_started_at, 23) AS started_at_cleaned,
            TRY_CONVERT(DATE, reviews_read_at, 23) AS read_at_cleaned,
            TRY_CONVERT(DATE, reviews_date_added, 23) AS date_added_cleaned,
            reviews_rating,
            TRIM(reviews_review_text) AS review_text_cleaned,
            reviews_n_votes,
            reviews_n_comments
        FROM silver.goodreads_reviews
    ),

    CTE_derived_columns AS
    (
        SELECT
            review_id_cleaned AS reviews_review_id,
            user_id_cleaned AS reviews_user_id,
            reviews_work_id,
            started_at_cleaned AS reviews_started_at,
            read_at_cleaned AS reviews_read_at,
            date_added_cleaned AS reviews_date_added,

            CASE
			WHEN read_at_cleaned IS NULL AND started_at_cleaned IS NOT NULL					THEN 'Reading_Or_Abandoned'
			WHEN read_at_cleaned IS NOT NULL AND started_at_cleaned IS NULL					THEN 'Completed_No_Start'
			WHEN read_at_cleaned IS NULL AND started_at_cleaned IS NULL						THEN 'No_Reading_Activity'
			WHEN read_at_cleaned IS NOT NULL AND started_at_cleaned IS NOT NULL				THEN 'Completed'
		    END AS review_status,

            -- ✅ READER TYPE
            CASE
                WHEN  started_at_cleaned IS NULL OR  read_at_cleaned IS NULL THEN NULL
                WHEN DATEDIFF(DAY,  started_at_cleaned,  read_at_cleaned) < 0 THEN 'Data Quality Issue'
                WHEN DATEDIFF(DAY,  started_at_cleaned,  read_at_cleaned) BETWEEN 0 AND 1 THEN 'Lightning Reader'
                WHEN DATEDIFF(DAY,  started_at_cleaned,  read_at_cleaned) BETWEEN 2 AND 7 THEN 'Steady Reader'
                WHEN DATEDIFF(DAY,  started_at_cleaned,  read_at_cleaned) BETWEEN 8 AND 30 THEN 'Absorbing Reader'
                WHEN DATEDIFF(DAY,  started_at_cleaned,  read_at_cleaned) BETWEEN 31 AND 90 THEN 'Analytical Reader'
                WHEN DATEDIFF(DAY,  started_at_cleaned,  read_at_cleaned) BETWEEN 91 AND 180 THEN 'Occasional Reader'
                WHEN DATEDIFF(DAY,  started_at_cleaned,  read_at_cleaned) BETWEEN 181 AND 365 THEN 'Dormant Reader'
                WHEN DATEDIFF(DAY,  started_at_cleaned,  read_at_cleaned) > 365 THEN 'Potentially Unreliable'
            END AS dwh_reader_type,

            -- ✅ CRITIC TYPE
            CASE
                WHEN  read_at_cleaned IS NULL OR  date_added_cleaned IS NULL THEN NULL
                WHEN DATEDIFF(DAY, read_at_cleaned,  date_added_cleaned) < 0 THEN 'Data Quality Issue'
                WHEN DATEDIFF(DAY, read_at_cleaned,  date_added_cleaned) BETWEEN 0 AND 1 THEN 'Immediate Reviewer'
                WHEN DATEDIFF(DAY, read_at_cleaned,  date_added_cleaned) BETWEEN 2 AND 7 THEN 'Thematic Reviewer'
                WHEN DATEDIFF(DAY, read_at_cleaned,  date_added_cleaned) BETWEEN 8 AND 30 THEN 'Analytical Reviewer'
                WHEN DATEDIFF(DAY, read_at_cleaned,  date_added_cleaned) BETWEEN 31 AND 60 THEN 'Retrospective Reviewer'
                WHEN DATEDIFF(DAY, read_at_cleaned,  date_added_cleaned) BETWEEN 61 AND 90 THEN 'Backlog Reviewer'
                WHEN DATEDIFF(DAY, read_at_cleaned,  date_added_cleaned) > 90 THEN 'Potentially Unreliable'
            END AS dwh_critic_type,

            reviews_rating,
            review_text_cleaned AS reviews_review_text,
            LEN(review_text_cleaned) AS dwh_text_review_length,
            reviews_n_votes,
            reviews_n_comments

        FROM CTE_cleaned 
    )
    INSERT INTO silver.goodreads_reviews
    (
        reviews_review_id,
        reviews_user_id,
        reviews_work_id,
        reviews_started_at,
        reviews_read_at,
        reviews_date_added,
        dwh_reader_type,
        dwh_critic_type,
        reviews_rating,
        reviews_review_text,
        dwh_text_review_length,
        reviews_n_votes,
        reviews_n_comments
    )
    SELECT 
        reviews_review_id,
        reviews_user_id,
        reviews_work_id,
        reviews_started_at,
        reviews_read_at,
        reviews_date_added,
        dwh_reader_type,
        dwh_critic_type,
        reviews_rating,
        reviews_review_text,
        dwh_text_review_length,
        reviews_n_votes,
        reviews_n_comments
    FROM CTE_derived_columns;

