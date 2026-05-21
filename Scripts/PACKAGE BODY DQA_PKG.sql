create or replace PACKAGE BODY DQA_PKG AS

/**************************************************************************************************************************************************

   NAME:    DATA_QUALITY (PACKAGE BODY)
   PURPOSE: Runs procedures for DWH data quality and assurance measures

   REVISIONS:
   
   Date         Author           Description
   -----------  ---------------  -------------------------------------------------------------------------------------------------------------------
   19/05/2026   Helen Outram     5. Changed the name of the package from DATA_QUALITY to DQA_PKG
                                    Also updated procedure names from DQ_ to DQA_
   12/01/2026   Helen Outram     4. Removed trunc from dt_insert so the code uses timestamp to identify like for like records
   21/11/2025   Helen Outram     3. Added the procedure DQ_TABLE_DIFFERENCES which puts the unique identifier of the rows (as defined in table 
                                    DQ_DWH_TABLES) that are different between source and target tables into table DQ_DWH_TABLE_DIFFERENCES to 
                                    enable us to analyse them.
   11/11/2025   Helen Outram     2. Added columns into CAPD_DWH_APP.DQ_DWH_TABLE_COUNTS and altered the procedure DQ_TABLE_COUNTS so that the 
                                    source and target row counts are inserted into the same row for easier comparison. Also added a ROW_MATCH_FLAG 
                                    to easily see if the counts match and a ROW_COUNT_DIFFERENCE column to calculate the difference.
   21/10/2025   Helen Outram     1. Created package body. 
                                    DQ_MAX_INSERT_DATES gets the max insert dates from DWH tables to run DQ code against
                                    DQ_TABLE_COUNTS gets the row counts from ODS and SOURCE tables for comparison. Inserts one line per table.

******************************************************************************************************************************************************/


procedure DQA_RUN_DATA_ASSURANCE_CHECKS AS  

--CONSTANT
--create a constant for the procedure name so we don't have to keep typing it!
c_proc_name constant varchar2(50) := 'DQA_RUN_DATA_ASSURANCE_CHECKS';

BEGIN 

execute immediate 'alter session set nls_date_format = ''DD-MON-YYYY HH24:MI:SS''';

      --enable dbms_output with a large buffer
      dbms_output.enable(1000000);

      DQA_MAX_INSERT_DATES;	
      DQA_TABLE_COUNTS;
      DQA_TABLE_COUNT_DIFFERENCES;

EXCEPTION
   WHEN OTHERS THEN
      v_err_code := sqlcode;
      v_err_msg := substr(sqlerrm, 1, 200);
      v_err_backtrace := sys.dbms_utility.format_error_backtrace;
      v_err_callstack := sys.dbms_utility.format_call_stack;

insert into dqa_errors (run_date, procedure_name, error_code, error_message, error_backtrace, error_callstack)
values (sysdate, c_proc_name, v_err_code, v_err_msg, v_err_backtrace, v_err_callstack);


END DQA_RUN_DATA_ASSURANCE_CHECKS;


/******************************************************************************/

PROCEDURE DQA_MAX_INSERT_DATES IS

--CONSTANT
--create a constant for the procedure name so we don't have to keep typing it!
c_proc_name constant varchar2(50) := 'DQA_MAX_INSERT_DATES';

--CURSOR
--create a cursor to bring back the list of tables to run code against (only ODS tables)
CURSOR cur_tables IS
select dwh_ref
, schema_name
, table_name
, connection_string
from dqa_dwh_tables_lkp
where table_type = 'TARGET';

--VARIABLES

--dynamic sql
v_sql varchar2(1000);

