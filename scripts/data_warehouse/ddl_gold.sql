/*
===============================================================================
DDL Script: Create Gold Views
===============================================================================
Script Purpose:
    This script creates views for the Gold layer in the data warehouse. 
    The Gold layer represents the final dimension and fact tables (Star Schema)

    Each view performs transformations and combines data from the Silver layer 
    to produce a clean, enriched, and business-ready dataset.

Usage:
    - These views can be queried directly for analytics and reporting.
===============================================================================
*/


-- =============================================================================
-- Create Fact Table: gold.fact_normal_reviews_summary
-- =============================================================================

IF OBJECT_ID('gold.fact_normal_reviews_summary', 'V') IS NOT NULL
    DROP VIEW gold.fact_normal_reviews_summary;
GO

CREATE VIEW gold.fact_normal_reviews_summary AS
WITH review_summary AS
(
    SELECT
        r.reviews_work_id AS work_id,

        -- Rating distribution
        SUM(CASE WHEN r.reviews_rating = 5 THEN 1 ELSE 0 END) AS english_5_star_ratings_count,
        SUM(CASE WHEN r.reviews_rating = 4 THEN 1 ELSE 0 END) AS english_4_star_ratings_count,
        SUM(CASE WHEN r.reviews_rating = 3 THEN 1 ELSE 0 END) AS english_3_star_ratings_count,
        SUM(CASE WHEN r.reviews_rating = 2 THEN 1 ELSE 0 END) AS english_2_star_ratings_count,
        SUM(CASE WHEN r.reviews_rating = 1 THEN 1 ELSE 0 END) AS english_1_star_ratings_count,

        -- Review metrics
        COUNT(r.reviews_rating) AS english_reviews_rating_count,
        SUM(COALESCE(r.reviews_n_votes, 0)) AS english_votes_count,
        COUNT(r.reviews_review_text) AS english_review_text_count,
        SUM(COALESCE(r.reviews_n_comments, 0)) AS english_comments_count,

        -- Shelf activity
        SUM(
            CASE
                WHEN r.dwh_review_status = 'Read' THEN 3
                WHEN r.dwh_review_status = 'Currently Reading' THEN 2
                WHEN r.dwh_review_status = 'Want to Read' THEN 1
                ELSE 0
            END
        ) AS english_total_shelf_weight,

        -- Read engagement rate
        CAST(
            SUM(
                CASE
                    WHEN r.dwh_review_status = 'Read' THEN 1
                    ELSE 0
                END
            ) * 1.0
            / NULLIF(COUNT(*), 0)
            AS DECIMAL(10,4)
        ) AS english_engagement_rate

    FROM silver.goodreads_reviews r

    WHERE r.dwh_review_type <> 'Anticipatory Review'
      AND r.dwh_review_status <> 'Data Quality Issue'

    GROUP BY
        r.reviews_work_id
),

interaction_scores AS
(
    SELECT
        rs.work_id,

        rs.english_5_star_ratings_count,
        rs.english_4_star_ratings_count,
        rs.english_3_star_ratings_count,
        rs.english_2_star_ratings_count,
        rs.english_1_star_ratings_count,

        rs.english_reviews_rating_count,
        rs.english_votes_count,
        rs.english_review_text_count,
        rs.english_comments_count,
        rs.english_total_shelf_weight,
        rs.english_engagement_rate,

        w.works_ratings_count AS total_ratings_count,
        w.works_text_reviews_count AS total_text_reviews_count,
        w.works_reviews_count AS total_reviews_count,

        CASE
            WHEN w.works_reviews_count > w.works_text_reviews_count
                THEN w.works_reviews_count - w.works_text_reviews_count
            ELSE 0
        END AS total_interaction_count

    FROM review_summary rs

    INNER JOIN silver.goodreads_works w
        ON rs.work_id = w.works_work_id
),

