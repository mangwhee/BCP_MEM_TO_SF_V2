connect ${user}/${pass}@${db_name}
set term off
set echo off
set head off
set feedback off
set trimspool on
set pagesize 0
set lines 20000
set pages 20000
SET TIMING ON

${clearstgtblaction} TABLE ${stagingtableschema}.${stagingtablename};

exit

