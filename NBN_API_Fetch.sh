#!/bin/bash

#Set working directory to the directory that the script is located
cd "$(dirname "$0")"

#Get NBN JSON data, convert to multi-line format and store in a veriable
NBN_Data=`curl -s --referer https://www.nbnco.com.au/ https://places.nbnco.net.au/places/v2/details/$1 | python3 -m json.tool`

#Parse required data
New_altReasonCode=`grep "altReasonCode" <<< "$NBN_Data" | xargs` 
New_techChangeStatus=`grep "techChangeStatus" <<< "$NBN_Data" | xargs` 
New_programType=`grep "programType" <<< "$NBN_Data" | xargs` 
New_targetEligibilityQuarter=`grep "targetEligibilityQuarter" <<< "$NBN_Data" | xargs` 
New_techFlip=`grep "techFlip" <<< "$NBN_Data" | xargs` 

#By default, don't send an email
Send_Email=false

#Check if the file exists that stores the previous values of variables
if test -f "$3_NBN_Data.txt"; then
    #Read previous values from file
	Old_altReasonCode=`grep "altReasonCode" $3_NBN_Data.txt | xargs` 
	Old_techChangeStatus=`grep "techChangeStatus" $3_NBN_Data.txt | xargs` 
	Old_programType=`grep "programType" $3_NBN_Data.txt | xargs` 
	Old_targetEligibilityQuarter=`grep "targetEligibilityQuarter" $3_NBN_Data.txt | xargs` 
	Old_techFlip=`grep "techFlip" $3_NBN_Data.txt | xargs` 
	
	#Get the day of the week
	DOW=$(date +%u)
	
	#If any values have changed, send an email with new values
	if [[ $Old_altReasonCode != $New_altReasonCode || $Old_techChangeStatus != $New_techChangeStatus || $Old_programType != $New_programType || $Old_targetEligibilityQuarter != $New_targetEligibilityQuarter || $Old_techFlip != $New_techFlip ]]; then
		#Send email with data
		Send_Email=true
		Subject_Text="$3 NBN API data has changed!"
	elif [[ $DOW == 5 && $4 == "Yes" ]]; then
		#Send email regardless of change of values if current day is Friday and input 4 is Yes	
		Send_Email=true
		Subject_Text="$3 NBN API Query for `date`"
	fi
else
	#Send email with initial data
	Send_Email=true
	Subject_Text="$3 NBN API Query for `date`"
fi

#Write variables to file even if nothing has changed (to change modified date and time)
echo $New_altReasonCode > $3_NBN_Data.txt
echo $New_techChangeStatus >> $3_NBN_Data.txt
echo $New_programType >> $3_NBN_Data.txt
echo $New_targetEligibilityQuarter >> $3_NBN_Data.txt
echo $New_techFlip >> $3_NBN_Data.txt

#Send email if required
if [ "$Send_Email" = true ] ; then
ssmtp -t << EOF
From: NBN Fetch Script
To: $2
Subject: $Subject_Text

$New_altReasonCode
$New_techChangeStatus
$New_programType
$New_targetEligibilityQuarter
$New_techFlip
EOF
fi