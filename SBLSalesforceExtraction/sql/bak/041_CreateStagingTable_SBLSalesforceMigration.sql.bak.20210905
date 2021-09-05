/* Formatted on 2/15/2017 8:23:19 PM (QP5 v5.256.13226.35538) */
connect ${user}/"${pass}"@${db_name}
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

CREATE /*+ parallel(8) */ TABLE ${stagingtableschema}.${stagingtablename}
AS
   (/* Formatted on 8/17/2021 12:09:01 AM (QP5 v5.256.13226.35538) */
      SELECT /*+ parallel (8)*/
      CARD.CARD_NUM AS "CARD_NUMBER",
       CON.EMPLMNT_STAT_CD AS "IDENTIFICATION_NUMBER",
       CON.FST_NAME AS "FIRST_NAME_THAI",
       CON.LAST_NAME AS "LAST_NAME_THAI",
       CON.ALIAS_NAME AS "FIRST_NAME_ENGLISH",
       CON.FURI_PTRNL_LSTNAME AS "LAST_NAME_ENGLISH",
       CON.SEX_MF AS "GENDER",
       CON.BIRTH_DT AS "BIRTHDATE",
       CON.CELL_PH_NUM AS "MOBILE_#",
       CON.EMAIL_ADDR AS "EMAIL_ADDRESS",
       CON.X_ADDR_HOUSE AS "HOUSE_NO_CONDO_VILLAGE",
       CON.X_ADDR_SOIMOO AS "MOO_SOI",
       CON.X_ADDR_STREET AS "ROAD_STREET",
       CON.X_ADDR_PROVINCE AS "PROVINCE",
       CON.X_ADDR_POSTCODE AS "POSTAL_CODE",
       CON.STATUS_CD AS "STATUS",
       CON.X_ADDR_DISTRICT AS "DISTRICT",
       CON.X_ADDR_SUBDIST AS "SUB_DISTRICT",
       MEM.ROW_ID AS "MEMBER_ID",
       MEM.MEM_CLASS_CD AS "MEMBER_CLASS",
       CON.X_DON_FLG AS "DONATION_FLAG",
       PROD.ALIAS_NAME AS "DONATION_NAME",
       CON.X_SAME_PR_FLG AS "JOINED_SAME_PRICE",
       MEM.MEM_NUM AS "MEMBER_#",
       CAST ('0' AS VARCHAR2 (30)) AS "ERR_STATUS",
       CAST (NULL AS VARCHAR2 (512)) AS "ERR_MSG",
       CAST (NULL AS DATE) AS "UPD_DTTM"
  FROM SIEBEL.S_LOY_MEMBER MEM,
       SIEBEL.S_LOY_CARD card,
       SIEBEL.S_LOY_MEM_CON mem_con,
       SIEBEL.S_CONTACT con,
       SIEBEL.S_PROD_INT PROD
 WHERE     CARD.MEMBER_ID = MEM.row_id
       -- TODO: Need to uncomment for Production
       AND CARD.STATUS_CD = 'Active'
       AND MEM_CON.MEMBER_ID = MEM.ROW_ID
       AND MEM_CON.PER_ID = CON.ROW_ID
       AND CON.X_PROD_ID = PROD.ROW_ID(+)
       AND (   MEM.CREATED + 7 / 24 >
                  (SELECT NVL (STG.LAST_EXTRACT_DATE,
                               TO_DATE ('01/01/1900', 'MM/DD/YYYY'))
                     FROM ${lastextracttableschema}.${lastextracttable} stg
                    WHERE STG.INTERFACE_NAME = '${interfacename}')
            OR CON.CREATED + 7 / 24 >
                  (SELECT NVL (STG.LAST_EXTRACT_DATE,
                               TO_DATE ('01/01/1900', 'MM/DD/YYYY'))
                     FROM ${lastextracttableschema}.${lastextracttable} stg
                    WHERE STG.INTERFACE_NAME = '${interfacename}')
            OR CON.LAST_UPD + 7 / 24 >
                  (SELECT NVL (STG.LAST_EXTRACT_DATE,
                               TO_DATE ('01/01/1900', 'MM/DD/YYYY'))
                     FROM ${lastextracttableschema}.${lastextracttable} stg
                    WHERE STG.INTERFACE_NAME = '${interfacename}')
                    )
   );

EXIT

