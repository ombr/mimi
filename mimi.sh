#!/bin/bash
token=$(curl -s -X POST "https://api.netatmo.com/oauth2/token" -H "Content-Type: application/x-www-form-urlencoded;charset=UTF-8" -d "grant_type=refresh_token&refresh_token=$REFRESH_TOKEN&client_id=$CLIENT_ID&client_secret=$CLIENT_SECRET" | jq -r ".access_token")
out_of_sight=$(curl -s -X GET "https://api.netatmo.com/api/homestatus?home_id=$HOME_ID" -H "accept: application/json" -H "Authorization: Bearer $token" | jq ".body.home.persons[] | select( .id | contains(\"$PERSON_ID\")) | .out_of_sight")
# out_of_sight=$(curl -s -X GET "https://api.netatmo.com/api/homestatus?home_id=$HOME_ID" -H "accept: application/json" -H "Authorization: Bearer $token" | jq ".body.home.persons[0].out_of_sight")
echo "OUT_OF_SIGHT=$out_of_sight"
if [ "$out_of_sight" = "true" ]; then
  echo "ERROR !"
  exit 1
else
  curl -s -d "m=presence_ok" "https://nosnch.in/$DEADMANSNITCH_ID"
  exit 0;
fi;
