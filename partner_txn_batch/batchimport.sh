#!/bin/ksh

. /home/$(whoami)/.bash_profile


declare_variable(){
	interface_name=$1
	
	inifile=${inipath}/${interface_name}.ini
	ctlfile=${ctlpath}/${interface_name}.ctl
	ctlfiletemplate=${ctlpath}/${interface_name}.ctl.template
	# inboundfile=${HomeDir}/inbound/${interface_name}_${DayRun}.csv
	# inboundfile=${HomeDir}/inbound/merchant_20180213_030000.csv
	
	if [ ! -f "$inifile" ]; then
		echo "cannot open ini/${interface_name}.ini"
		exit 1
	fi

	Schema=`cat $inifile | grep "^Schema=" | awk -F"=" '{print $2}'`
	BatchNum=`cat $inifile | grep "^BatchNum=" | awk -F"=" '{print $2}'`
	Organization=`cat $inifile | grep "^Organization=" | awk -F"=" '{print $2}'`
	Program=`cat $inifile | grep "^Program=" | awk -F"=" '{print $2}'`
	PrefixFile=`cat $inifile | grep "^PrefixFile=" | awk -F"=" '{print $2}'`
	IFBFile=`cat $inifile | grep "^IFBFile=" | awk -F"=" '{print $2}'`
	EIMTable=`cat $inifile | grep "^EIMTable=" | awk -F"=" '{print $2}'`
	RunSQLLoader=`cat $inifile | grep "^RunSQLLoader=" | awk -F"=" '{print $2}'`
	RunEIM=`cat $inifile | grep "^RunEIM=" | awk -F"=" '{print $2}'`
	RunPreSQL=`cat $inifile | grep "^RunPreSQL=" | awk -F"=" '{print $2}'`
	RunPostSQL=`cat $inifile | grep "^RunPostSQL=" | awk -F"=" '{print $2}'`
	ConcurrentEIM=`cat $inifile | grep "^ConcurrentEIM=" | awk -F"=" '{print $2}'`
	## MaxRecInSingleBatch=`cat $inifile | grep "^MaxRecInSingleBatch=" | awk -F"=" '{print $2}'`
	
	
	
	envname=`cat $inifile | grep "^EnvName="`
	eval ${envname}	
	runpostifnoeimdata=`cat $inifile | grep "^RunPostIfNoEIMData="`
	eval ${runpostifnoeimdata}
	stgtable=`cat $inifile | grep "^StgTable="`
	eval ${stgtable}
	inputprefix=`cat $inifile | grep "^InputPrefix="`
	eval ${inputprefix}
	inputext=`cat $inifile | grep "^InputExt="`
	eval ${inputext}
	headerfileformat=`cat $inifile | grep "^HeaderFileFormat="`
	eval ${headerfileformat}
	endoffileformat=`cat $inifile | grep "^EndOfFileFormat="`
	eval ${endoffileformat}
	batchsize=`cat $inifile | grep "^BatchSize="`
	eval ${batchsize}
	seqname=`cat $inifile | grep "^SeqName="`
	eval ${seqname}
	presql=`cat $inifile | grep "^PreSQL="`	
	eval ${presql}

	sleeptime=`cat $inifile | grep "^SleepTime="`	
	eval ${sleeptime}
	maxsleepcnt=`cat $inifile | grep "^MaxSleepCnt="`	
	eval ${maxsleepcnt}
	
	purgestagingtablebackupflg=`cat $inifile | grep "^PurgeStagingTableBackupFlg="`	
	eval ${purgestagingtablebackupflg}
	stagingtablebackupretention=`cat $inifile | grep "^StagingTableBackupRetention="`	
	eval ${stagingtablebackupretention}
	
	postsql=`cat $inifile | grep "^PostSQL="`	
	eval ${postsql}

	concurrenteim=`cat $inifile | grep "^ConcurrentEIM="`
	eval ${concurrenteim}
	headerflg=`cat $inifile | grep "^HeaderFlg="`
	eval ${headerflg}
	trailerflg=`cat $inifile | grep "^TrailerFlg="`
	eval ${trailerflg}
	eimstatuschk=`cat $inifile | grep "^EIMStatusChk="`
	eval ${eimstatuschk}
	sqlldrseq=`cat $inifile | grep "^SqlldrSEQ="`
	eval ${sqlldrseq}
	editctlfile=`cat $inifile | grep "^EditCTLFile="`
	eval ${editctlfile}
	backupstgallrecords=`cat $inifile | grep "^BackupSTGALLRecords="`
	eval ${backupstgallrecords}
	splitfile=`cat $inifile | grep "^SplitFile="`
	eval ${splitfile}
	splitfileuniquecolno=`cat $inifile | grep "^SplitFileUniqueColNo="`
	eval ${splitfileuniquecolno}
	splitedprefixname=`cat $inifile | grep "^SplitedPrefixName="`
	eval ${splitedprefixname}
	delimiter=`cat $inifile | grep "^Delimiter="`
	eval ${delimiter}
	checkdigitdelimiter=`cat $inifile | grep "^CheckDigitDelimiter="`
	eval ${checkdigitdelimiter}
	
	# for export
	runexportdata=`cat $inifile | grep "^RunExportData="`
	eval ${runexportdata}
	exportalldataflg=`cat $inifile | grep "^ExportAllDataFlg="`
	eval ${exportalldataflg}	
	# exportdatafilename=`cat $inifile | grep "^ExportDataFileName="`
	# eval ${exportdatafilename}	
	exportdataextname=`cat $inifile | grep "^ExportDataExtName="`
	eval ${exportdataextname}
	exportselectmaincolumn=`cat $inifile | grep "^ExportSelectMainColumn="`
	eval ${exportselectmaincolumn}
	exportprefixadditionalcol=`cat $inifile | grep "^ExportPrefixAdditionalCol="`
	eval ${exportprefixadditionalcol}
	exportselectcolumn=`cat $inifile | grep "^ExportSelectColumn="`
	eval ${exportselectcolumn}	
	exporttable=`cat $inifile | grep "^ExportTable="`
	eval ${exporttable}	
	exportheader=`cat $inifile | grep "^ExportHeader="`
	eval ${exportheader}					
	exportsuccesscriteriaflg=`cat $inifile | grep "^ExportSuccessCriteriaFlg="`
	eval ${exportsuccesscriteriaflg}
	# exportsuccesscriteria=`cat $inifile | grep "^ExportSuccessCriteria="`
	# eval ${exportsuccesscriteria}	
	# exportsuccessfilename=`cat $inifile | grep "^ExportSuccessFileName="`
	# eval ${exportsuccessfilename}
	exportsuccessextname=`cat $inifile | grep "^ExportSuccessExtName="`
	eval ${exportsuccessextname}
	exportfailcriteriaflg=`cat $inifile | grep "^ExportFailCriteriaFlg="`
	eval ${exportfailcriteriaflg}
	# exportfailcriteria=`cat $inifile | grep "^ExportFailCriteria="`
	# eval ${exportfailcriteria}
	# exportfailfilename=`cat $inifile | grep "^ExportFailFileName="`
	# eval ${exportfailfilename}
	exportfailextname=`cat $inifile | grep "^ExportFailExtName="`
	eval ${exportfailextname}	
	exportsyscolflg=`cat $inifile | grep "^ExportSysColFlg="`
	eval ${exportsyscolflg}	
	exportsyscol=`cat $inifile | grep "^ExportSysCol="`
	eval ${exportsyscol}
	exportsyscolsql=`cat $inifile | grep "^ExportSysColSQL="`
	eval ${exportsyscolsql}
	exportsendemailflg=`cat $inifile | grep "^ExportSendEmailFlg="`
	eval ${exportsendemailflg}
	exportemaillist=`cat $inifile | grep "^ExportEmailList="`
	eval ${exportemaillist}
	exportemailsubject=`cat $inifile | grep "^ExportEmailSubject="`
	eval ${exportemailsubject}
	# exportemailbody=`cat $inifile | grep "^ExportEmailBody="`
	# eval ${exportemailbody}
	# exportemailbody=`cat $inifile | awk '/^ExportEmailBody=/,/^\"/'` 
	# eval ${exportemailbody}

	iecho "Check database connection variables"
	if [[ "${BCPBATUSER}" == "" ]] || [[ "${BCPBATPASS}" == "" ]] || [[ "${DB_NAME}" == "" ]]
	then
		ierror " Database connection variables are not valid"
		ierror " Database connection variables --> [${BCPBATUSER}/${BCPBATPASS}@${DB_NAME}]"
		exit 1
	fi
	db_connect_str=${BCPBATUSER}/${BCPBATPASS}@${DB_NAME}
	
}

