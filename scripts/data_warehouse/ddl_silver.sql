/*
===============================================================================
DDL Script: Create Silver Tables
===============================================================================
Script Purpose:
    This script creates tables in the 'silver' schema, dropping existing tables 
    if they already exist.
	  Run this script to re-define the DDL structure of 'silver' Tables
===============================================================================
*/

IF OBJECT_ID('silver.goodreads_reviews', 'U') IS NOT NULL
    DROP TABLE silver.goodreads_reviews;
GO

CREATE TABLE silver.goodreads_reviews(
    reviews_review_id       VARCHAR(50),
    reviews_user_id         VARCHAR(50),
    reviews_work_id         BIGINT,
    reviews_started_at      DATE,
    reviews_read_at         DATE,
    reviews_date_added      DATE,
    dwh_review_type         VARCHAR(100),
    dwh_review_status       VARCHAR(100),
    dwh_reader_type         VARCHAR(100),
    dwh_critic_type         VARCHAR(100),
    reviews_rating          INT,
    reviews_review_text     VARCHAR(MAX),
    dwh_text_review_length  INT,
    reviews_n_votes         INT,
    reviews_n_comments      INT,
    dwh_create_date         DATETIME2           DEFAULT GETDATE(),
);
GO

IF OBJECT_ID('silver.goodreads_works', 'U') IS NOT NULL
    DROP TABLE silver.goodreads_works;
GO

CREATE TABLE silver.goodreads_works(
    works_work_id                                                   BIGINT,
    works_isbn                                                      VARCHAR(250),
    works_isbn13                                                    FLOAT,
    works_original_title                                            VARCHAR(1000),
    works_author                                                    VARCHAR(500),
    works_original_publication_year                                 INT,
    works_literary_period                                           VARCHAR(75),
    works_num_pages                                                 INT,
    works_description                                               VARCHAR(MAX),
    works_children_genre_flag                                       INT,
    works_comics_and_graphics_genre_flag                            INT,
    works_fantasy_and_paranormal_genre_flag                         INT,
    works_history_and_biography_genre_flag                          INT,
    works_mystery_thriller_and_crime_genre_flag                     INT,
    works_poetry_genre_flag                                         INT,
    works_romance_genre_flag                                        INT,
    works_young_adult_genre_flag                                    INT,
    works_image_url                                                 VARCHAR(255),
    works_reviews_count                                             BIGINT,                       
    works_text_reviews_count                                        BIGINT,
    works_5_star_ratings                                            BIGINT,
    works_4_star_ratings                                            BIGINT,
    works_3_star_ratings                                            BIGINT,
    works_2_star_ratings                                            BIGINT,
    works_1_star_ratings                                            BIGINT,
    works_ratings_count                                             BIGINT,
    works_average_rating                                            DECIMAL(10,2),
    works_similar_books                                             VARCHAR(MAX),
    dwh_create_date                                                 DATETIME2                   DEFAULT GETDATE(),
);
GO