BEGIN

    --log the start time
    v_start_time := systimestamp;

    --truncate the table
    execute immediate 'truncate table dqa_max_insert_dt';

    --main processing loop, cursor is automatically opened/fetched/closed
    FOR rec IN cur_tables LOOP  

            v_sql := 'insert into dqa_max_insert_dt (run_date, dwh_ref, table_name, max_insert_dt)
                      select trunc(sysdate)
                      , ''' || rec.dwh_ref || '''
                      , ''' || rec.table_name || '''
                      , max(dt_insert)
                      from ' || rec.connection_string;

            execute immediate v_sql;

            dbms_output.put_line(v_sql);

            commit;

                   --read lines from dbms_output and insert into log table

                   LOOP

                        dbms_output.get_line(v_line, v_status);

                        EXIT WHEN v_status != 0; -- no more lines
                        INSERT INTO dqa_dbms_log (run_date, procedure_name, dwh_ref, schema_name, table_name, log_message)
                        VALUES (sysdate, c_proc_name, rec.dwh_ref, rec.schema_name, rec.table_name, v_line);

                   END LOOP;

                   commit;

            END LOOP;

    --log the end times
    v_end_time := systimestamp;

   --insert the running times into a table for reference
    insert into dqa_running_times(run_date, procedure_name, start_time, end_time, run_time)
    values(sysdate
           , c_proc_name
           , to_char(v_start_time, 'HH24:MI:SS')
           , to_char(v_end_time, 'HH24:MI:SS')
           , to_char(lpad(extract(hour from (v_end_time - v_start_time)), 2, '0') || ':' || lpad(extract(minute from (v_end_time - v_start_time)), 2, '0') || ':' || lpad(trunc(extract(second from (v_end_time - v_start_time))), 2, '0')));

EXCEPTION
   WHEN OTHERS THEN
      v_err_code := sqlcode;
      v_err_msg := substr(sqlerrm, 1, 200);
      v_err_backtrace := sys.dbms_utility.format_error_backtrace;
      v_err_callstack := sys.dbms_utility.format_call_stack;

insert into dqa_errors (run_date, procedure_name, error_code, error_message, error_backtrace, error_callstack)
values (sysdate, c_proc_name, v_err_code, v_err_msg, v_err_backtrace, v_err_callstack);

RETURN;

END DQA_MAX_INSERT_DATES;


/******************************************************************************/


PROCEDURE DQA_TABLE_COUNTS IS

--CONSTANT
--create a constant for the procedure name so we don't have to keep typing it!
c_proc_name constant varchar2(50) := 'DQA_TABLE_COUNTS';

--CURSOR
--create a cursor to bring back the list of tables to run code against
CURSOR cur_tables IS
select dwh_ref
, schema_name 
, table_name
, connection_string
, table_type
, ref_ods_table_name
from dqa_dwh_tables_lkp;


--VARIABLES

--dynamic sql
v_sql_source clob;
v_sql_target clob;

--dates
v_maxdate date;

