/* Formatted on 2/19/2017 2:22:18 PM (QP5 v5.163.1008.3004) */
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


spool ${plsqloutputpath}
-- spool /interface/custom_scripts/SBLSalesforceExtraction/output

SELECT  '"CARD_NUMBER","IDENTIFICATION_NUMBER","FIRST_NAME_THAI","LAST_NAME_THAI","FIRST_NAME_ENGLISH","LAST_NAME_ENGLISH","GENDER","BIRTHDATE","MOBILE_#","EMAIL_ADDRESS","HOUSE_NO_CONDO_VILLAGE","MOO_SOI","ROAD_STREET","PROVINCE","POSTAL_CODE","STATUS","DISTRICT","SUB_DISTRICT","MEMBER_ID","MEMBER_CLASS","DONATION_FLAG","DONATION_NAME","JOINED_SAME_PRICE","MEMBER_#"' FROM DUAL;
SELECT /*+parallel (16)*/
      '"'
       || CARD_NUMBER
       || '"'
       || ','
       || '"'
       || IDENTIFICATION_NUMBER
       || '"'
       || ','
       || '"'
       || REPLACE(FIRST_NAME_THAI, '"', ' ')
       || '"'
       || ','
       || '"'
       || REPLACE(LAST_NAME_THAI, '"', ' ')
       || '"'
       || ','
       || '"'
       || REPLACE(FIRST_NAME_ENGLISH, '"', ' ')
       || '"'
       || ','
       || '"'
       || REPLACE(LAST_NAME_ENGLISH, '"', ' ')
       || '"'
       || ','
       || '"'
       || GENDER
       || '"'
       || ','
       || '"'
       || TO_CHAR (BIRTHDATE, 'MM/DD/YYYY')
       || '"'
       || ','
       || '"'
       || MOBILE_#
       || '"'
       || ','
       || '"'
       || REPLACE(EMAIL_ADDRESS, '"', ' ')
       || '"'
       || ','
       || '"'
       || REPLACE(HOUSE_NO_CONDO_VILLAGE, '"', ' ')
       || '"'
       || ','
       || '"'
       || REPLACE(MOO_SOI, '"', ' ')
       || '"'
       || ','
       || '"'
       || REPLACE(ROAD_STREET, '"', ' ')
       || '"'
       || ','
       || '"'
       || REPLACE(PROVINCE, '"', ' ')
       || '"'
       || ','
       || '"'
       || REPLACE(POSTAL_CODE, '"', ' ')
       || '"'
       || ','
       || '"'
       || STATUS
       || '"'
       || ','
       || '"'
       || REPLACE(DISTRICT, '"', ' ')
       || '"'
       || ','
       || '"'
       || REPLACE(SUB_DISTRICT, '"', ' ')
       || '"'
       || ','
       || '"'
       || MEMBER_ID
       || '"'
       || ','
       || '"'
       || MEMBER_CLASS
       || '"'
       || ','
       || '"'
       || DONATION_FLAG
       || '"'
       || ','
       || '"'
       || DONATION_NAME
       || '"'
       || ','
       || '"'
       || JOINED_SAME_PRICE
       || '"'
       || ','
       || '"'
       || MEMBER_#
       || '"'
    FROM ${stagingtableschema}.${stagingtablename};

  spool off;

-- exit
-- EOF


BEGIN

  BEGIN
      UPDATE /*+ parallel(16) */ ${stagingtableschema}.${stagingtablename} STG
        SET STG.ERR_STATUS = 2,
            STG.ERR_MSG = 'Completed',
            STG.UPD_DTTM = SYSDATE
      WHERE STG.ERR_STATUS = 0;
  EXCEPTION
      WHEN OTHERS
      THEN
        DBMS_OUTPUT.PUT_LINE ('Can not update staging table : ' || SQLERRM);
  END;

  COMMIT;

EXCEPTION
   WHEN OTHERS
   THEN
      DBMS_OUTPUT.PUT_LINE ('Unexpected Error : ' || SQLERRM);
END;
/




