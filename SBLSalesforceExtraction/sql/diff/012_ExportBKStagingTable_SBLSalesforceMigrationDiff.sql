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

SELECT  '"CARD_NUMBER","IDENTIFICATION_NUMBER","FIRST_NAME_THAI","LAST_NAME_THAI","FIRST_NAME_ENGLISH","LAST_NAME_ENGLISH","GENDER","BIRTHDATE","MOBILE_#","EMAIL_ADDRESS","HOUSE_NO_CONDO_VILLAGE","MOO_SOI","ROAD_STREET","PROVINCE","POSTAL_CODE","STATUS","DISTRICT","SUB_DISTRICT","MEMBER_ID","MEMBER_CLASS","DONATION_FLAG","DONATION_NAME","JOINED_SAME_PRICE","MEMBER_#","ERR_STATUS","ERR_MSG,"UPD_DTTM"' FROM DUAL;
SELECT         '"'
            || CARD_NUMBER
            || '"'
            || ','
            || '"'
            || IDENTIFICATION_NUMBER
            || '"'
            || ','
            || '"'
            || FIRST_NAME_THAI
            || '"'
            || ','
            || '"'
            || LAST_NAME_THAI
            || '"'
            || ','
            || '"'
            || FIRST_NAME_ENGLISH
            || '"'
            || ','
            || '"'
            || LAST_NAME_ENGLISH
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
            || EMAIL_ADDRESS
            || '"'
            || ','
            || '"'
            || HOUSE_NO_CONDO_VILLAGE
            || '"'
            || ','
            || '"'
            || MOO_SOI
            || '"'
            || ','
            || '"'
            || ROAD_STREET
            || '"'
            || ','
            || '"'
            || PROVINCE
            || '"'
            || ','
            || '"'
            || POSTAL_CODE
            || '"'
            || ','
            || '"'
            || STATUS
            || '"'
            || ','
            || '"'
            || DISTRICT
            || '"'
            || ','
            || '"'
            || SUB_DISTRICT
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
       || ','
       || '"'
       || ERR_STATUS
       || '"'
       || ','
       || '"'
       || ERR_MSG
       || '"'
       || ','
       || '"'
       || UPD_DTTM
       || '"'
  FROM ${bkstagingtableschema}.${bkstagingtablename};
spool off;

exit
EOF

