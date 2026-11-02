/*
===============================================================================
Stored Procedure: Load Bronze Layer (Source -> Bronze)
===============================================================================
Script Purpose:
    This stored procedure loads data into the 'bronze' schema from external CSV files. 
    It performs the following actions:
    - Truncates the bronze tables before loading data.
    - Uses the `BULK INSERT` command to load data from csv Files to bronze tables.

Parameters:
    None. 
	  This stored procedure does not accept any parameters or return any values.

Usage Example:
    EXEC bronze.load_bronze;
===============================================================================
*/
CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN
DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME; 
	BEGIN TRY
		SET @batch_start_time = GETDATE();
		PRINT '================================================';
		PRINT 'Loading Bronze Layer';
		PRINT '================================================';

        SET @start_time = GETDATE();
		PRINT '>> Truncating Table: bronze.goodreads_reviews';
        TRUNCATE TABLE bronze.goodreads_reviews;
        PRINT '>> Inserting Data Into: bronze.goodreads_reviews';
        BULK INSERT bronze.goodreads_reviews
        FROM 'C:\Users\Asus\Documents\Python Folder\cleaned csv\goodreads_reviews_cleaned.csv'
        WITH (
		        FIRSTROW = 2,
		        FIELDTERMINATOR = ',',
                ROWTERMINATOR = '\n',
		        TABLOCK
        );
        SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '>> -------------';

        SET @start_time = GETDATE();
		PRINT '>> Truncating Table: bronze.goodreads_works';
        TRUNCATE TABLE bronze.goodreads_works;
        PRINT '>> Inserting Data Into: bronze.goodreads_works';
        BULK INSERT bronze.goodreads_works
        FROM 'C:\Users\Asus\Downloads\Portfolios\Goodreads+Book+Reviews\goodreads_works_power_query.csv'
        WITH (
		        FIRSTROW = 2,
		        FIELDTERMINATOR = ',',
                ROWTERMINATOR = '\n',
		        TABLOCK
        );
        SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '>> -------------';

        SET @batch_end_time = GETDATE();
		PRINT '=========================================='
		PRINT 'Loading Bronze Layer is Completed';
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
