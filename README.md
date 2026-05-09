# What Task Heterogeneity Is Lost When Using the O*NET? Evidence from Firm and Worker-Level Data

## Description
- Project Aim: This project aims to analyze what heterogeneity is lost when using O*NET rather than firm-specific information and understand the implications of its limitations. The paper can inform policymakers and firms about whether occupation-level task measures used in labor research accurately reflect how work is organized within firms, which has implications for training policies and workplace automation. It helps interpret past findings in the task-based labor literature and guides future research on technology, specialization, and productivity as new data sources increasingly allow task measurement at the firm and worker level.
- Available Data: Github Dataset (2023) and the O*NET
- Project Structure:
  ```text
  data_raw/      unprocessed raw datasets
  scripts/       data cleaning and analysis scripts
  data_clean/    processed datasets
  output/        tables and figures
  ```
## Data Availability Statement
- The main Github Dataset used in this project is obtained from Dr. Jinci Liu, as part of her working paper, How does the Division of Labor Affect Team Productivity? Evidence from GitHub. The master data is constructed by a panel of 35 million code files, 292,840 developers, and 64,400 teams over seven years from GitHub, the world’s largest online coding platform. This granular data captures individual activity, specifying who engages in particular files and at which point in time, enabling the construction of novel measures for team specialization and productivity at a team-month level.
- The part of the master dataset used by this specific project is restricted to the year 2023, and restricted to task counts of each repository/team by month and task type. 

## Computational Requirements
-	R-Studio, Version 2-26.04.0 Build 526
-	Additional Package: Apache Arrow (for processing the main dataset in Parquet format), Version 24.0.0
-	Computer Hardware Specification as used by the author: 
-	The computer hardware specification as used by the author: Windows 11, Version 24H2
-	The wall-clock time given the provided computer hardware (yet unknown)

## Project Structure
- scripts/       data cleaning and analysis scripts
- data_raw/      (not tracked) raw data  
- data_clean/    processed data  
- output/        tables and figures 

## Instructions for Data Preparation and Analysis
-	Note: currently just got to 01_summary_stats so this is in progress
-	Specifying the instructions allowing a replicator to produce the same results, separately for data preparation and analysis

## Reference of Readme Format (AEA)
https://social-science-data-editors.github.io/template_README/
