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

/* Formatted on 2/26/2017 9:27:59 AM (QP5 v5.256.13226.35538) */
  SELECT ERR_STATUS || '|' || COUNT (*)
    FROM ${stagingtableschema}.${stagingtablename} 
GROUP BY ERR_STATUS;

exit
