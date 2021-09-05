#!/bin/ksh

##############################################################################################
#
#           FILE NAME:  SBLSalesforceExtraction.sh
#         DESCRIPTION:  Extract Data to Salesforce
#              AUTHOR:  Tayat Wattanasopon
#                TEAM:  Siebel Application Consultant
#             VERSION:  1.0
#             CREATED:  16.08.2021
#       LAST MODIFIED: 
#            MODIFIER: Tayat Wattanasopon
#		  MODIFY DESC: 
#           EXECUTION:
#
##############################################################################################

. /home/sbpbcpp2/.bash_profile

#****************************************************************
# :- VALIDATE ARGUMENT(S) -:
#****************************************************************
##Usage: $(basename $0) -j jobname -o normal/rerun -t 20110912010101 20110912020101
Usage="
Usage: $(basename $0) -j jobname
Usage: $(basename $0) -l Y/N

Option :
  -j       jobname
 Or use -l to show job name and show configuration of job
  -l       show configuration of job flag (Y/N)	
"

typeset OraSID
typeset JobName

index=1
while [ ${index} -le $# ]
do
  eval "cmd=\${$index}"
  case ${cmd} in
	-l) let index=index+1; eval "ShowConfig=\${$index}" ;;
    -j) let index=index+1; eval "JobName=\${$index}" ;;
     *) echo "${Usage}" ; exit 1 ;;
  esac
  let index=index+1
done

if [ "z${JobName}" = "z" ]
then
	if [ "z${ShowConfig}" = "z" ]
	then
		echo "${Usage}"
		exit 1
	fi
fi

#-------------------------------------------------------
# Main parameters
#-------------------------------------------------------
DayRun=$(date +%Y%m%d)
CurrentDateTime=`date +"%Y%m%d_%H%M%S"`
HomeDir=$(dirname $0)
ScriptPath=${HomeDir}/../scripts
ConfigPath=${HomeDir}/../conf
LogPath=${HomeDir}/../log
OutputPath=${HomeDir}/../output
OutputArchivePath=${HomeDir}/../output/archive
SqlPath=${HomeDir}/../sql
TempPath=${HomeDir}/../temp
# JobConfigFile=${ConfigPath}/$(basename $0 | cut -d. -f1).job
JobConfigFile=${ConfigPath}/$(basename $0 | awk -F".sh" '{print $1}').job

MainEmailSubject="MK-SIEBEL"
adminemail="tayat@locus.co.th"
#-------------------------------------------------------
# Read function from library
#-------------------------------------------------------
. ${ConfigPath}/library.ksh

