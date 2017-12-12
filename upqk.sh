#!/bin/bash
# Enter user credentials for authentication
echo -n "Enter your iHealth user name (Email Address): "
read  USER_ID
echo -n "Enter your iHealth password: "
#read -s USER_SECRET
#echo "$USER_SECRET" | sed 's/./*/g'
p=''
while true; do
IFS=
read -s -n1 CHAR
HEX=$(xxd -pu <<< "$CHAR")
case "$HEX" in
        0a)   echo -e "\r\r"
                break;;
        7f0a) echo -ne "\b \b"
              p=$(echo $p | sed -e 's/.$//');;
         *)    echo -n "*"
               p=$p$CHAR
esac
done
USER_SECRET=$p
# Read location of qkview and location to store cookie
echo -n "Enter the path to the qkview and location to store cookie: "
read LOCATION
# authenticate with iHealth API and create session cookie
curl -s -H"Content-type: application/json" --user-agent "MyGreatiHealthClient" --cookie-jar $LOCATION/qkview_cookie -o - --data-ascii "{\"user_id\": \"$USER_ID\", \"user_secret\": \"$USER_SECRET\"}" https://api.f5.com/auth/pub/sso/login/ihealth-api > /dev/null
# Read in Variables to upload Qkview
echo -n "Enter the Qkview File Name: "
read QKVIEW_FILE_NAME
echo -n "Enter the Support Service Request Number: "
read F5_SUPPORT_CASE
echo -n "Enter description of the Case: "
read DESCRIPTION
# Upload Qkview
curl -s -H "Accept: application/vnd.f5.ihealth.api" --user-agent "debbie-api" --cookie $LOCATION/qkview_cookie --cookie-jar $LOCATION/qkview_cookie -o - -F qkview=@$LOCATION/$QKVIEW_FILE_NAME -F 'visible_in_gui=True' -F "f5_support_case=$F5_SUPPORT_CASE" -F "description=$DESCRIPTION" https://ihealth-api.f5.com/qkview-analyzer/api/qkviews
# Delete cookie after Qkview upload
\rm $LOCATION/qkview_cookie