normalization_limits AS
(
    SELECT
        MIN(total_ratings_count) AS min_total_ratings_count,
        MAX(total_ratings_count) AS max_total_ratings_count,

        MIN(total_text_reviews_count) AS min_total_text_reviews_count,
        MAX(total_text_reviews_count) AS max_total_text_reviews_count,

        MIN(total_reviews_count) AS min_total_reviews_count,
        MAX(total_reviews_count) AS max_total_reviews_count,

        MIN(total_interaction_count) AS min_total_interaction_count,
        MAX(total_interaction_count) AS max_total_interaction_count

    FROM interaction_scores
),

engagement_rank AS
(
SELECT
    t.work_id,

    -- ==========================================
    -- ENGLISH RATING DISTRIBUTION
    -- ==========================================

    t.english_5_star_ratings_count,
    t.english_4_star_ratings_count,
    t.english_3_star_ratings_count,
    t.english_2_star_ratings_count,
    t.english_1_star_ratings_count,

    -- ==========================================
    -- ENGLISH REVIEW METRICS
    -- ==========================================

    t.english_reviews_rating_count,
    t.english_votes_count,
    t.english_review_text_count,
    t.english_comments_count,
    t.english_total_shelf_weight,

    -- ==========================================
    -- ENGLISH READER ENGAGEMENT
    -- ==========================================

    t.english_reviews_rating_count
        + 2 * t.english_votes_count
        + 3 * t.english_review_text_count
        + 4 * t.english_comments_count
        + 5 * t.english_total_shelf_weight
        AS english_reader_engagement,

    t.english_engagement_rate,

    -- ==========================================
    -- ENGLISH INFLUENCE SCORE
    -- ==========================================

    CAST(
        (
            t.english_votes_count
            + t.english_comments_count
        ) * 1.0
        / NULLIF(t.english_review_text_count, 0)
        AS DECIMAL(10,2)
    ) AS english_influence_score,

    -- ==========================================
    -- GOODREADS WORK-LEVEL TOTALS
    -- ==========================================

    t.total_ratings_count,
    t.total_text_reviews_count,
    t.total_reviews_count,

    t.total_interaction_count,

    -- ==========================================
    -- NORMALIZED RATINGS
    -- ==========================================

    CAST(
        (
            t.total_ratings_count
            - n.min_total_ratings_count
        ) * 1.0
        /
        NULLIF(
            n.max_total_ratings_count
            - n.min_total_ratings_count,
            0
        )
        AS DECIMAL(10,4)
    ) AS normalized_total_ratings_count,

    -- ==========================================
    -- NORMALIZED TEXT REVIEWS
    -- ==========================================

    CAST(
        (
            t.total_text_reviews_count
            - n.min_total_text_reviews_count
        ) * 1.0
        /
        NULLIF(
            n.max_total_text_reviews_count
            - n.min_total_text_reviews_count,
            0
        )
        AS DECIMAL(10,4)
    ) AS normalized_total_text_reviews_count,

    -- ==========================================
    -- NORMALIZED TOTAL REVIEWS
    -- ==========================================

    CAST(
        (
            t.total_reviews_count
            - n.min_total_reviews_count
        ) * 1.0
        /
        NULLIF(
            n.max_total_reviews_count
            - n.min_total_reviews_count,
            0
        )
        AS DECIMAL(10,4)
    ) AS normalized_total_reviews_count,

    -- ==========================================
    -- NORMALIZED INTERACTIONS
    -- ==========================================

    CAST(
        (
            t.total_interaction_count
            - n.min_total_interaction_count
        ) * 1.0
        /
        NULLIF(
            n.max_total_interaction_count
            - n.min_total_interaction_count,
            0
        )
        AS DECIMAL(10,4)
    ) AS normalized_total_interaction_count,

    -- ==========================================
    -- TOTAL READER ENGAGEMENT
    -- ==========================================

CAST(
    (
        (
            t.total_ratings_count
            - n.min_total_ratings_count
        ) * 1.0
        /
        NULLIF(
            n.max_total_ratings_count
            - n.min_total_ratings_count,
            0
        )

        +

        2 *
        (
            t.total_text_reviews_count
            - n.min_total_text_reviews_count
        ) * 1.0
        /
        NULLIF(
            n.max_total_text_reviews_count
            - n.min_total_text_reviews_count,
            0
        )

        +

        3 *
        (
            t.total_interaction_count
            - n.min_total_interaction_count
        ) * 1.0
        /
        NULLIF(
            n.max_total_interaction_count
            - n.min_total_interaction_count,
            0
        )
    ) * 1000000
    AS INTEGER
) AS total_reader_engagement,

    -- ==========================================
    -- TOTAL INFLUENCE SCORE
    -- ==========================================

    CAST(
        t.total_interaction_count * 1.0
        / NULLIF(t.total_text_reviews_count, 0)
        AS DECIMAL(10,2)
    ) AS total_influence_score

FROM interaction_scores t

CROSS JOIN normalization_limits n
)
SELECT
work_id,
english_5_star_ratings_count,
english_4_star_ratings_count,
english_3_star_ratings_count,
english_2_star_ratings_count,
english_1_star_ratings_count,
english_reviews_rating_count,
english_votes_count,
english_review_text_count,
english_comments_count,
english_total_shelf_weight,
english_reader_engagement,
english_engagement_rate,
english_influence_score,
total_ratings_count,
total_text_reviews_count,
total_reviews_count,
total_interaction_count,
normalized_total_ratings_count,
normalized_total_text_reviews_count,
normalized_total_reviews_count,
normalized_total_interaction_count,
total_reader_engagement,