import_data(){

	if [ "${ctlfile}" != "" ]; then
		if [ ! -f "${ctlfile}" ]; then
			ierror "cannot open $ctlfile"
			exit 1
		fi
		if [ ! -f "${inboundfile}" ]; then
			ierror "Data File NOT FOUND!!"
			exit 1
		fi
		
		iecho "1) Import Data into Staging Started"
		iecho "SqlldrSEQ = [${SqlldrSEQ}]"
		SqlldrLogOnlyName="sqlldr_$(basename ${inboundfile}|awk -v FS=".${InputExt}" '{print $1}')"
		if [[ "${SqlldrSEQ}" == "Y" ]]
		then
			sqlldr userid="$db_connect_str" control="$ctlfile" data="$inboundfile" log="$logpath"/"${SqlldrLogOnlyName}_${CurrentDateTime}".log bad="$logpath"/"${SqlldrLogOnlyName}_${CurrentDateTime}".bad ERRORS=999
			sqlldrExit=$?		
		else
			sqlldr userid="$db_connect_str" control="$ctlfile" data="$inboundfile" log="$logpath"/"${SqlldrLogOnlyName}_${CurrentDateTime}".log bad="$logpath"/"${SqlldrLogOnlyName}_${CurrentDateTime}".bad direct=true ERRORS=999 streamsize=10000000
			sqlldrExit=$?
		fi
		if [[ ${sqlldrExit} -ne 0 ]] && [[ ${sqlldrExit} -ne 2 ]] 
		then
			ierror "SQLLDR ERROR==> while run sqlldr command"
			CountAllRecords=$(grep "Total logical records read:" ${logpath}/${SqlldrLogOnlyName}_${CurrentDateTime}.log |awk '{print $NF}')
			CountRejected=$(grep "Total logical records rejected:" ${logpath}/${SqlldrLogOnlyName}_${CurrentDateTime}.log |awk '{print $NF}')
			CountDiscarded=$(grep "Total logical records discarded:" ${logpath}/${SqlldrLogOnlyName}_${CurrentDateTime}.log |awk '{print $NF}')
			((SuccessRecords=CountAllRecords-CountRejected-CountDiscarded))
			((SuccessRecords=SuccessRecords-CountDiscarded))
			ierror "CountAllRecords = [${CountAllRecords}] record(s)"	
			ierror "CountRejected = [${CountRejected}] record(s)"	
			ierror "CountDiscarded = [${CountDiscarded}] record(s)"	
			ierror "SuccessRecords = [${SuccessRecords}] record(s)"	
			ierror "more details in [${logpath}/${SqlldrLogOnlyName}_${CurrentDateTime}.log]"	
			ierror "Error code: ${sqlldrExit}"
			ierror "Exit with - Error code: ${sqlldrExit}"
			exit ${sqlldrExit}
		elif [[ ${sqlldrExit} -eq 2 ]] 
		then
			ierror "SQLLDR ERROR==> while run sqlldr command (some records were rejected)"
			CountAllRecords=$(grep "Total logical records read:" ${logpath}/${SqlldrLogOnlyName}_${CurrentDateTime}.log |awk '{print $NF}')
			CountRejected=$(grep "Total logical records rejected:" ${logpath}/${SqlldrLogOnlyName}_${CurrentDateTime}.log |awk '{print $NF}')
			CountDiscarded=$(grep "Total logical records discarded:" ${logpath}/${SqlldrLogOnlyName}_${CurrentDateTime}.log |awk '{print $NF}')
			((SuccessRecords=CountAllRecords-CountRejected))
			((SuccessRecords=SuccessRecords-CountDiscarded))
			ierror "CountAllRecords = [${CountAllRecords}] record(s)"	
			ierror "CountRejected = [${CountRejected}] record(s)"	
			ierror "CountDiscarded = [${CountDiscarded}] record(s)"	
			ierror "SuccessRecords = [${SuccessRecords}] record(s)"	
			ierror "more details in [${logpath}/${SqlldrLogOnlyName}_${CurrentDateTime}.log]"	
			ierror "Error code: ${sqlldrExit}"
		else
			CountAllRecords=$(grep "Total logical records read:" ${logpath}/${SqlldrLogOnlyName}_${CurrentDateTime}.log |awk '{print $NF}')
			CountRejected=$(grep "Total logical records rejected:" ${logpath}/${SqlldrLogOnlyName}_${CurrentDateTime}.log |awk '{print $NF}')
			CountDiscarded=$(grep "Total logical records discarded:" ${logpath}/${SqlldrLogOnlyName}_${CurrentDateTime}.log |awk '{print $NF}')
			((SuccessRecords=CountAllRecords-CountRejected))
			((SuccessRecords=SuccessRecords-CountDiscarded))
			iecho "CountAllRecords = [${CountAllRecords}] record(s)"	
			iecho "CountRejected = [${CountRejected}] record(s)"	
			iecho "CountDiscarded = [${CountDiscarded}] record(s)"	
			iecho "SuccessRecords = [${SuccessRecords}] record(s)"	
			iecho "more details in [${logpath}/${SqlldrLogOnlyName}_${CurrentDateTime}.log]"	
			iecho "Error code: ${sqlldrExit}"
		fi
		iecho "1) Import Data into Staging Ended"
		iecho ""
	fi
}

pre_exec(){

	iecho "2) Execute Pre-Procedure Started"
	# StrProc="${PreSQL}('${Organization}','${BatchNum}')"
	iecho " running Store Procedure [${PreSQL}]"
	RunPreExec=`$ORACLE_HOME/bin/sqlplus -s /nolog <<-EOF
	connect ${db_connect_str}
	whenever sqlerror exit 1;
	whenever oserror exit 1;
	SET SERVEROUTPUT ON;
	SET PAGESIZE 0;
	SET FEEDBACK OFF;
	SET VERIFY OFF;
	SET HEADING OFF;
	SET ECHO OFF;
	begin
		${PreSQL};
	end;
	/
EOF`
	out=$(echo ${RunPreExec} | grep "ORA\-[0-9]")
	if [[ $? -eq 0 ]] # if found "ORA-" result will be "0"
	then
		RetVal=1
		ierror "SQL ERROR==> while execute store procedure [${PreSQL}]"
		ierror "SQL ERROR==> ${out}"
		ierror "Error code: ${RetVal}"
		exit ${RetVal}
	fi
	iecho "2) Execute Pre-Procedure Ended"
	iecho ""
	extract_stg_error 
}

extract_stg_error () {

	iecho "2.1) Extract error record(s) from staging table Started"
## Backup Error record(s)
	iecho " checking and backup error data in [${StgTable}]"

	CntNotExecuteSTG=`$ORACLE_HOME/bin/sqlplus -s ${db_connect_str} <<-THEEND
set pagesize 0 feedback off verify off heading off echo off;
select trim(count(1)) from ${StgTable} where err_status=0 ;
EXIT
THEEND`
	out=$(echo ${CntNotExecuteSTG} | grep "ORA\-[0-9]")
	if [[ $? -eq 0 ]] # if found "ORA-" result will be "0"
	then
		RetVal=1
		ierror "SQL ERROR==> while check not executed record(s) in staging table"
		ierror "SQL ERROR==> ${out}"
		ierror "Error code: ${RetVal}"
		exit ${RetVal}
	fi
	
	CntSuccessSTG=`$ORACLE_HOME/bin/sqlplus -s ${db_connect_str} <<-THEEND
set pagesize 0 feedback off verify off heading off echo off;
select trim(count(1)) from ${StgTable} where err_status>0 ;
EXIT
THEEND`
	out=$(echo ${CntSuccessSTG} | grep "ORA\-[0-9]")
	if [[ $? -eq 0 ]] # if found "ORA-" result will be "0"
	then
		RetVal=1
		ierror "SQL ERROR==> while check success record(s) in staging table"
		ierror "SQL ERROR==> ${out}"
		ierror "Error code: ${RetVal}"
		exit ${RetVal}
	fi
	
	CntFailSTG=`$ORACLE_HOME/bin/sqlplus -s ${db_connect_str} <<-THEEND
set pagesize 0 feedback off verify off heading off echo off;
select trim(count(1)) from ${StgTable} where err_status<0 ;
EXIT
THEEND`
	out=$(echo ${CntFailSTG} | grep "ORA\-[0-9]")
	if [[ $? -eq 0 ]] # if found "ORA-" result will be "0"
	then
		RetVal=1
		ierror "SQL ERROR==> while check check fail record(s) in staging table"
		ierror "SQL ERROR==> ${out}"
		ierror "Error code: ${RetVal}"
		exit ${RetVal}
	fi
	iecho " ------------------------------------------"
	iecho " CntNotExecuteSTG = [${CntNotExecuteSTG}]"
	iecho " CntSuccessSTG = [${CntSuccessSTG}]"
	iecho " CntFailSTG = [${CntFailSTG}]"
	iecho " ------------------------------------------"
	if [[ ${CntFailSTG} -eq 0 ]]
	then
		iecho " There is no error in staging table --> [${CntFailSTG}] record"
	else
		ChkStgTbl=$(echo ${StgTable} | awk -F"." '{print NF}')
		if [[ ${ChkStgTbl} -eq 2 ]]
		then
			BakSTGTBl="${Schema}.BK_$(echo ${StgTable}|awk -F"." '{print $2}')"
		elif [[ ${ChkStgTbl} -eq 1 ]]
		then
			BakSTGTBl="${Schema}.BK_${StgTable}"
		else
			ierror "  Invalid Staging Table Name [${StgTable}]"
			exit 1
		fi
		iecho " Found error in staging table --> [${CntFailSTG}] record(s)"
		iecho " BakSTGTBl = [${BakSTGTBl}]"
		iecho " Inserting error record(s) in backup table [${BakSTGTBl}]"
		InsertErrToBakSTGTBL=`$ORACLE_HOME/bin/sqlplus -s ${db_connect_str} <<-THEEND
		set pagesize 0 feedback off verify off heading off echo off;
		INSERT /*+ APPEND */
		INTO ${BakSTGTBl}
		SELECT * FROM ${StgTable} where err_status<0 ;
EXIT
THEEND`
		out=$(echo ${InsertErrToBakSTGTBL} | grep "ORA\-[0-9]")
		if [[ $? -eq 0 ]] # if found "ORA-" result will be "0"
		then
			RetVal=1
			ierror "  SQL ERROR==> while Insert error record(s) in backup table [${BakSTGTBl}]"
			ierror "  SQL ERROR==> ${out}"
			ierror "  Error code: ${RetVal}"
			exit ${RetVal}
		fi
	fi

## Backup Error record(s)
iecho ""
iecho " BackupSTGALLRecords = [${BackupSTGALLRecords}]"
if [[ "${BackupSTGALLRecords}" == "Y" ]]
then
	iecho " Need to backup success/not executed record(s) as well"
	iecho " checking and backup success/not executed data in [${StgTable}]"
	CntFailSTG=`$ORACLE_HOME/bin/sqlplus -s ${db_connect_str} <<-THEEND
set pagesize 0 feedback off verify off heading off echo off;
select trim(count(1)) from ${StgTable} where err_status>=0 ;
EXIT
THEEND`
	out=$(echo ${CntFailSTG} | grep "ORA\-[0-9]")
	if [[ $? -eq 0 ]] # if found "ORA-" result will be "0"
	then
		RetVal=1
		ierror "SQL ERROR==> while check success/not executed record(s) in staging table"
		ierror "SQL ERROR==> ${out}"
		ierror "Error code: ${RetVal}"
		exit ${RetVal}
	fi
	if [[ ${CntFailSTG} -eq 0 ]]
	then
		iecho " There is no success/not executed in staging table --> [${CntFailSTG}] record"
	else
		ChkStgTbl=$(echo ${StgTable} | awk -F"." '{print NF}')
		if [[ ${ChkStgTbl} -eq 2 ]]
		then
			BakSTGTBl="${Schema}.BK_$(echo ${StgTable}|awk -F"." '{print $2}')"
		elif [[ ${ChkStgTbl} -eq 1 ]]
		then
			BakSTGTBl="${Schema}.BK_${StgTable}"
		else
			ierror "  Invalid Staging Table Name [${StgTable}]"
			exit 1
		fi
		iecho " Found success/not executed record(s) in staging table --> [${CntFailSTG}] record(s)"
		iecho " BakSTGTBl = [${BakSTGTBl}]"
		iecho " Inserting success/not executed record(s) in backup table [${BakSTGTBl}]"
		InsertErrToBakSTGTBL=`$ORACLE_HOME/bin/sqlplus -s ${db_connect_str} <<-THEEND
		set pagesize 0 feedback off verify off heading off echo off;
		INSERT /*+ APPEND */
		INTO ${BakSTGTBl}
		SELECT * FROM ${StgTable} where err_status>=0 ;
EXIT
THEEND`
		out=$(echo ${InsertErrToBakSTGTBL} | grep "ORA\-[0-9]")
		if [[ $? -eq 0 ]] # if found "ORA-" result will be "0"
		then
			RetVal=1
			ierror "  SQL ERROR==> while Insert success/not executed record(s) in backup table [${BakSTGTBl}]"
			ierror "  SQL ERROR==> ${out}"
			ierror "  Error code: ${RetVal}"
			exit ${RetVal}
		fi
	fi
else
	iecho " No need to backup success/not executed record(s)"
fi		
	

	iecho "2.1) Extract error record(s) from staging table Ended"
	iecho ""
}

