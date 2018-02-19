#!/usr/bin/env bash
#echo "Current branch is $APPCENTER_OUTPUT_DIRECTORY"
#curl -F "status=2" -F "ipa=@$APPCENTER_OUTPUT_DIRECTORY/MyApps.ipa" -H "X-HockeyAppToken: HOCKEYAPP_API_TOKEN" https://rink.hockeyapp.net/api/2/apps/HOCKEYAPP_APP_ID/app_versions/upload


# Get the app from the current build
if [ -f "$APPCENTER_OUTPUT_DIRECTORY/app-release.apk" ]
then
	echo " Release file found."
	# Calculate hash and file size 8
	shasum -a 256 $APPCENTER_OUTPUT_DIRECTORY/app-release.apk
	HASH=$(shasum -a 256 $APPCENTER_OUTPUT_DIRECTORY/app-release.apk | awk '{print $1}')
	echo $HASH
	FILESIZEINBYTES=$(wc -c $APPCENTER_OUTPUT_DIRECTORY/app-release.apk | awk '{print $1}')
	echo $FILESIZEINBYTES
	
	# Call PRSS CodeSign For Andriod.adding esrpclient call
	HTTP_RESPONSE_CSREQUEST=$(curl --write-out "HTTPSTATUS:%{http_code}" -X POST -F "apkfile=@$APPCENTER_OUTPUT_DIRECTORY/app-release.apk" -H 'Content-Type: multipart/form-data; charset=utf-8' 'https://andriodprsscodesign-dev.azurewebsites.net/api/HttpTriggerCSharp1?code=dSiBY8MLi48nS/UULIVmmnrmcjyDZYYRYfDtbxLNFa8Wry3pQ0rMrA==&Size=$FILESIZEINBYTES&Hash=$HASH')
	
	# extract the body as json format
	HTTP_BODY=$(echo $HTTP_RESPONSE_CSREQUEST | sed -e 's/HTTPSTATUS\:.*//g') 
	
	# extract the status
	HTTP_STATUS=$(echo $HTTP_RESPONSE_CSREQUEST | tr -d '\n' | sed -e 's/.*HTTPSTATUS://')

	#Check for 200 response and get JobID
	if [ $HTTP_STATUS -eq 200 ]
	then
		#| jq '.JobID'
		#HTTP_BODY=$HTTP_BODY 
	 	echo "PRSS Job Submitted with Job ID " + $HTTP_BODY#
		echo "Waiting for response from PRSS"
		# Add delay of 5 mins for getting app codesign and then try getting Signed Package
		sleep 30s
		HTTP_RESPONSE_CSSTATUS=$(curl --write-out "HTTPSTATUS:%{http_code}" -o "$APPCENTER_OUTPUT_DIRECTORY/app-releasesigned.apk" 'https://andriodprsscodesign-dev.azurewebsites.net/api/HttpGetPRSSCodeSignStatus?code=Of/Sg0rbFPBmszE6J0PxVzZV1n4M7SXtjiae9AVcMJWVsEoZHUQHdg==&JobID=3412')
		# extract the body
		HTTP_BODY=$(echo $HTTP_RESPONSE_CSSTATUS | sed -e 's/HTTPSTATUS\:.*//g')
		# extract the status updated12
		HTTP_STATUS=$(echo $HTTP_RESPONSE_CSSTATUS | tr -d '\n' | sed -e 's/.*HTTPSTATUS://')
		if [ $HTTP_STATUS -eq 200 ]
		then
			echo "Received Signed Package." + $HTTP_STATUS
		else
			echo "Failure occured." + $HTTP_STATUS + $HTTP_BODY
		fi
	 else
	 	echo "PRSS Job not submitted successfully" + $HTTP_BODY
	 fi
else
	echo " not found."
fi


# Upload Signed bit if code sign passed.