DENSE_RANK() OVER( 
            ORDER BY  total_reader_engagement
            DESC
            ) AS engagement_rank,

total_influence_score
FROM engagement_rank;

GO

-- =============================================================================
-- Create Fact Table: gold.fact_all_reviews_summary
-- =============================================================================
IF OBJECT_ID('gold.fact_all_reviews_summary', 'V') IS NOT NULL
    DROP VIEW gold.fact_all_reviews_summary;
GO

CREATE VIEW gold.fact_all_reviews_summary AS
WITH filtered_works AS
(
    SELECT
        works_work_id AS work_id,
        works_original_publication_year AS publication_year,
        works_literary_period,

        works_5_star_ratings,
        works_4_star_ratings,
        works_3_star_ratings,
        works_2_star_ratings,
        works_1_star_ratings,
        works_ratings_count,
        works_average_rating,

        SQRT(
            (
                works_5_star_ratings * SQUARE(5.0 - works_average_rating) +
                works_4_star_ratings * SQUARE(4.0 - works_average_rating) +
                works_3_star_ratings * SQUARE(3.0 - works_average_rating) +
                works_2_star_ratings * SQUARE(2.0 - works_average_rating) +
                works_1_star_ratings * SQUARE(1.0 - works_average_rating)
            )
            / NULLIF(works_ratings_count, 0)
        ) AS total_standard_deviation

    FROM silver.goodreads_works
    WHERE works_original_publication_year < 2019
),

