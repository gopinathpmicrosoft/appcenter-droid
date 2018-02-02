
#!/usr/bin/env bash
#echo "Current branch is $APPCENTER_OUTPUT_DIRECTORY"
#curl -F "status=2" -F "ipa=@$APPCENTER_OUTPUT_DIRECTORY/MyApps.ipa" -H "X-HockeyAppToken: HOCKEYAPP_API_TOKEN" https://rink.hockeyapp.net/api/2/apps/HOCKEYAPP_APP_ID/app_versions/upload


# Get the app from the current build
if [ -f "$APPCENTER_OUTPUT_DIRECTORY/app-release.apk" ]
then
	echo " found."
else
	echo " not found."
fi

# Call PRSS CodeSign For Andriod.
curl -X POST --header 'Content-Type: multipart/form-data; boundary=----WebKitFormBoundary7MA4YWxkTrZu0gW' --header 'Accept: application/json' -F "apk=@$APPCENTER_OUTPUT_DIRECTORY/app-release.apk"  'https://andriodprsscodesign-dev.azurewebsites.net/api/HttpTriggerJS1'

# Upload Signed bit if code sign passed.
