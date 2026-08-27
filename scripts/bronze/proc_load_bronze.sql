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

create or alter procedure bronze.load_bronze as 
  begin
  DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME; 
  begin try 
   SET @batch_start_time = GETDATE();
     print'======================================================================';
     print'load bronze layer';
     print'======================================================================';

     print'----------------------------------------------------------------------';
     print 'load CRM data';
     print'----------------------------------------------------------------------';

     print'>> truncate table bronze.crm_cust_info  ';

     SET @start_time = GETDATE();
     truncate table bronze.crm_cust_info 

     print'>> insert table bronze.crm_cust_info';
     bulk insert bronze.crm_cust_info 
     from 'D:\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
     with
     (
     firstrow =2, --skip the first row because it is the columns names
     fieldterminator=',', -- the separator between columns in the csv file
     tablock

     );
     SET @end_time = GETDATE();

     select count(*) from bronze.crm_cust_info 

     print'>> truncate table bronze.crm_prd_info  ';

     SET @start_time = GETDATE();
     truncate table bronze.crm_prd_info 

     print'>> insert table bronze.crm_prd_info ';
     bulk insert bronze.crm_prd_info  
     from 'D:\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
     with
     (
     firstrow =2, --skip the first row because it is the columns names
     fieldterminator=',', -- the separator between columns in the csv file
     tablock

     );
     SET @end_time = GETDATE();

     select count(*) from bronze.crm_prd_info 

     print'>> truncate table bronze.crm_sales_details ';

     SET @start_time = GETDATE();
     truncate table bronze.crm_sales_details 

     print'>> insert table bronze.crm_sales_details  ';
     bulk insert bronze.crm_sales_details 
     from 'D:\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
     with
     (
     firstrow =2, --skip the first row because it is the columns names
     fieldterminator=',', -- the separator between columns in the csv file
     tablock

     );
     SET @end_time = GETDATE();
     select count(*) from bronze.crm_sales_details 

     print'----------------------------------------------------------------------';
     print 'load CRM data';
     print'----------------------------------------------------------------------';

     print'>> truncate table bronze.erp_cust_az12 ';

     SET @start_time = GETDATE();
     truncate table bronze.erp_cust_az12 

     print'>> insert table bronze.erp_cust_az12 ';
     bulk insert bronze.erp_cust_az12  
     from 'D:\sql-data-warehouse-project\datasets\source_erp\cust_az12.csv'
     with
     (
     firstrow =2, --skip the first row because it is the columns names
     fieldterminator=',', -- the separator between columns in the csv file
     tablock

     );
     SET @end_time = GETDATE();

     select count(*) from bronze.erp_cust_az12  

     print'>> truncate table bronze.erp_loc_a101 ';

     SET @start_time = GETDATE();
     truncate table bronze.erp_loc_a101 

     print'>> insert table bronze.erp_loc_a101 ';
     bulk insert bronze.erp_loc_a101  
     from 'D:\sql-data-warehouse-project\datasets\source_erp\loc_a101.csv'
     with
     (
     firstrow =2, --skip the first row because it is the columns names
     fieldterminator=',', -- the separator between columns in the csv file
     tablock

     );
     SET @end_time = GETDATE();

     select count(*) from bronze.erp_loc_a101  

     print'>> truncate table bronze.erp_px_cat_g1v2 ';

     SET @start_time = GETDATE();
     truncate table bronze.erp_px_cat_g1v2

     print'>> insert table bronze.erp_px_cat_g1v2  ';
     bulk insert bronze.erp_px_cat_g1v2 
     from 'D:\sql-data-warehouse-project\datasets\source_erp\px_cat_g1v2.csv'
     with
      (
     firstrow =2, --skip the first row because it is the columns names
     fieldterminator=',', -- the separator between columns in the csv file
     tablock

     );
     SET @end_time = GETDATE();

     select count(*) from bronze.erp_px_cat_g1v2

     	PRINT '=========================================='
		PRINT 'Loading Bronze Layer is Completed';
        PRINT ' - Total Load Duration: ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds';
		PRINT '=========================================='
     end try 
     begin catch 
         print'error occurd during loading data';
         print'error message' + error_message();
         print'error message' + cast(error_number() as nvarchar);
         print'error message' + cast(error_state() as nvarchar);
     end catch
end