eim_process(){
	iecho "3) Execute EIM Started"
	
	#--------Check Valid IFB File----------#
	IFBFilePath=${SIEBSRVR_ROOT}/admin/${IFBFile}
	if [[ ! -f "${IFBFilePath}" ]]
	then
		ierror "IFB file not found [${IFBFilePath}]."
		exit 1
	fi
	#--------Check No of Batch Process must not be zero----------#
	if [[ ${ConcurrentEIM} -eq 0 ]]
	then
		ierror "No of Batch Process must not be zero [${ConcurrentEIM}]."
		exit 1
	fi

		
	
	
	iecho "GET EIM TABLE NAME AND START TIME"
	#***************************************************************************
	#	GET EIM TABLE NAME AND START TIME
	#***************************************************************************
	table_name=`cat  ${IFBFilePath}  |grep -w "TABLE.*=" |awk -F"=" '$2~/^.*EIM_/ {print $2}' |awk 'sub(/^[ \t\r\n]+/, "", $0) {print $0}'|head -1`
	start_time=`date +"%D %T"`

	iecho "EIM TABLE NAME = [${table_name}]"
	iecho "START TIME = [${start_time}]"
	
	ChkMinMaxEIM=`$ORACLE_HOME/bin/sqlplus -s ${db_connect_str} <<-THEEND
-- connect ${db_connect_str}
set pagesize 0 feedback off verify off heading off echo off;
SELECT MIN (A.IF_ROW_BATCH_NUM) || '|' || MAX (A.IF_ROW_BATCH_NUM) MIN_MAX
FROM siebel.${table_name} A
WHERE A.IF_ROW_BATCH_NUM LIKE '${BatchNum}%';
EXIT
THEEND`
	out=$(echo ${ChkMinMaxEIM} | grep "ORA\-[0-9]")
	if [[ $? -eq 0 ]] # if found "ORA-" result will be "0"
	then
		RetVal=1
		ierror "SQL ERROR==> while check mim/mix batch number in EIM table"
		ierror "SQL ERROR==> ${out}"
		ierror "Error code: ${RetVal}"
		exit ${RetVal}
	fi
	start_batch=$(echo ${ChkMinMaxEIM} | awk -F"|" '{print $1}')
	end_batch=$(echo ${ChkMinMaxEIM} | awk -F"|" '{print $2}')
	
	#--------Check Start and End Batch No.----------#
	iecho "Check start_batch/end_batch = [${start_batch}/${end_batch}]"
	batch_diff=`expr ${end_batch} - ${start_batch} + 1`
	iecho "BATCH END - BATCH START = [${batch_diff}]"
	iecho "ConcurrentEIM = [${ConcurrentEIM}]"
	if [[ ${batch_diff} -lt 0 ]]
	then
		ierror "Start Batch Number is greater than End Batch Number"
		exit 1
	fi
	#--------Check No of Batch Process must not be less than batch diff----------#
	if [[ ${ConcurrentEIM} -gt ${batch_diff} ]]
	then
		ierror "No of Batch Process [${ConcurrentEIM}] must not be greater than batch different [${batch_diff}]."
		mkdir -p ${InboundArchiveTodayPath}
		mv ${InboundBakFile} ${InboundArchiveTodayPath}
		mv ${InboundFileName} ${InboundArchiveTodayPath}
		exit 1
	fi	

	if [[ ${batch_diff} -eq 0 ]]
	then
		CountEIMProc=`expr ${ConcurrentEIM}`
	else
		CountEIMProc=`expr 1`
		iecho "CountEIMProc = ${CountEIMProc}"
	fi
	

	((proc_end_batch=start_batch-1))
	((batch_size=batch_diff/ConcurrentEIM))
	((batch_mod=batch_diff%ConcurrentEIM))
	iecho "BATCH SIZE = ${batch_size}"

	. ${SIEBSRVR_ROOT}/siebenv.sh
	# CountEIMProc=1
	while [[ ${CountEIMProc} -le ${ConcurrentEIM} ]]
	do	
	((proc_start_batch=proc_end_batch+1))
	((proc_end_batch=proc_start_batch+batch_size-1))
	#-----
	if [[ ${CountEIMProc} -le ${batch_mod} ]]; then
		((proc_end_batch=proc_end_batch+1))
	fi
	
	BATCH="${proc_start_batch}-${proc_end_batch}"
	iecho "Process ${CountEIMProc} START BATCH-END BATCH  = [${BATCH}]"
	
	srvrmgr /g $GatewayEIM /e $EnterpriseEIM /s $ServerEIM /u $UserEIM /p $PassEIM /c "run task for comp eim with config=${IFBFile},Errorflags=1,Sqlflags=1,Traceflags=1,extendedparams=\"BATCHRNG=${BATCH}\"" &
	srvrmr_pid=$!
	JobID[${CountEIMProc}]=${srvrmr_pid}
	((CountEIMProc=CountEIMProc+1))
	done
	FAIL=0
	CountWait=1
	((CountEIMProc=CountEIMProc-1))
	while [[ ${CountWait} -le ${CountEIMProc} ]]
	do
	iecho "${CountWait}|${JobID[${CountWait}]}"
	wait ${JobID[${CountWait}]}	
	srvrmgr_status=$?
	if [[ ${CountWait} -eq 1 ]]
	then
		iecho ""
	fi
	if [[ ${srvrmgr_status} -eq 0 ]]
	then
		iecho "JOB <${CountWait}>|${JobID[${CountWait}]}|success"
	else
		ierror "JOB <${CountWait}>|${JobID[${CountWait}]}|error"
		((FAIL=FAIL+1))
	fi
	((CountWait=CountWait+1))
	done

	if [[ ${FAIL} -ne 0 ]] # check return code of wait command
	then
		srvrmgr_exit=1
		ierror "No. of failure job(s) = [${FAIL}]"
		ierror "SRVRMGR ERROR==> while run srvrmgr command"
		ierror "Error code: ${srvrmgr_exit}"
		exit ${srvrmgr_exit}
	else
		iecho "All EIM Job(s) run successfully"
	fi	
	iecho ""
	iecho "3) Execute EIM Ended"
	iecho ""
	extract_eim_error
}

extract_eim_error () {
	iecho "3.1) Extract error record(s) from eim table Started"
	EIMTableS=`cat  ${IFBFilePath}  |grep -w "TABLE.*=" |awk -F"=" '$2~/^.*EIM_/ {print $2}' |awk 'sub(/^[ \t\r\n]+/, "", $0) {print $0}'`
	if [[ "${EIMTableS}" == "" ]]
	then
		ierror " No EIM table in IFB file"
		exit 1
	fi
	for EIMTable in ${EIMTableS}
	do
		iecho " checking error in eim table [${EIMTable}]"
		if [[ "${EIMStatusChk}" == "" ]]
		then
			ierror " No EIMStatusChk --> [${EIMStatusChk}]"
			exit 1
		fi
		CntEIMStatus=`$ORACLE_HOME/bin/sqlplus -s ${db_connect_str} <<-THEEND
set pagesize 0 feedback off verify off heading off echo off;
WITH EIM_STATUS_TMP
     AS (SELECT 'SUCCESSFULLY' EIM_STAT_TMP FROM DUAL
         UNION
         SELECT 'NOT_SUCCESSFULLY' EIM_STAT_TMP FROM DUAL),
     EIM_STAT_CNT
     AS (  SELECT                                            /*+parallel (8)*/
                 CASE
                     WHEN A.IF_ROW_STAT IN ${EIMStatusChk} THEN 'SUCCESSFULLY'
                     ELSE 'NOT_SUCCESSFULLY'
                  END
                     AS EIM_STATUS,
                  COUNT (1) EIM_CNT
             FROM SIEBEL.${EIMTable} A
            WHERE A.IF_ROW_BATCH_NUM LIKE '${BatchNum}%'
         GROUP BY CASE
                     WHEN A.IF_ROW_STAT IN ${EIMStatusChk} THEN 'SUCCESSFULLY'
                     ELSE 'NOT_SUCCESSFULLY'
                  END)
SELECT    TRIM (EIM_STAT.EIM_STAT_TMP)
       || '|'
       || TRIM (NVL (EIM_CNT_TBL.EIM_CNT, 0))
          AS CNT
  FROM EIM_STAT_CNT EIM_CNT_TBL, EIM_STATUS_TMP EIM_STAT
 WHERE EIM_STAT.EIM_STAT_TMP = EIM_CNT_TBL.EIM_STATUS(+);
EXIT
THEEND`
		out=$(echo ${CntEIMStatus} | grep "ORA\-[0-9]")
		if [[ $? -eq 0 ]] # if found "ORA-" result will be "0"
		then
			RetVal=1
			ierror "  SQL ERROR==> while check check fail record(s) in eim table [${EIMTable}]"
			ierror "  SQL ERROR==> ${out}"
			ierror "  Error code: ${RetVal}"
			exit ${RetVal}
		fi
		CntEIMStatusNew=$(echo ${CntEIMStatus}|sed -e 's/ /|/g')
		CntEIMSuccessCOL=$(echo ${CntEIMStatusNew} | awk -F"|" '{ for (i=1; i<=NF; ++i) { if ($i == "SUCCESSFULLY") print i } }')
		((CntEIMSuccessCOL=CntEIMSuccessCOL+1))
		CntEIMErrorCOL=$(echo ${CntEIMStatusNew} | awk -F"|" '{ for (i=1; i<=NF; ++i) { if ($i == "NOT_SUCCESSFULLY") print i } }')
		((CntEIMErrorCOL=CntEIMErrorCOL+1))		
		CntEIMSuccess=$(echo ${CntEIMStatusNew} | awk -v CntEIMSuccessCOL="${CntEIMSuccessCOL}" -F"|" '{print $CntEIMSuccessCOL}')
		CntEIMError=$(echo ${CntEIMStatusNew} | awk -v CntEIMErrorCOL="${CntEIMErrorCOL}" -F"|" '{print $CntEIMErrorCOL}')
		iecho " CntEIMSuccess in [${EIMTable}] = [${CntEIMSuccess}] record(s)"
		iecho " CntEIMError in [${EIMTable}] = [${CntEIMError}] record(s)"
		if [[ ${CntEIMError} -eq 0 ]]
		then
			iecho " There is no error in eim table [${EIMTable}] --> [${CntEIMError}] record"
		else
			iecho " Found error in eim table [${EIMTable}] --> [${CntEIMError}] record(s)"
			# EIMBakTable="${Schema}.BK_${EIMTable}"
			# iecho " Inserting error record(s) in table [${EIMBakTable}]"
			# InsertErrToBakTBL=`$ORACLE_HOME/bin/sqlplus -s ${db_connect_str} <<-THEEND
			# set pagesize 0 feedback off verify off heading off echo off;
			# INSERT /*+ APPEND */
				  # INTO ${EIMBakTable}
			   # SELECT *
				 # FROM SIEBEL.${EIMTable} A
				# WHERE A.IF_ROW_BATCH_NUM LIKE '${BatchNum}%' AND A.IF_ROW_STAT IN ${EIMStatusChk};
# EXIT
# THEEND`
			# out=$(echo ${InsertErrToBakTBL} | grep "ORA\-[0-9]")
			# if [[ $? -eq 0 ]] # if found "ORA-" result will be "0"
			# then
				# RetVal=1
				# ierror "  SQL ERROR==> while Insert error record(s) in table [${EIMBakTable}]"
				# ierror "  SQL ERROR==> ${out}"
				# ierror "  Error code: ${RetVal}"
				# exit ${RetVal}
			# fi
		fi
		iecho ""
	done
	iecho "3.1) Extract error record(s) from eim table Ended"
	iecho ""

}

