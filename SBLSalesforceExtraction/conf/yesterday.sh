#!/bin/ksh

#
# Script to calculate yesterday's date with custom output date format
#
# Author: ibrahim - www.digitalinternals.com
#

  # default output format
  defaultof="%Y%m%d"

  # check for input format, else use default format,
  # refer to 'man date' for help on format
  # script only supports %Y %m %d at the moment
  of=$defaultof
  ##[ $# -eq 1 ] && of="$1"

  # get today's date
  ## get value from $1
	if [ $# -eq 1 ]
	then
		if [ ${#1} -ne 8 ]
		then
			echo "Plese input format: $0 YYYYMMDD"
			echo "EXAMPLE: $0 20110815"
			exit 1
		else
			y=`echo $1|cut -c1-4`
			m=`echo $1|cut -c5-6`
			d=`echo $1|cut -c7-8`
		fi
	elif [ $# -eq 0 ]
	then
	  eval "`date +'y=%Y m=%m d=%d'`"
	else
		echo "invalid format"
		echo "Plese input format: $0 YYYYMMDD"
		echo "EXAMPLE: $0 20110815"
		exit 1
	fi

  # subtract 1 day
  d=`expr $d - 1`
  if [ $d -eq 0 ];  then
    # if day is 0, subtract month by 1
    m=`expr $m - 1`
    if [ $m -eq 0 ]; then
      # if month is 0, subtract year and set month to 12
      m=12
      y=`expr $y - 1`
    fi

    # set day depending on value of month
    d=31
    if [ $m -eq 4 ] || [ $m -eq 6 ] || [ $m -eq 9 ] || [ $m -eq 11 ] ; then
      d=30
    fi

    # check for leap year
    if [ $m -eq 2 ]; then
      d=28
      leap1=`expr $y % 4`
      leap2=`expr $y % 100`
      leap3=`expr $y % 400`
      if [ $leap1 -eq 0 ] ; then
        if [ $leap2 -gt 0 ] || [ $leap3 -eq 0 ] ; then
          d=29
        fi
      fi
    fi
  fi

  #Solaris date does not accept -d
  #date -d "$y-$m-$d" +"$of"

  eval "y=`expr $y + 0` m=`expr $m + 0` d=`expr $d + 0`"
  eval "y=`printf "%04d" $y` m=`printf "%02d" $m` d=`printf "%02d" $d`"
  echo "$of" | sed -e "s/%Y/$y/" -e s/%m"/$m/" -e "s/%d/$d/"
