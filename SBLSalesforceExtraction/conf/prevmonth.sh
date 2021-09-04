#!/bin/ksh

Zero="0"
YearMonthInput=${1}
if [[ ${#YearMonthInput} -ne 6 ]]
then
	echo "ERR: Invalid input"
	echo "EXAMPLE: $0 YYYYMM"
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

if [[ "${MonthInput}" == "01" ]]
then
	PrevMonth="12"
	((PrevYear=YearInput-1))
else
	((PrevMonth=MonthInput-1))
	PrevYear=${YearInput}
fi

if [[ ${#PrevMonth} -ne 2 ]]
then
	PrevMonth=$(echo "${Zero}${PrevMonth}")
fi
echo "${PrevYear}${PrevMonth}"

