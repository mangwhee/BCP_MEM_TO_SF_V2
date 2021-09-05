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
   WITH MEMBER_TBL
        AS (SELECT /*+ parallel (8)*/
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
                   CAST (NULL AS DATE) AS "UPD_DTTM",
                   CARD.ROW_ID CARD_ROW_ID
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
                              (SELECT NVL (
                                         STG.LAST_EXTRACT_DATE - 30,
                                         TO_DATE ('01/01/1900', 'MM/DD/YYYY'))
                                 FROM ${stagingtableschema}.${stagingtablename}stg
                                WHERE STG.INTERFACE_NAME = '${interfacename}')
                        OR CON.CREATED + 7 / 24 >
                              (SELECT NVL (
                                         STG.LAST_EXTRACT_DATE - 30,
                                         TO_DATE ('01/01/1900', 'MM/DD/YYYY'))
                                 FROM ${stagingtableschema}.${stagingtablename} stg
                                WHERE STG.INTERFACE_NAME = '${interfacename}')
                        OR CON.LAST_UPD + 7 / 24 >
                              (SELECT NVL (
                                         STG.LAST_EXTRACT_DATE - 30,
                                         TO_DATE ('01/01/1900', 'MM/DD/YYYY'))
                                 FROM ${stagingtableschema}.${stagingtablename}stg
                                WHERE STG.INTERFACE_NAME = '${interfacename}'))),
        AUDIT_ITM
        AS (SELECT ITM.ROW_ID ITM_ROW_ID,
                   ITM.TBL_RECORD_ID TBL_RECORD_ID,
                   TO_CHAR (ITM.AUDIT_LOG) AUDIT_LOG,
                   ROW_NUMBER ()
                   OVER (PARTITION BY ITM.TBL_RECORD_ID
                         ORDER BY itm.created DESC)
                      "ORDER_NO",
                   ITM.CREATED + 7 / 24 ITM_CREATED,
                   SUBSTR (TO_CHAR (ITM.AUDIT_LOG),
                             INSTR (TO_CHAR (ITM.AUDIT_LOG),
                                    '*',
                                    1,
                                    9)
                           + 1,
                             LENGTH (TO_CHAR (ITM.AUDIT_LOG))
                           - INSTR (TO_CHAR (ITM.AUDIT_LOG),
                                    '*',
                                    1,
                                    9))
                      "OLDVALUE",
                   SUBSTR (TO_CHAR (ITM.AUDIT_LOG),
                             INSTR (TO_CHAR (ITM.AUDIT_LOG),
                                    '*',
                                    1,
                                    6)
                           + 1,
                             INSTR (TO_CHAR (ITM.AUDIT_LOG),
                                    '*',
                                    1,
                                    7)
                           - INSTR (TO_CHAR (ITM.AUDIT_LOG),
                                    '*',
                                    1,
                                    6)
                           - 2)
                      "NEWVALUE"
              FROM SIEBEL.S_AUDIT_ITEM itm
             WHERE     ITM.BUSCOMP_NAME = 'LOY Membership Card'
                   AND ITM.OPERATION_CD = 'Modify'
                   AND ITM.BC_BASE_TBL = 'S_LOY_CARD'
                   AND ITM.TBL_NAME = 'S_LOY_CARD'
                   AND itm.AUDIT_SOURCE_CD = 'User'
                   AND itm.DB_LAST_UPD_SRC = 'User'
                   AND ITM.NODE_NAME = 'HQ'
                   AND (ITM.CREATED + 7 / 24 >
                           (SELECT NVL (STG.LAST_EXTRACT_DATE - 30,
                                        TO_DATE ('01/01/1900', 'MM/DD/YYYY'))
                              FROM ${stagingtableschema}.${stagingtablename} stg
                             WHERE STG.INTERFACE_NAME = '${interfacename}'))
                   AND                                         -- Check Column
                      SUBSTR (TO_CHAR (ITM.AUDIT_LOG),
                                INSTR (TO_CHAR (ITM.AUDIT_LOG),
                                       '*',
                                       1,
                                       3)
                              + 1,
                                INSTR (TO_CHAR (ITM.AUDIT_LOG),
                                       '*',
                                       1,
                                       4)
                              - INSTR (TO_CHAR (ITM.AUDIT_LOG),
                                       '*',
                                       1,
                                       3)
                              - 2) = 'STATUS_CD'
                   AND                                      -- Check New Value
                      SUBSTR (TO_CHAR (ITM.AUDIT_LOG),
                                INSTR (TO_CHAR (ITM.AUDIT_LOG),
                                       '*',
                                       1,
                                       6)
                              + 1,
                                INSTR (TO_CHAR (ITM.AUDIT_LOG),
                                       '*',
                                       1,
                                       7)
                              - INSTR (TO_CHAR (ITM.AUDIT_LOG),
                                       '*',
                                       1,
                                       6)
                              - 2) = 'Active'
                   AND                                      -- Check Old Value
                      SUBSTR (TO_CHAR (ITM.AUDIT_LOG),
                                INSTR (TO_CHAR (ITM.AUDIT_LOG),
                                       '*',
                                       1,
                                       9)
                              + 1,
                                LENGTH (TO_CHAR (ITM.AUDIT_LOG))
                              - INSTR (TO_CHAR (ITM.AUDIT_LOG),
                                       '*',
                                       1,
                                       9)) <> 'New')
   (SELECT /*+ parallel (8)*/
          CARD_NUMBER,
           IDENTIFICATION_NUMBER,
           FIRST_NAME_THAI,
           LAST_NAME_THAI,
           FIRST_NAME_ENGLISH,
           LAST_NAME_ENGLISH,
           GENDER,
           BIRTHDATE,
           MOBILE_#,
           EMAIL_ADDRESS,
           HOUSE_NO_CONDO_VILLAGE,
           MOO_SOI,
           ROAD_STREET,
           PROVINCE,
           POSTAL_CODE,
           STATUS,
           DISTRICT,
           SUB_DISTRICT,
           MEMBER_ID,
           MEMBER_CLASS,
           DONATION_FLAG,
           DONATION_NAME,
           JOINED_SAME_PRICE,
           MEMBER_#,
           ERR_STATUS,
           ERR_MSG,
           UPD_DTTM
      FROM MEMBER_TBL
    UNION
    SELECT /*+parallel(8)*/
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
           SIEBEL.S_LOY_MEM_CON mem_con,
           SIEBEL.S_CONTACT con,
           SIEBEL.S_PROD_INT PROD,
           SIEBEL.S_LOY_CARD card,
           AUDIT_ITM AUDIT_ITM
     WHERE     CARD.MEMBER_ID = MEM.row_id
           -- TODO: Need to uncomment for Production
           AND CARD.STATUS_CD = 'Active'
           AND MEM_CON.MEMBER_ID = MEM.ROW_ID
           AND MEM_CON.PER_ID = CON.ROW_ID
           AND CON.X_PROD_ID = PROD.ROW_ID(+)
           -- FOR AUDIT
           AND card.row_id = AUDIT_ITM.TBL_RECORD_ID
           AND AUDIT_ITM.ORDER_NO = 1
           AND (card.LAST_UPD + 7 / 24 >
                   (SELECT NVL (STG.LAST_EXTRACT_DATE - 30,
                                TO_DATE ('01/01/1900', 'MM/DD/YYYY'))
                      FROM ${stagingtableschema}.${stagingtablename} stg
                     WHERE STG.INTERFACE_NAME = '${interfacename}'))
           AND CARD.ROW_ID NOT IN (SELECT CARD_ROW_ID FROM MEMBER_TBL)


      );


EXIT

