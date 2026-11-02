/*
===============================================================================
Book Trend Analysis
===============================================================================
Purpose:
    - To track trends, growth, and changes in reader engagement over publication year.
    - For time-series analysis and identifying seasonality.
    - To measure growth or decline over specific periods.

SQL Functions Used:
    - Aggregate Functions: PERCENTILE_CONT()
    - WHERE: Defines the allowable range
    - ORDER BY: Arranges the data
===============================================================================
*/

-- Analyse total reader engagements per publication year
SELECT DISTINCT
        b.publication_year,
        ROUND(PERCENTILE_CONT(0.5)
        WITHIN GROUP (ORDER BY e.english_reader_engagement)
        OVER (PARTITION BY b.publication_year), 0) AS median_english_reader_engagement,
        ROUND(PERCENTILE_CONT(0.5)
        WITHIN GROUP (ORDER BY e.total_reader_engagement)
        OVER (PARTITION BY b.publication_year), 0) AS median_reader_engagement,
        ROUND(PERCENTILE_CONT(0.5)
        WITHIN GROUP (ORDER BY c.english_controversy_score)
        OVER (PARTITION BY b.publication_year), 2) AS median_english_controversy_score,
        ROUND(PERCENTILE_CONT(0.5)
        WITHIN GROUP (ORDER BY c.total_controversy_score)
        OVER (PARTITION BY b.publication_year), 2) AS median_controversy_score
FROM gold.dim_books b
LEFT JOIN gold.fact_engagements e
ON b.work_id = e.work_id
LEFT JOIN gold.fact_controversy c
ON b.work_id = c.work_id
WHERE publication_year <= 2017 AND publication_year >= 1450
ORDER BY b.publication_year DESC
