/**************************************************************************************************************
   NAME:    DQA CREATE TABLES.sql
   PURPOSE: Creates the tables used for DWH data quality and assurance measures

   REVISIONS:
   
   Date         Author           Description
   ---------  -----------  -------------------------------------------------------------------------------------
   19/05/2026   Helen Outram     6. Added column dwh_ref to DQA_DBMS_LOG table
                                    Changed name of DQA_DWH_TABLES TO DQ_DWH_TABLES_LKP to make it clearer that it's a lookup table
                                    Also made some minor cosmetic changes to this script, typos etc
   18/05/2026   Helen Outram     5. Added data sensitivity marking to table and column comments
   15/05/2026   Helen Outram     4. Added the following tables:
                                               - DQA_INFORMATICA_MAPPINGS_ALL
                                               - DQA_INFORMATICA_FOLDER_LINKS_LKP
                                    Also changed existing tables names to DQA_ instead of DQ_
   21/11/2025   Helen Outram     3. Added comments to tables and columns
   11/11/2025   Helen Outram     2. Added error logging and monitoring tables:
                                               - DQ_ERRORS
                                               - DQ_RUNNING_TIMES
                                               - DQ_DBMS LOG
   21/10/2025   Helen Outram     1. Created script for following tables:
                                               - DQ_DWH_TABLES
                                               - DQ_MAX_INSERT_DT
                                               - DQ_DWH_TABLE_COUNTS
                                               - DQ_DWH_TABLE_COUNT_DIFFERENCES
                                               
*****************************************************************************************************************/

--ERROR LOGGING AND MONITORING

--Errors

create table dqa_errors
(run_date date
, procedure_name varchar2(50)
, error_code varchar2(10)
, error_message varchar2(200)
, error_backtrace varchar2(1000)
, error_callstack varchar2(1000))
;

comment on table dqa_errors is 'Sensitivity Marking: Official. This table is used as part of the DWH Data Quality and Assurance packages. It is used to log any Oracle errors to help debug if the DATA_QUALITY package fails'; 

comment on column dqa_errors.run_date is 'Date the procedure is run. Sensitivity Marking: Official';
comment on column dqa_errors.procedure_name is 'Name of the procedure. Sensitivity Marking: Official';
comment on column dqa_errors.error_code is 'ORACLE error code. Sensitivity Marking: Official';
comment on column dqa_errors.error_message is 'ORACLE error message. Sensitivity Marking: Official';
comment on column dqa_errors.error_backtrace is 'The location of the error: gives line number where error occurred and the package/procedure/function names involved. Sensitivity Marking: Official';
comment on column dqa_errors.error_callstack is 'How the error occurred: the full chain of procedure/function/package calls that were active when the exception was raised. Sensitivity Marking: Official';


--Running Times

create table dqa_running_times
(run_date date
, procedure_name varchar2(50)
, start_time varchar2(10)
, end_time varchar2(10)
, run_time varchar2(10))
;

comment on table dqa_running_times is 'Sensitivity Marking: Official. This table is used as part of the DWH Data Quality and Assurance packages. It is used to log the start, end and overall run time of each procedure within the Data Quality packages';

comment on column dqa_running_times.run_date is 'Date the procedure is run. Sensitivity Marking: Official';
comment on column dqa_running_times.procedure_name is 'Name of the procedure. Sensitivity Marking: Official';
comment on column dqa_running_times.start_time is 'Time procedure started. Sensitivity Marking: Official';
comment on column dqa_running_times.end_time is 'Time procedure ended. Sensitivity Marking: Official';
comment on column dqa_running_times.run_time is 'Duration of the procedure. Sensitivity Marking: Official';


--DBMS Log

create table dqa_dbms_log
(run_date date
, procedure_name varchar2(50)
, dwh_ref varchar2(10)
, schema_name varchar2(50)
, table_name varchar2(100)
, log_message varchar2(4000))
;