#-------------------------------------------------------
# Validate Parameters
#-------------------------------------------------------
if [[ $# -ne 2 ]]
then
	echo "${Usage}"
	exit 1

else
	if [[ "z${ShowConfig}" != "z" ]]
	then

		if [[ ! -r ${JobConfigFile} ]]
		then
		  ierror "job configuration file is not exist [${JobConfigFile}]"
		  exit 1
		fi
		
		if [[ "${ShowConfig}" == "Y" ]] || [[ "${ShowConfig}" == "N" ]]
		then
			iecho ">>>>> START <<<<<"
			Count=1
			egrep "^<JOB:|^<\/JOB:" ${JobConfigFile}|awk -F":" '{print $2}'|sed s/\>//g|sort |uniq -c|awk '{if ($1==2 ){print $2}}'|while read ListJobNameS
			do 
				iecho "JobName NO.[${Count}] is [${ListJobNameS}]"
				if [[ "${ShowConfig}" == "Y" ]]
				then
					iecho "Parameters of Job [${ListJobNameS}] as below"
					iecho "##### Start show parameters"
					awk "/^<JOB:${ListJobNameS}>/,/^<\/JOB:${ListJobNameS}>/" ${JobConfigFile}
					iecho "##### End show parameters"
					iecho ""
				elif [[ "${ShowConfig}" == "N" ]]
				then
					iecho "Doesn't show parameters of job"
					iecho ""
				fi
				((Count=Count+1))
			done
			iecho ">>>>> END <<<<<"
			exit 0
		else
			echo "${Usage}"
			echo ">>>>> Show Configuration flag should be (Y/N) <<<<<"
			exit 1
		fi
	else
		if [[ "z${JobName}" == "z" ]]
		then
			echo "${Usage}"
			exit 1
		fi
	fi
fi

#---------------------------------------------------
# Read job information from jobfile
#-------------------------------------------------------

if [[ ! -r ${JobConfigFile} ]]
then
	ierror "job configuration file is not exist [${JobConfigFile}]"
  	exit 1
fi

jobdetail=`awk "/^<JOB:${JobName}>/,/^<\/JOB:${JobName}>/" ${JobConfigFile} | awk "/<SubJOB:MainFunction>/,/<\/SubJOB:MainFunction>/"`

if [[ "z${jobdetail}" == "z" ]]
then
  ierror "no job information for job [${JobName}] in job configuration file"
  exit 1
fi

# TEMPEXT=tmp
# CLEARSTGTBLFLAG="Y"
# CLEARBKSTGTBLFLAG="N"

tempext=`echo "${jobdetail}" | grep "TEMPEXT="`
eval ${tempext}
tempext=${TEMPEXT}

clearstgtblflag=`echo "${jobdetail}" | grep "CLEARSTGTBLFLAG="`
eval ${clearstgtblflag}
clearstgtblflag=${CLEARSTGTBLFLAG}

clearbkstgtblflag=`echo "${jobdetail}" | grep "CLEARBKSTGTBLFLAG="`
eval ${clearbkstgtblflag}
clearbkstgtblflag=${CLEARBKSTGTBLFLAG}

bkstgtblflag=`echo "${jobdetail}" | grep "BKSTGTBLFLAG="`
eval ${bkstgtblflag}
bkstgtblflag=${BKSTGTBLFLAG}

createstgtblflag=`echo "${jobdetail}" | grep "CREATESTGTBLFLAG="`
eval ${createstgtblflag}
createstgtblflag=${CREATESTGTBLFLAG}

createidxflag=`echo "${jobdetail}" | grep "CREATEIDXFLAG="`
eval ${createidxflag}
createidxflag=${CREATEIDXFLAG}

runanalyzetblflag=`echo "${jobdetail}" | grep "RUNANALYZETBLFLAG="`
eval ${runanalyzetblflag}
runanalyzetblflag=${RUNANALYZETBLFLAG}

runplsqlflag=`echo "${jobdetail}" | grep "RUNPLSQLFLAG="`
eval ${runplsqlflag}
runplsqlflag=${RUNPLSQLFLAG}

dataextractionflag=`echo "${jobdetail}" | grep "DATAEXTRACTIONFLAG="`
eval ${dataextractionflag}
dataextractionflag=${DATAEXTRACTIONFLAG}


debug=`echo "${jobdetail}" | grep "DEBUG="`
eval ${debug}
debug=${DEBUG}

## * -------------------------------------------------------------
## * Add for update last extract data after extraction to SF
## * --------------------------------------------------------------
lastextracttableschema=`echo "${jobdetail}" | grep "LASTEXTRACTTABLESCHEMA="`
eval ${lastextracttableschema}
lastextracttableschema=${LASTEXTRACTTABLESCHEMA}

lastextracttable=`echo "${jobdetail}" | grep "LASTEXTRACTTABLE="`
eval ${lastextracttable}
lastextracttable=${LASTEXTRACTTABLE}

interfacename=`echo "${jobdetail}" | grep "INTERFACENAME="`
eval ${interfacename}
interfacename=${INTERFACENAME}

updatelastextractflg=`echo "${jobdetail}" | grep "UPDATELASTEXTRACTFLG="`
eval ${updatelastextractflg}
updatelastextractflg=${UPDATELASTEXTRACTFLG}

outputfiletype=`echo "${jobdetail}" | grep "OUTPUTFILETYPE="`
eval ${outputfiletype}
outputfiletype=${OUTPUTFILETYPE}

uft8bomflag=`echo "${jobdetail}" | grep "UFT8BOMFLAG="`
eval ${uft8bomflag}
uft8bomflag=${UFT8BOMFLAG}

sftpflag=`echo "${jobdetail}" | grep "SFTPFLAG="`
eval ${sftpflag}
sftpflag=${SFTPFLAG}

adminemail=`echo "${jobdetail}" | grep "ADMINEMAIL="`
eval ${adminemail}
adminemail=${ADMINEMAIL}

emailtag=`echo "${jobdetail}" | grep "EMAILTAG="`
eval ${emailtag}
emailtag=${EMAILTAG}


if [[ "${clearbkstgtblflag}" == "Y" ]] || [[ "${bkstgtblflag}" == "Y" ]]
then
SubJobClrBkStgTbl=`awk "/^<JOB:${JobName}>/,/^<\/JOB:${JobName}>/" ${JobConfigFile} | awk "/<SubJOB:ClearBKStagingTable>/,/<\/SubJOB:ClearBKStagingTable>/"`
	if [[ "z${SubJobClrBkStgTbl}" == "z" ]]
	then
	  ierror "no job information for sub job [ClearBKStagingTable in ${JobName}] in job configuration file"
	  exit 1
	fi
	# iecho " SubJobClrBkStgTbl = [${SubJobClrBkStgTbl}]"
	clearbkstgtblaction=`echo "${SubJobClrBkStgTbl}" | grep "CLEARBKSTGTBLACTION="`
	eval ${clearbkstgtblaction}
	clearbkstgtblaction=${CLEARBKSTGTBLACTION}

	clearbkstagingtablesql=`echo "${SubJobClrBkStgTbl}" | grep "CLEARBKSTAGINGTABLESQL="`
	eval ${clearbkstagingtablesql}
	clearbkstagingtablesql=${CLEARBKSTAGINGTABLESQL}

	bkstagingtableschema=`echo "${SubJobClrBkStgTbl}" | grep "BKSTAGINGTABLESCHEMA="`
	eval ${bkstagingtableschema}
	bkstagingtableschema=${BKSTAGINGTABLESCHEMA}

	bkstagingtablename=`echo "${SubJobClrBkStgTbl}" | grep "BKSTAGINGTABLENAME="`
	eval ${bkstagingtablename}
	bkstagingtablename=${BKSTAGINGTABLENAME}

	exportbkstgtblflag=`echo "${SubJobClrBkStgTbl}" | grep "EXPORTBKSTGTBLFLAG="`
	eval ${exportbkstgtblflag}
	exportbkstgtblflag=${EXPORTBKSTGTBLFLAG}

	exportbkstgtblsql=`echo "${SubJobClrBkStgTbl}" | grep "EXPORTBKSTGTBLSQL="`
	eval ${exportbkstgtblsql}
	exportbkstgtblsql=${EXPORTBKSTGTBLSQL}

	exportoutputfile=`echo "${SubJobClrBkStgTbl}" | grep "EXPORTOUTPUTFILE="`
	eval ${exportoutputfile}
	exportoutputfile=${EXPORTOUTPUTFILE}
	
	outputretention=`echo "${SubJobClrBkStgTbl}" | grep "OUTPUTRETENTION="`
	eval ${outputretention}
	outputretention=${OUTPUTRETENTION}

fi

if [[ "${bkstgtblflag}" == "Y" ]]
then
SubJobBakStgTbl=`awk "/^<JOB:${JobName}>/,/^<\/JOB:${JobName}>/" ${JobConfigFile} | awk "/<SubJOB:BackupStagingTable>/,/<\/SubJOB:BackupStagingTable>/"`
	if [[ "z${SubJobBakStgTbl}" == "z" ]]
	then
	  ierror "no job information for sub job [BackupStagingTable in ${JobName}] in job configuration file"
	  exit 1
	fi
	backupstgtablesql=`echo "${SubJobBakStgTbl}" | grep "BACKUPSTGTABLESQL="`
	eval ${backupstgtablesql}
	backupstgtablesql=${BACKUPSTGTABLESQL}
fi

if [[ "${clearstgtblflag}" == "Y" ]] || [[ "${bkstgtblflag}" == "Y" ]] || [[ "${createstgtblflag}" == "Y" ]] || [[ "${runplsqlflag}" == "Y" ]]
then
SubJobClrStgTbl=`awk "/^<JOB:${JobName}>/,/^<\/JOB:${JobName}>/" ${JobConfigFile} | awk "/<SubJOB:ClearStagingTable>/,/<\/SubJOB:ClearStagingTable>/"`
	if [[ "z${SubJobClrStgTbl}" == "z" ]]
	then
	  ierror "no job information for sub job [ClearStagingTable in ${JobName}] in job configuration file"
	  exit 1
	fi
	clearstgtblaction=`echo "${SubJobClrStgTbl}" | grep "CLEARSTGTBLACTION="`
	eval ${clearstgtblaction}
	clearstgtblaction=${CLEARSTGTBLACTION}

	clearstagingtablesql=`echo "${SubJobClrStgTbl}" | grep "CLEARSTAGINGTABLESQL="`
	eval ${clearstagingtablesql}
	clearstagingtablesql=${CLEARSTAGINGTABLESQL}

	stagingtableschema=`echo "${SubJobClrStgTbl}" | grep "STAGINGTABLESCHEMA="`
	eval ${stagingtableschema}
	stagingtableschema=${STAGINGTABLESCHEMA}

	stagingtablename=`echo "${SubJobClrStgTbl}" | grep "STAGINGTABLENAME="`
	eval ${stagingtablename}
	stagingtablename=${STAGINGTABLENAME}
fi


if [[ "${createstgtblflag}" == "Y" ]]
then
SubJobCreateStgTbl=`awk "/^<JOB:${JobName}>/,/^<\/JOB:${JobName}>/" ${JobConfigFile} | awk "/<SubJOB:CreateStagingTable>/,/<\/SubJOB:CreateStagingTable>/"`
	if [[ "z${SubJobCreateStgTbl}" == "z" ]]
	then
	  ierror "no job information for sub job [CreateStagingTable in ${JobName}] in job configuration file"
	  exit 1
	fi
	createstgtablesql=`echo "${SubJobCreateStgTbl}" | grep "CREATESTGTABLESQL="`
	eval ${createstgtablesql}
	createstgtablesql=${CREATESTGTABLESQL}
fi


if [[ "${createidxflag}" == "Y" ]]
then
SubJobCreateIdx=`awk "/^<JOB:${JobName}>/,/^<\/JOB:${JobName}>/" ${JobConfigFile} | awk "/<SubJOB:CreateIdx>/,/<\/SubJOB:CreateIdx>/"`
	if [[ "z${SubJobCreateIdx}" == "z" ]]
	then
	  ierror "no job information for sub job [CreateIdx in ${JobName}] in job configuration file"
	  exit 1
	fi

	createidxstgtblsql=`echo "${SubJobCreateIdx}" | grep "CREATEIDXSTGTBLSQL="`
	eval ${createidxstgtblsql}
	createidxstgtblsql="${CREATEIDXSTGTBLSQL}"
	
	noofindex=`echo "${SubJobCreateIdx}" | grep "NOOFINDEX="`
	eval ${noofindex}
	noofindex="${NOOFINDEX}"

	idxschema=`echo "${SubJobCreateIdx}" | grep "IDXSCHEMA="`
	eval ${idxschema}
	idxschema="${IDXSCHEMA}"

	idxname=`echo "${SubJobCreateIdx}" | grep "IDXNAME="`
	eval ${idxname}
	idxname="${IDXNAME}"
	
	idxtableschema=`echo "${SubJobCreateIdx}" | grep "IDXTABLESCHEMA="`
	eval ${idxtableschema}
	idxtableschema="${IDXTABLESCHEMA}"

	idxtablename=`echo "${SubJobCreateIdx}" | grep "IDXTABLENAME="`
	eval ${idxtablename}
	idxtablename="${IDXTABLENAME}"

	idxcolname=`echo "${SubJobCreateIdx}" | grep "IDXCOLNAME="`
	eval ${idxcolname}
	idxcolname="${IDXCOLNAME}"

	idxtblspacename=`echo "${SubJobCreateIdx}" | grep "IDXTBLSPACENAME="`
	eval ${idxtblspacename}
	idxtblspacename="${IDXTBLSPACENAME}"
fi

if [[ "${runanalyzetblflag}" == "Y" ]]
then
SubJobRunAnalyzeTable=`awk "/^<JOB:${JobName}>/,/^<\/JOB:${JobName}>/" ${JobConfigFile} | awk "/<SubJOB:RunAnalyzeTable>/,/<\/SubJOB:RunAnalyzeTable>/"`
	if [[ "z${SubJobRunAnalyzeTable}" == "z" ]]
	then
	  ierror "no job information for sub job [RunAnalyzeTable in ${JobName}] in job configuration file"
	  exit 1
	fi
	
	runanalyzetblsql=`echo "${SubJobRunAnalyzeTable}" | grep "RUNANALYZETBLSQL="`
	eval ${runanalyzetblsql}
	runanalyzetblsql="${RUNANALYZETBLSQL}"

	nooftable=`echo "${SubJobRunAnalyzeTable}" | grep "NOOFTABLE="`
	eval ${nooftable}
	nooftable="${NOOFTABLE}"
	
	analyzetableschema=`echo "${SubJobRunAnalyzeTable}" | grep "ANALYZETABLESCHEMA="`
	eval ${analyzetableschema}
	analyzetableschema="${ANALYZETABLESCHEMA}"

	analyzetablename=`echo "${SubJobRunAnalyzeTable}" | grep "ANALYZETABLENAME="`
	eval ${analyzetablename}
	analyzetablename="${ANALYZETABLENAME}"
	
	estimatepercent=`echo "${SubJobRunAnalyzeTable}" | grep "ESTIMATEPERCENT="`
	eval ${estimatepercent}
	estimatepercent="${ESTIMATEPERCENT}"

	degree=`echo "${SubJobRunAnalyzeTable}" | grep "DEGREE="`
	eval ${degree}
	degree="${DEGREE}"
fi

if [[ "${runplsqlflag}" == "Y" ]]
then
SubJobRunPLSQL=`awk "/^<JOB:${JobName}>/,/^<\/JOB:${JobName}>/" ${JobConfigFile} | awk "/<SubJOB:RunPLSQL>/,/<\/SubJOB:RunPLSQL>/"`
	if [[ "z${SubJobRunPLSQL}" == "z" ]]
	then
	  ierror "no job information for sub job [RunPLSQL in ${JobName}] in job configuration file"
	  exit 1
	fi

	noofplsql=`echo "${SubJobRunPLSQL}" | grep "NOOFPLSQL="`
	eval ${noofplsql}
	noofplsql="${NOOFPLSQL}"
	
	usestgtbl=`echo "${SubJobRunPLSQL}" | grep "USESTGTBL="`
	eval ${usestgtbl}
	usestgtbl="${USESTGTBL}"
	
	plsqlfile=`echo "${SubJobRunPLSQL}" | grep "PLSQLFILE="`
	eval ${plsqlfile}
	plsqlfile="${PLSQLFILE}"

	batchsize=`echo "${SubJobRunPLSQL}" | grep "BATCHSIZE="`
	eval ${batchsize}
	batchsize="${BATCHSIZE}"

	checkerrstatussql=`echo "${SubJobRunPLSQL}" | grep "CHECKERRSTATUSSQL="`
	eval ${checkerrstatussql}
	checkerrstatussql="${CHECKERRSTATUSSQL}"

	plsqloutputprefix=`echo "${SubJobRunPLSQL}" | grep "PLSQLOUTPUTPREFIX="`
	eval ${plsqloutputprefix}
	plsqloutputprefix="${PLSQLOUTPUTPREFIX}"

	plsqloutputext=`echo "${SubJobRunPLSQL}" | grep "PLSQLOUTPUTEXT="`
	eval ${plsqloutputext}
	plsqloutputext="${PLSQLOUTPUTEXT}"

	plsqloutputpath=`echo "${SubJobRunPLSQL}" | grep "PLSQLOUTPUTPATH="`
	eval ${plsqloutputpath}
	plsqloutputpath="${PLSQLOUTPUTPATH}"

	plsqloutputretention=`echo "${SubJobRunPLSQL}" | grep "PLSQLOUTPUTRETENTION="`
	eval ${plsqloutputretention}
	plsqloutputretention="${PLSQLOUTPUTRETENTION}"

	eofflag=`echo "${SubJobRunPLSQL}" | grep "EOFFLAG="`
	eval ${eofflag}
	eofflag="${EOFFLAG}"

fi

if [[ "${sftpflag}" == "Y" ]]
then
SubJobRunSFTP=`awk "/^<JOB:${JobName}>/,/^<\/JOB:${JobName}>/" ${JobConfigFile} | awk "/<SubJOB:RunSFTP>/,/<\/SubJOB:RunSFTP>/"`
	if [[ "z${SubJobRunSFTP}" == "z" ]]
	then
	  ierror "no job information for sub job [RunSFTP in ${JobName}] in job configuration file"
	  exit 1
	fi

	sftpserver=`echo "${SubJobRunSFTP}" | grep "SFTPSERVER="`
	eval ${sftpserver}
	sftpserver="${SFTPSERVER}"

	sftpuser=`echo "${SubJobRunSFTP}" | grep "SFTPUSER="`
	eval ${sftpuser}
	sftpuser="${SFTPUSER}"

	sftppath=`echo "${SubJobRunSFTP}" | grep "SFTPPATH="`
	eval ${sftppath}
	sftppath="${SFTPPATH}"
fi
## * -------------------------------------------------------------
## * Add if/else to check output file type
## * --------------------------------------------------------------
# Get Database User/Pass and SID
if [ -z "${outputfiletype}" ]
then
	. ${ConfigPath}/${JobName}.usr
else
	. ${ConfigPath}/${JobName}.usr ${outputfiletype}
fi


SEND_EMAIL_FUNC ()
{
	if [[ $# -ne 4 ]]
	then
		echo "Please input Parameter: $0 <TypeEmail or Module> <Email Subject> <Body Email> <Email Address>"
		echo "Example $0 NCCA \"Found Error while load Data\" \"Please see log at /xxx/xxx\""
	exit 1
	fi
	
	##${OutLogfile}
	TypeEmail="${1}"
	SubjEmail="${2}"
	BodyEmail="${3}"
	EmailAddrInFunc="${4}"
	iecho "Sending email to [${EmailAddrInFunc}]"
	echo "${BodyEmail}"|/bin/mailx -s "[${TypeEmail}] ${SubjEmail}" ${EmailAddrInFunc} -- -f ${senderemail}
	iecho "Send email to [${EmailAddrInFunc}] success"
}

SEND_EMAIL_ATT_FUNC ()
{
	if [[ $# -ne 4 ]]
	then
		echo "Please input Parameter: $0 <TypeEmail or Module> <Email Subject> <Attachment Filename(full path)> <Email Address>"
		echo "Example $0 NCCA \"Found Error while load Data\" \"Please see log at /xxx/xxx\""
	exit 1
	fi
	
	##${OutLogfile}
	TypeEmail="${1}"
	SubjEmail="${2}"
	FiletoEmail="${3}"
	EmailAddrInFunc="${4}"

	FiletoEmailDir=$(dirname ${FiletoEmail})
	FiletoEmailFile=$(basename ${FiletoEmail})
	iecho "Sending email to [${EmailAddrInFunc}]"
	iecho "Attach file is [${FiletoEmail}]"
	cd ${FiletoEmailDir}
	# uuencode ${FiletoEmailFile} ${FiletoEmailFile}|/usr/bin/mailx -s "[${TypeEmail}] ${SubjEmail}" ${EmailAddrInFunc}
	cat ${FiletoEmailFile}|/bin/mailx -s "[${TypeEmail}] ${SubjEmail}" ${EmailAddrInFunc} -- -f ${senderemail}
	cd - > /dev/null 
	iecho "Send email to [${EmailAddrInFunc}] success"
}

CHECK_DEL_FILE_FUNC ()
{
	if [[ $# -ne 5 ]]
	then
		echo "Usage: $0 <Type or Module> <filename> <Remove Flag Y/N> <Require File Flag Y/N> <Email Address>"
		echo "Example: $0 \"NCCA\" \"/home/test/Test.txt\" \"Y\" \"Y\" \"tayat@dtac.co.th\""
		exit 1
	fi
	TypeEmail="${1}"
	FileNameCheck="${2}"
	RemoveFlag="${3}"
	RequireFileFlag="${4}"
	EmailAddrInFunc="${5}"

	if [[ -f ${FileNameCheck} ]]
	then 
		iecho "Found file [${FileNameCheck}]"
		
		if [[ "${RemoveFlag}" == "Y" ]]
		then
			rm ${FileNameCheck}
			if [[ $? -eq 0 ]]
			then
				iecho "Remove file [${FileNameCheck}] already"
			else
				ierror "Remove file [${FileNameCheck}] not success"
				SEND_EMAIL_ATT_FUNC "${TypeEmail}"  "ERR: Remove file [${FileNameCheck}] not success" "${Logfile}" "${EmailAddrInFunc}";
				exit 1
			fi
		elif [[ "${RemoveFlag}" == "N" ]]
		then
			iecho "Doesn't remove file [${FileNameCheck}]"
		else
			ierror "Invalid Remove Flag [${RemoveFlag}]"
			SEND_EMAIL_ATT_FUNC "${TypeEmail}"  "ERR: Invalid Remove Flag [${RemoveFlag}]" "${Logfile}" "${EmailAddrInFunc}";
			exit 1
		fi
	else

		if [[ "${RequireFileFlag}" == "Y" ]]
		then
			ierror "Not found file [${FileNameCheck}]"
			SEND_EMAIL_ATT_FUNC "${TypeEmail}"  "ERR: Not found file [${FileNameCheck}]" "${Logfile}" "${EmailAddrInFunc}";
			
			exit 1
		elif [[ "${RequireFileFlag}" == "N" ]]
		then
			iecho "Not found file [${FileNameCheck}]"
		else
			ierror "Invalid Require File Flag [${RemoveFlag}]"
			SEND_EMAIL_ATT_FUNC "${TypeEmail}"  "ERR: Invalid Require File Flag [${RemoveFlag}]" "${Logfile}" "${EmailAddrInFunc}";
			
			exit 1
		fi
	fi
}

PURGE_LOG_FUNC ()
{
	if [[ ${#} -ne 4 ]]
	then
		ierror "Invalid Parameters"
		echo "Pleas input valid parameters: $0 LogPath PrefixLog ExtensionLog RetentionDate"
		echo "Example: $0 /dks003/custom/tech/CCASPRD1/script/monitor/log sbl_camp_sync_monitor out 7"
		exit 1
	fi

	PurgePath=${1}
	PurgePrefix=${2}
	PurgeExt=${3}
	PurgeRetention=${4}
	iecho ">>> Start Purge File"
	iecho "Parameters Path = [${PurgePath}]"
	iecho "Parameters PrefixFile = [${PurgePrefix}]"
	iecho "Parameters ExtensionFile = [${PurgeExt}]"
	iecho "Parameters Retention = [${PurgeRetention}] days"
	CountFile=$(find ${PurgePath} -name "${PurgePrefix}*.${PurgeExt}" -mtime +${PurgeRetention}|wc -l|tr -d [:blank:])
	if [[ ${CountFile} -gt 0 ]]
	then
		find ${PurgePath} -name "${PurgePrefix}*.${PurgeExt}" -mtime +${PurgeRetention} -exec rm {} \;
				if [[ $? -ne 0 ]]
				then
					ErrorMessage="Error while Purge File"
					ierror "${ErrorMessage}"
					ErrorEmailSubject="${ErrorMessage}"
					ErrorEmailBody="${ErrorMessage}"
					SEND_EMAIL_FUNC "${emailtag}" "${ErrorEmailSubject}" "${ErrorEmailBody}" "${adminemail}"
					exit 1
				else
					iecho "Number of files which was purged = [${CountFile}]"
					iecho "##### End Purge File"
					iecho ""
				fi
	else
		iecho "No file to purge"
		iecho ">>> End Purge File"
		iecho ""
	fi
}


CONVERT_UNIX_TO_WIN_FUNC ()
{
	if [[ $# -ne 3 ]]
	then
		echo "Usage: $0 <Type or Module> <filename> <Email Address>"
		echo "Example: $0 \"NCCA\" \"/home/test/Test.txt\" tayat@dtac.co.th"
		exit 1
	fi
	TypeEmail="${1}"
	FileForConvert="${2}"
	EmailAddrInFunc="${3}"

	##### Convert from UNIX to WINDOW FORMAT #####
	iecho "Filename is [${FileForConvert}]"
	TempFileForConvert="${FileForConvert}.convert"
	iecho "Tempfile is [${TempFileForConvert}]"
	ServerOS=$(uname)
	if [[ "${ServerOS}" == "SunOS" ]]
	then
		iecho "ServerOS is [${ServerOS}]"
			nawk 'sub("$", "\r")' ${FileForConvert} > ${TempFileForConvert}
		if [[ $? -eq 0 ]]; 
		then
			iecho "Change file from UNIX to WINDOW mode SUCCESS"
		else
			ierror "Error while change file from UNIX to WINDOW mode"
			SEND_EMAIL_ATT_FUNC "${TypeEmail}"  "ERR: Error while change file from UNIX to WINDOW mode" "${Logfile}" "${EmailAddrInFunc}";
			exit 1
		fi
	else
		iecho "ServerOS is [${ServerOS}]"
			awk 'sub("$", "\r")' ${FileForConvert} > ${TempFileForConvert}
		if [[ $? -eq 0 ]]; 
		then
			iecho "Change file from UNIX to WINDOW mode SUCCESS"
		else
			ierror "Error while change file from UNIX to WINDOW mode"
			SEND_EMAIL_ATT_FUNC "${TypeEmail}"  "ERR: Error while change file from UNIX to WINDOW mode" "${Logfile}" "${EmailAddrInFunc}";
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
		SEND_EMAIL_ATT_FUNC "${TypeEmail}"  "ERR: Error while rename temp file to actual file (Convert Unix to Window)" "${Logfile}" "${EmailAddrInFunc}";	
		exit 1
	fi
	iecho "##### End change file from UNIX to WINDOW mode"
	iecho ""
}

F01_ClearBkStgTbl ()
{
iecho "#### 01 - Start clear bk staging table"

if [[ "${exportbkstgtblflag}" == "Y" ]]
then

iecho ">>> Start count bk staging table"
CountRecBkStgTbl=$(sqlplus -s ${user}/${pass}@${db_name} << THEEND
set term off
set echo off
set head off
set feedback off
SET TERMOUT OFF
set trimspool on
set pagesize 0
set lines 20000
set pages 20000
SELECT TRIM(COUNT(*)) FROM ${bkstagingtableschema}.${bkstagingtablename};
EXIT
THEEND
)

	# if action = "drop|DROP" then we have to check whether error = ORA-00942 or not?. If so, we can igonre
	#ORA-00942: table or view does not exist
	ORAErrorCount=$(echo ${CountRecBkStgTbl} | grep -c "ORA\-[0-9]")
	ORAErrorCode=$(echo ${CountRecBkStgTbl} | grep "ORA\-[0-9]" | awk -F"ORA-" '{print $2}' |awk -F":" '{print $1}')
	ORAErrorMsg=$(echo ${CountRecBkStgTbl} | grep "ORA\-[0-9]" | awk -F"ORA-" '{print $2}' |awk -F":" '{print $2}')
	FullORAErrCode="ORA-${ORAErrorCode}"
	if [[ ${ORAErrorCount} -eq 0 ]]
	then
		if [[ ${CountRecBkStgTbl} -eq 0 ]]
		then
			ChkExpFlag="N"
		else
			ChkExpFlag="Y"	
		fi
		iecho "ChkExpFlag = [${ChkExpFlag}]"
		iecho "No. of records in bk staging table = [${CountRecBkStgTbl}]"
	else
		if [[ "${FullORAErrCode}" == "ORA-00942" ]] 
		then
			iecho "FullORAErrCode = [${FullORAErrCode}]"
			iecho "ORAErrorMsg = [${ORAErrorMsg}]"
			ChkExpFlag="N"
		else
			ierror "ORAErrorCount = [${ORAErrorCount}]"
			ierror "FullORAErrCode = [${FullORAErrCode}]"
			ierror "ORAErrorMsg = [${ORAErrorMsg}]"
			ErrorMessage="Found Datebase Error ==> ORA-$(echo ${CountRecBkStgTbl}| awk -F"ORA-" '{print $2}' |awk -F":" '{print $1}')"
			ierror "${ErrorMessage}"
			ErrorEmailSubject="${ErrorMessage}"
			ErrorEmailBody="${ErrorMessage}"
			SEND_EMAIL_FUNC "${emailtag}" "${ErrorEmailSubject}" "${ErrorEmailBody}" "${adminemail}"
			exit 1
		fi
	fi

	if [[ "${ChkExpFlag}" == "Y" ]]
	then
		#-------------------------------------------------------
		# Generate SQL file
		#-------------------------------------------------------
		iecho "ChkExpFlag = [${ChkExpFlag}]"
		iecho ">>> End count bk staging table"
		iecho ""
		SQLExpBkStgTblTemp=${TempPath}/SQLExpBkStgTblTemp_${JobName}_${CurrentDateTime}.${tempext}
		SQLExpBkStgTblLogTemp=${TempPath}/SQLExpBkStgTblLogTemp_${JobName}_${CurrentDateTime}.${tempext}
		OutputFile=${OutputPath}/${exportoutputfile}
		OutputFileEdit=$(echo "${OutputFile}"|sed -e 's:/:\\/:g')
		##### replace parameter in sql file #####
		iecho ">>> Start Prepare Sql file for export bk staging table"
		iecho "Edit sql file [${exportbkstgtblsql}]"
		iecho "Sql temp file [$(basename ${SQLExpBkStgTblTemp})]"
		iecho "Username [${user}]"
		idebug "Password [${pass}]"
		iecho "Oracle SID [${db_name}]"
		iecho "bkstagingtableschema = [${bkstagingtableschema}]"
		iecho "bkstagingtablename = [${bkstagingtablename}]"
		BkStgTblPrefix=$(echo ${bkstagingtablename} |awk '{print substr($0,1,2)}')
		if [[ "${bkstagingtableschema}" == "SIEBEL" ]] && [[ "${BkStgTblPrefix}" == "S_" ]]
		then
			ierror "BkStgTblPrefix = [${BkStgTblPrefix}]"
			ierror "bkstagingtableschema = SIEBEL and BkStgTblPrefix = S_"
			ierror "There is no permission on SIEBEL.S_* tables"
			exit 1
		else
			ierror "BkStgTblPrefix = [${BkStgTblPrefix}]"
		
		fi
		iecho "exportoutputfile = [${exportoutputfile}]"

		cat ${SqlPath}/${exportbkstgtblsql} | sed -e s/'${user}'/"${user}"/g -e s/'${pass}'/"${pass}"/g -e s/'${db_name}'/"${db_name}"/g \
		-e s/'${exportoutputfile}'/"${OutputFileEdit}"/g -e s/'${bkstagingtableschema}'/"${bkstagingtableschema}"/g -e s/'${bkstagingtablename}'/"${bkstagingtablename}"/g >> ${SQLExpBkStgTblTemp}

		if [[ $? -ne 0 ]]
		then
			ErrorMessage="Error while edit sql file"
			ierror "${ErrorMessage}"
			ErrorEmailSubject="${ErrorMessage}"
			ErrorEmailBody="${ErrorMessage}"
			SEND_EMAIL_FUNC "${emailtag}" "${ErrorEmailSubject}" "${ErrorEmailBody}" "${adminemail}"
			exit 1
		else
			idebug ""
			idebug "-- Start show sql text"
			cat ${SQLExpBkStgTblTemp} |while read Line
			do
				idebug "${Line}"
			done
			idebug "-- End show sql text"
			idebug ""
			iecho "Prepare sql file success"
			iecho ">>> End Prepare Sql file for export bk staging table"
			iecho ""
		fi


		#-------------------------------------------------------
		# Connect to DB 
		#-------------------------------------------------------
		iecho ">>>  Start execute for export bk staging table"
		iecho "Executing SQL file [$(basename ${SQLExpBkStgTblTemp})]"
		iecho "Temp Output [$(basename ${SQLExpBkStgTblLogTemp})]"
		sqlplus -s /nolog < ${SQLExpBkStgTblTemp} 1> /dev/null 2> ${SQLExpBkStgTblLogTemp}

		#-------------------------------------------------------
		# Check DB error
		#-------------------------------------------------------
		iecho "Checking database error"
		CountError=$(grep -c "ORA\-[0-9]" ${SQLExpBkStgTblLogTemp})
		iecho "Count database error = [${CountError}]"
		if [ ${CountError} -ne 0 ]
		then
			ErrorMessage="Found Datebase Error ==> $(grep "ORA\-[0-9]" ${SQLExpBkStgTblLogTemp})"
			ierror "${ErrorMessage}"
			ierror "Can see more details at ${SQLExpBkStgTblLogTemp}"
			ErrorEmailSubject="${ErrorMessage}"
			ErrorEmailBody="${ErrorMessage}"
			SEND_EMAIL_FUNC "${emailtag}" "${ErrorEmailSubject}" "${ErrorEmailBody}" "${adminemail}"
			#### remove temp file #####
			CHECK_DEL_FILE_FUNC "${MainEmailSubject}" "${SQLExpBkStgTblTemp}" "Y" "N" "${adminemail}";
			exit 1
		else 
			iecho "Not found database error"
			## TODO: Need to comment/uncomment for testing #################################################################################################################
			CHECK_DEL_FILE_FUNC "${MainEmailSubject}" "${SQLExpBkStgTblTemp}" "Y" "N" "${adminemail}";
			CHECK_DEL_FILE_FUNC "${MainEmailSubject}" "${SQLExpBkStgTblLogTemp}" "Y" "N" "${adminemail}";
			OutputPrefix=$(echo ${exportoutputfile} | awk -F"${JobName}" '{print $1}')
			OutputExt=$(echo ${exportoutputfile} | awk -F"." '{print $2}')
			PURGE_LOG_FUNC ${OutputPath} "${OutputPrefix}" "${OutputExt}" ${outputretention}
			iecho ">>>  End execute for export bk staging table"

			#-------------------------------------------------------
			# edit output 
			#-------------------------------------------------------
			iecho ""
			iecho ">>> Start Edit output"
			exportoutputfiletemp=${OutputFile}.edit
			iecho "Output file temp [${exportoutputfiletemp}]"
			iecho "Output file [${OutputFile}]"
			iecho "Check output file"
			CountExportoutput=$(cat ${OutputFile}|wc -l |tr -d [:blank:])
			iecho "CountExportoutput = [${CountExportoutput}]"
			iecho "outputfiletype = [${outputfiletype}]"
			iecho "uft8bomflag = [${uft8bomflag}]"
			
			if [[ ${CountExportoutput} -ne 0 ]]
			then
				iecho "CountExportoutput != 0 --> Need edit output"
				if [[ ${uft8bomflag} == "Y" ]] && [[ ${outputfiletype} = "UTF8" ]]
				then
					printf '\xEF\xBB\xBF' > ${exportoutputfiletemp}
					cat ${OutputFile}|grep -v "^$" >> ${exportoutputfiletemp}
					ErrorPlsqlCheck=$?
				else
					cat ${OutputFile}|grep -v "^$" > ${exportoutputfiletemp}
					ErrorPlsqlCheck=$?
				fi

				if [[ ${ErrorPlsqlCheck} -ne 0 ]]
				then
					ErrorMessage="Error while edit temp output [${exportoutputfiletemp}]"
					ierror "${ErrorMessage}"
					ErrorEmailSubject="${ErrorMessage}"
					ErrorEmailBody="${ErrorMessage}"
					SEND_EMAIL_FUNC "${emailtag}" "${ErrorEmailSubject}" "${ErrorEmailBody}" "${adminemail}"
					exit 1
				fi

				mv ${exportoutputfiletemp} ${OutputFile}
				if [[ $? -ne 0 ]]
				then
					ErrorMessage "Error while edit move to real output [${OutputFile}]"=
					ierror "${ErrorMessage}"
					ErrorEmailSubject="${ErrorMessage}"
					ErrorEmailBody="${ErrorMessage}"
					SEND_EMAIL_FUNC "${emailtag}" "${ErrorEmailSubject}" "${ErrorEmailBody}" "${adminemail}"
					exit 1
				fi

				CountExportoutputEditted=$(cat ${OutputFile}|wc -l |tr -d [:blank:])
				iecho "CountExportoutputEditted = [${CountExportoutputEditted}]"
				iecho "Edit output success"
				iecho ">>> End Edit output"
			fi
		fi
	else
		iecho "ChkExpFlag = [${ChkExpFlag}]"
		iecho "No need to export data from bk stage table"
		iecho ">>> End count bk staging table"
		iecho ""

	fi

else
	iecho "No need to export bk staging table"
fi

#-------------------------------------------------------
# Generate SQL file
#-------------------------------------------------------
SQLClrBkStgTblTemp=${TempPath}/SQLClrBkStgTblTemp_${JobName}_${CurrentDateTime}.${tempext}
SQLClrBkStgTblLogTemp=${TempPath}/SQLClrBkStgTblLogTemp_${JobName}_${CurrentDateTime}.${tempext}
##### replace parameter in sql file #####
iecho ">>> Start Prepare Sql file for clear bk staging table"
iecho "Edit sql file [${clearbkstagingtablesql}]"
iecho "Sql temp file [$(basename ${SQLClrBkStgTblTemp})]"
iecho "Username [${user}]"
idebug "Password [${pass}]"
iecho "Oracle SID [${db_name}]"
if [[ "${clearbkstgtblaction}" = "DROP" ]] || [[ "${clearbkstgtblaction}" = "drop" ]] || [[ "${clearbkstgtblaction}" = "TRUNCATE" ]] || [[ "${clearbkstgtblaction}" = "truncate" ]]
then
	iecho "clearbkstgtblaction = [${clearbkstgtblaction}]"
else
	ErrorMessage="Clear Bk staging table action [${clearbkstgtblaction}] not equql DROP|drop|TRUNCATE|truncate"
	ierror "${ErrorMessage}"
	ErrorEmailSubject="${ErrorMessage}"
	ErrorEmailBody="${ErrorMessage}"
	SEND_EMAIL_FUNC "${emailtag}" "${ErrorEmailSubject}" "${ErrorEmailBody}" "${adminemail}"
	exit 1
fi
iecho "bkstagingtableschema = [${bkstagingtableschema}]"
iecho "bkstagingtablename = [${bkstagingtablename}]"
iecho "clearbkstgtblaction = [${clearbkstgtblaction}]"
cat ${SqlPath}/${clearbkstagingtablesql} | sed -e s/'${user}'/"${user}"/g -e s/'${pass}'/"${pass}"/g -e s/'${db_name}'/"${db_name}"/g \
-e s/'${clearbkstgtblaction}'/"${clearbkstgtblaction}"/g -e s/'${bkstagingtableschema}'/"${bkstagingtableschema}"/g -e s/'${bkstagingtablename}'/"${bkstagingtablename}"/g >> ${SQLClrBkStgTblTemp}
if [[ $? -ne 0 ]]
then
	ErrorMessage="Error while edit sql file"
	ierror "${ErrorMessage}"
	ErrorEmailSubject="${ErrorMessage}"
	ErrorEmailBody="${ErrorMessage}"
	SEND_EMAIL_FUNC "${emailtag}" "${ErrorEmailSubject}" "${ErrorEmailBody}" "${adminemail}"
	exit 1
else
	idebug ""
	idebug "-- Start show sql text"
	cat ${SQLClrBkStgTblTemp} |while read Line
	do
		idebug "${Line}"
	done
	idebug "-- End show sql text"
	idebug ""
	iecho "Prepare sql file success"
	iecho ">>> End Prepare Sql file for clear bk staging table"
	iecho ""
fi


#-------------------------------------------------------
# Connect to DB 
#-------------------------------------------------------
iecho ">>>  Start execute for clear bk staging table"
iecho "Executing SQL file [$(basename ${SQLClrBkStgTblTemp})]"
iecho "Temp Output [$(basename ${SQLClrBkStgTblLogTemp})]"
sqlplus -s /nolog < ${SQLClrBkStgTblTemp} > ${SQLClrBkStgTblLogTemp}

#-------------------------------------------------------
# Check DB error
#-------------------------------------------------------
iecho "Checking database error"
CountError=$(grep -c "ORA\-[0-9]" ${SQLClrBkStgTblLogTemp})
iecho "Count database error = [${CountError}]"
if [ ${CountError} -ne 0 ]
then
	if [[ "${clearbkstgtblaction}" == "DROP" ]] || [[ "${clearbkstgtblaction}" == "drop" ]] 
	then
		# if action = "drop|DROP" then we have to check whether error = ORA-00942 or not?. If so, we can igonre
		#ORA-00942: table or view does not exist
		ORAErrorCode=$(grep "ORA\-[0-9]" ${SQLClrBkStgTblLogTemp} |awk -F":" '{print $1}')
		ORAErrorMsg=$(grep "ORA\-[0-9]" ${SQLClrBkStgTblLogTemp} |awk -F":" '{print $2}')
		if [[ "${ORAErrorCode}" == "ORA-00942" ]] 
		then
			iecho "ORAErrorCode = [${ORAErrorCode}]"
			iecho "ORAErrorMsg = [${ORAErrorMsg}]"
			iecho "This error could be ignored when action = \"DROP\" or \"drop\""
			iecho ">>>  End execute for clear bk staging table"
			iecho ""
		else
			ErrorMessage="Found Datebase Error ==> $(grep "ORA\-[0-9]" ${SQLClrBkStgTblLogTemp})"
			ierror "${ErrorMessage}"
			ierror "Can see more details at ${SQLClrBkStgTblLogTemp}"
			ErrorEmailSubject="${ErrorMessage}"
			ErrorEmailBody="${ErrorMessage}"
			SEND_EMAIL_FUNC "${emailtag}" "${ErrorEmailSubject}" "${ErrorEmailBody}" "${adminemail}"
			#### remove temp file #####
			CHECK_DEL_FILE_FUNC "${MainEmailSubject}" "${SQLClrBkStgTblTemp}" "Y" "N" "${adminemail}";
			exit 1
		fi
	else
		ErrorMessage="Found Datebase Error ==> $(grep "ORA\-[0-9]" ${SQLClrBkStgTblLogTemp})"
		ierror "${ErrorMessage}"
		ierror "Can see more details at ${SQLClrBkStgTblLogTemp}"
		ErrorEmailSubject="${ErrorMessage}"
		ErrorEmailBody="${ErrorMessage}"
		SEND_EMAIL_FUNC "${emailtag}" "${ErrorEmailSubject}" "${ErrorEmailBody}" "${adminemail}"
		#### remove temp file #####
		CHECK_DEL_FILE_FUNC "${MainEmailSubject}" "${SQLClrBkStgTblTemp}" "Y" "N" "${adminemail}";
		exit 1
	fi
else 
	iecho "Not found database error"
	CHECK_DEL_FILE_FUNC "${MainEmailSubject}" "${SQLClrBkStgTblTemp}" "Y" "N" "${adminemail}";
	CHECK_DEL_FILE_FUNC "${MainEmailSubject}" "${SQLClrBkStgTblLogTemp}" "Y" "N" "${adminemail}";
	iecho ">>>  End execute for clear bk staging table"
fi
iecho "#### 01 - End clear bk staging table"
iecho ""

PURGE_LOG_FUNC ${OutputPath} "*${JobName}" "txt" ${outputretention}

}

F02_BakStgTbl ()
{
iecho "#### 02 - Start backup staging table"

#-------------------------------------------------------
# Generate SQL file
#-------------------------------------------------------

SQLBackupStgTblTemp=${TempPath}/SQLBackupStgTblTemp_${JobName}_${CurrentDateTime}.${tempext}
SQLBackupStgTblLogTemp=${TempPath}/SQLBackupStgTblLogTemp_${JobName}_${CurrentDateTime}.${tempext}
##### replace parameter in sql file #####
iecho ">>> Start Prepare Sql file for backup staging table"
iecho "Edit sql file [${backupstgtablesql}]"
iecho "Sql temp file [$(basename ${SQLBackupStgTblTemp})]"
iecho "Username [${user}]"
idebug "Password [${pass}]"
iecho "Oracle SID [${db_name}]"
iecho "bkstagingtableschema = [${bkstagingtableschema}]"
iecho "bkstagingtablename = [${bkstagingtablename}]"
iecho "stagingtableschema = [${stagingtableschema}]"
iecho "stagingtablename = [${stagingtablename}]"
# iecho "clearbkstgtblaction = [${clearbkstgtblaction}]"
cat ${SqlPath}/${backupstgtablesql} | sed -e s/'${user}'/"${user}"/g -e s/'${pass}'/"${pass}"/g -e s/'${db_name}'/"${db_name}"/g \
-e s/'${bkstagingtableschema}'/"${bkstagingtableschema}"/g -e s/'${bkstagingtablename}'/"${bkstagingtablename}"/g -e s/'${stagingtableschema}'/"${stagingtableschema}"/g \
-e s/'${stagingtablename}'/"${stagingtablename}"/g >> ${SQLBackupStgTblTemp}
if [[ $? -ne 0 ]]
then
	ErrorMessage="Error while edit sql file"
	ierror "${ErrorMessage}"
	ErrorEmailSubject="${ErrorMessage}"
	ErrorEmailBody="${ErrorMessage}"
	SEND_EMAIL_FUNC "${emailtag}" "${ErrorEmailSubject}" "${ErrorEmailBody}" "${adminemail}"
	exit 1
else
	idebug ""
	idebug "-- Start show sql text"
	cat ${SQLBackupStgTblTemp} |while read Line
	do
		idebug "${Line}"
	done
	idebug "-- End show sql text"
	idebug ""
	iecho "Prepare sql file success"
	iecho ">>> End Prepare Sql file for backup staging table"
	iecho ""
fi

#-------------------------------------------------------
# Connect to DB 
#-------------------------------------------------------
iecho ">>>  Start execute for backup staging table"
iecho "Executing SQL file [$(basename ${SQLBackupStgTblTemp})]"
iecho "Temp Output [$(basename ${SQLBackupStgTblLogTemp})]"
sqlplus -s /nolog < ${SQLBackupStgTblTemp} > ${SQLBackupStgTblLogTemp}

#-------------------------------------------------------
# Check DB error
#-------------------------------------------------------
iecho "Checking database error"
CountError=$(grep -c "ORA\-[0-9]" ${SQLBackupStgTblLogTemp})
iecho "Count database error = [${CountError}]"
if [ ${CountError} -ne 0 ]
then
	ErrorMessage="Found Datebase Error ==> $(grep "ORA\-[0-9]" ${SQLBackupStgTblLogTemp})"
	ierror "${ErrorMessage}"
	ierror "Can see more details at ${SQLBackupStgTblLogTemp}"
	ErrorEmailSubject="${ErrorMessage}"
	ErrorEmailBody="${ErrorMessage}"
	SEND_EMAIL_FUNC "${emailtag}" "${ErrorEmailSubject}" "${ErrorEmailBody}" "${adminemail}"
	#### remove temp file #####
	CHECK_DEL_FILE_FUNC "${MainEmailSubject}" "${SQLBackupStgTblTemp}" "Y" "N" "${adminemail}";
	exit 1
else 
	iecho "Not found database error"
	CHECK_DEL_FILE_FUNC "${MainEmailSubject}" "${SQLBackupStgTblTemp}" "Y" "N" "${adminemail}";
	CHECK_DEL_FILE_FUNC "${MainEmailSubject}" "${SQLBackupStgTblLogTemp}" "Y" "N" "${adminemail}";
	iecho ">>>  End execute for backup staging table"
fi
iecho "#### 02 - End backup staging table"
iecho ""
}

F03_ClearStgTbl ()
{
iecho "#### 03 - Start clear staging table"

#-------------------------------------------------------
# Generate SQL file
#-------------------------------------------------------
SQLClrStgTblTemp=${TempPath}/SQLClrStgTblTemp_${JobName}_${CurrentDateTime}.${tempext}
SQLClrStgTblLogTemp=${TempPath}/SQLClrStgTblLogTemp_${JobName}_${CurrentDateTime}.${tempext}
##### replace parameter in sql file #####
iecho ">>> Start Prepare Sql file for clear staging table"
iecho "Edit sql file [${clearstagingtablesql}]"
iecho "Sql temp file [$(basename ${SQLClrStgTblTemp})]"
iecho "Username [${user}]"
idebug "Password [${pass}]"
iecho "Oracle SID [${db_name}]"
iecho "stagingtableschema = [${stagingtableschema}]"
iecho "stagingtablename = [${stagingtablename}]"
StgTblPrefix=$(echo ${stagingtablename} |awk '{print substr($0,1,2)}')
if [[ "${stagingtableschema}" == "SIEBEL" ]] && [[ "${StgTblPrefix}" == "S_" ]]
then
	ierror "StgTblPrefix = [${StgTblPrefix}]"
	ierror "stagingtableschema = SIEBEL and StgTblPrefix = S_"
	ErrorMessage="There is no permission on SIEBEL.S_* tables"
	ierror "${ErrorMessage}"
	ErrorEmailSubject="${ErrorMessage}"
	ErrorEmailBody="${ErrorMessage}"
	SEND_EMAIL_FUNC "${emailtag}" "${ErrorEmailSubject}" "${ErrorEmailBody}" "${adminemail}"
	exit 1
else
	ierror "StgTblPrefix = [${StgTblPrefix}]"

fi
if [[ "${clearstgtblaction}" = "DROP" ]] || [[ "${clearstgtblaction}" = "drop" ]] || [[ "${clearstgtblaction}" = "TRUNCATE" ]] || [[ "${clearstgtblaction}" = "truncate" ]]
then
	iecho "clearstgtblaction = [${clearstgtblaction}]"
else
	ErrorMessage="Clear staging table action [${clearstgtblaction}] not equql DROP|drop|TRUNCATE|truncate"
	ierror "${ErrorMessage}"
	ErrorEmailSubject="${ErrorMessage}"
	ErrorEmailBody="${ErrorMessage}"
	SEND_EMAIL_FUNC "${emailtag}" "${ErrorEmailSubject}" "${ErrorEmailBody}" "${adminemail}"
	exit 1
fi

iecho "clearstgtblaction = [${clearstgtblaction}]"

cat ${SqlPath}/${clearstagingtablesql} | sed -e s/'${user}'/"${user}"/g -e s/'${pass}'/"${pass}"/g -e s/'${db_name}'/"${db_name}"/g \
-e s/'${clearstgtblaction}'/"${clearstgtblaction}"/g -e s/'${stagingtableschema}'/"${stagingtableschema}"/g -e s/'${stagingtablename}'/"${stagingtablename}"/g >> ${SQLClrStgTblTemp}

if [[ $? -ne 0 ]]
then
	ErrorMessage="Error while edit sql file"
	ierror "${ErrorMessage}"
	ErrorEmailSubject="${ErrorMessage}"
	ErrorEmailBody="${ErrorMessage}"
	SEND_EMAIL_FUNC "${emailtag}" "${ErrorEmailSubject}" "${ErrorEmailBody}" "${adminemail}"
	exit 1
else
	idebug ""
	idebug "-- Start show sql text"
	cat ${SQLClrStgTblTemp} |while read Line
	do
		idebug "${Line}"
	done
	idebug "-- End show sql text"
	idebug ""
	iecho "Prepare sql file success"
	iecho ">>> End Prepare Sql file for clear staging table"
	iecho ""
fi


#-------------------------------------------------------
# Connect to DB 
#-------------------------------------------------------
iecho ">>>  Start execute for clear staging table"
iecho "Executing SQL file [$(basename ${SQLClrStgTblTemp})]"
iecho "Temp Output [$(basename ${SQLClrStgTblLogTemp})]"
sqlplus -s /nolog < ${SQLClrStgTblTemp} > ${SQLClrStgTblLogTemp}

#-------------------------------------------------------
# Check DB error
#-------------------------------------------------------
iecho "Checking database error"
CountError=$(grep -c "ORA\-[0-9]" ${SQLClrStgTblLogTemp})
iecho "Count database error = [${CountError}]"
if [ ${CountError} -ne 0 ]
then
	if [[ "${clearstgtblaction}" == "DROP" ]] || [[ "${clearstgtblaction}" == "drop" ]] 
	then
		# if action = "drop|DROP" then we have to check whether error = ORA-00942 or not?. If so, we can igonre
		#ORA-00942: table or view does not exist
		ORAErrorCode=$(grep "ORA\-[0-9]" ${SQLClrStgTblLogTemp} |awk -F":" '{print $1}')
		ORAErrorMsg=$(grep "ORA\-[0-9]" ${SQLClrStgTblLogTemp} |awk -F":" '{print $2}')
		if [[ "${ORAErrorCode}" == "ORA-00942" ]] 
		then
			iecho "ORAErrorCode = [${ORAErrorCode}]"
			iecho "ORAErrorMsg = [${ORAErrorMsg}]"
			iecho "This error could be ignored when action = \"DROP\" or \"drop\""
			iecho ">>>  End execute for clear staging table"
			iecho ""
		else
			ErrorMessage="Found Datebase Error ==> $(grep "ORA\-[0-9]" ${SQLClrStgTblLogTemp})"
			ierror "${ErrorMessage}"
			ierror "Can see more details at ${SQLClrStgTblLogTemp}"
			ErrorEmailSubject="${ErrorMessage}"
			ErrorEmailBody="${ErrorMessage}"
			SEND_EMAIL_FUNC "${emailtag}" "${ErrorEmailSubject}" "${ErrorEmailBody}" "${adminemail}"
			#### remove temp file #####
			CHECK_DEL_FILE_FUNC "${MainEmailSubject}" "${SQLClrStgTblTemp}" "Y" "N" "${adminemail}";
			exit 1
		fi
	else
		ErrorMessage="Found Datebase Error ==> $(grep "ORA\-[0-9]" ${SQLClrStgTblLogTemp})"
		ierror "${ErrorMessage}"
		ierror "Can see more details at ${SQLClrStgTblLogTemp}"
		ErrorEmailSubject="${ErrorMessage}"
		ErrorEmailBody="${ErrorMessage}"
		SEND_EMAIL_FUNC "${emailtag}" "${ErrorEmailSubject}" "${ErrorEmailBody}" "${adminemail}"
		#### remove temp file #####
		CHECK_DEL_FILE_FUNC "${MainEmailSubject}" "${SQLClrStgTblTemp}" "Y" "N" "${adminemail}";
		exit 1
	fi
else 
	iecho "Not found database error"
	CHECK_DEL_FILE_FUNC "${MainEmailSubject}" "${SQLClrStgTblTemp}" "Y" "N" "${adminemail}";
	CHECK_DEL_FILE_FUNC "${MainEmailSubject}" "${SQLClrStgTblLogTemp}" "Y" "N" "${adminemail}";
	iecho ">>>  End execute for clear staging table"
fi
iecho "#### 03 - End clear staging table"
iecho ""
}

F04_CreateStgTbl ()
{
iecho "#### 04 - Start create staging table"
#-------------------------------------------------------
# Generate SQL file
#-------------------------------------------------------
SQLCreateStgTblTemp=${TempPath}/SQLCreateStgTblTemp_${JobName}_${CurrentDateTime}.${tempext}
SQLCreateStgTblLogTemp=${TempPath}/SQLCreateStgTblLogTemp_${JobName}_${CurrentDateTime}.${tempext}


## Add Datetime for Stamp into Last Update Table BCPMIG.STG_MEMBER_TO_SF_LAST_EXT After Step 7
LastExtractDateTime=`date +"%Y%m%d_%H%M%S"`

##### replace parameter in sql file #####
iecho ">>> Start Prepare Sql file for create staging table"
iecho "Edit sql file [${createstgtablesql}]"
iecho "Sql temp file [$(basename ${SQLCreateStgTblTemp})]"
iecho "Username [${user}]"
idebug "Password [${pass}]"
iecho "Oracle SID [${db_name}]"
iecho "stagingtableschema = [${stagingtableschema}]"
iecho "stagingtablename = [${stagingtablename}]"

cat ${SqlPath}/${createstgtablesql} | sed -e s/'${user}'/"${user}"/g -e s/'${pass}'/"${pass}"/g -e s/'${db_name}'/"${db_name}"/g \
-e s/'${stagingtableschema}'/"${stagingtableschema}"/g -e s/'${stagingtablename}'/"${stagingtablename}"/g -e s/'${lastextracttableschema}'/"${lastextracttableschema}"/g \
-e s/'${lastextracttable}'/"${lastextracttable}"/g -e s/'${interfacename}'/"${interfacename}"/g >> ${SQLCreateStgTblTemp}

if [[ $? -ne 0 ]]
then
	Error="Error while edit sql file"
	ierror "${ErrorMessage}"
	ErrorEmailSubject="${ErrorMessage}"
	ErrorEmailBody="${ErrorMessage}"
	SEND_EMAIL_FUNC "${emailtag}" "${ErrorEmailSubject}" "${ErrorEmailBody}" "${adminemail}"
	exit 1
else
	idebug ""
	idebug "-- Start show sql text"
	cat ${SQLCreateStgTblTemp} |while read Line
	do
		idebug "${Line}"
	done
	idebug "-- End show sql text"
	idebug ""
	iecho "Prepare sql file success"
	iecho ">>> End Prepare Sql file for create staging table"
	iecho ""
fi

#-------------------------------------------------------
# Connect to DB 
#-------------------------------------------------------
iecho ">>>  Start execute for create staging table"
iecho "Executing SQL file [$(basename ${SQLCreateStgTblTemp})]"
iecho "Temp Output [$(basename ${SQLCreateStgTblLogTemp})]"
sqlplus -s /nolog < ${SQLCreateStgTblTemp} > ${SQLCreateStgTblLogTemp}

#-------------------------------------------------------
# Check DB error
#-------------------------------------------------------
iecho "Checking database error"
CountError=$(grep -c "ORA\-[0-9]" ${SQLCreateStgTblLogTemp})
iecho "Count database error = [${CountError}]"
if [ ${CountError} -ne 0 ]
then
	ErrorMessage="Found Datebase Error ==> $(grep "ORA\-[0-9]" ${SQLCreateStgTblLogTemp})"
	ierror "${ErrorMessage}"
	ierror "Can see more details at ${SQLCreateStgTblLogTemp}"
	ErrorEmailSubject="${ErrorMessage}"
	ErrorEmailBody="${ErrorMessage}"
	SEND_EMAIL_FUNC "${emailtag}" "${ErrorEmailSubject}" "${ErrorEmailBody}" "${adminemail}"
	#### remove temp file #####
	CHECK_DEL_FILE_FUNC "${MainEmailSubject}" "${SQLCreateStgTblTemp}" "Y" "N" "${adminemail}";
	exit 1
else 
	iecho "Not found database error"
	CHECK_DEL_FILE_FUNC "${MainEmailSubject}" "${SQLCreateStgTblTemp}" "Y" "N" "${adminemail}";
	CHECK_DEL_FILE_FUNC "${MainEmailSubject}" "${SQLCreateStgTblLogTemp}" "Y" "N" "${adminemail}";
	iecho ">>>  End execute for create staging table"
	iecho ""
fi

iecho ">>>  Start count staging table"
CountRecStgTbl=$(sqlplus -s ${user}/${pass}@${db_name} << THEEND
set term off
set echo off
set head off
set feedback off
SET TERMOUT OFF
set trimspool on
set pagesize 0
set lines 20000
set pages 20000
SELECT TRIM(COUNT(*)) FROM ${stagingtableschema}.${stagingtablename};
EXIT
THEEND
)

# if action = "drop|DROP" then we have to check whether error = ORA-00942 or not?. If so, we can igonre
#ORA-00942: table or view does not exist
ORAErrorCount=$(echo ${CountRecStgTbl} | grep -c "ORA\-[0-9]")
ORAErrorCode=$(echo ${CountRecStgTbl} | grep "ORA\-[0-9]" | awk -F"ORA-" '{print $2}' |awk -F":" '{print $1}')
ORAErrorMsg=$(echo ${CountRecStgTbl} | grep "ORA\-[0-9]" | awk -F"ORA-" '{print $2}' |awk -F":" '{print $2}')
FullORAErrCode="ORA-${ORAErrorCode}"
if [[ ${ORAErrorCount} -eq 0 ]]
then
	iecho "Not found database error"
	if [[ ${CountRecStgTbl} -eq 0 ]]
	then
		iecho "No record in staging table [${CountRecStgTbl}]"
		NoRecord="Y"
	else
		iecho "No. or records in staging table = [${CountRecStgTbl}]"
	fi
else
	ierror "ORAErrorCount = [${ORAErrorCount}]"
	ierror "FullORAErrCode = [${FullORAErrCode}]"
	ierror "ORAErrorMsg = [${ORAErrorMsg}]"
	ErrorMessage="Found Datebase Error ==> ORA-$(echo ${CountRecStgTbl}| awk -F"ORA-" '{print $2}' |awk -F":" '{print $1}')"
	ierror "${ErrorMessage}"
	ErrorEmailSubject="${ErrorMessage}"
	ErrorEmailBody="${ErrorMessage}"
	SEND_EMAIL_FUNC "${emailtag}" "${ErrorEmailSubject}" "${ErrorEmailBody}" "${adminemail}"
	exit 1
fi
iecho ">>>  End count staging table"
iecho "#### 04 - End create staging table"
iecho ""
}

F05_CreateIdx ()
{
iecho "#### 05 - Start create index"
iecho "No. of Index = [${noofindex}]"
iecho ">>> Start check no. of parameters whether they equal no. of index or not?"
c_idxschema=$(echo ${idxschema} | awk '{print NF}')
if [[ ${c_idxschema} -ne  ${noofindex} ]]
then
	iecho "Index Schema = [${idxschema}]"
	ErrorMessage="Index Schema Count [${c_idxschema}] !=  No. of Index [${noofindex}]"
	ierror "${ErrorMessage}"
	ErrorEmailSubject="${ErrorMessage}"
	ErrorEmailBody="${ErrorMessage}"
	SEND_EMAIL_FUNC "${emailtag}" "${ErrorEmailSubject}" "${ErrorEmailBody}" "${adminemail}"
	exit 1
fi

c_idxname=$(echo ${idxname} | awk '{print NF}')
if [[ ${c_idxname} -ne  ${noofindex} ]]
then
	iecho "Index Name = [${idxname}]"
	ErrorMessage="Index Name Count [${c_idxname}] !=  No. of Index [${noofindex}]"	ierror "${ErrorMessage}"
	ErrorEmailSubject="${ErrorMessage}"
	ErrorEmailBody="${ErrorMessage}"
	SEND_EMAIL_FUNC "${emailtag}" "${ErrorEmailSubject}" "${ErrorEmailBody}" "${adminemail}"
	exit 1
fi

c_idxtableschema=$(echo ${idxtableschema} | awk '{print NF}')
if [[ ${c_idxtableschema} -ne  ${noofindex} ]]
then
	iecho "Index Table Schema = [${idxtableschema}]"
	ErrorMessage="Index Table Schema Count [${c_idxtableschema}] !=  No. of Index [${noofindex}]"
	ierror "${ErrorMessage}"
	ErrorEmailSubject="${ErrorMessage}"
	ErrorEmailBody="${ErrorMessage}"
	SEND_EMAIL_FUNC "${emailtag}" "${ErrorEmailSubject}" "${ErrorEmailBody}" "${adminemail}"
	exit 1
fi

c_idxtablename=$(echo ${idxtablename} | awk '{print NF}')
if [[ ${c_idxtablename} -ne  ${noofindex} ]]
then
	iecho "Index Table Name = [${idxtablename}]"
	ErrorMessage="Index Table Name Count [${c_idxtablename}] !=  No. of Index [${noofindex}]"
	ierror "${ErrorMessage}"
	ErrorEmailSubject="${ErrorMessage}"
	ErrorEmailBody="${ErrorMessage}"
	SEND_EMAIL_FUNC "${emailtag}" "${ErrorEmailSubject}" "${ErrorEmailBody}" "${adminemail}"
	exit 1
fi

c_idxcolname=$(echo ${idxcolname} | awk '{print NF}')
if [[ ${c_idxcolname} -ne  ${noofindex} ]]
then
	iecho "Index Column Name = [${idxcolname}]"
	ErrorMessage="Index Column Name Count [${c_idxcolname}] !=  No. of Index [${noofindex}]"
	ierror "${ErrorMessage}"
	ErrorEmailSubject="${ErrorMessage}"
	ErrorEmailBody="${ErrorMessage}"
	SEND_EMAIL_FUNC "${emailtag}" "${ErrorEmailSubject}" "${ErrorEmailBody}" "${adminemail}"
	exit 1
fi

c_idxtblspacename=$(echo ${idxtblspacename} | awk '{print NF}')
if [[ ${c_idxtblspacename} -ne  ${noofindex} ]]
then
	iecho "Index Tablespace Name = [${idxtblspacename}]"
	ErrorMessage="Index Tablespace Name Count [${c_idxtblspacename}] !=  No. of Index [${noofindex}]"
	ierror "${ErrorMessage}"
	ErrorEmailSubject="${ErrorMessage}"
	ErrorEmailBody="${ErrorMessage}"
	SEND_EMAIL_FUNC "${emailtag}" "${ErrorEmailSubject}" "${ErrorEmailBody}" "${adminemail}"
	exit 1
fi
iecho ">>> End check no. of parameters whether they equal no. of index or not?"
iecho ""

iecho ">>> Start list index information"
CountIdx=1
while [[ ${CountIdx} -le ${noofindex} ]]
do
	## Index Schema
	i=1
	for IndexSchema in ${idxschema}
	do
		if [[ ${i} -eq ${CountIdx} ]]
		then
			iecho "Index Schema [${i}/${noofindex}] = [${IndexSchema}]"
			IndexSchemaCurrent=${IndexSchema}
		fi
	((i=i+1))
	done
	
	## Index Name
	i=1
	for IndexName in ${idxname}
	do
		if [[ ${i} -eq ${CountIdx} ]]
		then
			iecho "Index Name [${i}/${noofindex}] = [${IndexName}]"
			IndexNameCurrent=${IndexName}
		fi
	((i=i+1))
	done
	
	## Index Table Schema idxtableschema
	i=1
	for IndexTableSchema in ${idxtableschema}
	do
		if [[ ${i} -eq ${CountIdx} ]]
		then
			iecho "Index Table Schema [${i}/${noofindex}] = [${IndexTableSchema}]"
			IndexTableSchemaCurrent=${IndexTableSchema}
		fi
	((i=i+1))
	done	
	
	## Index Index Table Name
	i=1
	for IndexTableName in ${idxtablename}
	do
		if [[ ${i} -eq ${CountIdx} ]]
		then
			iecho "Index Table Name [${i}/${noofindex}] = [${IndexTableName}]"
			IndexTableNameCurrent=${IndexTableName}
		fi
	((i=i+1))
	done
	
	## Index Column Name
	i=1
	for IndexColumnName in ${idxcolname}
	do
		if [[ ${i} -eq ${CountIdx} ]]
		then
			iecho "Index Column Name [${i}/${noofindex}] = [${IndexColumnName}]"
			IndexColumnNameCurrent=${IndexColumnName}
		fi
	((i=i+1))
	done

	## Index Table Space Name
	i=1
	for IndexTableSpaceName in ${idxtblspacename}
	do
		if [[ ${i} -eq ${CountIdx} ]]
		then
			iecho "Index Table Space Name [${i}/${noofindex}] = [${IndexTableSpaceName}]"
			IndexTableSpaceNameCurrent=${IndexTableSpaceName}
		fi
	((i=i+1))
	done
iecho ""

iecho "IndexSchemaCurrent = [${IndexSchemaCurrent}]"
iecho "IndexNameCurrent = [${IndexNameCurrent}]"
iecho "IndexTableSchemaCurrent = [${IndexTableSchemaCurrent}]"
iecho "IndexTableNameCurrent = [${IndexTableNameCurrent}]"
iecho "IndexColumnNameCurrent = [${IndexColumnNameCurrent}]"
iecho "IndexTableSpaceNameCurrent = [${IndexTableSpaceNameCurrent}]"
iecho ">>> End list index information"
iecho ""
#-------------------------------------------------------
# Generate SQL file
#-------------------------------------------------------

SQLCreateIdxTemp=${TempPath}/SQLCreateIdxTemp_${JobName}_${CurrentDateTime}_${CountIdx}_${noofindex}.${tempext}
SQLCreateIdxLogTemp=${TempPath}/SQLCreateIdxLogTemp_${JobName}_${CurrentDateTime}_${CountIdx}_${noofindex}.${tempext}

##### replace parameter in sql file #####
iecho ">>> Start Prepare Sql file for create index [${CountIdx}/${noofindex}]"
iecho "Edit sql file [${createidxstgtblsql}]"
iecho "Sql temp file [$(basename ${SQLCreateIdxTemp})]"
iecho "Username [${user}]"
idebug "Password [${pass}]"
iecho "Oracle SID [${db_name}]"

cat ${SqlPath}/${createidxstgtblsql} | sed -e s/'${user}'/"${user}"/g -e s/'${pass}'/"${pass}"/g -e s/'${db_name}'/"${db_name}"/g \
-e s/'${IndexSchemaCurrent}'/"${IndexSchemaCurrent}"/g -e s/'${IndexNameCurrent}'/"${IndexNameCurrent}"/g -e s/'${IndexTableSchemaCurrent}'/"${IndexTableSchemaCurrent}"/g \
-e s/'${IndexTableNameCurrent}'/"${IndexTableNameCurrent}"/g -e s/'${IndexColumnNameCurrent}'/"${IndexColumnNameCurrent}"/g \
-e s/'${IndexTableSpaceNameCurrent}'/"${IndexTableSpaceNameCurrent}"/g >> ${SQLCreateIdxTemp}

if [[ $? -ne 0 ]]
then
	ErrorMessage="Error while edit sql file"
	ierror "${ErrorMessage}"
	ErrorEmailSubject="${ErrorMessage}"
	ErrorEmailBody="${ErrorMessage}"
	SEND_EMAIL_FUNC "${emailtag}" "${ErrorEmailSubject}" "${ErrorEmailBody}" "${adminemail}"
	exit 1
else
	idebug ""
	idebug "-- Start show sql text"
	cat ${SQLCreateIdxTemp} |while read Line
	do
		idebug "${Line}"
	done
	idebug "-- End show sql text"
	idebug ""
	iecho "Prepare sql file success"
	iecho ">>> End Prepare Sql file for create index [${CountIdx}/${noofindex}]"
	iecho ""
fi

#-------------------------------------------------------
# Connect to DB 
#-------------------------------------------------------
iecho ">>>  Start execute for create index [${CountIdx}/${noofindex}]"
iecho "Executing SQL file [$(basename ${SQLCreateIdxTemp})]"
iecho "Temp Output [$(basename ${SQLCreateIdxLogTemp})]"
sqlplus -s /nolog < ${SQLCreateIdxTemp} > ${SQLCreateIdxLogTemp}

#-------------------------------------------------------
# Check DB error
#-------------------------------------------------------
iecho "Checking database error"
CountError=$(grep -c "ORA\-[0-9]" ${SQLCreateIdxLogTemp})
iecho "Count database error = [${CountError}]"
if [ ${CountError} -ne 0 ]
then
	ErrorMessage="Found Datebase Error ==> $(grep "ORA\-[0-9]" ${SQLCreateIdxLogTemp})"
	ierror "${ErrorMessage}"
	ierror "Can see more details at ${SQLCreateIdxLogTemp}"
	ErrorEmailSubject="${ErrorMessage}"
	ErrorEmailBody="${ErrorMessage}"
	SEND_EMAIL_FUNC "${emailtag}" "${ErrorEmailSubject}" "${ErrorEmailBody}" "${adminemail}"
	#### remove temp file #####
	CHECK_DEL_FILE_FUNC "${MainEmailSubject}" "${SQLCreateIdxTemp}" "Y" "N" "${adminemail}";
	exit 1
else 
	iecho "Not found database error"
	CHECK_DEL_FILE_FUNC "${MainEmailSubject}" "${SQLCreateIdxTemp}" "Y" "N" "${adminemail}";
	CHECK_DEL_FILE_FUNC "${MainEmailSubject}" "${SQLCreateIdxLogTemp}" "Y" "N" "${adminemail}";
	iecho ">>>  End execute for create index [${CountIdx}/${noofindex}]"
fi	
((CountIdx=CountIdx+1))
done
iecho "#### 05 - End create index"
iecho ""
}

F06_RunAnalyzeTbl ()
{
iecho "#### 06 - Start run analyze table"
iecho "No. of Table = [${nooftable}]"
iecho ">>> Start check no. of parameters whether they equal no. of table or not?"
c_analyzetableschema=$(echo ${analyzetableschema} | awk '{print NF}')
if [[ ${c_analyzetableschema} -ne  ${nooftable} ]]
then
	iecho "Analyze Table Schema = [${analyzetableschema}]"
	ErrorMessage="Analyze Table Schema Count [${c_analyzetableschema}] !=  no. of table [${nooftable}]"
	ierror "${ErrorMessage}"
	ErrorEmailSubject="${ErrorMessage}"
	ErrorEmailBody="${ErrorMessage}"
	SEND_EMAIL_FUNC "${emailtag}" "${ErrorEmailSubject}" "${ErrorEmailBody}" "${adminemail}"
	exit 1
fi

c_analyzetablename=$(echo ${analyzetablename} | awk '{print NF}')
if [[ ${c_analyzetablename} -ne  ${nooftable} ]]
then
	iecho "Analyze Table Name = [${analyzetablename}]"
	ErrorMessage="Analyze Table Name Count [${c_analyzetablename}] !=  no. of table [${nooftable}]"
	ierror "${ErrorMessage}"
	ErrorEmailSubject="${ErrorMessage}"
	ErrorEmailBody="${ErrorMessage}"
	SEND_EMAIL_FUNC "${emailtag}" "${ErrorEmailSubject}" "${ErrorEmailBody}" "${adminemail}"
	exit 1
fi

c_estimatepercent=$(echo ${estimatepercent} | awk '{print NF}')
if [[ ${c_estimatepercent} -ne  ${nooftable} ]]
then
	iecho "Estimate Percent for Analyze Table = [${estimatepercent}]"
	ErrorMessage="Estimate Percent for Analyze Table Count [${c_estimatepercent}] !=  no. of table [${nooftable}]"
	ierror "${ErrorMessage}"
	ErrorEmailSubject="${ErrorMessage}"
	ErrorEmailBody="${ErrorMessage}"
	SEND_EMAIL_FUNC "${emailtag}" "${ErrorEmailSubject}" "${ErrorEmailBody}" "${adminemail}"
	exit 1
fi

c_degree=$(echo ${degree} | awk '{print NF}')
if [[ ${c_degree} -ne  ${nooftable} ]]
then
	iecho "Degree Estimate Percent for Analyze Table = [${degree}]"
	ErrorMessage="Degree Estimate Percent for Analyze Table Count [${c_degree}] !=  no. of table [${nooftable}]"
	ierror "${ErrorMessage}"
	ErrorEmailSubject="${ErrorMessage}"
	ErrorEmailBody="${ErrorMessage}"
	SEND_EMAIL_FUNC "${emailtag}" "${ErrorEmailSubject}" "${ErrorEmailBody}" "${adminemail}"
	exit 1
fi

iecho ">>> End check no. of parameters whether they equal no. of table or not?"
iecho ""

iecho ">>> Start list analyze table information"
CountTbl=1
while [[ ${CountTbl} -le ${nooftable} ]]
do
	## AnalyzeTableSchema
	i=1
	for AnalyzeTableSchema in ${analyzetableschema}
	do
		if [[ ${i} -eq ${CountTbl} ]]
		then
			iecho "Analyze Table Schema [${i}/${nooftable}] = [${AnalyzeTableSchema}]"
			AnalyzeTableSchemaCurrent=${AnalyzeTableSchema}
		fi
	((i=i+1))
	done
	
	## AnalyzeTableName
	i=1
	for AnalyzeTableName in ${analyzetablename}
	do
		if [[ ${i} -eq ${CountTbl} ]]
		then
			iecho "Analyze Table Name [${i}/${nooftable}] = [${AnalyzeTableName}]"
			AnalyzeTableNameCurrent=${AnalyzeTableName}
		fi
	((i=i+1))
	done
	
	## Estimate Percent
	i=1
	for EstimatePercent in ${estimatepercent}
	do
		if [[ ${i} -eq ${CountTbl} ]]
		then
			iecho "Estimate Percent [${i}/${nooftable}] = [${EstimatePercent}]"
			EstimatePercentCurrent=${EstimatePercent}
		fi
	((i=i+1))
	done	
	
	## Degree 
	i=1
	for Degree in ${degree}
	do
		if [[ ${i} -eq ${CountTbl} ]]
		then
			iecho "Degree [${i}/${nooftable}] = [${Degree}]"
			DegreeCurrent=${Degree}
		fi
	((i=i+1))
	done
iecho ""

iecho "AnalyzeTableSchemaCurrent = [${AnalyzeTableSchemaCurrent}]"
iecho "AnalyzeTableNameCurrent = [${AnalyzeTableNameCurrent}]"
iecho "EstimatePercentCurrent = [${EstimatePercentCurrent}]"
iecho "DegreeCurrent = [${DegreeCurrent}]"
iecho ">>> End list analyze table information"
iecho ""
#-------------------------------------------------------
# Generate SQL file
#-------------------------------------------------------
SQLAnalyzeTblTemp=${TempPath}/SQLAnalyzeTblTemp_${JobName}_${CurrentDateTime}_${CountTbl}_${nooftable}.${tempext}
SQLAnalyzeTblTempLogTemp=${TempPath}/SQLAnalyzeTblTempLogTemp_${JobName}_${CurrentDateTime}_${CountTbl}_${nooftable}.${tempext}

##### replace parameter in sql file #####
iecho ">>> Start Prepare Sql file for analyze table [${CountTbl}/${nooftable}]"
iecho "Edit sql file [${runanalyzetblsql}]"
iecho "Sql temp file [$(basename ${SQLAnalyzeTblTemp})]"
iecho "Username [${user}]"
idebug "Password [${pass}]"
iecho "Oracle SID [${db_name}]"

cat ${SqlPath}/${runanalyzetblsql} | sed -e s/'${user}'/"${user}"/g -e s/'${pass}'/"${pass}"/g -e s/'${db_name}'/"${db_name}"/g \
-e s/'${AnalyzeTableSchemaCurrent}'/"${AnalyzeTableSchemaCurrent}"/g -e s/'${AnalyzeTableNameCurrent}'/"${AnalyzeTableNameCurrent}"/g \
-e s/'${EstimatePercentCurrent}'/"${EstimatePercentCurrent}"/g -e s/'${DegreeCurrent}'/"${DegreeCurrent}"/g >> ${SQLAnalyzeTblTemp}

if [[ $? -ne 0 ]]
then
	ErrorMessage="Error while edit sql file"
	ierror "${ErrorMessage}"
	ErrorEmailSubject="${ErrorMessage}"
	ErrorEmailBody="${ErrorMessage}"
	SEND_EMAIL_FUNC "${emailtag}" "${ErrorEmailSubject}" "${ErrorEmailBody}" "${adminemail}"
	exit 1
else
	idebug ""
	idebug "-- Start show sql text"
	cat ${SQLAnalyzeTblTemp} |while read Line
	do
		idebug "${Line}"
	done
	idebug "-- End show sql text"
	idebug ""
	iecho "Prepare sql file success"
	iecho ">>> End Prepare Sql file for analyze table [${CountTbl}/${nooftable}]"
	iecho ""
fi

#-------------------------------------------------------
# Connect to DB 
#-------------------------------------------------------
# SQLAnalyzeTblTemp=${TempPath}/SQLAnalyzeTblTemp_${JobName}_${CurrentDateTime}_${CountTbl}_${nooftable}.${tempext}
# SQLAnalyzeTblTempLogTemp=${TempPath}/SQLAnalyzeTblTempLogTemp_${JobName}_${CurrentDateTime}_${CountTbl}_${nooftable}.${tempext}
iecho ">>>  Start execute for analyze table [${CountTbl}/${nooftable}]"
iecho "Executing SQL file [$(basename ${SQLAnalyzeTblTemp})]"
iecho "Temp Output [$(basename ${SQLAnalyzeTblTempLogTemp})]"
sqlplus -s /nolog < ${SQLAnalyzeTblTemp} > ${SQLAnalyzeTblTempLogTemp}

#-------------------------------------------------------
# Check DB error
#-------------------------------------------------------
iecho "Checking database error"
CountError=$(grep -c "ORA\-[0-9]" ${SQLAnalyzeTblTempLogTemp})
iecho "Count database error = [${CountError}]"
if [ ${CountError} -ne 0 ]
then
	ErrorMessage="Found Datebase Error ==> $(grep "ORA\-[0-9]" ${SQLAnalyzeTblTempLogTemp})"
	ierror "${ErrorMessage}"
	ierror "Can see more details at ${SQLAnalyzeTblTempLogTemp}"
	ErrorEmailSubject="${ErrorMessage}"
	ErrorEmailBody="${ErrorMessage}"
	SEND_EMAIL_FUNC "${emailtag}" "${ErrorEmailSubject}" "${ErrorEmailBody}" "${adminemail}"
	#### remove temp file #####
	CHECK_DEL_FILE_FUNC "${MainEmailSubject}" "${SQLAnalyzeTblTemp}" "Y" "N" "${adminemail}";
	exit 1
else 
	iecho "Not found database error"
	CHECK_DEL_FILE_FUNC "${MainEmailSubject}" "${SQLAnalyzeTblTemp}" "Y" "N" "${adminemail}";
	CHECK_DEL_FILE_FUNC "${MainEmailSubject}" "${SQLAnalyzeTblTempLogTemp}" "Y" "N" "${adminemail}";
	iecho ">>>  End execute for analyze table [${CountTbl}/${nooftable}]"
fi	
((CountTbl=CountTbl+1))
done
iecho "#### 06 - End run analyze table"
iecho ""
}

F07_RunPLSQL ()
{
iecho "#### 07 - Start run PLSQL"
iecho "no. of PLSQL = [${noofplsql}]"
iecho ">>> Start check no. of parameters whether they equal no. of PLSQL or not?"
c_usestgtbl=$(echo ${usestgtbl} | awk '{print NF}')
if [[ ${c_usestgtbl} -ne  ${noofplsql} ]]
then
	iecho "Use Staging Table Flag = [${usestgtbl}]"
	ErrorMessage="Use Staging Table Flag Count [${c_usestgtbl}] !=  no. of PLSQL [${noofplsql}]"
	ierror "${ErrorMessage}"
	ErrorEmailSubject="${ErrorMessage}"
	ErrorEmailBody="${ErrorMessage}"
	SEND_EMAIL_FUNC "${emailtag}" "${ErrorEmailSubject}" "${ErrorEmailBody}" "${adminemail}"
	exit 1
fi

c_plsqlfile=$(echo ${plsqlfile} | awk '{print NF}')
if [[ ${c_plsqlfile} -ne  ${noofplsql} ]]
then
	iecho "PLSQL file = [${plsqlfile}]"
	ErrorMessage="PLSQL file Count [${c_plsqlfile}] !=  no. of PLSQL [${noofplsql}]"
	ierror "${ErrorMessage}"
	ErrorEmailSubject="${ErrorMessage}"
	ErrorEmailBody="${ErrorMessage}"
	SEND_EMAIL_FUNC "${emailtag}" "${ErrorEmailSubject}" "${ErrorEmailBody}" "${adminemail}"
	exit 1
fi

c_batchsize=$(echo ${batchsize} | awk '{print NF}')
if [[ ${c_batchsize} -ne  ${noofplsql} ]]
then
	iecho "Batch Size = [${batchsize}]"
	ErrorMessage="Batch Size Count [${c_batchsize}] !=  no. of PLSQL [${noofplsql}]"
	ierror "${ErrorMessage}"
	ErrorEmailSubject="${ErrorMessage}"
	ErrorEmailBody="${ErrorMessage}"
	SEND_EMAIL_FUNC "${emailtag}" "${ErrorEmailSubject}" "${ErrorEmailBody}" "${adminemail}"
	exit 1
fi
iecho ">>> End check no. of parameters whether they equal no. of PLSQL or not?"
iecho ""
iecho ">>> Start list PLSQL information"
CountPLSQL=1
while [[ ${CountPLSQL} -le ${noofplsql} ]]
do
	## UseStgTbl
	i=1
	for UseStgTbl in ${usestgtbl}
	do
		if [[ ${i} -eq ${CountPLSQL} ]]
		then
			iecho "Use Staging Table Flag [${i}/${noofplsql}] = [${UseStgTbl}]"
			UseStgTblCurrent=${UseStgTbl}
		fi
	((i=i+1))
	done
	
	## PLSQLFile
	i=1
	for PLSQLFile in ${plsqlfile}
	do
		if [[ ${i} -eq ${CountPLSQL} ]]
		then
			iecho "PLSQL file [${i}/${noofplsql}] = [${PLSQLFile}]"
			PLSQLFileCurrent=${PLSQLFile}
		fi
	((i=i+1))
	done
	
	## batchsize
	i=1
	for BatchSize in ${batchsize}
	do
		if [[ ${i} -eq ${CountPLSQL} ]]
		then
			iecho "Batch Size [${i}/${noofplsql}] = [${BatchSize}]"
			BatchSizeCurrent=${BatchSize}
		fi
	((i=i+1))
	done	

iecho ""

iecho "UseStgTblCurrent = [${UseStgTblCurrent}]"
iecho "PLSQLFileCurrent = [${PLSQLFileCurrent}]"
iecho "BatchSizeCurrent = [${BatchSizeCurrent}]"
iecho ">>> End list PLSQL information"
iecho ""
#-------------------------------------------------------
# Generate SQL file
#-------------------------------------------------------
SQLRunPLSQLTemp=${TempPath}/SQLRunPLSQLTemp_${JobName}_${CurrentDateTime}_${CountPLSQL}_${noofplsql}.${tempext}
SQLRunPLSQLLogTemp=${TempPath}/SQLRunPLSQLLogTemp_${JobName}_${CurrentDateTime}_${CountPLSQL}_${noofplsql}.${tempext}

##### replace parameter in sql file #####
iecho ">>> Start Prepare Sql file for run PLSQL [${CountPLSQL}/${noofplsql}]"
iecho "Edit sql file [${PLSQLFileCurrent}]"
iecho "Sql temp file [$(basename ${SQLRunPLSQLTemp})]"
iecho "Username [${user}]"
idebug "Password [${pass}]"
iecho "Oracle SID [${db_name}]"
iecho "Output Path for PL/SQL [${plsqloutputpath}]"
plsqloutputpathEdit=$(echo "${plsqloutputpath}"|sed -e 's:/:\\/:g')
iecho "Output Path for PL/SQL(editted) [${plsqloutputpathEdit}]"

if [[ "${UseStgTblCurrent}" == "Y" ]]
then
	cat ${SqlPath}/${PLSQLFileCurrent} | sed -e s/'${user}'/"${user}"/g -e s/'${pass}'/"${pass}"/g -e s/'${db_name}'/"${db_name}"/g \
	-e s/'${stagingtableschema}'/"${stagingtableschema}"/g -e s/'${stagingtablename}'/"${stagingtablename}"/g -e s/'${BatchSizeCurrent}'/"${BatchSizeCurrent}"/g \
	-e s/'${plsqloutputpath}'/"${plsqloutputpathEdit}"/g >> ${SQLRunPLSQLTemp}
else
	cat ${SqlPath}/${PLSQLFileCurrent} | sed -e s/'${user}'/"${user}"/g -e s/'${pass}'/"${pass}"/g -e s/'${db_name}'/"${db_name}"/g \
	-e s/'${BatchSizeCurrent}'/"${BatchSizeCurrent}"/g -e s/'${plsqloutputpath}'/"${plsqloutputpathEdit}"/g >> ${SQLRunPLSQLTemp}
fi

if [[ $? -ne 0 ]]
then
	ErrorMessage="Error while edit sql file"
	ierror "${ErrorMessage}"
	ErrorEmailSubject="${ErrorMessage}"
	ErrorEmailBody="${ErrorMessage}"
	SEND_EMAIL_FUNC "${emailtag}" "${ErrorEmailSubject}" "${ErrorEmailBody}" "${adminemail}"
	exit 1
else
	idebug ""
	idebug "-- Start show sql text"
	cat ${SQLRunPLSQLTemp} |while read Line
	do
		idebug "${Line}"
	done
	idebug "-- End show sql text"
	idebug ""
	iecho "Prepare sql file success"
	iecho ">>> End Prepare Sql file for analyze run PLSQL [${CountPLSQL}/${noofplsql}]"
	iecho ""
fi

#-------------------------------------------------------
# Connect to DB 
#-------------------------------------------------------
iecho ">>>  Start execute for run PLSQL [${CountPLSQL}/${noofplsql}]"
iecho "Executing SQL file [$(basename ${SQLRunPLSQLTemp})]"
iecho "Temp Output [$(basename ${SQLRunPLSQLLogTemp})]"
sqlplus -s /nolog < ${SQLRunPLSQLTemp} 1> /dev/null 2> ${SQLRunPLSQLLogTemp}

#-------------------------------------------------------
# Check DB error
#-------------------------------------------------------
iecho "Checking database error"
CountError=$(grep -c "ORA\-[0-9]" ${SQLRunPLSQLLogTemp})
ElapsedTime=$(grep "Elapsed" ${SQLRunPLSQLLogTemp})
iecho "Count database error = [${CountError}]"
if [ ${CountError} -ne 0 ]
then
	ErrorMessage="Found Datebase Error ==> $(grep "ORA\-[0-9]" ${SQLRunPLSQLLogTemp})"
	ierror "${ErrorMessage}"
	ierror "Can see more details at ${SQLRunPLSQLLogTemp}"
	ErrorEmailSubject="${ErrorMessage}"
	ErrorEmailBody="${ErrorMessage}"
	SEND_EMAIL_FUNC "${emailtag}" "${ErrorEmailSubject}" "${ErrorEmailBody}" "${adminemail}"
	#### remove temp file #####
	CHECK_DEL_FILE_FUNC "${MainEmailSubject}" "${SQLRunPLSQLTemp}" "Y" "N" "${adminemail}";
	exit 1
else 
	iecho "Not found database error"
	iecho "ElapsedTime: ${ElapsedTime}"

	## TODO: Need to comment/uncomment for testing #################################################################################################################
	CHECK_DEL_FILE_FUNC "${MainEmailSubject}" "${SQLRunPLSQLTemp}" "Y" "N" "${adminemail}";
	CHECK_DEL_FILE_FUNC "${MainEmailSubject}" "${SQLRunPLSQLLogTemp}" "Y" "N" "${adminemail}";
	iecho ">>>  End execute for run PLSQL [${CountPLSQL}/${noofplsql}]"
	iecho ""
fi	
((CountPLSQL=CountPLSQL+1))
done


SQLChkErrTemp=${TempPath}/SQLChkErrTemp_${JobName}_${CurrentDateTime}.${tempext}
SQLChkErrLogTemp=${TempPath}/SQLChkErrLogTemp_${JobName}_${CurrentDateTime}.${tempext}
iecho ">>> Start Prepare Sql file for check error status"
iecho "Edit sql file [${checkerrstatussql}]"
iecho "Sql temp file [$(basename ${SQLChkErrTemp})]"
iecho "Username [${user}]"
idebug "Password [${pass}]"
iecho "Oracle SID [${db_name}]"
iecho "outputfiletype [${outputfiletype}]"
iecho "NLS_LANG [${NLS_LANG}]"

cat ${SqlPath}/${checkerrstatussql} | sed -e s/'${user}'/"${user}"/g -e s/'${pass}'/"${pass}"/g -e s/'${db_name}'/"${db_name}"/g \
-e s/'${stagingtableschema}'/"${stagingtableschema}"/g -e s/'${stagingtablename}'/"${stagingtablename}"/g >> ${SQLChkErrTemp}

if [[ $? -ne 0 ]]
then
	ErrorMessage="Error while edit sql file"
	ierror "${ErrorMessage}"
	ErrorEmailSubject="${ErrorMessage}"
	ErrorEmailBody="${ErrorMessage}"
	SEND_EMAIL_FUNC "${emailtag}" "${ErrorEmailSubject}" "${ErrorEmailBody}" "${adminemail}"
	exit 1
else
	idebug ""
	idebug "-- Start show sql text"
	cat ${SQLChkErrTemp} |while read Line
	do
		idebug "${Line}"
	done
	idebug "-- End show sql text"
	idebug ""
	iecho "Prepare sql file success"
	iecho ">>> End Prepare Sql file for check error status"
	iecho ""
fi

#-------------------------------------------------------
# Connect to DB 
#-------------------------------------------------------
iecho ">>>  Start execute for count error status in staging table"
iecho "Executing SQL file [$(basename ${SQLChkErrTemp})]"
iecho "Temp Output [$(basename ${SQLChkErrLogTemp})]"
sqlplus -s /nolog < ${SQLChkErrTemp} > ${SQLChkErrLogTemp}

#-------------------------------------------------------
# Check DB error
#-------------------------------------------------------
iecho "Checking database error"
CountError=$(grep -c "ORA\-[0-9]" ${SQLChkErrLogTemp})
iecho "Count database error = [${CountError}]"
if [ ${CountError} -ne 0 ]
then
	ErrorMessage="Found Datebase Error ==> $(grep "ORA\-[0-9]" ${SQLChkErrLogTemp})"
	ierror "${ErrorMessage}"
	ierror "Can see more details at ${SQLChkErrLogTemp}"
	ErrorEmailSubject="${ErrorMessage}"
	ErrorEmailBody="${ErrorMessage}"
	SEND_EMAIL_FUNC "${emailtag}" "${ErrorEmailSubject}" "${ErrorEmailBody}" "${adminemail}"
	#### remove temp file #####
	CHECK_DEL_FILE_FUNC "${MainEmailSubject}" "${SQLChkErrTemp}" "Y" "N" "${adminemail}";
	exit 1
else 
	iecho "Not found database error"
	idebug ""
	idebug "-- Start show sql output"
	cat ${SQLChkErrLogTemp} |while read Line
	do
		idebug "${Line}"
	done
	idebug "-- End show sql output"
	idebug ""
	CountNoAction=$(cat ${SQLChkErrLogTemp} |grep -v "^$" |awk -F"|" '$1=="0" {print $2}')
	if [[ "${CountNoAction}" == "" ]]
	then
		CountNoAction=0
	fi
	CountSuccess=$(cat ${SQLChkErrLogTemp} |grep -v "^$" |awk -F"|" '$1=="2" {print $2}')
	if [[ "${CountSuccess}" == "" ]]
	then
		CountSuccess=0
	fi
	CountError=$(cat ${SQLChkErrLogTemp} |grep -v "^$"|awk -F"|" '$1<0 {print $2}')
	if [[ "${CountError}" == "" ]]
	then
		CountError=0
	fi
	((CountAllRecord=CountNoAction+CountSuccess+CountError))
	iecho "CountNoAction = [${CountNoAction}]"
	iecho "CountSuccess = [${CountSuccess}]"
	iecho "CountError = [${CountError}]"
	iecho "CountAllRecord = [${CountAllRecord}]"
	if [[ ${CountError} -gt 0 ]]
	then
		if [[ ${CountError} -eq  ${CountAllRecord} ]]
		then
			ErrorMessage="All records can not be updated with error"
			ierror "${ErrorMessage}"
			ierror "Please see error in table [${stagingtableschema}.${stagingtablename}]"
			ErrorEmailSubject="${ErrorMessage}"
			ErrorEmailBody="${ErrorMessage}"
			SEND_EMAIL_FUNC "${emailtag}" "${ErrorEmailSubject}" "${ErrorEmailBody}" "${adminemail}"
			exit 1 
		else
			ierror "Some records can not be updated with error"
			ierror "Please see error in table [${stagingtableschema}.${stagingtablename}]"
			exit 2	
		fi
	else
		iecho "All records can be updated"
	
	fi
	CHECK_DEL_FILE_FUNC "${MainEmailSubject}" "${SQLChkErrTemp}" "Y" "N" "${adminemail}";
	CHECK_DEL_FILE_FUNC "${MainEmailSubject}" "${SQLChkErrLogTemp}" "Y" "N" "${adminemail}";
	iecho ">>>  End execute for count error status in staging table"
fi	


#-------------------------------------------------------
# edit output 
#-------------------------------------------------------
iecho ""
iecho ">>> Start Edit output"
plsqloutputpathtemp=${plsqloutputpath}.edit
iecho "Output file temp [${plsqloutputpathtemp}]"
iecho "Output file [${plsqloutputpath}]"
iecho "Check output file"
Countplsqloutput=$(cat ${plsqloutputpath}|wc -l |tr -d [:blank:])
iecho "Countplsqloutput = [${Countplsqloutput}]"
iecho "outputfiletype = [${outputfiletype}]"
iecho "uft8bomflag = [${uft8bomflag}]"

if [[ ${Countplsqloutput} -ne 0 ]]
then
	idebug "Countplsqloutput != 0 --> Need edit output"
	if [[ ${uft8bomflag} == "Y" ]] && [[ ${outputfiletype} = "UTF8" ]]
	then
		printf '\xEF\xBB\xBF' > ${plsqloutputpathtemp}
		cat ${plsqloutputpath}|grep -v "^$" >> ${plsqloutputpathtemp}
		ErrorPlsqlCheck=$?
	else
		cat ${plsqloutputpath}|grep -v "^$" > ${plsqloutputpathtemp}
		ErrorPlsqlCheck=$?
	fi

	if [[ ${ErrorPlsqlCheck} -ne 0 ]]
	then
		ErrorMessage="Error while edit temp output [${plsqloutputpathtemp}]"
		ierror "${ErrorMessage}"
		ErrorEmailSubject="${ErrorMessage}"
		ErrorEmailBody="${ErrorMessage}"
		SEND_EMAIL_FUNC "${emailtag}" "${ErrorEmailSubject}" "${ErrorEmailBody}" "${adminemail}"
		exit 1
	fi

	iecho "eofflag = [${eofflag}]"
	if [[ ${eofflag} == "Y" ]]
	then
		eofformat=`echo "${SubJobRunPLSQL}" | grep "EOFFORMAT="`
		eval ${eofformat}
		eofformat="${EOFFORMAT}"
		iecho "eofformat = [${eofformat}]"
		echo "${eofformat}" >> ${plsqloutputpathtemp}
	fi

	mv ${plsqloutputpathtemp} ${plsqloutputpath}
	if [[ $? -ne 0 ]]
	then
		ErrorMessage="Error while edit move to real output [${plsqloutputpath}]"
		ierror "${ErrorMessage}"
		ErrorEmailSubject="${ErrorMessage}"
		ErrorEmailBody="${ErrorMessage}"
		SEND_EMAIL_FUNC "${emailtag}" "${ErrorEmailSubject}" "${ErrorEmailBody}" "${adminemail}"
		exit 1
	fi

	CountplsqloutputEditted=$(cat ${plsqloutputpath}|wc -l |tr -d [:blank:])
	iecho "CountplsqloutputEditted/CountAllRecord = [${CountplsqloutputEditted}/${CountAllRecord}]"
	iecho "Edit output success"
	iecho ">>> End Edit output"
fi
iecho "#### 07 - End run PLSQL"
}


F08_RunSFTP () {
if [[ $# -ne 5 ]]
then
	ierror "Example: $0 <Module> <FileName> <ServerName> <UserName> <ScpServerPath>"
	ErrorMessage="Error while calling F08_RunSFTP"
	ierror "${ErrorMessage}"
	ErrorEmailSubject="${ErrorMessage}"
	ErrorEmailBody="${ErrorMessage}"
	SEND_EMAIL_FUNC "${emailtag}" "${ErrorEmailSubject}" "${ErrorEmailBody}" "${adminemail}"
	exit 1
fi

Module="${1}"
FileName="${2}"
ScpServer="${3}"
ScpUser="${4}"
ScpServerPath="${5}"


iecho "#### 08 - Start SCP to [${Module}]"
iecho " FileName = [${FileName}]"
iecho " ScpServer = [${ScpServer}]"
iecho " ScpUser = [${ScpUser}]"
iecho " ScpServerPath = [${ScpServerPath}]"
if [[ -f ${FileName} ]]
then
	RetryCount=3
	CountSCP=1
	while [[ ${CountSCP} -le ${RetryCount} ]]
	do
		iecho ">> Start SCP [${CountSCP}/${RetryCount}]"
		scp ${FileName} ${ScpUser}@${ScpServer}:${ScpServerPath}
		ErrorCheck=$?
		iecho "ErrorCheck =[${ErrorCheck}]"
		if [[ ${ErrorCheck} -ne 0 ]]
		then
			if [[ ${CountSCP} -eq ${RetryCount} ]]
			then
				ErrorMessage="Error while SFTP to [${ScpServer}] (reach maxinum retry)"
				ierror "${ErrorMessage}"
				ErrorEmailSubject="${ErrorMessage}"
				ErrorEmailBody="${ErrorMessage}"
				SEND_EMAIL_FUNC "${emailtag}" "${ErrorEmailSubject}" "${ErrorEmailBody}" "${adminemail}"
				exit 1
			else
			 sleep 5
			 iecho ">>> End SCP [${CountSCP}/${RetryCount}]"
			fi
		else
			iecho ">>> End SCP [${CountSCP}/${RetryCount}]"
			break 1
		fi
	((CountSCP=CountSCP+1))
	done
else
	ErrorMessage="Not Found File [${FileName}] --> Cannot start scp"
	ierror "${ErrorMessage}"
	ErrorEmailSubject="${ErrorMessage}"
	ErrorEmailBody="${ErrorMessage}"
	SEND_EMAIL_FUNC "${emailtag}" "${ErrorEmailSubject}" "${ErrorEmailBody}" "${adminemail}"
	exit 1
fi

PLSQLOutputPrefix=$(echo ${FileName} | awk -F"/" '{print $NF}' | awk -F"." '{print $1}')
PLSQLOutputExt=$(echo ${FileName} |awk -F"/" '{print $NF}' | awk -F"." '{print $2}')
mv ${FileName} ${OutputArchivePath}/${PLSQLOutputPrefix}_${CurrentDateTime}.${PLSQLOutputExt}

if [[ $? -ne 0 ]]
then
	ErrorMessage="Error while moving [${FileName}] to [${OutputArchivePath}]"
	ierror "${ErrorMessage}"
	ErrorEmailSubject="${ErrorMessage}"
	ErrorEmailBody="${ErrorMessage}"
	SEND_EMAIL_FUNC "${emailtag}" "${ErrorEmailSubject}" "${ErrorEmailBody}" "${adminemail}"
else
	iecho "Move [${FileName}] to [${OutputArchivePath}] done"
fi

iecho ""
PURGE_LOG_FUNC ${OutputArchivePath} "${plsqloutputprefix}" "${plsqloutputext}" ${plsqloutputretention}
iecho "#### 08 - End SCP to [${Module}]"

}


F09_UpdateLastExtractDate () {
#-------------------------------------------------------
# Update Last Extract Date
#-------------------------------------------------------
iecho ""
iecho "#### 09 - Start Run update Last Extract Date in Table [${lastextracttable}]"
iecho ">>> Start Stamp Last Extract Date in Table [${lastextracttable}]"
iecho "Username [${user}]"
idebug "Password [${pass}]"
iecho "Oracle SID [${db_name}]"
iecho "lastextracttableschema = [${lastextracttableschema}]"
iecho "interfacename = [${interfacename}]"
iecho "LastExtractDateTime (get before create staging)= [${LastExtractDateTime}]"
UpdateLastExtractDate=$(sqlplus -s ${user}/${pass}@${db_name} << THEEND
set pagesize 0 feedback off verify off heading off echo off;
set SERVEROUTPUT ON

update ${lastextracttableschema}.${lastextracttable} stg 
set stg.LAST_EXTRACT_DATE = TO_DATE ('${LastExtractDateTime}','YYYYMMDD_HH24MISS')
WHERE INTERFACE_NAME = '${interfacename}';

COMMIT;

EXIT
THEEND
)

ORAErrorCount=$(echo ${UpdateLastExtractDate} | grep -c "ORA\-[0-9]")
ORAErrorCode=$(echo ${UpdateLastExtractDate} | grep "ORA\-[0-9]" | awk -F"ORA-" '{print $2}' |awk -F":" '{print $1}')
ORAErrorMsg=$(echo ${UpdateLastExtractDate} | grep "ORA\-[0-9]" | awk -F"ORA-" '{print $2}' |awk -F":" '{print $2}')
FullORAErrCode="ORA-${ORAErrorCode}"
if [[ ${ORAErrorCount} -ne 0 ]]
then
	ierror "ORAErrorCount = [${ORAErrorCount}]"
	ierror "FullORAErrCode = [${FullORAErrCode}]"
	ierror "ORAErrorMsg = [${ORAErrorMsg}]"
	ErrorMessage="Found Datebase Error ==> ORA-$(echo ${UpdateLastExtractDate}| awk -F"ORA-" '{print $2}' |awk -F":" '{print $1}')"
	ierror "${ErrorMessage}"
	ErrorEmailSubject="${ErrorMessage}"
	ErrorEmailBody="${ErrorMessage}"
	SEND_EMAIL_FUNC "${emailtag}" "${ErrorEmailSubject}" "${ErrorEmailBody}" "${adminemail}"
	exit 1
else
	iecho "Update Last Extract Date is Done"
fi
iecho "#### 09 - End Run update Last Extract Date in Table [${lastextracttable}]"
}

## -------------------------------------------------
## Start Main Program
## -------------------------------------------------

iecho "###--------------------------------------------------------------------"
iecho "### Start Main Program"
iecho "###--------------------------------------------------------------------"



	#-------------------------------------------------------
	# Check whether there is a script is running or not?
	#-------------------------------------------------------
	iecho ""
	iecho "#### 00 - Start Pre-Check previous process"
	current_pid=$$
	parent_pid=$(ps -o ppid= -p "${current_pid}")

	iecho "My Current PID: [${current_pid}]"
	iecho "My Parent PID: [${parent_pid}]"
	iecho ""
	pid=`ps -fu $(whoami) |grep -w "$(basename $0)" | grep -w "${JobName}" |grep -v grep | grep -v "${parent_pid}" |wc -l`
	if [[ $pid -gt 0 ]]
	then
		ps -fu $(whoami) |grep -w "$(basename $0)" | grep -w "${JobName}" |grep -v grep | grep -v "${parent_pid}" | while read FullProcessDesc
		do
			ierror "Running Process is: [${FullProcessDesc}]"
		done
		ierror ""
		ps -fu $(whoami) |grep -w "$(basename $0)" | grep -w "${JobName}" |grep -v grep | grep -v "${parent_pid}" | awk '{print $2}' | while read ProcessID
		do
			ierror "Found PID [${ProcessID}] is runnning"
		done
		# ps -fu $(whoami) |grep -w "$(basename $0)" |grep -v grep | grep -v "${parent_pid}" | awk '{print "Found PID "$2" is running"}'
		ErrorMessage="Exit 9: Found another batch extract data to salesforce is running."
		ierror "-----------"
		ierror "${ErrorMessage}"
		ierror "-----------"
		ErrorEmailSubject="${ErrorMessage}"
		ErrorEmailBody="${ErrorMessage}"
		SEND_EMAIL_FUNC "${emailtag}" "${ErrorEmailSubject}" "${ErrorEmailBody}" "${adminemail}"
		exit 9
	else
		iecho "There is no any previous process running"
		iecho ""
	fi
	iecho "#### 00 - End Pre-Check previous process"
	iecho ""

	# TODO: Need to remove before production
	sleep 180
	
	if [[ "${clearbkstgtblflag}" == "Y" ]]
	then
		F01_ClearBkStgTbl;
	else
		iecho ""
		iecho "01 - No need clear bk staging table"
		iecho ""
	fi

	if [[ "${bkstgtblflag}" == "Y" ]]
	then
		F02_BakStgTbl;
	else
		iecho ""
		iecho "02 - No need backup staging table"
		iecho ""
	fi

	if [[ "${clearstgtblflag}" == "Y" ]]
	then
		F03_ClearStgTbl;
	else
		iecho ""
		iecho "03 - No need clear staging table"
		iecho ""
	fi

	if [[ "${createstgtblflag}" == "Y" ]]
	then
		F04_CreateStgTbl;
	else
		iecho ""
		iecho "04 - No need create staging table"
		iecho ""
	fi

	if [[ "${NoRecord}" = "Y" ]]
	then
		iecho ""
		iecho "No record found in staging table will skip some steps"
		iecho ""
		if [[ "${dataextractionflag}" == "Y" ]] &&  [[ "${runplsqlflag}" == "Y" ]]
		then
			F07_RunPLSQL;
		else
			iecho ""
			iecho "07 - No need to run PLSQL"
			iecho ""
		fi

		if [[ "${sftpflag}" == "Y" ]]
		then
			F08_RunSFTP "Salesforce" "${plsqloutputpath}" "${sftpserver}" "${sftpuser}" "${sftppath}";
		else
			iecho ""
			iecho "08 - No need to run SFTP"
			iecho ""
		fi

		if [[ "${updatelastextractflg}" == "Y" ]]
		then
			F09_UpdateLastExtractDate;
		else
			iecho ""
			iecho "09 - No need to run Update Last Extract Date"
			iecho ""
		fi
		ErrorMessage="RunJobExtract from SBL to SF Successfully (no data)"
		iecho "-----------"
		iecho "${ErrorMessage}"
		iecho "-----------"
		ErrorEmailSubject="${ErrorMessage}"
		ErrorEmailBody="${ErrorMessage}"
		SEND_EMAIL_FUNC "${emailtag}" "${ErrorEmailSubject}" "${ErrorEmailBody}" "${adminemail}"
		iecho "###--------------------------------------------------------------------"
		iecho "### End Main Program"
		iecho "###--------------------------------------------------------------------"
		exit 98
	else
		if [[ "${createidxflag}" == "Y" ]]
		then
			F05_CreateIdx;
		else
			iecho ""
			iecho "05 - No need create index"
			iecho ""
		fi

		if [[ "${runanalyzetblflag}" == "Y" ]]
		then
			F06_RunAnalyzeTbl;
		else
			iecho ""
			iecho "06 - No need to analyze table"
			iecho ""
		fi

		if [[ "${runplsqlflag}" == "Y" ]]
		then
			F07_RunPLSQL;
		else
			iecho ""
			iecho "07 - No need to run PLSQL"
			iecho ""
		fi

		if [[ "${sftpflag}" == "Y" ]]
		then
			F08_RunSFTP "Salesforce" "${plsqloutputpath}" "${sftpserver}" "${sftpuser}" "${sftppath}";
		else
			iecho ""
			iecho "08 - No need to run SFTP"
			iecho ""
		fi

		if [[ "${updatelastextractflg}" == "Y" ]]
		then
			F09_UpdateLastExtractDate;
		else
			iecho ""
			iecho "09 - No need to run Update Last Extract Date"
			iecho ""
		fi
	fi
ErrorMessage="RunJobExtract from SBL to SF Successfully"
iecho "-----------"
iecho "${ErrorMessage}"
iecho "-----------"
ErrorEmailSubject="${ErrorMessage}"
ErrorEmailBody="${ErrorMessage}

----------------------------------------

No. of Record(s) = [$(printf "%'d" ${CountAllRecord})]

----------------------------------------
"
SEND_EMAIL_FUNC "${emailtag}" "${ErrorEmailSubject}" "${ErrorEmailBody}" "${adminemail}"
iecho "###--------------------------------------------------------------------"
iecho "### End Main Program"
iecho "###--------------------------------------------------------------------"


## -------------------------------------------------
## End Main Program
## -------------------------------------------------