discoverability_score AS
(
    SELECT
        r.reviews_work_id AS work_id,

        w.publication_year,
        w.works_literary_period,

        -- Review engagement
        SUM(r.reviews_n_votes) AS n_votes_count,
        COUNT(r.reviews_review_text) AS text_reviews_count,
        SUM(r.reviews_n_comments) AS n_comments_count,

        -- Rating distribution
        SUM(CASE WHEN r.reviews_rating = 5 THEN 1 ELSE 0 END)
            AS english_5_star_ratings_count,

        SUM(CASE WHEN r.reviews_rating = 4 THEN 1 ELSE 0 END)
            AS english_4_star_ratings_count,

        SUM(CASE WHEN r.reviews_rating = 3 THEN 1 ELSE 0 END)
            AS english_3_star_ratings_count,

        SUM(CASE WHEN r.reviews_rating = 2 THEN 1 ELSE 0 END)
            AS english_2_star_ratings_count,

        SUM(CASE WHEN r.reviews_rating = 1 THEN 1 ELSE 0 END)
            AS english_1_star_ratings_count,

        COUNT(r.reviews_rating) AS english_total_ratings_count,

        CAST(
            AVG(r.reviews_rating * 1.0)
            AS DECIMAL(10,2)
        ) AS english_average_rating,

        SUM(r.dwh_text_review_length) AS english_total_review_length,

        -- Goodreads work-level totals
        w.works_5_star_ratings AS total_5_star_ratings,
        w.works_4_star_ratings AS total_4_star_ratings,
        w.works_3_star_ratings AS total_3_star_ratings,
        w.works_2_star_ratings AS total_2_star_ratings,
        w.works_1_star_ratings AS total_1_star_ratings,

        w.works_ratings_count AS total_ratings_count,
        w.works_average_rating AS total_average_rating,
        w.total_standard_deviation

    FROM silver.goodreads_reviews AS r

    INNER JOIN filtered_works AS w
        ON r.reviews_work_id = w.work_id

    WHERE r.dwh_review_status <> 'Data Quality Issue'

    GROUP BY
        r.reviews_work_id,
        w.publication_year,
        w.works_literary_period,

        w.works_5_star_ratings,
        w.works_4_star_ratings,
        w.works_3_star_ratings,
        w.works_2_star_ratings,
        w.works_1_star_ratings,

        w.works_ratings_count,
        w.works_average_rating,
        w.total_standard_deviation
),

rating_threshold AS
(
    SELECT DISTINCT
        works_literary_period,

        PERCENTILE_CONT(0.75)
            WITHIN GROUP (
                ORDER BY total_ratings_count
            )
            OVER (
                PARTITION BY works_literary_period
            ) AS minimum_rating_threshold

    FROM discoverability_score
),

book_ranking AS
(
SELECT
    d.work_id,
    d.publication_year,
    d.works_literary_period,

    d.n_votes_count,
    d.text_reviews_count,
    d.n_comments_count,

    d.english_5_star_ratings_count,
    d.english_4_star_ratings_count,
    d.english_3_star_ratings_count,
    d.english_2_star_ratings_count,
    d.english_1_star_ratings_count,

    d.english_total_ratings_count,
    d.english_average_rating,
    d.english_total_review_length,

    -- Discoverability Index
    LOG(
        1.0 + d.total_ratings_count,
        100.0
    )
    *
    (
        d.text_reviews_count * 1.0
        / NULLIF(2018 - d.publication_year + 1, 0)
    )
    *
    (
        1.0 +
        (
            d.n_votes_count + d.n_comments_count
        )
        / NULLIF(d.text_reviews_count + 1.0, 0)
    ) AS discoverability_index,

    d.total_5_star_ratings,
    d.total_4_star_ratings,
    d.total_3_star_ratings,
    d.total_2_star_ratings,
    d.total_1_star_ratings,

    d.total_ratings_count,
    d.total_average_rating,
    d.total_standard_deviation,

    CASE
                WHEN d.total_5_star_ratings < d.total_1_star_ratings
                    THEN d.total_5_star_ratings
                ELSE d.total_1_star_ratings
            END AS minimum_extremes,

    t.minimum_rating_threshold,

    -- Controversy Score
    d.total_standard_deviation
    *
    (
        (
            CASE
                WHEN d.total_5_star_ratings < d.total_1_star_ratings
                    THEN d.total_5_star_ratings
                ELSE d.total_1_star_ratings
            END
        )
        /
        NULLIF(
            d.total_ratings_count
            + t.minimum_rating_threshold,
            0
        )
    ) AS controversy_score

FROM discoverability_score AS d

LEFT JOIN rating_threshold AS t
    ON d.works_literary_period = t.works_literary_period
)
SELECT
    work_id,
    n_votes_count,
    text_reviews_count,
    n_comments_count,
    english_5_star_ratings_count,
    english_4_star_ratings_count,
    english_3_star_ratings_count,
    english_2_star_ratings_count,
    english_1_star_ratings_count,
    english_total_ratings_count,
    english_average_rating,
    english_total_review_length,
    discoverability_index,
    DENSE_RANK() OVER( 
            ORDER BY  discoverability_index
            DESC
            ) AS discoverability_rank,

    total_5_star_ratings,
    total_4_star_ratings,
    total_3_star_ratings,
    total_2_star_ratings,
    total_1_star_ratings,
    total_ratings_count,
    total_average_rating,
    total_standard_deviation,
    minimum_extremes,
    minimum_rating_threshold,
    controversy_score,

    DENSE_RANK() OVER( 
            ORDER BY controversy_score
            DESC
            ) AS controversy_rank