post_exec(){
	iecho "4) Execute Post-Procedure Started"
	iecho " running Post Store Procedure [${PostSQL}]"
	RunPostExec=`$ORACLE_HOME/bin/sqlplus -s /nolog <<-EOF
	connect ${db_connect_str}
	whenever sqlerror exit 1;
	whenever oserror exit 1;
	SET SERVEROUTPUT ON;
	SET PAGESIZE 0;
	SET FEEDBACK OFF;
	SET VERIFY OFF;
	SET HEADING OFF;
	SET ECHO OFF;
	begin
		${PostSQL};
	end;
	/
EOF`
	out=$(echo ${RunPostExec} | grep "ORA\-[0-9]")
	if [[ $? -eq 0 ]] # if found "ORA-" result will be "0"
	then
		RetVal=1
		ierror "SQL ERROR==> while execute store procedure [${PostSQL}]"
		ierror "SQL ERROR==> ${out}"
		ierror "Error code: ${RetVal}"
		exit ${RetVal}
	fi
	iecho "4) Execute Post-Procedure Ended"
	iecho ""
}

export_data(){

iecho ""
iecho "6) Start Export Data to file(s)"
iecho ""
InputFileInQueue=$(cat ${QFileName} | wc -l |tr -d [:blank:])


NoOfInput=1
cat ${QFileName} | while read Queue
do
exportsuccessfilename=`cat $inifile | grep "^ExportSuccessFileName="`
eval ${exportsuccessfilename}
exportfailfilename=`cat $inifile | grep "^ExportFailFileName="`
eval ${exportfailfilename}
exportoriginalfilename=`cat $inifile | grep "^ExportOriginalFileName="`
eval ${exportoriginalfilename}

##------------------------------------------------------------------------------
InputQDataFileName=$(echo ${Queue}|grep "${RunNumber}" |awk -v FS="_${RunNumber}" -v InputExt="${InputExt}" '{print $1"."InputExt}')
iecho " -- Start Check data and prepare Header and SQL"
## Add to fix flexible Column
# FileNameAndNoOfColList[${#FileNameAndNoOfColList[*]}+1]="${FileNameChk}|${NoOfInputColumn}"
NoOfArrayFileNameAndNoOfColList=$(echo ${#FileNameAndNoOfColList[*]})
CntFileInList=1
iecho " InputQDataFileName = [${InputQDataFileName}]"
for FileNameAndNoOfCol in ${FileNameAndNoOfColList[*]}
do
	OnlyFileNameAndNoOfCol=$(basename ${FileNameAndNoOfCol})
	iecho " OnlyFileNameAndNoOfCol = [${OnlyFileNameAndNoOfCol}]"
	FileNameInList=$(echo ${OnlyFileNameAndNoOfCol} | awk -F"|" '{print $1}')
	if [[ "${InputQDataFileName}" == "${FileNameInList}" ]]
	then
	NoOfColInList=$(echo ${OnlyFileNameAndNoOfCol} | awk -F"|" '{print $2}')
	NoOfInputColumn=${NoOfColInList}
	break
	fi
((CntFileInList=CntFileInList+1))
done

ExportNoOfMainColumn=$(echo ${ExportSelectMainColumn} |awk -v FS="${Delimiter}" '{print NF}')
((NoOfAdditionalColInFile=NoOfInputColumn-ExportNoOfMainColumn))
iecho " NoOfInputColumn = [${NoOfInputColumn}]"
iecho " ExportNoOfMainColumn = [${ExportNoOfMainColumn}]"
iecho " NoOfAdditionalColInFile = [${NoOfAdditionalColInFile}]"
iecho " ExportPrefixAdditionalCol = [${ExportPrefixAdditionalCol}]"
# AllSysColNameForSQL=$(echo "${ExportSysCol}" | sed -e "s/${Delimiter}/||\'${Delimiter}\'||/g")

set -A AdditionalColumnNameList
set -A AdditionalColumnNameSQLList
CntAdditionalColumn=1
while [[ ${CntAdditionalColumn} -le ${NoOfAdditionalColInFile} ]]
do
	## Add Data into the list
	AdditionalColumnNameList[${#AdditionalColumnNameList[*]}+1]="${ExportPrefixAdditionalCol}${CntAdditionalColumn}"
	if [[ ${CntAdditionalColumn} -eq ${NoOfAdditionalColInFile}  ]]
	then
		if [[ ${NoOfAdditionalColInFile} -eq 1  ]]
		then
			AdditionalColumnName="||'${Delimiter}'||${ExportPrefixAdditionalCol}${CntAdditionalColumn}"
		else
			AdditionalColumnName="${ExportPrefixAdditionalCol}${CntAdditionalColumn}"
		fi
	else
		if [[ ${CntAdditionalColumn} -eq 1  ]]
		then
			AdditionalColumnName="||'${Delimiter}'||${ExportPrefixAdditionalCol}${CntAdditionalColumn}||'${Delimiter}'||"
		else
			AdditionalColumnName="${ExportPrefixAdditionalCol}${CntAdditionalColumn}||'${Delimiter}'||"
		fi
	fi
	AdditionalColumnNameSQLList[${#AdditionalColumnNameSQLList[*]}+1]="${AdditionalColumnName}"
((CntAdditionalColumn=CntAdditionalColumn+1))
done
AdditionalColumnNameForSQL=$(echo "${AdditionalColumnNameSQLList[*]}")


iecho " ExportSelectMainColumnForSQL = [${ExportSelectMainColumn}]"
iecho " AdditionalColumnNameForSQL = [${AdditionalColumnNameForSQL}]"
iecho " ExportSysColSQL = [${ExportSysColSQL}]"

## for header
if [[ "${ExportHeader}" == "Y" ]]
then
AdditionalColumnNameForHeader=$(echo "${AdditionalColumnNameList[*]}"| sed -e "s/ /${Delimiter}/g")
	if [[ "${ExportSysColFlg}" == "Y" ]]
	then
		if [[ ${NoOfAdditionalColInFile} -eq 0 ]]
		then
			OutputHeader="$(echo "$(cat ${HeaderFileName} |grep "${Queue}" | awk -v FS="${CheckDigitDelimiter}" '{printf "%s",$2}' | sed -e 's/\r//g'|awk -v FS="${Delimiter}"  -v f=1 -v t=${ExportNoOfMainColumn} -v OFS="${Delimiter}" '{for(i=f;i<=t;i++) printf("%s%s",$i,(i==t)?"\n":OFS)}')${ExportSysCol}")"
		else
			OutputHeader="$(echo "$(cat ${HeaderFileName} |grep "${Queue}" | awk -v FS="${CheckDigitDelimiter}" '{printf "%s",$2}' | sed -e 's/\r//g'|awk -v FS="${Delimiter}"  -v f=1 -v t=${NoOfInputColumn} -v OFS="${Delimiter}" '{for(i=f;i<=t;i++) printf("%s%s",$i,(i==t)?"\n":OFS)}')${ExportSysCol}")"
		fi
	else
		if [[ ${NoOfAdditionalColInFile} -eq 0 ]]
		then
			OutputHeader=$( echo "$(cat ${HeaderFileName} |grep "${Queue}" | awk -v FS="${CheckDigitDelimiter}" '{print $2}'| awk -v FS="${Delimiter}"  -v f=1 -v t=${ExportNoOfMainColumn} -v OFS="${Delimiter}" '{for(i=f;i<=t;i++) printf("%s%s",$i,(i==t)?"\n":OFS)}')")
		else
			OutputHeader=$( echo "$(cat ${HeaderFileName} |grep "${Queue}" | awk -v FS="${CheckDigitDelimiter}" '{print $2}'| awk -v FS="${Delimiter}"  -v f=1 -v t=${NoOfInputColumn} -v OFS="${Delimiter}" '{for(i=f;i<=t;i++) printf("%s%s",$i,(i==t)?"\n":OFS)}')")
		fi
	fi
iecho " AdditionalColumnNameForHeader = [${AdditionalColumnNameForHeader}]"
iecho " ExportSysForHeader = [${ExportSysCol}]"
iecho " AllOutputHeader = [${OutputHeader}]"
fi

iecho " -- End Check data and prepare Header and SQL"
iecho ""
##------------------------------------------------------------------------------

iecho " NoOfInput/InputFileInQueue = [${NoOfInput}/${InputFileInQueue}]"
iecho " Checking ExportAllDataFlg ==> [${ExportAllDataFlg}] "
if [[ "${ExportAllDataFlg}" == "Y" ]]
then
	exportallcriteria=`cat $inifile | grep "^ExportAllCriteria="`
	eval ${exportallcriteria}	
	exportdatafilename=`cat $inifile | grep "^ExportDataFileName="`
	eval ${exportdatafilename}	
	ExportOutputFile="${outputpath}/${ExportDataFileName}.${ExportDataExtName}"
	iecho " ExportOutputFile=[${ExportOutputFile}]"
	ExportEmailAttachment="-a ${ExportOutputFile}"
	
	if [[ "${ExportHeader}" == "Y" ]]
	then
		SQL="
		spool ${ExportOutputFile};
		SELECT '${OutputHeader}' FROM DUAL;
		SELECT ${ExportSelectMainColumn}${AdditionalColumnNameForSQL}${ExportSysColSQL}
		FROM ${ExportTable} WHERE (1=1)
		AND ${ExportAllCriteria};
		spool off;
		"
	else
		SQL="
		spool ${ExportOutputFile};
		SELECT ${ExportSelectMainColumn}${AdditionalColumnNameForSQL}${ExportSysColSQL}
		FROM ${ExportTable} WHERE (1=1)
		AND ${ExportAllCriteria};
		spool off;
		"
	fi
else
	exportsuccesscriteria=`cat $inifile | grep "^ExportSuccessCriteria="`
	eval ${exportsuccesscriteria}	
	exportfailcriteria=`cat $inifile | grep "^ExportFailCriteria="`
	eval ${exportfailcriteria}
	iecho " Checking ExportSuccessCriteriaFlg & ExportFailCriteriaFlg ===> [${ExportSuccessCriteriaFlg}/${ExportFailCriteriaFlg}] "
	ExportSuccessOutputFile="${outputpath}/${ExportSuccessFileName}.${ExportSuccessExtName}"
	ExportFailOutputFile="${outputpath}/${ExportFailFileName}.${ExportFailExtName}"
	iecho " ExportSuccessOutputFile=[${ExportSuccessOutputFile}]"
	iecho " ExportFailOutputFile=[${ExportFailOutputFile}]"
	if [[ "${ExportSuccessCriteriaFlg}" == "Y" ]] && [[ "${ExportFailCriteriaFlg}" == "Y" ]] 
	then
		ExportEmailAttachment="-a ${ExportSuccessOutputFile} -a ${ExportFailOutputFile}"
		if [[ "${ExportHeader}" == "Y" ]]
		then
			SQL="
			spool ${ExportSuccessOutputFile};
			SELECT '${OutputHeader}' FROM DUAL;
			SELECT ${ExportSelectMainColumn}${AdditionalColumnNameForSQL}${ExportSysColSQL}
			FROM ${ExportTable} WHERE (1=1)
			AND ${ExportSuccessCriteria};
			spool off;

			spool ${ExportFailOutputFile};
			SELECT '${OutputHeader}' FROM DUAL;
			SELECT ${ExportSelectMainColumn}${AdditionalColumnNameForSQL}${ExportSysColSQL}
			FROM ${ExportTable} WHERE (1=1)
			AND ${ExportFailCriteria};
			spool off;

			"
		else
			SQL="
			spool ${ExportSuccessOutputFile};
			SELECT ${ExportSelectMainColumn}${AdditionalColumnNameForSQL}${ExportSysColSQL}
			FROM ${ExportTable} WHERE (1=1)
			AND ${ExportSuccessCriteria};
			spool off;

			spool ${ExportFailOutputFile};
			SELECT ${ExportSelectMainColumn}${AdditionalColumnNameForSQL}${ExportSysColSQL}
			FROM ${ExportTable} WHERE (1=1)
			AND ${ExportFailCriteria};
			spool off;

			"
		fi
	elif [[ "${ExportSuccessCriteriaFlg}" == "Y" ]] && [[ "${ExportFailCriteriaFlg}" == "N" ]] 
	then
		ExportEmailAttachment="-a ${ExportSuccessOutputFile}"
		if [[ "${ExportHeader}" == "Y" ]]
		then
			SQL="
			spool ${ExportSuccessOutputFile};
			SELECT '${OutputHeader}' FROM DUAL;
			SELECT ${ExportSelectMainColumn}${AdditionalColumnNameForSQL}${ExportSysColSQL}
			FROM ${ExportTable} WHERE (1=1)
			AND ${ExportSuccessCriteria};
			spool off;

			"
		else
			SQL="
			spool ${ExportSuccessOutputFile};
			SELECT ${ExportSelectMainColumn}${AdditionalColumnNameForSQL}${ExportSysColSQL}
			FROM ${ExportTable} WHERE (1=1)
			AND ${ExportSuccessCriteria};
			spool off;

			"

		fi
	elif [[ "${ExportSuccessCriteriaFlg}" == "N" ]] && [[ "${ExportFailCriteriaFlg}" == "Y" ]] 
	then
		ExportEmailAttachment="-a ${ExportFailOutputFile}"
		if [[ "${ExportHeader}" == "Y" ]]
		then
			SQL="
			spool ${ExportFailOutputFile};
			SELECT '${OutputHeader}' FROM DUAL;
			SELECT ${ExportSelectMainColumn}${AdditionalColumnNameForSQL}${ExportSysColSQL}
			FROM ${ExportTable} WHERE (1=1)
			AND ${ExportFailCriteria};
			spool off;

			"
		else

			SQL="
			spool ${ExportFailOutputFile};
			SELECT ${ExportSelectMainColumn}${AdditionalColumnNameForSQL}${ExportSysColSQL}
			FROM ${ExportTable} WHERE (1=1)
			AND ${ExportFailCriteria};
			spool off;

			"
		fi
	else
		iecho " No need to run export with criteria"
	fi

fi

export NLS_LANG=AMERICAN_AMERICA.UTF8

ExeExportDataToFile=`$ORACLE_HOME/bin/sqlplus -s ${db_connect_str} <<-THEEND
WHENEVER OSERROR EXIT 1;
WHENEVER SQLERROR EXIT 1;

SET SPACE 0
SET HEADING OFF
SET FEEDBACK OFF
SET TERMOUT OFF
set linesize 32767
SET LONG 32767 LONGC 32767 LIN 32767 pages 0
set echo off
set newpage 0
set space 0
set pagesize 0
set lines 32767
set TRIMSPOOL ON

SET SERVEROUTPUT ON SIZE 1000000
CALL DBMS_JAVA.SET_OUTPUT(1000000);
${SQL}
EXIT
THEEND`

out=$(echo ${ExeExportDataToFile} | grep "ORA\-[0-9]")
if [[ $? -eq 0 ]] # if found "ORA-" result will be "0"
then
	RetVal=1
	ierror "SQL ERROR==> while exporting data to file"
	ierror "SQL ERROR==> ${out}"
	ierror "Error code: ${RetVal}"
	exit ${RetVal}
fi
((NoOfInput=NoOfInput+1))
iecho ""
iecho " -- Start Send Email the results to users"
iecho " ExportSendEmailFlg = [${ExportSendEmailFlg}]"

if [[ "${ExportSendEmailFlg}" == "Y" ]]
then
	exportemailbody=`cat $inifile | awk '/^ExportEmailBody=/,/^\"/'` 
	eval ${exportemailbody}
	ExportEmailBodyTempFile=${temppath}/ExportEmailBody_${CurrentDateTime}.tmp
	iecho " NLS_LANG = [${NLS_LANG}]"
	iecho " ExportEmailList = [${ExportEmailList}]"
	iecho " ExportEmailSubject = [${ExportEmailSubject}]"
	iecho " ExportEmailBody = [${ExportEmailBody}]"
	iecho " ExportEmailAttachment = [${ExportEmailAttachment}]"
	echo -e "${ExportEmailBody}" > ${ExportEmailBodyTempFile}
	cat ${ExportEmailBodyTempFile} | /bin/mailx -s "${ExportEmailSubject}" ${ExportEmailAttachment} ${ExportEmailList}
	if [[ $? -ne 0 ]]
	then
			ierror "Error while sending email to [${ExportEmailList}] success"
	else
			iecho " Send email to [${ExportEmailList}] success"
	fi
else
	iecho " No need to send email to users"

fi
iecho " -- End Send Email the results to users"
iecho ""

done
iecho "6) End Export Data to file(s)"
iecho ""

}

iecho(){

	dt_val=`date '+%Y-%m-%d %H:%M:%S'`
	echo "${dt_val}|INF:|${1}"
}

ierror(){

	dt_val=`date '+%Y-%m-%d %H:%M:%S'`
	echo "${dt_val}|ERR:|${1}"
}

convert_unix_to_win_func (){
if [[ $# -ne 1 ]]
then
        echo "Usage: $0 <filename>"
        echo "Example: $0 \"/home/test/Test.txt\""
        exit 1
fi
FileForConvert="${1}"
	iecho "0) Change file from WINDOW to UNIX started"
	##### Convert from WINDOW to UNIX FORMAT #####
	iecho "Filename is [${FileForConvert}]"
	TempFileForConvert="${FileForConvert}.convert"
	iecho "Tempfile is [${TempFileForConvert}]"
	ServerOS=$(uname)
	if [[ "${ServerOS}" == "SunOS" ]]
	then
		iecho "ServerOS is [${ServerOS}]"
		nawk '{ sub("\r$", ""); print }' ${FileForConvert} > ${TempFileForConvert}
		if [[ $? -eq 0 ]];
		then
			iecho "Change file from WINDOW to UNIX mode SUCCESS"
		else
			ierror "Error while change file from WINDOW to UNIX mode"
			exit 1
		fi
	else
		iecho "ServerOS is [${ServerOS}]"
		awk '{ sub("\r$", ""); print }' ${FileForConvert} > ${TempFileForConvert}
		if [[ $? -eq 0 ]];
		then
			iecho "Change file from WINDOW to UNIX mode SUCCESS"
		else
			ierror "Error while change file from WINDOW to UNIX mode"
			exit 1
		fi
	fi
	
	iecho "Rename temp file to actual file"
	mv ${TempFileForConvert} ${FileForConvert}
	if [[ $? -eq 0 ]];
	then
			iecho "Rename temp file to actual file SUCCESS"
	else
			ierror "Error while rename temp file to actual file"
			exit 1
	fi
	iecho "0) Change file from WINDOW to UNIX ended"
	iecho ""
}

SplitFile () {
RunNumber=$(echo "obase=16; $(date +"%Y%m%d%H%M%S%N")" | bc)
iecho " Need to split file"
iecho " RunNumber = [${RunNumber}]"
iecho " SplitFileUniqueColNo = [${SplitFileUniqueColNo}]"	
if [[ "${SplitFileUniqueColNo}" == "" ]]
then
	ierror " Cannot process split file because SplitFileUniqueColNo in ini file is null"
	exit 1
fi

iecho " SplitedPrefixName = [${SplitedPrefixName}]"				
if [[ "${SplitedPrefixName}" == "" ]]
then
	ierror " Cannot process split file because SplitedPrefixName in ini file is null"
	exit 1
fi


QFileName="${temppath}/inbound_queue.queue"

if [[ -f "${QFileName}" ]]
then
	rm ${QFileName}
	if [[ $? -ne 0 ]]
	then
		ierror "Error while deleting queue file [${QFileName}]"
		exit 1
	fi
fi


HeaderFileName="${temppath}/header_record.queue"

if [[ -f "${HeaderFileName}" ]]
then
	rm ${HeaderFileName}
	if [[ $? -ne 0 ]]
	then
		ierror "Error while deleting queue file [${HeaderFileName}]"
		exit 1
	fi
fi

CountBeforeFile=1
iecho " HeaderFlg/TrailerFlg = [${HeaderFlg}/${TrailerFlg}]"
find ${InboundPath} -maxdepth 1 -type f -name "${InputPrefix}*.${InputExt}" |xargs ls -rt |while read InboundBefSplitName
do			
	InboundBefSplitOnlyName=$(basename ${InboundBefSplitName})
	InboundBefSplitOnlyNameNoEXT=$(basename ${InboundBefSplitName}|awk -F"." '{print $1}')
	# -- check header and trailer of file
	if [[ "${HeaderFlg}" == "N" ]] && [[ "${TrailerFlg}" == "N" ]]
	then
		CommandUniq="cat ${InboundBefSplitName} | awk -v FS=\"${Delimiter}\" -v ColumnNumber=\"${SplitFileUniqueColNo}\" '{print \$ColumnNumber}' | sort | uniq -c > ${temppath}/${InboundBefSplitOnlyName}.tmp"
	elif [[ "${HeaderFlg}" == "Y" ]] && [[ "${TrailerFlg}" == "N" ]]
	then
		CommandUniq="cat ${InboundBefSplitName} | awk -v FS=\"${Delimiter}\" -v ColumnNumber=\"${SplitFileUniqueColNo}\" 'NR>1 {print \$ColumnNumber}' | sort | uniq -c > ${temppath}/${InboundBefSplitOnlyName}.tmp"
	elif [[ "${HeaderFlg}" == "N" ]] && [[ "${TrailerFlg}" == "Y" ]]
	then
		if [[ "z${EndOfFileFormat}" == "z" ]]
		then
			ierror " There is no EndOfFileFormat [${EndOfFileFormat}]"
			exit 1
		fi
		iecho " Checking the end of file"
		CountEOF=$(grep "^${EndOfFileFormat}" ${InboundBefSplitName} |tail -1 |wc -l | tr -d [:blank:])
		if [[ ${CountEOF} -eq 1 ]]
		then
			iecho " Found the end of file"
		else
			ierror " Not found the end of file"
			exit 1
		fi
		CommandUniq="cat ${InboundBefSplitName} | awk -v FS=\"${Delimiter}\" -v ColumnNumber=\"${SplitFileUniqueColNo}\" '{print \$ColumnNumber}' | sed '\$d' | sort | uniq -c > ${temppath}/${InboundBefSplitOnlyName}.tmp"
	elif [[ "${HeaderFlg}" == "Y" ]] && [[ "${TrailerFlg}" == "Y" ]]
	then
		if [[ "z${EndOfFileFormat}" == "z" ]]
		then
			ierror " There is no EndOfFileFormat [${EndOfFileFormat}]"
			exit 1
		fi
		iecho " Checking the end of file"
		CountEOF=$(grep "^${EndOfFileFormat}" ${InboundBefSplitName} |tail -1 |wc -l | tr -d [:blank:])
		if [[ ${CountEOF} -eq 1 ]]
		then
			iecho " Found the end of file"
		else
			ierror " Not found the end of file"
			exit 1
		fi
		CommandUniq="cat ${InboundBefSplitName} | awk -v FS=\"${Delimiter}\" -v ColumnNumber=\"${SplitFileUniqueColNo}\" 'NR > 1 {print \$ColumnNumber}' | sed '\$d' | sort | uniq -c > ${temppath}/${InboundBefSplitOnlyName}.tmp"
	fi

iecho " command = [${CommandUniq}]"
eval ${CommandUniq}
if [[ $? -ne 0 ]]
then
	ierror " Error while check uniq data in file"
	exit 1
fi

CountUniqRecord=$(cat ${temppath}/${InboundBefSplitOnlyName}.tmp | wc -l | tr -d [:blank:])

# AllRecForName=$(echo ${CountUniqRecord}  | awk '{printf "%0.6d\n", $1}')
NoDupRecForName="000000"
iecho " CountUniqRecord = [${CountUniqRecord}]"
# iecho " AllRecForName = [${AllRecForName}]"
iecho " NoDupRecForName = [${NoDupRecForName}]"

CountAllNoDupValue=$(cat ${temppath}/${InboundBefSplitOnlyName}.tmp | awk '$1=="1" {print $2}'|wc -l | tr -d [:blank:])
CountAllDupValue=$(cat ${temppath}/${InboundBefSplitOnlyName}.tmp | awk '$1>1 {print $2}'|wc -l | tr -d [:blank:])
CountAllDupRec=$(cat ${temppath}/${InboundBefSplitOnlyName}.tmp  | awk '
{
if ($1>1)
{
sum+=$1;
}
}
END {print sum}
')

if [[ ${CountAllNoDupValue} -gt 0 ]]
then
	NoDupOutputFile=1
else
	NoDupOutputFile=0
fi
((AllNoOfOutputFile=NoDupOutputFile+CountAllDupRec))

AllNoOfOutputFileName=$(echo ${AllNoOfOutputFile}| awk '{printf "%0.6d\n", $1}')
iecho " AllNoOfOutputFile = [${AllNoOfOutputFile}]"
if [[ ${CountAllNoDupValue} -gt 0 ]]
then
	iecho " CountAllNoDupValue = [${CountAllNoDupValue}]"
	FileNameNoDup="${InboundPath}/${SplitedPrefixName}_${InboundBefSplitOnlyNameNoEXT}_${RunNumber}_${NoDupRecForName}_${AllNoOfOutputFile}.${InputExt}"
	CountNoDupValue=1
	iecho " FileNameNoDup = [${FileNameNoDup}]"
	cat ${temppath}/${InboundBefSplitOnlyName}.tmp | awk '$1=="1" {print $2}' | while read NoDupValue
	do
		if [[ ${CountNoDupValue} -eq 1 ]]
		then
			if [[ "${HeaderFlg}" == "Y" ]]
			then
				head -1 ${InboundBefSplitName} > ${FileNameNoDup}
				awk -v FS="${Delimiter}" -v ColumnNumber="${SplitFileUniqueColNo}" '$ColumnNumber=="'${NoDupValue}'"' ${InboundBefSplitName} >> ${FileNameNoDup}
			else
				awk -v FS="${Delimiter}" -v ColumnNumber="${SplitFileUniqueColNo}" '$ColumnNumber=="'${NoDupValue}'"' ${InboundBefSplitName} > ${FileNameNoDup}
			fi
		else
			awk -v FS="${Delimiter}" -v ColumnNumber="${SplitFileUniqueColNo}" '$ColumnNumber=="'${NoDupValue}'"' ${InboundBefSplitName} >> ${FileNameNoDup}
		fi
		
		if [[  ${CountNoDupValue} -eq ${CountAllNoDupValue} ]]
		then
			if [[ "${TrailerFlg}" == "Y" ]]
			then
				echo ${EndOfFileFormat} >> ${FileNameNoDup}
			fi
		fi
	((CountNoDupValue=CountNoDupValue+1))
	done
else
	iecho " CountAllNoDupValue = [${CountAllNoDupValue}]"
	iecho " No need to create no dup file"
fi


if [[ ${CountAllDupValue} -gt 0 ]]
then
	iecho " CountAllDupValue = [${CountAllDupValue}]"
	CountDupValue=1
	cat ${temppath}/${InboundBefSplitOnlyName}.tmp | awk '$1>1 {print $2}' | while read DupValue
	do
	CountDupValueFileName=$(echo ${CountDupValue}  | awk '{printf "%0.6d\n", $1}')
		CountDupRecord=1		
		awk -v FS="${Delimiter}" -v ColumnNumber="${SplitFileUniqueColNo}" '$ColumnNumber=="'${DupValue}'"' ${InboundBefSplitName} | while read RecordS
		do
			CountDupRecordFileName=$(echo ${CountDupRecord}  | awk '{printf "%0.6d\n", $1}')
			FileNameDup="${InboundPath}/${SplitedPrefixName}_${InboundBefSplitOnlyNameNoEXT}_${RunNumber}_${CountDupValueFileName}_${CountDupRecordFileName}_${AllNoOfOutputFile}.${InputExt}"
			if [[ "${HeaderFlg}" == "Y" ]]
			then
				head -1 ${InboundBefSplitName} > ${FileNameDup}
				echo ${RecordS} >> ${FileNameDup}
			else
				echo ${RecordS} > ${FileNameDup}
			fi
			if [[ "${TrailerFlg}" == "Y" ]]
			then
				echo ${EndOfFileFormat} >> ${FileNameDup}
			fi
			iecho " FileNameDup = [${FileNameDup}]"
		((CountDupRecord=CountDupRecord+1))
		done
	((CountDupValue=CountDupValue+1))
	done
else
	iecho " CountAllDupValue = [${CountAllDupValue}]"
	iecho " No need to create duplicate file"
fi
#-------------------------------------------------------------------
## put file name in queue file in order to use as a key to query
#-------------------------------------------------------------------
echo "${InboundBefSplitOnlyNameNoEXT}_${RunNumber}" >> ${QFileName}
# CheckDigitDelimiter="--"
if [[ "${HeaderFlg}" == "Y" ]]
then
	head -1 ${InboundBefSplitName} | awk -v RunNumber="${InboundBefSplitOnlyNameNoEXT}_${RunNumber}" -v CheckDigitDelimiter="${CheckDigitDelimiter}" '{print RunNumber CheckDigitDelimiter $0}' >> ${HeaderFileName}
else
	touch ${HeaderFileName}
fi

mkdir -p ${InboundArchiveTodayPath}
mv ${InboundBefSplitName} ${InboundArchiveTodayPath}
if [[ $? -ne 0 ]]
then
	ierror "Error while move input temp file to archive path ==> [${InboundBefSplitName}]"
	exit 1
fi

((CountBeforeFile=CountBeforeFile+1))
done

}


SEND_EMAIL_FUNC ()
{
if [[ $# -ne 4 ]]
then
    echo "Please input Parameter: $0 <TypeEmail or Module> <Email Subject> <Body Email> <Email Address>"
    echo "Example $0 NCCA \"Found Error while load Data\" \"Please see log at /xxx/xxx\""
    SEND_EMAIL_FUNC "${EmailHeader}" "Please input Parameter: $0 <TypeEmail or Module> <Email Subject> <Body Email> <Email Address>" "Please input Parameter: $0 <TypeEmail or Module> <Email Subject> <Body Email> <Email Address>" "${adminemail}"
    exit 1
fi
iecho "##### Start Send Email"
TypeEmail="${1}"
SubjEmail="${2}"
BodyEmail="${3}"
EmailAddrInFunc="${4}"
iecho " TypeEmail = [${TypeEmail}]"
iecho " SubjEmail = [${SubjEmail}]"
iecho " BodyEmail = [${BodyEmail}]"
iecho " EmailAddrInFunc = [${EmailAddrInFunc}]"
iecho " Sending email to [${EmailAddrInFunc}]"
echo -e "${BodyEmail}"|/bin/mailx -s "[${TypeEmail}] ${SubjEmail}" ${EmailAddrInFunc}
if [[ $? -ne 0 ]]
then
        ierror " Error while sending email to [${EmailAddrInFunc}] success"
else
        iecho " Send email to [${EmailAddrInFunc}] success"
fi
iecho "##### End Send Email"
iecho ""
}

DayRun=$(date +%Y%m%d)
DayRunEmail=$(date +"%Y-%m-%d")
CurrentDateTime=`date +"%Y%m%d_%H%M%S"`
HomeDir=$(dirname $0)
cd ${HomeDir}
InboundPath=${HomeDir}/inbound
InboundArchivePath=${InboundPath}/archive
InboundArchiveTodayPath=${InboundArchivePath}/${CurrentDateTime}
inipath=${HomeDir}/ini
ctlpath=${HomeDir}/ctl
logpath=${HomeDir}/log
temppath=${HomeDir}/temp
outputpath=${HomeDir}/output
RejectPath=${InboundPath}/reject
RejectArchivePath=${RejectPath}/archive
RejectArchiveTodayPath=${RejectPath}/${CurrentDateTime}


Usage="
Usage: $(basename $0) <batch_interface_name>
Usage: $(basename $0) merchant
"

if [[ $# -ne 1 ]]
then
	echo "${Usage}"
	exit 1
fi

iecho "----------------------------------------------"
iecho " == Strart Pre-Process"
iecho "----------------------------------------------"
iecho "-----"
PID=$$
current_pid=$$
parent_pid=$(ps -o ppid= -p "$current_pid")
iecho "My PID : $current_pid"
iecho "My Parent PID : ${parent_pid}"

iecho "Parent Process: 
$(ps -ef |grep "${parent_pid}"|grep -v grep)"
iecho "-----"
iecho ""

#--------------------------
# New - Fix Error grep -v grep 
#-------------------------
iecho ">>>> Start check blocking process <<<<<"
CHECK_BLOCK_PROCESS_ID () {
  iecho " -- start function to check pid"
  pidtmp=`ps -fu $(whoami) |grep -w "$(basename $0)" | grep -w "partner_txn" | grep -vw "$parent_pid" | grep -vw "$current_pid" | grep -v grep |awk '{print $0}'`
  echo ${pidtmp}
  pid=`echo ${pidtmp} |awk '{print $2}'`
  iecho " -- end function to check pid"
  iecho ""
}

i=1
MaxCount=3

while [[ ${i} -le ${MaxCount} ]]
do
  CHECK_BLOCK_PROCESS_ID;
  if [[ "x${pid}" != "x" ]]
  then

    iecho "[${i}/${MaxCount}  Blocking PID: ${pid}]"

    if [[ ${i} -eq ${MaxCount} ]]
    then
      ierror "Exit 9 : Batch import is running."
      exit 9      
    else
      sleep 10
    fi

  else
    break
    iecho "[${i}/${MaxCount} No blocking PID"
  fi
((i=i+1))
done


iecho ">>>> End check blocking process <<<<<"
iecho ""
iecho "----------------------------------------------"
iecho " == End Pre-Process"
iecho "----------------------------------------------"
iecho ""

iecho "----------------------------------------------"
iecho "###### START PROGRAM with PID = [${PID}]"
iecho "----------------------------------------------"
if [ $1 != "" ]; then

	## Get variables from ini file
	declare_variable $1
	
	iecho "Checking RunSQLLoader, RunPreSQL, RunEIM and RunPostSQL flg --> [${RunSQLLoader}/${RunPreSQL}/${RunEIM}/${RunPostSQL}]"

	case ${RunSQLLoader} in
	"N")
		# Logic
		# (N N N)
		# (N N Y)
		# (N Y N)
		# (N Y Y)
		# (Y N N)
		# -- (Y N Y)
		# (Y Y N)
		# (Y Y Y)
		if [[ "${RunPreSQL}" == "N" ]] && [[ "${RunEIM}" == "N" ]] && [[ "${RunPostSQL}" == "N" ]]
		then 
			iecho " No need to run any process"
			exit 0
		elif [[ "${RunPreSQL}" == "N" ]] && [[ "${RunEIM}" == "N" ]] && [[ "${RunPostSQL}" == "Y" ]]
		then 
			iecho " Run only Post-SQL"
			post_exec
		elif [[ "${RunPreSQL}" == "N" ]] && [[ "${RunEIM}" == "Y" ]] && [[ "${RunPostSQL}" == "N" ]]
		then 
			iecho " Run only EIM Precess"
			eim_process
		elif [[ "${RunPreSQL}" == "N" ]] && [[ "${RunEIM}" == "Y" ]] && [[ "${RunPostSQL}" == "Y" ]]
		then 
			iecho " Run only EIM Precess and Post-SQL"
			eim_process
			post_exec
		elif [[ "${RunPreSQL}" == "Y" ]] && [[ "${RunEIM}" == "N" ]] && [[ "${RunPostSQL}" == "N" ]]
		then 
			iecho " Run only Pre-SQL"
			pre_exec
		elif [[ "${RunPreSQL}" == "Y" ]] && [[ "${RunEIM}" == "Y" ]] && [[ "${RunPostSQL}" == "N" ]]
		then 
			iecho " Run only Pre-SQL and EIM"
			pre_exec
			## Check Success Record in Staging Table before run EIM Process
			if [[ ${CntSuccessSTG} -eq 0 ]]
			then
				iecho " CntSuccessSTG = [${CntSuccessSTG}]"
				iecho " No success record from pre-process no need to run EIM Process"
				iecho ""
			else
				eim_process
			fi
		elif [[ "${RunPreSQL}" == "Y" ]] && [[ "${RunEIM}" == "Y" ]] && [[ "${RunPostSQL}" == "Y" ]]
		then 
			iecho "Run only Pre-SQL, EIM and Post-SQL"
			pre_exec
			## Check Success Record in Staging Table before run EIM Process
			if [[ ${CntSuccessSTG} -eq 0 ]]
			then
				iecho " CntSuccessSTG = [${CntSuccessSTG}]"
				iecho " No success record from pre-process no need to run EIM Process"
				iecho ""
			else
				eim_process
			fi
			
			## Check Success Record and RunPostIfNoEIMData in Staging table before run post process
			if [[ ${CntSuccessSTG} -eq 0 ]] && [[ "${RunPostIfNoEIMData}" == "Y" ]]
			then
				iecho " CntSuccessSTG = [${CntSuccessSTG}] (=0)"
				iecho " RunPostIfNoEIMData = [${RunPostIfNoEIMData}] (=Y)"
				iecho " Need to run Post-Process"
				iecho ""
				post_exec
			elif [[ ${CntSuccessSTG} -gt 0 ]]
			then
				iecho " CntSuccessSTG = [${CntSuccessSTG}] (>0)"
				iecho " Need to run Post-Process"
				iecho ""
				post_exec
			else
				iecho " CntSuccessSTG = [${CntSuccessSTG}]"
				iecho " RunPostIfNoEIMData = [${RunPostIfNoEIMData}]"
				iecho " No need to run Post-Process"
				iecho ""				
			fi
		else
			ierror " RunSQLLoader/RunPreSQL/RunEIM/RunPostSQL flg is invalid"
			exit 1
		fi
		## Export Data
		iecho " Checking RunExportData flg --> [${RunExportData}]"
		if [[ "${RunExportData}" == "Y" ]]
		then
			iecho " Run export_data"		
			export_data;
		fi
	;;
	
	"Y")	
PreFunction (){
		CountInputFile=$(find ${InboundPath} -maxdepth 1 -type f -name "${InputPrefix}*.${InputExt}"  |wc -l|tr -d [:blank:])
		## --------------------------
		## CR20 - Added Split files
		## --------------------------
		iecho "0-Pre01) Start Split file"
		iecho " NLS_LANG = [${NLS_LANG}]"
		if [[ ${CountInputFile} -eq 0 ]]
		then
			ierror ""
			ierror " No. of input file(s) = [${CountInputFile}]"
			ierror ""
			ierror " !!! No input file --> [${InputPrefix}*.${InputExt}]"	
			exit 98
		fi
				
		InputFileNameForCount=$(find ${InboundPath} -maxdepth 1 -type f -name "${InputPrefix}*.${InputExt}" |head -1)
		
		
		set -A FileNameAndNoOfColList
		NoOfFile=1
		find ${InboundPath} -maxdepth 1 -type f -name "${InputPrefix}*.${InputExt}" | sort | \
		{ 
		while read FileNameChk
		do
			## Add Data into the list
			OnlyFileNameChk=$(basename ${FileNameChk})
			NoOfInputColumn=$(awk -v FS="${Delimiter}" 'NR==2 {print NF}' ${FileNameChk})
			FileNameAndNoOfColList[${#FileNameAndNoOfColList[*]}+1]="${FileNameChk}|${NoOfInputColumn}"
			
			#-------
			#-- 21-Feb-19 Add Email Notification if there is no header of file.
			#-------
			iecho ""
			iecho "########## start check header & trailer file [${OnlyFileNameChk}]"
			iecho " FileNameChk = [${FileNameChk}]"
			iecho " HeaderFileFormat = [${HeaderFileFormat}]"
			if [[ "${HeaderFlg}" == "Y" ]]
			then
				iecho " Checking the header of file"
				 head -c3 ${FileNameChk}  | LC_ALL=C grep -qP "\xef\xbb\xbf"
				 if [[ $? -eq 0 ]]
				 then
					iecho " Found UTF-8 with BOM in this file"
					CountHeaderOfFile=$(head -1 ${FileNameChk} | LC_ALL=C grep -P "^\xef\xbb\xbf${HeaderFileFormat}"  |wc -l | tr -d [:blank:])
				else
					iecho " Not found UTF-8 with BOM in this file"
					CountHeaderOfFile=$(grep "^${HeaderFileFormat}" ${FileNameChk} |head -1 |wc -l | tr -d [:blank:])
				fi
				if [[ ${CountHeaderOfFile} -eq 1 ]]
				then
					iecho " Found the header of file"
					#-------
					#-- 21-Feb-19 Add Email Notification if there is no end of file & end of file.
					#-------
					if [[ "${TrailerFlg}" == "Y" ]]
					then
						if [[ "z${EndOfFileFormat}" == "z" ]]
						then
							ierror " There is no EndOfFileFormat [${EndOfFileFormat}]"
							exit 1
						fi
						iecho " Checking the end of file"
						CountEOF=$(grep "^${EndOfFileFormat}" ${FileNameChk} |tail -1 |wc -l | tr -d [:blank:])
						if [[ ${CountEOF} -eq 1 ]]
						then
							iecho " Found the end of file"
						else
							ierror " Not found the end of file"
							

							mkdir -p ${RejectArchiveTodayPath}
							cp ${FileNameChk} ${RejectArchiveTodayPath}
							if [[ $? -ne 0 ]]
							then
								ierror " Error while copying reject file to reject path [${RejectArchiveTodayPath}/${OnlyFileNameChk}]"
								exit 1				
							fi
							rm ${FileNameChk}
							if [[ $? -ne 0 ]]
							then
								ierror " Error while deleting reject file"
								exit 1				
							fi
							SEND_EMAIL_FUNC "BCP-${EnvName}" "Not found the end of file(${EndOfFileFormat}) in file ==> [${OnlyFileNameChk}]" "Please look into folder for original file ==> [${RejectArchiveTodayPath}/${OnlyFileNameChk}]" "${ExportEmailList}"
						fi
					fi # Check Trailer Flag
					#-------
					#-- 21-Feb-19 Add Email Notification if there is no end of file.
					#-------
				else
					ierror " Not found the header of file"
					mkdir -p ${RejectArchiveTodayPath}
					cp ${FileNameChk} ${RejectArchiveTodayPath}
					if [[ $? -ne 0 ]]
					then
						ierror " Error while copying reject file to reject path [${RejectArchiveTodayPath}/${OnlyFileNameChk}]"
						exit 1				
					fi
					rm ${FileNameChk}
					if [[ $? -ne 0 ]]
					then
						ierror " Error while deleting reject file"
						exit 1				
					fi
					SEND_EMAIL_FUNC "BCP-${EnvName}" "Not found the header of file(${HeaderFileFormat}) in file ==> [${OnlyFileNameChk}]" "Please look into folder for original file ==> [${RejectArchiveTodayPath}/${OnlyFileNameChk}]" "${ExportEmailList}"
				fi
			fi
			#-------
			#-- 21-Feb-19 Add Email Notification if there is no header of file & end of file.
			#-------		
			iecho "########## End check header & trailer file [${OnlyFileNameChk}]"
			iecho ""
		((NoOfFile=NoOfFile+1))
		done
		
		} ## End while list file
}

MainFunction(){
		CountInputFileAfterValidate=$(find ${InboundPath} -maxdepth 1 -type f -name "${InputPrefix}*.${InputExt}"  |wc -l|tr -d [:blank:])
		## --------------------------
		## Check file after validate header & tailer
		## --------------------------
		iecho " Check file after validate header & tailer"
		if [[ ${CountInputFileAfterValidate} -eq 0 ]]
		then
			ierror ""
			ierror " No. of input file(s) = [${CountInputFileAfterValidate}]"
			ierror ""
			ierror " !!! No input file to process after validate header & tailer --> [${InputPrefix}*.${InputExt}]"	
			exit 98
		fi
		iecho " SplitFile = [${SplitFile}]"
		if [[ "${SplitFile}" == "Y" ]]
		then
			# ---------------------------
			# -- Call Function SplitFile
			# ---------------------------
			SplitFile;
			GetFileCMD="find ${InboundPath} -maxdepth 1 -type f -name \"${SplitedPrefixName}_${InputPrefix}*.${InputExt}\""
			CountInputFileAfterSplit=$(find ${InboundPath} -maxdepth 1 -type f -name "${SplitedPrefixName}_${InputPrefix}*.${InputExt}"  |wc -l|tr -d [:blank:])
			iecho ""
			iecho " No. of input file(s) after split = [${CountInputFileAfterSplit}]"
			iecho ""
			CountInputFileAfterChk=${CountInputFileAfterSplit}
		else
			iecho " No need to split file"
			GetFileCMD="find ${InboundPath} -maxdepth 1 -type f -name \"${InputPrefix}*.${InputExt}\""
			iecho ""
			iecho " No. of input file(s) = [${CountInputFile}]"
			iecho ""
			CountInputFileAfterChk=${CountInputFile}
		fi
		iecho "0-Pre01) End Split file"
		iecho ""
		## --------------------------
		## CR20 - Added Split files
		## --------------------------		
		CountFile=1
		iecho "GetFileCMD = [${GetFileCMD}]"
		eval ${GetFileCMD} |xargs ls -rt |while read InboundFileName
		do
		inboundfile=${InboundFileName}
		inboundOnlyFileName=$(basename ${InboundFileName})
		iecho ">>>>> Start process file [${CountFile}/${CountInputFileAfterChk}]"
		iecho " inboundfile = [${inboundOnlyFileName}]"
		iecho " Check Header and trailer Flag [${HeaderFlg}/${TrailerFlg}]"
		InboundBakFile=${InboundFileName}.bak.${CurrentDateTime}
		InboundTmpFile=${InboundFileName}.tmp.${CurrentDateTime}
		cp -p ${InboundFileName} ${InboundBakFile}
		if [[ $? -ne 0 ]]
		then
			ierror "Error while backup file"
			exit 1
		fi
		#-- Run convert Windows to UNIX format
		convert_unix_to_win_func "${InboundFileName}"
		
		if [[ "${HeaderFlg}" == "Y" ]]
		then
			awk 'NR>1' ${InboundFileName} > ${InboundTmpFile}
			if [[ $? -ne 0 ]]
			then
				ierror "Error while remove header of file"
				exit 1
			fi
			mv ${InboundTmpFile} ${InboundFileName}
			if [[ $? -ne 0 ]]
			then
				ierror "Error while move file"
				exit 1
			fi
			iecho " Remove header of file successfully"
		fi
		
		# -- check trailer of file
		if [[ "${TrailerFlg}" == "Y" ]]
		then
			if [[ "z${EndOfFileFormat}" == "z" ]]
			then
				ierror "There is no EndOfFileFormat [${EndOfFileFormat}]"
				exit 1
			fi
			iecho " Checking the end of file"
			CountEOF=$(grep "^${EndOfFileFormat}" ${InboundFileName} |tail -1 |wc -l | tr -d [:blank:])
			if [[ ${CountEOF} -eq 1 ]]
			then
				iecho " Found the end of file"
			else
				ierror " Not found the end of file"
				exit 1
			fi
			sed '$d' ${InboundFileName} > ${InboundTmpFile}
			if [[ $? -ne 0 ]]
			then
				ierror "Error while remove trailer of file"
				exit 1
			fi
			mv ${InboundTmpFile} ${InboundFileName}
			if [[ $? -ne 0 ]]
			then
				ierror "Error while move file"
				exit 1
			fi
			iecho " Remove trailer of file successfully"
		fi
		# Logic
		# Y (N N N)
		# Y --(N N Y)
		# Y --(N Y N)
		# Y --(N Y Y)
		# Y (Y N N)
		# Y --(Y N Y)
		# Y (Y Y N)
		# Y (Y Y Y)
		if [[ "${EditCTLFile}" == "Y" ]]
		then
			iecho " EditCTLFile = [${EditCTLFile}]"
			iecho " Need to edit ctl file"
			if [ ! -f "${ctlfiletemplate}" ]; then
				ierror " cannot open ${ctlfiletemplate}"
				exit 1
			fi
			iecho " clear old ctl file [${ctlfile}]"
			if [[ -f "${ctlfile}" ]]
			then
				rm ${ctlfile}
				if [[ $? -ne 0 ]]
				then
					ierror " Error while clearing old ctl file"
					exit 1			
				fi
			fi
			iecho " Editing clt template file [${ctlfiletemplate}]"
			editctlcmd=`cat $inifile | grep "EditCTLCMD="`
			eval ${editctlcmd}	
			if [[ "${editctlcmd}" == "" ]]
			then
				ierror " Cannot edit ctl template file because editctlcmd is null"
				exit 1
			else
				CTLCMD1=$(echo ${EditCTLCMD} | awk -F"|" '{print $1}')
				CTLCMD2=$(echo ${EditCTLCMD} | awk -F"|" -v q="'" '{print "TO_CHAR("q$2q")"}')
				iecho " CTLCMD1 = [${CTLCMD1}]"
				iecho " CTLCMD2 = [${CTLCMD2}]"
				sed -e s/"${CTLCMD1}"/"${CTLCMD2}"/g  ${ctlfiletemplate} > ${ctlfile}
				if [[ $? -ne 0 ]]
				then
					ierror " Error while editng ctl template file"
					exit 1
				fi
			fi
		else
			iecho " EditCTLFile = [${EditCTLFile}]"		
			iecho " No need to edit ctl file"
		fi
		
		
		
		if [[ "${RunPreSQL}" == "N" ]] && [[ "${RunEIM}" == "N" ]] && [[ "${RunPostSQL}" == "N" ]]
		then 
			iecho " Run only SQLLoader"
			import_data
			exit 0
		# elif [[ "${RunPreSQL}" == "N" ]] && [[ "${RunEIM}" == "N" ]] && [[ "${RunPostSQL}" == "Y" ]]
		# then 
			# iecho " Run only SQLLoader and Post-SQL"
			# import_data
			# post_exec
		# elif [[ "${RunPreSQL}" == "N" ]] && [[ "${RunEIM}" == "Y" ]] && [[ "${RunPostSQL}" == "N" ]]
		# then 
			# iecho " Run only SQLLoader and EIM Precess"
			# import_data
			# eim_process
		# elif [[ "${RunPreSQL}" == "N" ]] && [[ "${RunEIM}" == "Y" ]] && [[ "${RunPostSQL}" == "Y" ]]
		# then 
			# iecho " Run only SQLLoader, EIM Precess and Post-SQL"
			# import_data
			# eim_process
			# post_exec
		elif [[ "${RunPreSQL}" == "Y" ]] && [[ "${RunEIM}" == "N" ]] && [[ "${RunPostSQL}" == "N" ]]
		then 
			iecho " Run only SQLLoader and Pre-SQL"
			import_data
			pre_exec
		elif [[ "${RunPreSQL}" == "Y" ]] && [[ "${RunEIM}" == "Y" ]] && [[ "${RunPostSQL}" == "N" ]]
		then 
			iecho " Run only SQLLoader, Pre-SQL and EIM"
			import_data
			pre_exec
			## Check Success Record in Staging Table before run EIM Process
			if [[ ${CntSuccessSTG} -eq 0 ]]
			then
				iecho " CntSuccessSTG = [${CntSuccessSTG}]"
				iecho " No success record from pre-process no need to run EIM Process"
				iecho ""
			else
				eim_process
			fi
		elif [[ "${RunPreSQL}" == "Y" ]] && [[ "${RunEIM}" == "Y" ]] && [[ "${RunPostSQL}" == "Y" ]]
		then 
			iecho " Run all SQLLoader, Pre-SQL, EIM and Post-SQL"
			import_data
			pre_exec
			
			## Check Success Record in Staging Table before run EIM Process
			if [[ ${CntSuccessSTG} -eq 0 ]]
			then
				iecho " CntSuccessSTG = [${CntSuccessSTG}]"
				iecho " No success record from pre-process no need to run EIM Process"
				iecho ""
			else
				eim_process
			fi
			
			## Check Success Record and RunPostIfNoEIMData in Staging table before run post process
			if [[ ${CntSuccessSTG} -eq 0 ]] && [[ "${RunPostIfNoEIMData}" == "Y" ]]
			then
				iecho " CntSuccessSTG = [${CntSuccessSTG}] (=0)"
				iecho " RunPostIfNoEIMData = [${RunPostIfNoEIMData}] (=Y)"
				iecho " Need to run Post-Process"	
				iecho ""
				post_exec
			elif [[ ${CntSuccessSTG} -gt 0 ]]
			then
				iecho " CntSuccessSTG = [${CntSuccessSTG}] (>0)"
				iecho " Need to run Post-Process"
				iecho ""
				post_exec
			else
				iecho " CntSuccessSTG = [${CntSuccessSTG}]"
				iecho " RunPostIfNoEIMData = [${RunPostIfNoEIMData}]"
				iecho " No need to run Post-Process"
				iecho ""				
			fi
		else
			ierror " RunSQLLoader/RunPreSQL/RunEIM/RunPostSQL flg is invalid"
			exit 1
		fi

		iecho "5) Move file to archive path started"
		mkdir -p ${InboundArchiveTodayPath}
		if [[ $? -ne 0 ]]
		then
			ierror "Error while create directory in archive path"
			exit 1
		fi
		mv ${InboundBakFile} ${InboundArchiveTodayPath}
		if [[ $? -ne 0 ]]
		then
			ierror "Error while move backup file to archive path"
			exit 1
		fi		
		
		mv ${InboundFileName} ${InboundArchiveTodayPath}
		if [[ $? -ne 0 ]]
		then
			ierror "Error while move input file to archive path"
			exit 1
		fi
		if [[ -f ${InboundArchiveTodayPath} ]]
		then
			mv ${InboundTmpFile} ${InboundArchiveTodayPath}
			if [[ $? -ne 0 ]]
			then
				ierror "Error while move input temp file to archive path ==> [${InboundTmpFile}]"
				exit 1
			fi
		fi
		iecho "5) Move file to archive path ended"
		iecho ""
		
		iecho ">>>>> End process file [${CountFile}/${CountInputFileAfterChk}]"
		((CountFile=CountFile+1))
		done
	
		## Export Data
		iecho ""
		iecho " Checking RunExportData flag --> [${RunExportData}]"
		if [[ "${RunExportData}" == "Y" ]]
		then
			iecho " Run export_data"		
			export_data;
		fi		
		
}	
		
		# Call function PreFunction
		PreFunction;
		
		# Call function MainFunction
		MainFunction;
		
		iecho "----------------------------------------------"
		iecho "###### END PROGRAM with PID = [${PID}]"
		iecho "----------------------------------------------"
		iecho ""
	;;
	
	*)
		ierror "SQLLoader Flag is not valid"
		exit 1
	;;
	esac
else
	echo "${Usage}"
	exit 1
fi
