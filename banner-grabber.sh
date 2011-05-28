#!/bin/bash
### This source is free for anyone to use at any time for any purpose
### Copyleft 2010 Matt Criswell

#We get our domain to test
echo "Enter a domain: "
read theDomain
theDomain=$1

#echo the domain for sanity purposes
echo "$theDomain ..."

#We get the highest priority MX record
theHost=`dig +short $theDomain mx | sort -k1 | awk '{print $2}' | head -1 | sed 's/.$//g'`

#Grab a time stamp, make a tmp file
timeStamp=`date +%s`
tmpFile=/tmp/smtpbanner.tmp.$timeStamp
touch $tmpFile

#initialize variables
lineCount=0
loopCount=0
gotBanner=0

while [ true ]
	do
		# hit port 25, wait 9 seconds before dropping
		# we wait in case there is a banner delay
		nc -w 9 $theHost 25 > $tmpFile
		lineCount=`grep 220 $tmpFile | wc -l | awk '{print $1}'`
		let "loopCount+=1"
		echo "We have tried $loopCount times."
		if [ $lineCount != 0 ]
		    then
			#if we have gotten a line that should have a banner bust
			gotBanner=1
			break;
		fi
		if [ $loopCount -gt 3 ]
		   then
			# Fail out if we can't get something after 3 times bust
			echo "Failed to get SMTP banner"
			gotBanner=0
			break;
		fi
	done

#If we have the banner, print what we think it is to the screen
if [ $gotBanner == 1 ]
   then
	smtpBanner=`grep 220 $tmpFile | awk '{print $2}'`
	echo "In theory, the SMTP banner for $theHost is $smtpBanner"
fi

rm $tmpFile
