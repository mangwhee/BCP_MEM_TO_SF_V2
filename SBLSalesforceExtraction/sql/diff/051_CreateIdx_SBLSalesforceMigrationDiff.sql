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

CREATE INDEX ${IndexSchemaCurrent}.${IndexNameCurrent} ON ${IndexTableSchemaCurrent}.${IndexTableNameCurrent}
(${IndexColumnNameCurrent})
LOGGING
TABLESPACE ${IndexTableSpaceNameCurrent}
PCTFREE    10
INITRANS   2
MAXTRANS   255
STORAGE    (
            INITIAL          64K
            NEXT             1M
            MINEXTENTS       1
            MAXEXTENTS       UNLIMITED
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
           )
NOPARALLEL;

EXIT
