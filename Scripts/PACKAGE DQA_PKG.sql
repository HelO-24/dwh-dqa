create or replace PACKAGE DQA_PKG AS

/*******************************************************************************************************************************

   NAME:    DQA_PKG
   PURPOSE: Runs the procedures detailed below to run the DWH data quality and assurance measures

   REVISIONS:
   
   Date         Author           Description
   ---------  -----------  ------------------------------------------------------------------------------------------------------
   19/05/2026   Helen Outram     3. Changed the name of the package from DATA_QUALITY to DQA_PKG
                                    Also updated procedure names from DQ_ to DQA_
   21/11/2025   Helen Outram     2. Added a further procedure DQ_TABLE_DIFFERENCES to bring back the underlying data to 
                                    enable us to analyse the differences in the SOURCE and ODS tables.
   29/10/2025   Helen Outram     1. Created this package. Contains two main procedures, DQ_MAX_INSERT_DATES and DQ_TABLE_COUNTS.
                                    Procedure DQ_RUN_INTEGRATION_COMPARISON added to riun the two main procedures.
                                    
*********************************************************************************************************************************/

--GLOBAL VARIABLES

--error handling
v_start_time timestamp;
v_end_time timestamp;
v_err_code varchar2(10);   
v_err_msg varchar2(200);
v_err_backtrace varchar2(1000);   
v_err_callstack varchar2(1000);   
v_err_errorstack varchar2(1000); 

--writing to the log table
v_line varchar2(32767);
v_status integer;




--PROCEDURES

PROCEDURE DQA_RUN_DATA_ASSURANCE_CHECKS; --Main procedure to run everything for the integration checks

PROCEDURE DQA_MAX_INSERT_DATES; --gets the max insert date of the ODS table for us to use when getting the SOURCE table row counts
PROCEDURE DQA_TABLE_COUNTS; --gets the row counts of the SOURCE and ODS tables
PROCEDURE DQA_TABLE_COUNT_DIFFERENCES; --gets the underlying data of the rows that are different where the row counts of SOURCE and ODS rtables don't match 


END DQA_PKG;