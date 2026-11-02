/*
This query text was retrieved from showplan XML, and may be truncated.
*/

/*
===============================================================================
Stored Procedure: Load Silver Layer (Bronze -> Silver)
===============================================================================
Script Purpose:
    This stored procedure performs the ETL (Extract, Transform, Load) process to 
    populate the 'silver' schema tables from the 'bronze' schema.
	Actions Performed:
		- Truncates Silver tables.
		- Inserts transformed and cleansed data from Bronze into Silver tables.
		
Parameters:
    None. 
	  This stored procedure does not accept any parameters or return any values.

Usage Example:
    EXEC Silver.load_silver;
===============================================================================
*/

CREATE OR ALTER PROCEDURE silver.load_silver 
AS
BEGIN
    DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME; 
        BEGIN TRY
            SET @batch_start_time = GETDATE();
            PRINT '================================================';
            PRINT 'Loading Silver Layer';
            PRINT '================================================';

		    PRINT '------------------------------------------------';
		    PRINT 'Loading CRM Tables';
		    PRINT '------------------------------------------------';

		       -- Loading silver.goodreads_reviews
               SET @start_time = GETDATE();
		       PRINT '>> Truncating Table: silver.goodreads_reviews';
		       TRUNCATE TABLE silver.goodreads_reviews;
		       PRINT '>> Inserting Data Into: silver.goodreads_reviews';
               INSERT INTO silver.goodreads_reviews
                (
                    reviews_review_id,
                    reviews_user_id,
                    reviews_work_id,
                    reviews_started_at,
                    reviews_read_at,
                    reviews_date_added,
                    dwh_review_type,
                    dwh_review_status,
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
                    dwh_review_type,
                    dwh_review_status,
                    dwh_reader_type,
                    dwh_critic_type,
                    reviews_rating,
                    reviews_review_text,
                    dwh_text_review_length,
                    reviews_n_votes,
                    reviews_n_comments
                FROM ( SELECT
                        review_id_cleaned AS reviews_review_id,
                        user_id_cleaned AS reviews_user_id,
                        reviews_work_id,
                        started_at_cleaned AS reviews_started_at,
                        read_at_cleaned AS reviews_read_at,
                        date_added_cleaned AS reviews_date_added,

                        -- ✅ REVIEW TYPE
		                CASE
                            WHEN publication_year < 1450 THEN 'Data Quality Issue'
		                    WHEN publication_year - YEAR(date_added_cleaned) < 1 THEN 'Normal Review'
		                    WHEN publication_year - YEAR(date_added_cleaned) = 1 THEN 'Galley Review'
		                    WHEN publication_year - YEAR(date_added_cleaned) > 1  OR publication_year > 2017 THEN 'Anticipatory Review'
		                END dwh_review_type,

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
            
                         -- ✅ REVIEW STATUS
                        CASE
                            WHEN read_at_cleaned > '2017-12-31' THEN 'Data Quality Issue'
			                WHEN read_at_cleaned IS NULL AND started_at_cleaned IS NOT NULL	THEN 'Currently Reading'
			                WHEN read_at_cleaned IS NOT NULL THEN 'Read'
			                WHEN read_at_cleaned IS NULL AND started_at_cleaned IS NULL	THEN 'Want to Read'
                        END AS dwh_review_status,

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

                        reviews_rating_cleaned AS reviews_rating,
                        review_text_cleaned AS reviews_review_text,
                        LEN(review_text_cleaned) AS dwh_text_review_length,
                        reviews_n_votes,
                        reviews_n_comments
                        FROM (
                                SELECT
                                    TRIM(r.reviews_review_id) AS review_id_cleaned,
                                    TRIM(r.reviews_user_id) AS user_id_cleaned,
                                    r.reviews_work_id,
                                    TRY_CONVERT(DATE, r.reviews_started_at, 23) AS read_at_cleaned,
                                    TRY_CONVERT(DATE, r.reviews_read_at, 23) AS date_added_cleaned,
                                    TRY_CONVERT(DATE, r.reviews_date_added, 23) AS started_at_cleaned,
                                    CAST(r.reviews_rating AS INT) AS reviews_rating_cleaned,
                                    TRIM(r.reviews_review_text) AS review_text_cleaned,
                                    ABS(r.reviews_n_votes) AS reviews_n_votes,
                                    ABS(r.reviews_n_comments) AS reviews_n_comments,
                                    w.works_original_publication_year AS publication_year
                                FROM bronze.goodreads_reviews r
                                LEFT JOIN bronze.goodreads_works w
                                ON r.reviews_work_id = w.works_work_id
                                WHERE (TRY_CONVERT(DATE, r.reviews_date_added, 23) <= TRY_CONVERT(DATE, r.reviews_started_at, 23)
                                  AND TRY_CONVERT(DATE, r.reviews_started_at, 23) <= TRY_CONVERT(DATE, r.reviews_read_at, 23)))t)t

             UNION

                SELECT 
                    reviews_review_id,
                    reviews_user_id,
                    reviews_work_id,
                    reviews_started_at,
                    reviews_read_at,
                    reviews_date_added,
                    dwh_review_type,
                    dwh_review_status,
                    dwh_reader_type,
                    dwh_critic_type,
                    reviews_rating,
                    reviews_review_text,
                    dwh_text_review_length,
                    reviews_n_votes,
                    reviews_n_comments
                FROM ( SELECT
                        review_id_cleaned AS reviews_review_id,
                        user_id_cleaned AS reviews_user_id,
                        reviews_work_id,
                        started_at_cleaned AS reviews_started_at,
                        read_at_cleaned AS reviews_read_at,
                        date_added_cleaned AS reviews_date_added,

                        -- ✅ REVIEW TYPE
		                CASE
                            WHEN publication_year < 1450 THEN 'Data Quality Issue'
		                    WHEN publication_year - YEAR(date_added_cleaned) < 1 THEN 'Normal Review'
		                    WHEN publication_year - YEAR(date_added_cleaned) = 1 THEN 'Galley Review'
		                    WHEN publication_year - YEAR(date_added_cleaned) > 1 OR publication_year > 2017 THEN 'Anticipatory Review'
		                END dwh_review_type,

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
            
                         -- ✅ REVIEW STATUS
                        CASE
                            WHEN read_at_cleaned > '2017-12-31' THEN 'Data Quality Issue'
			                WHEN read_at_cleaned IS NULL AND started_at_cleaned IS NOT NULL	THEN 'Currently Reading'
			                WHEN read_at_cleaned IS NOT NULL THEN 'Read'
			                WHEN read_at_cleaned IS NULL AND started_at_cleaned IS NULL	THEN 'Want to Read'
                        END AS dwh_review_status,

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

                        reviews_rating_cleaned AS reviews_rating,
                        review_text_cleaned AS reviews_review_text,
                        LEN(review_text_cleaned) AS dwh_text_review_length,
                        reviews_n_votes,
                        reviews_n_comments
                        FROM (
                                SELECT
                                    TRIM(r.reviews_review_id) AS review_id_cleaned,
                                    TRIM(r.reviews_user_id) AS user_id_cleaned,
                                    r.reviews_work_id,
                                    TRY_CONVERT(DATE, r.reviews_started_at, 23) AS started_at_cleaned,
                                    TRY_CONVERT(DATE, r.reviews_read_at, 23) AS read_at_cleaned,
                                    TRY_CONVERT(DATE, r.reviews_date_added, 23) AS date_added_cleaned,
                                    CAST(r.reviews_rating AS INT) AS reviews_rating_cleaned,
                                    TRIM(r.reviews_review_text) AS review_text_cleaned,
                                    ABS(r.reviews_n_votes) AS reviews_n_votes,
                                    ABS(r.reviews_n_comments) AS reviews_n_comments,
                                    w.works_original_publication_year AS publication_year
                                FROM bronze.goodreads_reviews r
                                LEFT JOIN bronze.goodreads_works w
                                ON r.reviews_work_id = w.works_work_id
                                WHERE (TRY_CONVERT(DATE, r.reviews_started_at, 23) <= TRY_CONVERT(DATE, r.reviews_read_at, 23)
                                  AND TRY_CONVERT(DATE, r.reviews_read_at, 23) <= TRY_CONVERT(DATE, r.reviews_date_added, 23)
                                  AND TRY_CONVERT(DATE, r.reviews_started_at, 23) < TRY_CONVERT(DATE, r.reviews_date_added, 23))
                                  OR (r.reviews_started_at IS NULL
                                  AND r.reviews_read_at IS NULL)
                                  OR (TRY_CONVERT(DATE, r.reviews_started_at, 23) <= TRY_CONVERT(DATE, r.reviews_date_added, 23)
                                  AND r.reviews_read_at IS NULL)
                                  OR (TRY_CONVERT(DATE, r.reviews_read_at, 23) <= TRY_CONVERT(DATE, r.reviews_date_added, 23)
                                  AND r.reviews_started_at IS NULL))t)t

                UNION

                SELECT 
                    reviews_review_id,
                    reviews_user_id,
                    reviews_work_id,
                    reviews_started_at,
                    reviews_read_at,
                    reviews_date_added,
                    dwh_review_type,
                    dwh_review_status,
                    dwh_reader_type,
                    dwh_critic_type,
                    reviews_rating,
                    reviews_review_text,
                    dwh_text_review_length,
                    reviews_n_votes,
                    reviews_n_comments
                FROM ( SELECT
                        review_id_cleaned AS reviews_review_id,
                        user_id_cleaned AS reviews_user_id,
                        reviews_work_id,
                        started_at_cleaned AS reviews_started_at,
                        read_at_cleaned AS reviews_read_at,
                        date_added_cleaned AS reviews_date_added,

                        -- ✅ REVIEW TYPE
		                CASE
                            WHEN publication_year < 1450 THEN 'Data Quality Issue'
		                    WHEN publication_year - YEAR(date_added_cleaned) < 1 THEN 'Normal Review'
		                    WHEN publication_year - YEAR(date_added_cleaned) = 1 THEN 'Galley Review'
		                    WHEN publication_year - YEAR(date_added_cleaned) > 1 OR publication_year > 2017 THEN 'Anticipatory Review'
		                END dwh_review_type,

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
            
                         -- ✅ REVIEW STATUS
                        CASE
                            WHEN read_at_cleaned > '2017-12-31' THEN 'Data Quality Issue'
			                WHEN read_at_cleaned IS NULL AND started_at_cleaned IS NOT NULL	THEN 'Currently Reading'
			                WHEN read_at_cleaned IS NOT NULL THEN 'Read'
			                WHEN read_at_cleaned IS NULL AND started_at_cleaned IS NULL	THEN 'Want to Read'
                        END AS dwh_review_status,

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

                        reviews_rating_cleaned AS reviews_rating,
                        review_text_cleaned AS reviews_review_text,
                        LEN(review_text_cleaned) AS dwh_text_review_length,
                        reviews_n_votes,
                        reviews_n_comments
                        FROM (
                                SELECT
                                    TRIM(r.reviews_review_id) AS review_id_cleaned,
                                    TRIM(r.reviews_user_id) AS user_id_cleaned,
                                    r.reviews_work_id,
                                    TRY_CONVERT(DATE, r.reviews_started_at, 23) AS started_at_cleaned,
                                    TRY_CONVERT(DATE, r.reviews_read_at, 23) AS date_added_cleaned,
                                    TRY_CONVERT(DATE, r.reviews_date_added, 23) AS read_at_cleaned,
                                    CAST(r.reviews_rating AS INT) AS reviews_rating_cleaned,
                                    TRIM(r.reviews_review_text) AS review_text_cleaned,
                                    ABS(r.reviews_n_votes) AS reviews_n_votes,
                                    ABS(r.reviews_n_comments) AS reviews_n_comments,
                                    w.works_original_publication_year AS publication_year
                                FROM bronze.goodreads_reviews r
                                LEFT JOIN bronze.goodreads_works w
                                ON r.reviews_work_id = w.works_work_id
                                WHERE (TRY_CONVERT(DATE, r.reviews_date_added, 23) < TRY_CONVERT(DATE, r.reviews_read_at, 23)
                                  AND r.reviews_started_at IS NULL)
                                  OR (TRY_CONVERT(DATE, r.reviews_date_added, 23) < TRY_CONVERT(DATE, r.reviews_read_at, 23)
                                  AND TRY_CONVERT(DATE, r.reviews_started_at, 23) < TRY_CONVERT(DATE, r.reviews_date_added, 23)))t)t
  
                  UNION

                SELECT 
                    reviews_review_id,
                    reviews_user_id,
                    reviews_work_id,
                    reviews_started_at,
                    reviews_read_at,
                    reviews_date_added,
                    dwh_review_type,
                    dwh_review_status,
                    dwh_reader_type,
                    dwh_critic_type,
                    reviews_rating,
                    reviews_review_text,
                    dwh_text_review_length,
                    reviews_n_votes,
                    reviews_n_comments
                FROM ( SELECT
                        review_id_cleaned AS reviews_review_id,
                        user_id_cleaned AS reviews_user_id,
                        reviews_work_id,
                        started_at_cleaned AS reviews_started_at,
                        read_at_cleaned AS reviews_read_at,
                        date_added_cleaned AS reviews_date_added,

                        -- ✅ REVIEW TYPE
		                CASE
                            WHEN publication_year < 1450 THEN 'Data Quality Issue'
		                    WHEN publication_year - YEAR(date_added_cleaned) < 1 THEN 'Normal Review'
		                    WHEN publication_year - YEAR(date_added_cleaned) = 1 THEN 'Galley Review'
		                    WHEN publication_year - YEAR(date_added_cleaned) > 1 OR publication_year > 2017 THEN 'Anticipatory Review'
		                END dwh_review_type,

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
            
                         -- ✅ REVIEW STATUS
                        CASE
                            WHEN read_at_cleaned > '2017-12-31' THEN 'Data Quality Issue'
			                WHEN read_at_cleaned IS NULL AND started_at_cleaned IS NOT NULL	THEN 'Currently Reading'
			                WHEN read_at_cleaned IS NOT NULL THEN 'Read'
			                WHEN read_at_cleaned IS NULL AND started_at_cleaned IS NULL	THEN 'Want to Read'
                        END AS dwh_review_status,

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

                        reviews_rating_cleaned AS reviews_rating,
                        review_text_cleaned AS reviews_review_text,
                        LEN(review_text_cleaned) AS dwh_text_review_length,
                        reviews_n_votes,
                        reviews_n_comments
                        FROM (
                                SELECT
                                    TRIM(r.reviews_review_id) AS review_id_cleaned,
                                    TRIM(r.reviews_user_id) AS user_id_cleaned,
                                    r.reviews_work_id,
                                    TRY_CONVERT(DATE, r.reviews_started_at, 23) AS date_added_cleaned,
                                    TRY_CONVERT(DATE, r.reviews_read_at, 23) AS read_at_cleaned,
                                    TRY_CONVERT(DATE, r.reviews_date_added, 23) AS started_at_cleaned,
                                    CAST(r.reviews_rating AS INT) AS reviews_rating_cleaned,
                                    TRIM(r.reviews_review_text) AS review_text_cleaned,
                                    ABS(r.reviews_n_votes) AS reviews_n_votes,
                                    ABS(r.reviews_n_comments) AS reviews_n_comments,
                                    w.works_original_publication_year AS publication_year
                                FROM bronze.goodreads_reviews r
                                LEFT JOIN bronze.goodreads_works w
                                ON r.reviews_work_id = w.works_work_id
                                WHERE (TRY_CONVERT(DATE, r.reviews_date_added, 23) < TRY_CONVERT(DATE, r.reviews_started_at, 23)
                                  AND r.reviews_read_at IS NULL)
                                  OR (TRY_CONVERT(DATE, r.reviews_read_at, 23) < TRY_CONVERT(DATE, r.reviews_started_at, 23)
                                  AND (TRY_CONVERT(DATE, r.reviews_date_added, 23) < TRY_CONVERT(DATE, r.reviews_read_at, 23))))t)t

             UNION

                SELECT 
                    reviews_review_id,
                    reviews_user_id,
                    reviews_work_id,
                    reviews_started_at,
                    reviews_read_at,
                    reviews_date_added,
                    dwh_review_type,
                    dwh_review_status,
                    dwh_reader_type,
                    dwh_critic_type,
                    reviews_rating,
                    reviews_review_text,
                    dwh_text_review_length,
                    reviews_n_votes,
                    reviews_n_comments
                FROM ( SELECT
                        review_id_cleaned AS reviews_review_id,
                        user_id_cleaned AS reviews_user_id,
                        reviews_work_id,
                        started_at_cleaned AS reviews_started_at,
                        read_at_cleaned AS reviews_read_at,
                        date_added_cleaned AS reviews_date_added,

                        -- ✅ REVIEW TYPE
		                CASE
                            WHEN publication_year < 1450 THEN 'Data Quality Issue'
		                    WHEN publication_year - YEAR(date_added_cleaned) < 1 THEN 'Normal Review'
		                    WHEN publication_year - YEAR(date_added_cleaned) = 1 THEN 'Galley Review'
		                    WHEN publication_year - YEAR(date_added_cleaned) > 1 OR publication_year > 2017 THEN 'Anticipatory Review'
		                END dwh_review_type,

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
            
                         -- ✅ REVIEW STATUS
                        CASE
                            WHEN read_at_cleaned > '2017-12-31' THEN 'Data Quality Issue'
			                WHEN read_at_cleaned IS NULL AND started_at_cleaned IS NOT NULL	THEN 'Currently Reading'
			                WHEN read_at_cleaned IS NOT NULL THEN 'Read'
			                WHEN read_at_cleaned IS NULL AND started_at_cleaned IS NULL	THEN 'Want to Read'
                        END AS dwh_review_status,

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

                        reviews_rating_cleaned AS reviews_rating,
                        review_text_cleaned AS reviews_review_text,
                        LEN(review_text_cleaned) AS dwh_text_review_length,
                        reviews_n_votes,
                        reviews_n_comments
                        FROM (
                                SELECT
                                    TRIM(r.reviews_review_id) AS review_id_cleaned,
                                    TRIM(r.reviews_user_id) AS user_id_cleaned,
                                    r.reviews_work_id,
                                    TRY_CONVERT(DATE, r.reviews_started_at, 23) AS date_added_cleaned,
                                    TRY_CONVERT(DATE, r.reviews_read_at, 23) AS started_at_cleaned,
                                    TRY_CONVERT(DATE, r.reviews_date_added, 23) AS read_at_cleaned,
                                    CAST(r.reviews_rating AS INT) AS reviews_rating_cleaned,
                                    TRIM(r.reviews_review_text) AS review_text_cleaned,
                                    ABS(r.reviews_n_votes) AS reviews_n_votes,
                                    ABS(r.reviews_n_comments) AS reviews_n_comments,
                                    w.works_original_publication_year AS publication_year
                                FROM bronze.goodreads_reviews r
                                LEFT JOIN bronze.goodreads_works w
                                ON r.reviews_work_id = w.works_work_id
                                WHERE (TRY_CONVERT(DATE, r.reviews_date_added, 23) < TRY_CONVERT(DATE, r.reviews_started_at, 23)
                                  AND TRY_CONVERT(DATE, r.reviews_read_at, 23) <= TRY_CONVERT(DATE, r.reviews_date_added, 23)
                                  AND TRY_CONVERT(DATE, r.reviews_read_at, 23) < TRY_CONVERT(DATE, r.reviews_started_at, 23)))t)t
                    SET @end_time = GETDATE();
                    PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
                    PRINT '>> -------------';

                    -- Loading silver.goodreads_works
		            SET @start_time = GETDATE();
		            PRINT '>> Truncating Table: silver.goodreads_works';
		            TRUNCATE TABLE silver.goodreads_works;
		            PRINT '>> Inserting Data Into: silver.goodreads_works';
                    INSERT INTO silver.goodreads_works
                    (
                    works_work_id,
                    works_isbn,
                    works_isbn13,
                    works_original_title,
                    works_author,
                    works_original_publication_year,
                    works_literary_period,
                    works_num_pages,
                    works_description,
                    works_children_genre_flag,
                    works_comics_and_graphics_genre_flag,
                    works_fantasy_and_paranormal_genre_flag,
                    works_history_and_biography_genre_flag,
                    works_mystery_thriller_and_crime_genre_flag,
                    works_poetry_genre_flag,
                    works_romance_genre_flag,
                    works_young_adult_genre_flag,
                    works_image_url,
                    works_reviews_count,
                    works_text_reviews_count,
                    works_5_star_ratings,
                    works_4_star_ratings,
                    works_3_star_ratings,
                    works_2_star_ratings,
                    works_1_star_ratings,
                    works_ratings_count,
                    works_average_rating,
                    works_similar_books
                    )
                    SELECT
                    works_work_id,
                    works_isbn,
                    works_isbn13,
                    works_original_title,
                    works_author,
                    works_original_publication_year,
                    works_literary_period,
                    works_num_pages,
                    works_description,
                    works_children_genre_flag,
                    works_comics_and_graphics_genre_flag,
                    works_fantasy_and_paranormal_genre_flag,
                    works_history_and_biography_genre_flag,
                    works_mystery_thriller_and_crime_genre_flag,
                    works_poetry_genre_flag,
                    works_romance_genre_flag,
                    works_young_adult_genre_flag,
                    works_image_url,
                    works_reviews_count,
                    works_text_reviews_count,
                    works_5_star_ratings,
                    works_4_star_ratings,
                    works_3_star_ratings,
                    works_2_star_ratings,
                    works_1_star_ratings,
                    works_ratings_count,
                    works_average_rating,
                    works_similar_books
                    FROM (
                            SELECT 
                            works_work_id,
                            TRIM(works_isbn) AS works_isbn,
                            works_isbn13,
                            TRIM(works_original_title) AS works_original_title,
                            TRIM(works_author) AS works_author,
                            works_original_publication_year,

                            CASE
	                            WHEN works_original_publication_year < 1450 THEN 'Manuscripts'
	                            WHEN works_original_publication_year BETWEEN 1451 AND 1500 THEN 'Incunabula'
	                            WHEN works_original_publication_year BETWEEN 1501 AND 1660 THEN 'Renaissance'
	                            WHEN works_original_publication_year BETWEEN 1661 AND 1785 THEN 'Neoclassical'
	                            WHEN works_original_publication_year BETWEEN 1786 AND 1836 THEN 'Romantic'
	                            WHEN works_original_publication_year BETWEEN 1837 AND 1901 THEN 'Victorian'
	                            WHEN works_original_publication_year BETWEEN 1890 AND 1914 THEN 'Edwardian'
	                            WHEN works_original_publication_year BETWEEN 1914 AND 1945 THEN 'Modernist'
	                            WHEN works_original_publication_year BETWEEN 1946 AND 1999 THEN 'Post-modernist'
                                WHEN works_original_publication_year > 1999 THEN 'Contemporary'
                            END AS works_literary_period,

                            works_num_pages,
                            TRIM(works_description) AS works_description,

                            CASE
                                WHEN works_genres LIKE '%children%' THEN 1
                                ELSE 0
                            END AS works_children_genre_flag,

                            CASE
                                WHEN works_genres LIKE '%comics%' OR works_genres LIKE '%graphics%' THEN 1
                                ELSE 0
                            END AS works_comics_and_graphics_genre_flag,

                            CASE
                                WHEN works_genres LIKE '%fantasy%' OR works_genres LIKE '%paranormal%' THEN 1
                                ELSE 0
                            END AS works_fantasy_and_paranormal_genre_flag,

                            CASE
                                WHEN works_genres LIKE '%history%' OR works_genres LIKE '%historical fiction%' OR works_genres LIKE '%biography%' THEN 1
                                ELSE 0
                            END AS works_history_and_biography_genre_flag,

                            CASE
                                WHEN works_genres LIKE '%mystery%' OR works_genres LIKE '%thriller%' OR works_genres LIKE '%crime%' THEN 1
                                ELSE 0
                            END AS works_mystery_thriller_and_crime_genre_flag,

                            CASE
                                WHEN works_genres LIKE '%poetry%' THEN 1
                                ELSE 0
                            END AS works_poetry_genre_flag,

                            CASE
                                WHEN works_genres LIKE '%romance%' THEN 1
                                ELSE 0
                            END AS works_romance_genre_flag,

                            CASE
                                WHEN works_genres LIKE '%young%' OR works_genres LIKE '%adult%' THEN 1
                                ELSE 0
                            END AS works_young_adult_genre_flag,

                            TRIM(works_image_url) AS works_image_url,
                            works_reviews_count,
                            works_text_reviews_count,
                            works_5_star_ratings,
                            works_4_star_ratings,
                            works_3_star_ratings,
                            works_2_star_ratings,
                            works_1_star_ratings,
                            works_ratings_count,
                            ROUND(CAST(
                                (1*works_1_star_ratings + 2*works_2_star_ratings + 3*works_3_star_ratings + 4*works_4_star_ratings + 5*works_5_star_ratings)
                            AS  FLOAT) / works_ratings_count, 1) AS works_average_rating,
                            REPLACE(works_similar_books, '_', '/') AS works_similar_books
                            FROM bronze.goodreads_works)t
	                    SET @end_time = GETDATE();
		                    PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
                            PRINT '>> -------------';

		        SET @batch_end_time = GETDATE();
		        PRINT '=========================================='
		        PRINT 'Loading Silver Layer is Completed';
                PRINT '   - Total Load Duration: ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds';
		        PRINT '=========================================='
		
	        END TRY
	        BEGIN CATCH
		        PRINT '=========================================='
		        PRINT 'ERROR OCCURED DURING LOADING BRONZE LAYER'
		        PRINT 'Error Message' + ERROR_MESSAGE();
		        PRINT 'Error Message' + CAST (ERROR_NUMBER() AS NVARCHAR);
		        PRINT 'Error Message' + CAST (ERROR_STATE() AS NVARCHAR);
		        PRINT '=========================================='
	        END CATCH
END