comment on table dqa_dbms_log is 'Sensitivity Marking: Official. This table is used as part of the DWH Data Quality and Assurance packages. It is used to help debug and analysis if the package fails - converts dynamic sql into clean queries which can be run directly in Oracle to analyse and replicate/identify errors';

comment on column dqa_dbms_log.run_date is 'Date the procedure is run. Sensitivity Marking: Official';
comment on column dqa_dbms_log.procedure_name is 'Name of the procedure. Sensitivity Marking: Official';
comment on column dqa_dbms_log.dwh_ref is 'Reference from CAPD_DWH_APP.DQA_DWH_TABLES lookup table. Sensitivity Marking: Official';
comment on column dqa_dbms_log.schema_name is 'Schema of the table. Sensitivity Marking: Official';
comment on column dqa_dbms_log.table_name is 'Name of the table. Sensitivity Marking: Official';
comment on column dqa_dbms_log.log_message is 'DBMS output text. Sensitivity Marking: Official';





--DATA QUALITY AND ASSURANCE TABLES

--Max Insert Dates

create table dqa_max_insert_dt
(run_date date
, dwh_ref varchar2(10)
, table_name varchar2(100)
, max_insert_dt date)
;

comment on table dqa_max_insert_dt is 'Sensitivity Marking: Official.This table is used as part of the DWH Data Quality and Assurance packages. It is used to hold the maximum insert date for each target table for lookup against equivalent source table to give like-for-like time periods';

comment on column dqa_max_insert_dt.run_date is 'Date the procedure is run. Sensitivity Marking: Official';
comment on column dqa_max_insert_dt.dwh_ref is 'Reference from CAPD_DWH_APP.DQA_DWH_TABLES lookup table. Sensitivity Marking: Official';
comment on column dqa_max_insert_dt.table_name is 'Name of the table. Sensitivity Marking: Official';
comment on column dqa_max_insert_dt.max_insert_dt is 'Date and time of the last inserted record. Sensitivity Marking: Official';


--DWH Tables Lookup

create table dqa_dwh_tables_lkp
(dwh_ref varchar2(10)
, schema_name varchar2(50)
, table_name varchar2(100)
, connection_string varchar2(200)
, table_type varchar2(6)
, unique_row_identifier varchar2(200)
, ref_ods_table_name varchar2(100)
, dwh_notes varchar2(500))
;

comment on table dqa_dwh_tables_lkp is 'Sensitivity Marking: Official. This table is used as part of the DWH Data Quality and Assurance packages. It is used as the main lookup table for the data assurance procedures to run against. One line per table with associated data needed for various lookups';

comment on column dqa_dwh_tables_lkp.dwh_ref is 'DWH designated reference - source and target tables are given the same reference. Sensitivity Marking: Official';
comment on column dqa_dwh_tables_lkp.schema_name is 'The schema name of the table. Sensitivity Marking: Official';
comment on column dqa_dwh_tables_lkp.table_name is 'The table name of the table. Sensitivity Marking: Official';
comment on column dqa_dwh_tables_lkp.connection_string is 'The full connection string of the table for use in the PL/SQL package. Sensitivity Marking: Official';
comment on column dqa_dwh_tables_lkp.table_type is 'The table type, either source or target. Sensitivity Marking: Official';
comment on column dqa_dwh_tables_lkp.unique_row_identifier is 'The column or combination of columns that bring back a distinct row where possible. Sensitivity Marking: Official';
comment on column dqa_dwh_tables_lkp.ref_ods_table_name is 'Used only for the source tables, this gives the corresponding ODS table name. For lookup use in the PL/SQL package. Sensitivity Marking: Official';


--DWH Table Counts

create table dqa_dwh_table_counts
(run_date date
, dwh_ref varchar2(10)
, source_schema_name varchar2(20)
, source_table_name varchar2(100)
, source_row_count number
, source_max_insert_dt_ref date
, target_schema_name varchar2(20)
, target_table_name varchar2(100)
, target_row_count number
, row_match_flag varchar2(1)
, row_count_difference number)
;

