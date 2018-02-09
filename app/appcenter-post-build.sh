
#!/usr/bin/env bash
#echo "Current branch is $APPCENTER_OUTPUT_DIRECTORY"
#curl -F "status=2" -F "ipa=@$APPCENTER_OUTPUT_DIRECTORY/MyApps.ipa" -H "X-HockeyAppToken: HOCKEYAPP_API_TOKEN" https://rink.hockeyapp.net/api/2/apps/HOCKEYAPP_APP_ID/app_versions/upload


# Get the app from the current build
if [ -f "$APPCENTER_OUTPUT_DIRECTORY/app-release.apk" ]
then
	echo " Release file found."
	# Call PRSS CodeSign For Andriod.
	HTTPRESPONSE=$(curl --write-out "HTTPSTATUS:%{http_code}" -X POST --header 'Content-Type: multipart/form-data; boundary=----WebKitFormBoundary7MA4YWxkTrZu0gW' --header 'Accept: application/json' -F "apk=@$APPCENTER_OUTPUT_DIRECTORY/app-release.apk"  'https://andriodprsscodesign-dev.azurewebsites.net/api/HttpTriggerCSharp1?code=dSiBY8MLi48nS/UULIVmmnrmcjyDZYYRYfDtbxLNFa8Wry3pQ0rMrA==')
	
	# extract the body
	HTTP_BODY=$(echo $HTTPRESPONSE | sed -e 's/HTTPSTATUS\:.*//g')

	# extract the status
	HTTP_STATUS=$(echo $HTTPRESPONSE | tr -d '\n' | sed -e 's/.*HTTPSTATUS://')

	#Check for 200 response and get JobID
	if "$HTTP_STATUS" -eq 200
	then
	 	echo "PRSS Job Submitted with Job ID " + $HTTP_BODY
		# Add delay of 5 mins for getting app codesign and then try getting Signed Package
		
	 else
	 
	 fi
else
	echo " not found."
fi


# Upload Signed bit if code sign passed.
