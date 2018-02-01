#!/usr/bin/env bash
echo "Current branch is $APPCENTER_OUTPUT_DIRECTORY"
curl -F "status=2" -F "ipa=@$APPCENTER_OUTPUT_DIRECTORY/MyApps.ipa" -H "X-HockeyAppToken: HOCKEYAPP_API_TOKEN" https://rink.hockeyapp.net/api/2/apps/HOCKEYAPP_APP_ID/app_versions/upload