comment on table dqa_dwh_table_counts is 'Sensitivity Marking: Official. This table is used as part of the DWH Data Quality and Assurance packages. It is used to store the row counts of each source/target table pair so we can identify where there is a difference in the row counts';

comment on column dqa_dwh_table_counts.run_date is 'Date the procedure is run. Sensitivity Marking: Official';
comment on column dqa_dwh_table_counts.dwh_ref is ' Reference of the source/target table pair from CAPD_DWH_APP.DQ_DWH_TABLES lookup. Sensitivity Marking: Official';
comment on column dqa_dwh_table_counts.source_schema_name is 'Schema of the source table. Sensitivity Marking: Official';
comment on column dqa_dwh_table_counts.source_table_name is 'Name of the source table. Sensitivity Marking: Official';
comment on column dqa_dwh_table_counts.source_row_count is 'Number of rows in the source table. Sensitivity Marking: Official';
comment on column dqa_dwh_table_counts.source_max_insert_dt_ref is 'Maximum insert date the row count has been run against - from CAPD_DWH_APP.DQ_MAX_INSERT_DT lookup table. Sensitivity Marking: Official';
comment on column dqa_dwh_table_counts.target_schema_name is 'Schema of the target table. Sensitivity Marking: Official';
comment on column dqa_dwh_table_counts.target_table_name is 'Name of the target table. Sensitivity Marking: Official';
comment on column dqa_dwh_table_counts.target_row_count is 'Number of rows in the target table. Sensitivity Marking: Official';
comment on column dqa_dwh_table_counts.row_match_flag is 'Comparison of SOURCE_ROW_COUNT and TARGET_ROW_COUNT. Y/N depending on whether the counts match. Sensitivity Marking: Official';
comment on column dqa_dwh_table_counts.row_count_difference is 'Numerical difference between SOURCE_ROW_COUNT and TARGET_ROW_COUNT. Sensitivity Marking: Official';


--DWH Table Count Differences

create table dqa_dwh_table_count_differences
(run_date date
, schema_name varchar2(20)
, table_name varchar2(100)
, unique_row_identifier varchar2(200)
, unique_row_value varchar2(200)
, dwh_info varchar2(40))
;

comment on table dqa_dwh_table_count_differences is 'Sensitivity Marking: Official. This table is used as part of the DWH Data Quality and Assurance packages. It is used to provide low level data for any rows that do not match between source and target where a row count difference has been identified in CAPD_DWH_APP.DQ_DWH_TABLE_COUNTS';

comment on column dqa_dwh_table_count_differences.run_date is 'Date the procedure is run. Sensitivity Marking: Official';
comment on column dqa_dwh_table_count_differences.schema_name is 'Schema of the table. Sensitivity Marking: Official';
comment on column dqa_dwh_table_count_differences.table_name is 'Name of the table. Sensitivity Marking: Official';
comment on column dqa_dwh_table_count_differences.unique_row_identifier is 'The name of the column used to uniquely identify a row. Sensitivity Marking: Official';
comment on column dqa_dwh_table_count_differences.unique_row_value is 'The value of the unique identifier. Sensitivity Marking: Official';
comment on column dqa_dwh_table_count_differences.dwh_info is 'Information provided by DWH at runtime. Sensitivity Marking: Official';


--All DWH Informatica Mappings

create table dqa_informatica_mappings_all
(subject_area varchar2(50) 
, mapping_id number
, mapping_name varchar2(100)
, source_database_name varchar2(50)
, source_object_name varchar2(100)
, source_table_name varchar2(100)
, source_column_id number
, source_column_order_num number 
, source_column_name varchar2(100) 
, source_column_datatype varchar2(20) 
, source_column_precision number
, source_column_key_type varchar2(20) 
, target_object_name varchar2(100)
, target_table_name varchar2(100) 
, target_column_id number
, target_column_order_num number
, target_column_name varchar2(100) 
, target_column_datatype varchar2(20) 
, target_column_precision number
, target_column_key_type varchar2(20))
;

