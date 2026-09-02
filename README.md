# 🏗️ SQL Data Warehouse & Analytics Project

End-to-End Data Warehouse built with Microsoft SQL Server using the Medallion Architecture (Bronze → Silver → Gold).

This project demonstrates how raw CRM and ERP data can be transformed into a clean, integrated, and analytics-ready data warehouse.

The pipeline covers database initialization, raw data ingestion, data cleansing, transformation, integration, dimensional modeling, ETL stored procedures, and data-quality validation.

# 📌 Project Overview

The goal of this project is to build a small but complete Data Warehouse that integrates data coming from different CRM and ERP source systems.

The project follows a layered architecture:

                 ┌─────────────────────┐
                 │   CRM / ERP CSVs    │
                 └──────────┬──────────┘
                            │
                            ▼
                 ┌─────────────────────┐
                 │    🥉 BRONZE        │
                 │  Raw / Staging Data │
                 └──────────┬──────────┘
                            │
                     ETL + Cleaning
                            │
                            ▼
                 ┌─────────────────────┐
                 │    🥈 SILVER        │
                 │ Cleaned & Integrated│
                 │       Data          │
                 └──────────┬──────────┘
                            │
                 Business Transformations
                            │
                            ▼
                 ┌─────────────────────┐
                 │     🥇 GOLD         │
                 │ Analytics-Ready     │
                 │    Star Schema      │
                 └──────────┬──────────┘
                            │
                            ▼
                    📊 Analytics /
                       Reporting

# 🎯 Objectives

Build a structured SQL Server Data Warehouse.

Load raw CRM and ERP data into a Bronze layer.

Clean, standardize, deduplicate, and transform data in the Silver layer.

Integrate information from multiple source systems.

Build business-ready Gold dimensions and fact views.

Implement reusable ETL stored procedures.

Validate data quality and referential integrity.

Demonstrate a Star Schema suitable for analytics and reporting.

# 🛠️ Technologies

Technology

Purpose

Microsoft SQL Server

Database & Data Warehouse

T-SQL

ETL, transformations, validation & modeling

BULK INSERT

Loading CSV source files

Stored Procedures

Automating Bronze & Silver ETL

Views

Creating Gold analytical models

SQL Window Functions

Deduplication & surrogate key generation

Medallion Architecture

Bronze → Silver → Gold

Star Schema

Analytical data modeling

# 🗂️ Source Data

The warehouse integrates two main source systems.

CRM

cust_info.csv — customer information

prd_info.csv — product information

sales_details.csv — sales transactions

ERP

cust_az12.csv — additional customer attributes

loc_a101.csv — customer location/country

px_cat_g1v2.csv — product categories and metadata

# 🥉 Bronze Layer — Raw Data

The Bronze layer acts as the landing/staging layer.

Data is loaded from CSV files with minimal transformation so that the original source structure can be preserved.

Main Bronze tables

bronze.crm_cust_info
bronze.crm_prd_info
bronze.crm_sales_details

bronze.erp_cust_az12
bronze.erp_loc_a101
bronze.erp_px_cat_g1v2

Loading process

The project uses BULK INSERT to load the CSV files.

The Bronze loading procedure:

EXEC bronze.load_bronze;

The procedure:

Truncates the existing Bronze table.

Loads the corresponding CSV file.

Uses the first row as column headers.

Records loading progress and duration.

Handles errors using TRY...CATCH.

# 🥈 Silver Layer — Cleansing & Transformation

The Silver layer contains cleaned, standardized, and integrated data.

Typical transformations include:

# 🧹 Data Cleaning

Removing unwanted spaces using TRIM().

Handling NULL values.

Replacing missing product costs with 0.

Standardizing categorical values.

Converting date fields to the appropriate DATE type.

Removing duplicate customer records.

# 🔄 Data Standardization

## Example:

CASE 
    WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
    WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
    ELSE 'n/a'
END

Gender values are also standardized:

F → Female
M → Male

Product lines are converted from source codes into readable business values:

M → Mountain
R → Road
S → Other Sales
T → Touring

# 🔑 Deduplication

## The project uses:

ROW_NUMBER() OVER (
    PARTITION BY cst_id
    ORDER BY cst_create_date DESC
)

to keep the latest customer record for each customer ID.

# 📅 Product Date Handling

LEAD() is used to derive product end dates based on the next product start date:

LEAD(prd_start_dt)
OVER (
    PARTITION BY prd_key
    ORDER BY prd_start_dt
)

# 🥇 Gold Layer — Analytics Model

The Gold layer provides business-ready analytical views.

The project follows a Star Schema consisting of:

                  ┌──────────────────┐
                  │  dim_customers   │
                  └────────┬─────────┘
                           │
                           │
                           ▼
┌──────────────────┐  ┌──────────────┐  ┌──────────────────┐
│  dim_products    │◄─┤  fact_sales  ├─►│   dim_customers  │
└──────────────────┘  └──────────────┘  └──────────────────┘

# 👤 Customer Dimension

gold.dim_customers

Contains:

Customer surrogate key

Customer ID

Customer number

First and last name

Country

Marital status

Gender

Birthdate

Creation date

A surrogate key is generated using:

ROW_NUMBER() OVER (ORDER BY cst_id)

# 🛍️ Product Dimension

gold.dim_products

Contains:

Product surrogate key

Product ID

Product number

Product name

Category

Subcategory

Maintenance

Cost

Product line

Start date

The Gold product view keeps the current product records by filtering historical records where:

prd_end_dt IS NULL

# 💰 Sales Fact

gold.fact_sales

Contains:

Order number

Product key

Customer key

Order date

Shipping date

Due date

Sales amount

Quantity

Price

The fact view connects sales transactions to the customer and product dimensions.

# 🔗 Data Integration

One important part of the project is resolving information that exists across different source systems.

For example, customer information is integrated from:

CRM Customer Data
        +
ERP Customer Data
        +
ERP Location Data
        ↓
gold.dim_customers

The project also handles conflicting gender values by treating the CRM gender as the primary source and using ERP as a fallback when the CRM value is unavailable.

# ⚙️ ETL Workflow

The complete workflow can be executed in the following order:

# 1️⃣ Initialize the database

## Run:

init_database.sql

This creates:

DataWarehouse
├── bronze
├── silver
└── gold

## ⚠️ init_database.sql drops and recreates the DataWarehouse database if it already exists. Make sure you have backups before running it.

# 2️⃣ Create Bronze tables

## Run:

sql-project-bronze-schema-tabels.sql

# 3️⃣ Create Silver tables

## Run:

ddl_silver.sql

# 4️⃣ Create Gold views

## Run:

ddl_gold.sql

# 5️⃣ Create Bronze loading procedure

## Run:

proc_load_bronze.sql

## Then execute:

EXEC bronze.load_bronze;

# 6️⃣ Create Silver loading procedure

## Run:

proc_load_silver.sql

## Then execute:

EXEC silver.load_silver;

# 7️⃣ Run data-quality checks

## For Silver:

quality_checks_silver.sql

## For Gold:

quality_checks_gold.sql

# 🧪 Data Quality Checks

The project includes dedicated validation scripts.

Silver Layer Checks

## The checks cover:

NULL primary keys

Duplicate records

Unwanted spaces

Negative or missing costs

Data standardization

Invalid date ranges

Data consistency

## Example:

SELECT 
    prd_id,
    COUNT(*)
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL;

Gold Layer Checks

## The Gold checks validate:

Dimension surrogate-key uniqueness

Fact-to-dimension relationships

Referential integrity

Missing customer/product keys

## Example:

SELECT *
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
    ON c.customer_key = f.customer_key
LEFT JOIN gold.dim_products p
    ON p.product_key = f.product_key
WHERE p.product_key IS NULL
   OR c.customer_key IS NULL;

The expected result is no unmatched records.

# 📁 Project Structure