BEGIN

    --log the start time
    v_start_time := systimestamp;

    --main processing loop, cursor is automatically opened/fetched/closed
    FOR rec IN cur_tables LOOP  

                    --put the max_insert_dt into the variable 
                    IF rec.table_type = 'SOURCE' THEN

                        SELECT mid.max_insert_dt
                        INTO v_maxdate
                        FROM dqa_max_insert_dt mid
                        WHERE mid.table_name = rec.ref_ods_table_name;                                       

                    ELSE

                        v_maxdate := NULL;

                    END IF;

                    --run the dynamic sql
                    --source tables run against the max insert date of ODS tables so the counts should be aligned  
                    v_sql_source := 'insert into dqa_dwh_table_counts (run_date, dwh_ref, source_schema_name, source_table_name, source_row_count, source_max_insert_dt_ref)
                                     select sysdate, ''' || rec.dwh_ref || ''',''' || rec.schema_name || ''',''' || rec.table_name || ''', count(*), ''' || v_maxdate || '''
                                     from ' || rec.connection_string || 
                                     ' where dt_insert <= :max_dt';

                    --ods tables just need the full row count WILL NEED TO REVIEW THIS FOR DELTAS
                    v_sql_target := 'update dqa_dwh_table_counts tc
                                     set tc.target_schema_name = ''' || rec.schema_name || ''',
                                         tc.target_table_name = ''' || rec.table_name || ''',
                                         tc.target_row_count = (select count(*) from ' || rec.connection_string || ')
                                         where tc.dwh_ref = ''' || rec.dwh_ref || '''
                                         and trunc(tc.run_date) = trunc(sysdate)';

                    --IF statement looks to see whether the table is source or target(ods) and runs relevant sql statement above
                    IF rec.table_type = 'SOURCE' THEN

                        EXECUTE IMMEDIATE v_sql_source USING v_maxdate; --using v_maxdate passes value of max date variable into the bind variable :max_dt

                        dbms_output.put_line(v_sql_source);

                    ELSIF rec.table_type = 'TARGET' THEN

                        EXECUTE IMMEDIATE v_sql_target;

                        dbms_output.put_line(v_sql_target);

                    ELSE

                        CONTINUE; --continue to next record

                        dbms_output.put_line('Unknown table type: ' || rec.table_type);

                    END IF;                          

                            --read lines from dbms_output and insert into log table         
                            LOOP

                            dbms_output.get_line(v_line, v_status);

                            EXIT WHEN v_status != 0; -- no more lines in dbms_output

                                    INSERT INTO dqa_dbms_log (run_date, procedure_name, dwh_ref, schema_name, table_name, log_message)
                                    VALUES (sysdate, c_proc_name, rec.dwh_ref, rec.schema_name, rec.table_name, v_line);

                            END LOOP;     

    END LOOP;

    --update the flag to show if the source and target row counts match
    update dqa_dwh_table_counts
    set row_match_flag = case when source_row_count = target_row_count then 'Y'
                              else 'N'
                              end;

    --update the difference in row count between source and target if there is one
    update dqa_dwh_table_counts
    set row_count_difference = abs(source_row_count - target_row_count);

    commit;

    --log the end time
    v_end_time := systimestamp;

    --insert the running times into a table for reference
    insert into dqa_running_times(run_date, procedure_name, start_time, end_time, run_time)
    values(sysdate
           , c_proc_name
           , to_char(v_start_time, 'HH24:MI:SS')
           , to_char(v_end_time, 'HH24:MI:SS')
           , to_char(lpad(extract(hour from (v_end_time - v_start_time)), 2, '0') || ':' || lpad(extract(minute from (v_end_time - v_start_time)), 2, '0') || ':' || lpad(trunc(extract(second from (v_end_time - v_start_time))), 2, '0')));

EXCEPTION
   WHEN OTHERS THEN
      v_err_code := sqlcode;
      v_err_msg := substr(sqlerrm, 1, 200);
      v_err_backtrace := sys.dbms_utility.format_error_backtrace;
      v_err_callstack := sys.dbms_utility.format_call_stack; 

insert into dqa_errors (run_date, procedure_name, error_code, error_message, error_backtrace, error_callstack)
values (sysdate, c_proc_name, v_err_code, v_err_msg, v_err_backtrace, v_err_callstack);

RETURN;

END DQA_TABLE_COUNTS;


/******************************************************************************/


PROCEDURE DQA_TABLE_COUNT_DIFFERENCES IS 

--CONSTANT
--create a constant for the procedure name so we don't have to keep typing it!
c_proc_name constant varchar2(50) := 'DQA_TABLE_COUNT_DIFFERENCES';


--CURSOR
--create a cursor to bring back the row count data for comparison
CURSOR cur_table_counts IS
select run_date
, dwh_ref
, source_schema_name
, source_table_name
, source_row_count
, source_max_insert_dt_ref
, target_schema_name
, target_table_name
, target_row_count
from dqa_dwh_table_counts
where trunc(run_date) = trunc(sysdate);

--VARIABLES

--lookup data (from table dq_dwh_tables)
v_connection_string_source varchar2(200);
v_connection_string_target varchar2(200);
v_unique_row_identifier_source varchar2(200);
v_unique_row_identifier_target varchar2(200);

 --dynamic sql
v_sql clob;

--dates
v_maxdate date;     

