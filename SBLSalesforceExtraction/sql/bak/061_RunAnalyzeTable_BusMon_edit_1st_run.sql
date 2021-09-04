connect ${user}/${pass}@${db_name}
set term off
set echo off
set head off
set feedback off
SET TERMOUT OFF
set trimspool on
set pagesize 0
set lines 20000
set pages 20000
SET TIMING ON

EXEC DBMS_STATS.GATHER_TABLE_STATS(ownname => '${AnalyzeTableSchemaCurrent}', tabname => '${AnalyzeTableNameCurrent}', estimate_percent => ${EstimatePercentCurrent}, cascade=> true, degree=> ${DegreeCurrent});

EXIT