datawarhouse final project/
│
├── init_database.sql
│
├── sql-project-bronze-schema-tabels.sql
├── ddl_silver.sql
├── ddl_gold.sql
│
├── bulk_insert_bronze_layer.sql
├── proc_load_bronze.sql
├── proc_load_silver.sql
├── silver layer stored procedure.sql
├── the 2 stored procedures.sql
│
├── data-cleasing-cust-table.sql
├── product_cleansing-table.sql
│
├── clean bronze.erp_cust_az12 and insert into silver.erp_cust_az12.sql
├── clean bronze.erp_loc101 and insert into silver.erp_loc101.sql
├── clean bronze.erp_px_cat_g1v2 and insert into silver.erp_px_cat_g1v2.sql
├── clean bronze.sales_detales and insert ino silver.sales_details.sql
│
├── create the dim customer (gold layer).sql
├── create the dim product (gold layer).sql
├── create fact sales (gold layer).sql
│
├── quality_checks_silver.sql
├── quality_checks_gold.sql
│
└── cheks.sql

# 🧠 Key SQL Concepts Demonstrated

This project demonstrates practical use of:

CREATE DATABASE

CREATE SCHEMA

CREATE TABLE

CREATE VIEW

CREATE OR ALTER PROCEDURE

BULK INSERT

TRUNCATE TABLE

INSERT INTO ... SELECT

CASE WHEN

COALESCE

ISNULL

TRIM

REPLACE

SUBSTRING

CAST

ROW_NUMBER()

LEAD()

LEFT JOIN

GROUP BY

HAVING

TRY...CATCH

Data-quality validation

Dimensional modeling

Star Schema design

# 🚀 How to Run the Project

Prerequisites

Microsoft SQL Server

SQL Server Management Studio (SSMS)

Access to the source CSV files

Appropriate permissions for BULK INSERT

Recommended execution order

1. init_database.sql
          ↓
2. Bronze DDL
          ↓
3. Silver DDL
          ↓
4. Gold DDL
          ↓
5. Bronze Load Procedure
          ↓
6. EXEC bronze.load_bronze
          ↓
7. Silver Load Procedure
          ↓
8. EXEC silver.load_silver
          ↓
9. Gold Views
          ↓
10. Data Quality Checks

## ⚠️ Important: CSV File Paths

The Bronze loading scripts contain local Windows paths such as:

D:\sql-data-warehouse-project\datasets\source_crm\...

Before running the ETL, update these paths to match the location of your CSV files on your machine.

## 📊 Example Analytical Queries

After the warehouse is loaded, the Gold layer can be queried directly.

Total Sales

SELECT SUM(sales_amount) AS total_sales
FROM gold.fact_sales;

Sales by Product

SELECT
    p.product_name,
    SUM(f.sales_amount) AS total_sales
FROM gold.fact_sales f
JOIN gold.dim_products p
    ON f.product_key = p.product_key
GROUP BY p.product_name
ORDER BY total_sales DESC;

Sales by Country

SELECT
    c.country,
    SUM(f.sales_amount) AS total_sales
FROM gold.fact_sales f
JOIN gold.dim_customers c
    ON f.customer_key = c.customer_key
GROUP BY c.country
ORDER BY total_sales DESC;

# 🌟 What This Project Shows

This project demonstrates an end-to-end Data Engineering workflow rather than isolated SQL queries.

The main pipeline is:

Raw Data → Ingestion → Cleaning → Integration → Dimensional Modeling → Data Quality → Analytics

It shows how SQL Server can be used to transform operational CRM/ERP data into a structured warehouse that is easier and safer to use for business analysis and reporting.

## Diagrams: 
![data architecture.drawio](data architecture.drawio.png)

# 🔮 Possible Future Improvements

Some potential extensions include:

Add an orchestration tool such as SQL Server Agent, Azure Data Factory, or Airflow.

Add incremental loading instead of full truncation/reload.

Implement logging and ETL audit tables.

Add Slowly Changing Dimensions (SCD).

Add a date dimension.

Build Power BI dashboards on top of the Gold layer.

Add automated data-quality reporting.

Add indexing and performance optimization.

Parameterize source-file paths instead of hard-coding them.

# 👩‍💻 Project Type

Data Engineering / SQL Server / Data Warehousing

Architecture: Medallion Architecture
Model: Star Schema
Database: Microsoft SQL Server
Language: T-SQL
Pipeline: CRM & ERP → Bronze → Silver → Gold
