#!/bin/ksh

if [[ $# -ne 2 ]]
then
	echo "ERR: Invalid input"
	echo "EXAMPLE: $0 YYYYMM <Number of NextMonth>"
	echo "EXAMPLE: $0 201306 1"
	exit 1
fi
Zero="0"
YearMonthInput=${1}
NumberofNextMonth=${2}
if [[ ${#YearMonthInput} -ne 6 ]]
then
	echo "ERR: Invalid input"
	echo "EXAMPLE: $0 YYYYMM <Number of NextMonth>"
	echo "EXAMPLE: $0 201306 1"
	exit 1
fi
YearInput=$(echo ${YearMonthInput} |cut -c1-4)
MonthInput=$(echo ${YearMonthInput} |cut -c5-6)
for MonthTemp in 01 02 03 04 05 06 07 08 09 10 11 12
do
	if [[ "${MonthInput}" == "${MonthTemp}" ]]
	then
		FoundFlag="Y"
		break
	else
		FoundFlag="N"
	fi
done

if [[ "${FoundFlag}" != "Y" ]]
then
	echo "ERR: Invalid month (month should be \"01 02 03 04 05 06 07 08 09 10 11 12\")"
	echo "EXAMPLE: $0 YYYYMM"
	exit 1
fi

i=1
MonthInputTemp=${MonthInput}
YearInputTemp=${YearInput}
while [[ ${i} -le ${NumberofNextMonth} ]]
do
	if [[ "${MonthInputTemp}" == "12" ]]
	then
		NextMonth="1"
		((NextYear=YearInputTemp+1))
	else
		((NextMonth=MonthInputTemp+1))
		NextYear=${YearInputTemp}
	fi

	if [[ ${#NextMonth} -ne 2 ]]
	then
		NextMonth=$(echo "${Zero}${NextMonth}")
	fi
MonthInputTemp=${NextMonth}
YearInputTemp=${NextYear}
((i=i+1))
done
echo "${NextYear}${NextMonth}"