FROM book_ranking;
GO

-- =============================================================================
-- Create Dimension: gold.dim_books
-- =============================================================================
IF OBJECT_ID('gold.dim_books', 'V') IS NOT NULL
    DROP VIEW gold.dim_books;
GO

CREATE VIEW gold.dim_books AS
SELECT
    works_work_id AS work_id,
    works_original_title AS title,
    works_author AS author,
    works_original_publication_year AS publication_year,
    works_literary_period AS literary_period
FROM silver.goodreads_works
WHERE works_original_publication_year < 2019
      OR works_original_publication_year IS NULL
GO

-- =============================================================================
-- Create Dimension: gold.bridge_genres
-- =============================================================================
IF OBJECT_ID('gold.bridge_genres', 'V') IS NOT NULL
    DROP VIEW gold.bridge_genres;
GO

CREATE VIEW gold.bridge_genres AS
SELECT
    works_work_id AS work_id,
    'Children' AS genres
FROM silver.goodreads_works
WHERE works_children_genre_flag = 1

UNION ALL

SELECT
    works_work_id AS work_id,
    'Comics & Graphics' AS genres
FROM silver.goodreads_works
WHERE works_comics_and_graphics_genre_flag = 1

UNION ALL

SELECT
    works_work_id AS work_id,
    'Fantasy & Paranormal' AS genres
FROM silver.goodreads_works
WHERE works_fantasy_and_paranormal_genre_flag = 1

UNION ALL

SELECT
    works_work_id AS work_id,
    'History & Biography' AS genres
FROM silver.goodreads_works
WHERE works_history_and_biography_genre_flag = 1

UNION ALL

SELECT
    works_work_id AS work_id,
    'Mystery, Thriller & Crime' AS genres
FROM silver.goodreads_works
WHERE works_mystery_thriller_and_crime_genre_flag = 1

UNION ALL

SELECT
    works_work_id AS work_id,
    'Poetry' AS genres
FROM silver.goodreads_works
WHERE works_poetry_genre_flag = 1

UNION ALL

SELECT
    works_work_id AS work_id,
    'Romance' AS genres
FROM silver.goodreads_works
WHERE works_romance_genre_flag = 1

UNION ALL

SELECT
    works_work_id AS work_id,
    'Young Adult' AS genres
FROM silver.goodreads_works
WHERE works_young_adult_genre_flag = 1
GO

-- =============================================================================
-- Create Fact Table: gold.fact_authors
-- =============================================================================

IF OBJECT_ID('gold.fact_authors', 'V') IS NOT NULL
    DROP VIEW gold.fact_authors;
GO

CREATE VIEW gold.fact_authors AS
WITH bayesian_reputation AS
(
    SELECT DISTINCT
        works_author AS author,
        works_work_id AS work_id,
        works_ratings_count AS ratings_count,
        works_average_rating AS average_rating,

        COUNT(works_work_id) OVER (
            PARTITION BY works_author
        ) AS book_count,

        STDEVP(works_average_rating) OVER (
            PARTITION BY works_author
        ) AS standard_deviation,

        PERCENTILE_CONT(0.75)
            WITHIN GROUP (
                ORDER BY works_ratings_count
            )
            OVER (
                PARTITION BY works_author
            ) AS minimum_rating_threshold,

        PERCENTILE_CONT(0.75)
            WITHIN GROUP (
                ORDER BY works_average_rating
            )
            OVER (
                PARTITION BY works_author
            ) AS overall_average_rating

    FROM silver.goodreads_works

    WHERE works_original_publication_year < 2019
       OR works_original_publication_year IS NULL
),

