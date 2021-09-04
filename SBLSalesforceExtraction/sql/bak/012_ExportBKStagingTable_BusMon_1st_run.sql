connect ${user}/${pass}@${db_name}
set term off
set echo off
set head off
set feedback off
set termout off
set trimspool on
set pagesize 0
set lines 20000
set pages 20000

spool ${exportoutputfile}

SELECT  'ACCOUNT_ID|NAME|CREATED|SUBMITTED_DATE|REG_CHANNEL|OLD_STAT|CURRENT_STAT|LOV_SLA|DUE_DATE|SLA_STAT|SLA_DUE_DATE_NEW|SLA_STATUS_NEW|ERR_STATUS|ERR_MSG|UPD_DTTM'
FROM DUAL;
SELECT    ACCOUNT_ID
       || '|'
       || NAME
       || '|'
       || CREATED
       || '|'
       || SUBMITTED_DATE
       || '|'
       || REG_CHANNEL
       || '|'
       || OLD_STAT
       || '|'
       || CURRENT_STAT
       || '|'
       || LOV_SLA
       || '|'
       || DUE_DATE
       || '|'
       || SLA_STAT
       || '|'
       || SLA_DUE_DATE_NEW
       || '|'
       || SLA_STATUS_NEW
       || '|'
       || ERR_STATUS
       || '|'
       || REPLACE (ERR_MSG, 'ORA-', 'ORA - ')
       || '|'
       || UPD_DTTM
  FROM ${bkstagingtableschema}.${bkstagingtablename};

spool off;

exit
EOF

