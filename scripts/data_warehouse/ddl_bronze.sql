/*
===============================================================================
DDL Script: Create Bronze Tables
===============================================================================
Script Purpose:
    This script creates tables in the 'bronze' schema, dropping existing tables 
    if they already exist.
	  Run this script to re-define the DDL structure of 'bronze' Tables
===============================================================================
*/

IF OBJECT_ID('bronze.goodreads_reviews', 'U') IS NOT NULL
    DROP TABLE bronze.goodreads_reviews;
GO

CREATE TABLE bronze.goodreads_reviews(
    reviews_review_id       VARCHAR(50),
    reviews_user_id         VARCHAR(50),
    reviews_work_id         BIGINT,
    reviews_started_at      VARCHAR(MAX), 
    reviews_read_at         VARCHAR(MAX),
    reviews_date_added      DATETIME,
    reviews_rating          DECIMAL(10,2),
    reviews_review_text     VARCHAR(MAX),
    reviews_n_votes         INT,
    reviews_n_comments      INT,
);
GO

IF OBJECT_ID('bronze.goodreads_works', 'U') IS NOT NULL
    DROP TABLE bronze.goodreads_works;
GO

CREATE TABLE bronze.goodreads_works(
    works_work_id                       BIGINT,
    works_isbn                          VARCHAR(MAX),
    works_isbn13                        FLOAT,
    works_original_title                VARCHAR(MAX),
    works_author                        VARCHAR(MAX),
    works_original_publication_year     INT,
    works_num_pages                     INT,
    works_description                   VARCHAR(MAX),
    works_genres                        VARCHAR(MAX),
    works_image_url                     VARCHAR(255),
    works_reviews_count                 BIGINT,                       
    works_text_reviews_count            BIGINT,
    works_5_star_ratings                BIGINT,
    works_4_star_ratings                BIGINT,
    works_3_star_ratings                BIGINT,
    works_2_star_ratings                BIGINT,
    works_1_star_ratings                BIGINT,
    works_ratings_count                 BIGINT,
    works_avg_rating                    DECIMAL(10,2),
    works_similar_books                 VARCHAR(MAX),
);
GO