author_reputation AS
(
    SELECT
        CASE
                WHEN book_count > 20 THEN 'Prolific Author'
                WHEN book_count BETWEEN 11 AND 20 THEN 'Established Author'
                WHEN book_count BETWEEN 2 AND 10 THEN 'Emerging Author'
                ELSE 'Debut Author'
        END AS author_type,
        
        author,
        work_id,
        book_count,
        ratings_count,
        standard_deviation,
        minimum_rating_threshold,
        average_rating,
        overall_average_rating,

        (
            (
                average_rating
                * (
                    CAST(ratings_count AS FLOAT)
                    / NULLIF(
                        ratings_count + minimum_rating_threshold,
                        0
                    )
                )
            )
            +
            (
                overall_average_rating
                * (
                    CAST(minimum_rating_threshold AS FLOAT)
                    / NULLIF(
                        ratings_count + minimum_rating_threshold,
                        0
                    )
                )
            )
        ) * 0.5
        *
        0.25 * LOG(1 + book_count, 100)
        *
        (
            1 - (
                standard_deviation / 2.0
            )
        ) * 0.25 AS author_reputation

    FROM bayesian_reputation
)

SELECT
    a.author_type,
    a.author,
    a.work_id,
    a.book_count,
    a.standard_deviation,
    a.ratings_count,
    a.minimum_rating_threshold,
    average_rating,
    a.overall_average_rating,
    a.author_reputation,

    DENSE_RANK() OVER (
        ORDER BY a.author_reputation DESC
    ) AS reputation_rank,

    s.satisfaction_score,

            PERCENTILE_CONT(0.5)
            WITHIN GROUP (
                ORDER BY s.satisfaction_score
            )
            OVER (
                PARTITION BY a.author
            ) AS author_rating

FROM author_reputation a
INNER JOIN gold.fact_satisfaction s
ON s.work_id = a.work_id;
GO

-- =============================================================================
-- Create Fact Table: gold.fact_satisfaction
-- =============================================================================

IF OBJECT_ID('gold.fact_satisfaction', 'V') IS NOT NULL
    DROP VIEW gold.fact_satisfaction;
GO

CREATE VIEW gold.fact_satisfaction AS
WITH reader_satisfaction AS
(
    SELECT
        a.work_id,

        a.total_ratings_count
        - (a.english_total_ratings_count - n.english_reviews_rating_count) AS real_ratings_count,

        CAST(
            (
                1.0 *
                (
                    1 * (a.total_1_star_ratings - (a.english_1_star_ratings_count - n.english_1_star_ratings_count))
                  + 2 * (a.total_2_star_ratings - (a.english_2_star_ratings_count - n.english_2_star_ratings_count))
                  + 3 * (a.total_3_star_ratings - (a.english_3_star_ratings_count - n.english_3_star_ratings_count))
                  + 4 * (a.total_4_star_ratings - (a.english_4_star_ratings_count - n.english_4_star_ratings_count))
                  + 5 * (a.total_5_star_ratings - (a.english_5_star_ratings_count - n.english_5_star_ratings_count))
                )
            )
            /
            NULLIF(
                a.total_ratings_count
                - (a.english_total_ratings_count - n.english_reviews_rating_count),
                0
            )
            AS DECIMAL(10, 2)
        ) AS real_average_rating

    FROM gold.fact_all_reviews_summary AS a
    LEFT JOIN gold.fact_normal_reviews_summary AS n
        ON a.work_id = n.work_id
),

