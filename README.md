<p align="center">
  <img src="https://github.com/joshuabufi-analyst/Goodreads_Data_Warehouse_and_Reviewer_Behavior_Analysis/blob/main/photos/Goodreads-Logo.jpg" width="150">
</p>

<h1 align="center" style="font-size: 56px;">
  Goodreads Data Warehouse and Reviewer Behavior Analysis
</h1>

<h2 align="center" style="font-size: 40px;">
  Project Overview
</h2>

In this project, the following activities were undertaken:

1. **Data Warehouse Architecture Design:** Designed a modern three-layer data warehouse architecture consisting of Bronze, Silver, and Gold layers.
2. **ETL Pipeline Development:** Developed ETL pipelines to ingest source files, transform the data, and transfer it across the respective warehouse layers.
3. **Data Modeling:** Organized the data into fact and dimension tables to support efficient querying and reporting.
4. **SQL-Based Data Analysis:** Performed SQL analyses to answer key business questions and derive actionable insights.
5. **Dashboard Development:** Designed and developed interactive dashboards to visualize key performance indicators, present analytical findings, and support data-driven decision-making.

<h2 align="center" style="font-size: 40px;">
  Project Requirements
</h2>

### Building the Data Warehouse (Data Engineering)
**Objective**
Develop a modern data warehouse using SQL Server to consolidate reviews data, enabling analytical reporting and informed decision-making.

**Specifications:** 
  - **Data Sources:** Import data from two source files (goodreads_reviews and goodreads_works) provided as CSV files.
  - **Data Quality:** Cleanse and resolve data quality issues prior to analysis.
  - **Integration:** Combine both files into a single, user-friendly data model designed for analytical queries.
  - **Scope:** Focus on the latest dataset only; historization of data is not required.
  - **Documentation:** Provide clear documentation of the data model to support both business stakeholders and analytics teams.

### BI: Analytics & Reporting (Data Analysis)
**Objective**
Develop SQL-based and Power BI analytics to deliver detailed insights into:

  - User Behavior
  - Author and Book Performance
  - Review Trends

These insights empower stakeholders with key business metrics, enabling strategic decision-making.

<h2 align="center" style="font-size: 40px;">
  Data Architecture
</h2>

The data architecture for this project follows Medallion Architecture **Bronze**, **Silver**, and **Gold** layers:

<p align="center">
  <img src="https://github.com/joshuabufi-analyst/Goodreads_Data_Warehouse_and_Reviewer_Behavior_Analysis/blob/main/photos/Data%20Architecture.drawio.png" width="100%">
</p>

1. **Bronze Layer:** Stores raw data as-is from the source systems. Data is ingested from CSV Files into SQL Server Database.
2. **Silver Layer:** This layer includes data cleansing, standardization, and normalization processes to prepare data for analysis.
3. **Gold Layer:** Houses business-ready data modeled into a star schema required for reporting and analytics.

<h2 align="center" style="font-size: 40px;">
  Dashboard Preview
</h2>

<h2 align="center" style="font-size: 40px;">
  Key Insights
</h2>