BEGIN

    --log the start time
    v_start_time := systimestamp;

    --main processing loop, cursor is automatically opened/fetched/closed
    FOR rec IN cur_table_counts LOOP

             --put the source table details into variables
            select ddt.connection_string, ddt.unique_row_identifier
            into v_connection_string_source, v_unique_row_identifier_source
            from dqa_dwh_tables_lkp ddt
            where rec.dwh_ref = ddt.dwh_ref
            and ddt.table_type = 'SOURCE';

            --put the target table details into variables
            select ddt.connection_string, ddt.unique_row_identifier
            into v_connection_string_target, v_unique_row_identifier_target
            from dqa_dwh_tables_lkp ddt
            where rec.dwh_ref = ddt.dwh_ref
            and ddt.table_type = 'TARGET'; 

            --put the max_insert_dt into the variable 
            v_maxdate := rec.source_max_insert_dt_ref;

            --run the dynamic sql
            v_sql := 'insert into dqa_dwh_table_count_differences (run_date, schema_name, table_name, unique_row_identifier, unique_row_value, dwh_comments)
                      select sysdate
                      , case when source.unique_row_id is not null then ''' || rec.source_schema_name || '''
                             else ''' || rec.target_schema_name || ''' 
                             end as schema_name
                      , case when source.unique_row_id is not null then ''' || rec.source_table_name || '''
                             else ''' || rec.target_table_name || ''' 
                             end as table_name
                      , case when source.unique_row_id is not null then ''' || v_unique_row_identifier_source || '''
                             else ''' || v_unique_row_identifier_target || '''
                             end as unique_row_identifier
                      , nvl(source.unique_row_id, target.unique_row_id) as unique_row_value
                      , case when nvl(source.cnt, 0) > nvl(target.cnt, 0) then ''Additional row in source table'' 
                             when nvl(target.cnt, 0) > nvl(source.cnt, 0) then ''Additional row in target table''
                             else null 
                             end as dwh_comments
                      from (select ' || v_unique_row_identifier_source || ' as unique_row_id
                            , count(' || v_unique_row_identifier_source || ') as cnt
                            from ' || v_connection_string_source || '
                            where dt_insert <= :max_dt
                            group by ' || v_unique_row_identifier_source || ') source
                            full outer join (select ' || v_unique_row_identifier_target || ' as unique_row_id
                                             , count(' || v_unique_row_identifier_target || ') as cnt
                                             from ' || v_connection_string_target || '
                                             group by ' || v_unique_row_identifier_target || ') target
                            on source.unique_row_id = target.unique_row_id
                      where nvl(source.cnt, 0) <> nvl(target.cnt, 0)';

            --run v_sql if counts don't match, otherwise move to next record        
            IF nvl(rec.source_row_count, 0) <> nvl(rec.target_row_count, 0) THEN

                execute immediate v_sql using v_maxdate;

                dbms_output.put_line(v_sql);

                --read lines from dbms_output and insert into log table         
                LOOP

                dbms_output.get_line(v_line, v_status);

                EXIT WHEN v_status != 0; -- no more lines in dbms_output

                        INSERT INTO dqa_dbms_log (run_date, procedure_name, dwh_ref, log_message)
                        VALUES (sysdate, c_proc_name, rec.dwh_ref, v_line);

                END LOOP;

                commit;

            ELSE

                CONTINUE; --continue to next record

            END IF;

    END LOOP;

    --log the end time
    v_end_time := systimestamp;

    --insert the running times into a table for reference
    insert into dqa_running_times(run_date, procedure_name, start_time, end_time, run_time)
    values(sysdate
           , c_proc_name
           , to_char(v_start_time, 'HH24:MI:SS')
           , to_char(v_end_time, 'HH24:MI:SS')
           , to_char(lpad(extract(hour from (v_end_time - v_start_time)), 2, '0') || ':' || lpad(extract(minute from (v_end_time - v_start_time)), 2, '0') || ':' || lpad(trunc(extract(second from (v_end_time - v_start_time))), 2, '0')));

EXCEPTION
   WHEN OTHERS THEN
      v_err_code := sqlcode;
      v_err_msg := substr(sqlerrm, 1, 200);
      v_err_backtrace := sys.dbms_utility.format_error_backtrace;
      v_err_callstack := sys.dbms_utility.format_call_stack; 

insert into dqa_errors (run_date, procedure_name, error_code, error_message, error_backtrace, error_callstack)
values (sysdate, c_proc_name, v_err_code, v_err_msg, v_err_backtrace, v_err_callstack);

dbms_output.put_line('Procedure DQ_TABLE_DIFFERENCES has encountered an error: ' || SQLERRM);
dbms_output.put_line('Check table DQ_ERRORS for more details');

RETURN;

END DQA_TABLE_COUNT_DIFFERENCES;

/******************************************************************************/


END DQA_PKG;