bayesian_satisfaction AS
(
    SELECT
        s.work_id,
        s.real_ratings_count,
        s.real_average_rating,
        b.literary_period,

        PERCENTILE_CONT(0.75)
            WITHIN GROUP (ORDER BY s.real_ratings_count)
            OVER (PARTITION BY b.literary_period) AS minimum_rating_threshold,

        AVG(s.real_average_rating)
            OVER (PARTITION BY b.literary_period) AS overall_average_rating

    FROM reader_satisfaction AS s
    LEFT JOIN gold.dim_books AS b
        ON s.work_id = b.work_id
),

satisfaction_score AS
(
    SELECT
    work_id,
    real_ratings_count,
    real_average_rating,
    minimum_rating_threshold,
    overall_average_rating,

        (
            real_average_rating
            * (
                real_ratings_count
                / NULLIF(
                    real_ratings_count + minimum_rating_threshold,
                    0
                )
            )
        )
        +
        (
            overall_average_rating
            * (
                minimum_rating_threshold
                / NULLIF(
                    real_ratings_count + minimum_rating_threshold,
                    0
                )
            )
        ) AS satisfaction_score
    FROM bayesian_satisfaction
)
    SELECT
    work_id,
    real_ratings_count,
    minimum_rating_threshold,
    real_average_rating,
    overall_average_rating,
    satisfaction_score,
    DENSE_RANK() OVER( 
            ORDER BY satisfaction_score
            DESC
            ) AS satisfaction_rank
    FROM satisfaction_score
    WHERE satisfaction_score IS NOT NULL;
GO

-- =============================================================================
-- Create Fact Table: gold.fact_customer_cohort
-- =============================================================================

IF OBJECT_ID('gold.fact_customer_cohort', 'V') IS NOT NULL
    DROP VIEW gold.fact_customer_cohort;
GO

CREATE VIEW gold.fact_customer_cohort AS
WITH reviewer_cohort AS
(
    SELECT
        reviews_user_id,
        YEAR(MIN(reviews_date_added)) AS cohort_year
    FROM silver.goodreads_reviews
    GROUP BY reviews_user_id
),

review_activity AS
(
    SELECT
        r.reviews_user_id,
        rc.cohort_year,
        YEAR(r.reviews_date_added) AS review_year,
        YEAR(r.reviews_date_added) - rc.cohort_year AS cohort_age,
        w.works_literary_period
    FROM silver.goodreads_reviews r
    INNER JOIN reviewer_cohort rc
        ON r.reviews_user_id = rc.reviews_user_id
    INNER JOIN silver.goodreads_works w
        ON r.reviews_work_id = w.works_work_id
    WHERE rc.cohort_year BETWEEN 2006 AND 2017
),

cohort_size AS
(
    SELECT
        cohort_year,
        COUNT(DISTINCT reviews_user_id) AS cohort_size
    FROM review_activity
    WHERE cohort_age = 0
    GROUP BY cohort_year
),

review_summary AS
(
    SELECT
        cohort_year,
        works_literary_period,
        cohort_age,

        COUNT(reviews_user_id) AS reviews_count,
        COUNT(DISTINCT reviews_user_id) AS reviewers_count

    FROM review_activity
    GROUP BY
        cohort_year,
        works_literary_period,
        cohort_age
),

overall_retention AS
(
    SELECT
        cohort_year,
        cohort_age,

        COUNT(DISTINCT reviews_user_id) AS overall_reviewers

    FROM review_activity
    GROUP BY
        cohort_year,
        cohort_age
)
SELECT
    cs.cohort_year,
    cs.cohort_size,

    rs.works_literary_period,
    rs.cohort_age,

    o.overall_reviewers,

    rs.reviewers_count,
    rs.reviews_count

FROM cohort_size cs

INNER JOIN review_summary rs
    ON cs.cohort_year = rs.cohort_year

INNER JOIN overall_retention o
    ON rs.cohort_year = o.cohort_year
   AND rs.cohort_age = o.cohort_age

WHERE rs.cohort_age < 13;
 GO
