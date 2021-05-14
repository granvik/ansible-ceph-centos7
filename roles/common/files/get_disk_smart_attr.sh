#!/bin/bash

while [[ $# > 1 ]]
do
	key="$1"
	case $key in
	    -g|--get)
		    GET="$2"
	    shift
	    ;;
	    -d|--disk)
		    DISK="$2"
	    shift
	    ;;
	    -a|--attr)
	    ATTR="$2"
	    shift
	    ;;
	    *)
            # unknown option
	    ;;
	esac
	shift
done

if [ "${GET}" = "drives" ]
then
	for d in $(ls -1 /dev/disk/by-id|grep ^ata|grep -v part); 
	do 
		z=$(smartctl -d sat -i /dev/disk/by-id/$d|grep "SMART support is: Enabled"); 
		if [ -n "$z" ]; 
		then 
			echo "/dev/disk/by-id/$d"; 
		fi; 
	done;
fi;

if [ "${GET}" = "list" ] 
then
	for d in `ls -1 /dev/sg?`; 
	do 
		z=$(smartctl -d sat -i $d|grep "SMART support is: Enabled"); 
		if [ -n "$z" ] 
		then 
			echo $d; 
		fi; 
	done;
fi;

if [ "${GET}" = "raw_value" ] 
then
	smartctl -d sat -A ${DISK} | grep "^\s*${ATTR} " | tr -s ' ' | sed "s/^[[:space:]]*\(.*\)[[:space:]]*$/\1/" | cut -d " " -f 10
fi

if [ "${GET}" = "value" -o "${GET}" = "rel_value" ] 
then
	smartctl -d sat -A ${DISK} | grep "^\s*${ATTR} " | tr -s ' ' | sed "s/^[[:space:]]*\(.*\)[[:space:]]*$/\1/" | awk '{print $4}'
fi

if [ "${GET}" = "thresh" ] 
then
	smartctl -d sat -A ${DISK} | grep "^\s*${ATTR} " | tr -s ' ' | sed "s/^[[:space:]]*\(.*\)[[:space:]]*$/\1/" | awk '{print $6}'
fi

if [ "${GET}" = "info" ] 
then
	smartctl -d sat -i ${DISK}|grep "${ATTR}"| sed "s/.*:\s*//g"
fi

if [ "${GET}" = "errors" ] 
then

	S=`smartctl -d sat -l error ${DISK}|grep "No Errors Logged"`
	if [ "$S" != "No Errors Logged" ]
	then
		smartctl -d sat -l error ${DISK}
	fi
#echo "err"
fi

if [ "${GET}" = "when_failed" ]
then
	F=""
	r=$(smartctl -d sat -A /dev/sda | grep -e "^\s*[0-9][0-9]*"|awk '{print $9}')
	for i in $r
	do
		if [ $(echo -n $i|sed 's/$//g'|wc -m) -gt 1 ]
		then
			F=${i}
		fi
	done
	echo -n $F
fi

