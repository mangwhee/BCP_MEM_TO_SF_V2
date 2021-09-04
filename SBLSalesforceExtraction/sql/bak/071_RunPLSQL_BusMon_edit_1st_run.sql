/* Formatted on 2/19/2017 2:22:18 PM (QP5 v5.163.1008.3004) */
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
SET SERVEROUTPUT ON SIZE 1000000
SET TIMING ON

DECLARE
   V_ACCNT_ROW_ID     SIEBEL.S_ORG_EXT.ROW_ID%TYPE;
   V_ACCNT_REG_STR    SIEBEL.S_ORG_EXT.X_REGIST_STORE%TYPE;
   V_ACCNT_CUST_NUM   SIEBEL.S_ORG_EXT.OU_NUM_1%TYPE;
   V_ACCNT_NAME       SIEBEL.S_ORG_EXT.X_ACCNT_NAME%TYPE;
   V_ACCNT_MEM_NO     SIEBEL.S_ORG_EXT.X_MEM_CARD_NUM%TYPE;
   v_ERR_STATUS       ${stagingtableschema}.${stagingtablename}.ERR_STATUS%TYPE;
   v_ERR_MSG          ${stagingtableschema}.${stagingtablename}.ERR_MSG%TYPE;
   i                  INTEGER;
   v_batch_size       INTEGER;

   CURSOR Cur_SLA_DATE_EDIT
   IS
      SELECT * FROM ${stagingtableschema}.${stagingtablename} 
		   WHERE     (1 = 1)
			AND ERR_STATUS = '0'
			AND (SLA_DUE_DATE_NEW != '09/09/999 09:09:09' OR SLA_STATUS_NEW != 'NOT FOUND');

   v_rec              Cur_SLA_DATE_EDIT%ROWTYPE;
BEGIN
   OPEN Cur_SLA_DATE_EDIT;

   i := 1;
   v_batch_size := ${BatchSizeCurrent};

   LOOP
      FETCH Cur_SLA_DATE_EDIT INTO v_rec;

      EXIT WHEN Cur_SLA_DATE_EDIT%NOTFOUND;

      /********************************************************
        1.  Query data in Siebel with ACCOUNT_ID
      ********************************************************/

      BEGIN
         SELECT ACCNT.ROW_ID,
                ACCNT.X_REGIST_STORE,
                ACCNT.OU_NUM_1,
                ACCNT.X_ACCNT_NAME,
                ACCNT.X_MEM_CARD_NUM
           INTO V_ACCNT_ROW_ID,
                V_ACCNT_REG_STR,
                V_ACCNT_CUST_NUM,
                V_ACCNT_NAME,
                V_ACCNT_MEM_NO
           FROM SIEBEL.S_ORG_EXT ACCNT
          WHERE ACCNT.ROW_ID = v_rec.ACCOUNT_ID;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            v_ERR_STATUS := -2;
            v_ERR_MSG := 'Cannot find this customer in Siebel : ' || SQLERRM;
            GOTO END_OF_PROC;
      END;

      /********************************************************
      2.  Case found: Update X_SLA_DUE_DATE in S_ORG_EXT
      ********************************************************/
      BEGIN
         UPDATE SIEBEL.S_ORG_EXT ACCNT
            SET ACCNT.X_SLA_DUE_DATE = TO_DATE (v_rec.SLA_DUE_DATE_NEW, 'MM/DD/YYYY HH24:MI:SS')
          WHERE ACCNT.ROW_ID = v_rec.ACCOUNT_ID;
      EXCEPTION
         WHEN OTHERS
         THEN
            v_ERR_STATUS := -2;
            v_ERR_MSG :=
               'Cannot update X_SLA_DUE_DATE in Siebel : ' || SQLERRM;
            GOTO END_OF_PROC;
      END;


      /********************************************************
      3.  Case found: Update X_SLA_STAT_CD in S_ORG_EXT
      ********************************************************/
      BEGIN
         UPDATE SIEBEL.S_ORG_EXT ACCNT
            SET ACCNT.X_SLA_STAT_CD = v_rec.SLA_STATUS_NEW
          WHERE ACCNT.ROW_ID = v_rec.ACCOUNT_ID;
      EXCEPTION
         WHEN OTHERS
         THEN
            v_ERR_STATUS := -2;
            v_ERR_MSG := 'Cannot update X_SLA_STAT_CD in Siebel : ' || SQLERRM;
            GOTO END_OF_PROC;
      END;

      /********************************************************
      4.  For successfully updated records
     ********************************************************/
      v_ERR_STATUS := 2;
      v_ERR_MSG := NULL;

     <<END_OF_PROC>>
      /********************************************************
      5.  Update record Status
       ********************************************************/
      BEGIN
         UPDATE ${stagingtableschema}.${stagingtablename}  STG
            SET STG.ERR_STATUS = v_ERR_STATUS,
                STG.ERR_MSG = v_ERR_MSG,
                STG.UPD_DTTM = SYSDATE
          WHERE STG.ACCOUNT_ID = v_rec.ACCOUNT_ID;
      EXCEPTION
         WHEN OTHERS
         THEN
            v_ERR_STATUS := -2;
            v_ERR_MSG := 'Cannot update ERR_MSG and ERR_STAUTS in stage table: ' || SQLERRM;
      END;

      IF MOD (i, v_batch_size) = 0
      THEN
         COMMIT;
      END IF;
      i := i + 1;
   END LOOP;
CLOSE Cur_SLA_DATE_EDIT;
COMMIT;


DBMS_OUTPUT.PUT_LINE ('All Records:' || i);
EXCEPTION
   WHEN OTHERS
   THEN
      DBMS_OUTPUT.PUT_LINE ('Unexpected Error : ' || SQLERRM);
END;
/