comment on table dqa_informatica_mappings_all is 'Sensitivity Marking: Official. This table is used as part of the DWH Data Quality and Assurance packages. It is used to ascertain all mappings we currently have in Informatica and provide source and target table information';

comment on column dqa_informatica_mappings_all.subject_area is 'Name of Informatica folder where the mapping is held. Sensitivity Marking: Official';
comment on column dqa_informatica_mappings_all.mapping_id is 'ID of the mapping. Sensitivity Marking: Official';
comment on column dqa_informatica_mappings_all.mapping_name is 'Name of the mapping. Sensitivity Marking: Official';
comment on column dqa_informatica_mappings_all.source_database_name is 'Origin of the source data for the mapping, e.g. database, another informatica folder, flatfile. Sensitivity Marking: Official';
comment on column dqa_informatica_mappings_all.source_object_name is 'Name of the Source Definition within the mapping. Sensitivity Marking: Official';
comment on column dqa_informatica_mappings_all.source_table_name is 'Name of the source table. Sensitivity Marking: Official';
comment on column dqa_informatica_mappings_all.source_column_id is 'ID of the source table column. Sensitivity Marking: Official';
comment on column dqa_informatica_mappings_all.source_column_order_num is 'Order number of the source table column as held in the source table. Sensitivity Marking: Official';
comment on column dqa_informatica_mappings_all.source_column_name is 'Name of the source table column. Sensitivity Marking: Official';
comment on column dqa_informatica_mappings_all.source_column_datatype is 'Datatype of the source table column. Sensitivity Marking: Official';
comment on column dqa_informatica_mappings_all.source_column_precision is 'Precision of the source table column. Sensitivity Marking: Official';
comment on column dqa_informatica_mappings_all.source_column_key_type is 'Key type of the source table column e.g. Primary Key. Sensitivity Marking: Official';
comment on column dqa_informatica_mappings_all.target_object_name is 'Name of the Target Definition within the mapping. Sensitivity Marking: Official';
comment on column dqa_informatica_mappings_all.target_table_name is 'Name of the target table. Sensitivity Marking: Official';
comment on column dqa_informatica_mappings_all.target_column_id is 'ID of the target table column. Sensitivity Marking: Official';
comment on column dqa_informatica_mappings_all.target_column_order_num is 'Order number of the target table column as held in the source table. Sensitivity Marking: Official';
comment on column dqa_informatica_mappings_all.target_column_name is 'Name of the target table column. Sensitivity Marking: Official';
comment on column dqa_informatica_mappings_all.target_column_datatype is 'Datatype of the target table column. Sensitivity Marking: Official';
comment on column dqa_informatica_mappings_all.target_column_precision is 'Precision of the target table column. Sensitivity Marking: Official';
comment on column dqa_informatica_mappings_all.target_column_key_type is 'Key type of the target table column e.g. Primary Key. Sensitivity Marking: Official';


--DWH Informatica Mappings link Lookup

create table dqa_informatica_folder_links_lkp
(source_mapping_subject_area varchar2(50)
, target_mapping_subject_area varchar2(50))
;

comment on table dqa_informatica_folder_links_lkp is 'Sensitivity Marking: Official. This table is used as part of the DWH Data Quality and Assurance packages. It is used to identify the combinations of source to target subject areas to feed into the source-to-target mappings code';

comment on column dqa_informatica_folder_links_lkp.source_mapping_subject_area is 'Subject area of the source mapping. Sensitivity Marking: Official';
comment on column dqa_informatica_folder_links_lkp.target_mapping_subject_area is 'Subject area of the target mapping. Sensitivity Marking: Official';