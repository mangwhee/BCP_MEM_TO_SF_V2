/* Formatted on 2/15/2017 8:23:19 PM (QP5 v5.256.13226.35538) */
connect ${user}/${pass}@${db_name}
set term off
set echo off
set head off
--set feedback off
SET TERMOUT OFF
set trimspool on
set pagesize 0
set lines 20000
set pages 20000
SET TIMING ON

CREATE TABLE ${stagingtableschema}.${stagingtablename}
AS
   (SELECT ACCOUNT_ID,
          NAME,
          CREATED,
          SUBMITTED_DATE,
          REG_CHANNEL,
          OLD_STAT,
          CURRENT_STAT,
          LOV_SLA,
          DUE_DATE,
          SLA_STAT,
          SLA_DUE_DATE_NEW,
          CASE
             -- Status: All
             -- Channel: All
             -- X_SLA_DUE_DATE is not null
             -- Sysdate < X_SLA_DUE_DATE
             WHEN     SLA_DUE_DATE_NEW IS NOT NULL AND SYSDATE < TO_DATE (SLA_DUE_DATE_NEW, 'MM/DD/YYYY HH24:MI:SS')
             THEN 'In Progress'
             -- Status: All
             -- Channel: All
             -- X_SLA_DUE_DATE is not null
             -- Sysdate >= X_SLA_DUE_DATE
             WHEN     SLA_DUE_DATE_NEW IS NOT NULL
                  AND SYSDATE >= TO_DATE (SLA_DUE_DATE_NEW, 'MM/DD/YYYY HH24:MI:SS')
             THEN 'Overdue'
             -- Status: Cancelled and Inactive
             -- Channel: All
             -- X_SLA_DUE_DATE is null or ''
             WHEN     (SLA_DUE_DATE_NEW IS NULL OR SLA_DUE_DATE_NEW = '') AND CURRENT_STAT IN ('Cancelled', 'Inactive')
             THEN 'Deactivate'
             -- Status: Approved, Active and  To be Deleted
             -- Channel: All
             -- X_SLA_DUE_DATE is null or ''
             WHEN     (SLA_DUE_DATE_NEW IS NULL OR SLA_DUE_DATE_NEW = '') AND CURRENT_STAT IN ('Approved', 'Active', 'To be Deleted')
             THEN 'No SLA'
             ELSE 'NOT FOUND'
          END
             AS SLA_STATUS_NEW,
          CAST ('0' AS VARCHAR2 (30)) AS ERR_STATUS,
          CAST (NULL AS VARCHAR2 (512)) AS ERR_MSG,
          CAST (NULL AS DATE) AS UPD_DTTM 
	FROM (SELECT /*+PARALLEL(16)*/
                  t2.row_id AS ACCOUNT_ID,
                   t2.NAME AS NAME,
                   t1.CREATED AS CREATED,
                   T2.X_INT_APPROVE_DATE AS SUBMITTED_DATE,
                   t2.CHANNEL_TYPE AS REG_CHANNEL,
                   t2.X_OLD_CUST_STAT AS OLD_STAT,
                   t2.CUST_STAT_CD AS CURRENT_STAT,
                   LOV_ACNT_TYPE.TARGET_HIGH AS LOV_SLA,
                   t2.X_SLA_DUE_DATE AS DUE_DATE,
                   t2.X_SLA_STAT_CD AS SLA_STAT,
                   CASE
                      -- Status: Edit
                      -- Previous Status: Submitted
                      -- Channel: Walk-In and Store CD
                      WHEN     t2.CUST_STAT_CD = 'Edit'
                           AND T2.X_OLD_CUST_STAT = 'Submitted'
                           AND T2.CHANNEL_TYPE IN ('Walk-In', 'Store CD')
                      THEN TO_CHAR (T2.X_INT_APPROVE_DATE + (LOV_ACNT_TYPE.TARGET_HIGH / 24),'MM/DD/YYYY HH24:MI:SS')
                      -- Status: Edit
                      -- Previous Status: Verified
                      -- Channel: Walk-In and Store CD
                      WHEN     t2.CUST_STAT_CD = 'Edit'
                           AND T2.X_OLD_CUST_STAT = 'Verified'
                           AND T2.CHANNEL_TYPE IN ('Walk-In', 'Store CD')
                      THEN TO_CHAR (SYSDATE + (LOV_ACNT_TYPE.TARGET_HIGH / 24),'MM/DD/YYYY HH24:MI:SS')
                      -- Status: Edit
                      -- Previous Status: Submitted, Verified, Completed
                      -- Channel: Canvass
                      WHEN     t2.CUST_STAT_CD = 'Edit'
                           AND T2.X_OLD_CUST_STAT IN ('Submitted','Verified','Completed')
                           AND T2.CHANNEL_TYPE IN ('Canvass')
                      THEN TO_CHAR (SYSDATE + (LOV_ACNT_TYPE.TARGET_HIGH / 24),'MM/DD/YYYY HH24:MI:SS')
                      -- Status: Edit
                      -- Previous Status: Active and To Be Deleted
                      -- Channel: All
                      WHEN     t2.CUST_STAT_CD = 'Edit' AND T2.X_OLD_CUST_STAT IN ('Active','To Be Deleted')
                      THEN TO_CHAR (SYSDATE + (48 / 24),'MM/DD/YYYY HH24:MI:SS')
                      ELSE '09/09/999 09:09:09'
                   END
                      AS SLA_DUE_DATE_NEW
              FROM siebel.s_party t1,
                   siebel.s_org_ext t2,
                   siebel.s_org_ext_x t3,
                   SIEBEL.S_LST_OF_VAL LOV_ACNT_TYPE
             WHERE     (t2.INT_ORG_FLG <> 'Y' OR t2.PRTNR_FLG <> 'N')
                   AND t1.row_id = t2.par_row_id
                   AND t2.X_OLD_CUST_STAT = LOV_ACNT_TYPE.VAL
                   AND t1.row_id = t3.par_row_id
                   AND t2.ACCNT_FLG <> 'N'
                   AND T2.BU_ID IN (SELECT ROW_ID FROM MKBAT.BATCH_ORGANIZATION WHERE INTERFACE_NAME = 'SLA_1ST' AND ACTIVE_FLG = 'Y')
                   AND LOV_ACNT_TYPE.TYPE = 'ACCOUNT_STATUS'
                   AND LOV_ACNT_TYPE.ACTIVE_FLG = 'Y'
				   AND LOV_ACNT_TYPE.BU_ID IN (SELECT ROW_ID FROM MKBAT.BATCH_ORGANIZATION WHERE INTERFACE_NAME = 'SLA_1ST' AND ACTIVE_FLG = 'Y')
                   AND t2.CUST_STAT_CD = 'Edit') TEMP_SLA_DATE );
EXIT


     