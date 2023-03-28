#!/bin/bash
token=$(curl -s -X POST "https://api.netatmo.com/oauth2/token" -H "Content-Type: application/x-www-form-urlencoded;charset=UTF-8" -d "grant_type=refresh_token&refresh_token=$REFRESH_TOKEN&client_id=$CLIENT_ID&client_secret=$CLIENT_SECRET" | jq -r ".access_token")
last_seen=$(curl -s -X GET "https://api.netatmo.com/api/homestatus?home_id=$HOME_ID" -H "accept: application/json" -H "Authorization: Bearer $token" | jq ".body.home.persons[] | select( .id | contains(\"$PERSON_ID\")) | .last_seen")
# out_of_sight=$(curl -s -X GET "https://api.netatmo.com/api/homestatus?home_id=$HOME_ID" -H "accept: application/json" -H "Authorization: Bearer $token" | jq ".body.home.persons[0].out_of_sight")
# curl -s -X GET "https://api.netatmo.com/api/getevents?home_id=$HOME_ID" -H "accept: application/json" -H "Authorization: Bearer $token" | jq "."
# curl -s -X GET "https://api.netatmo.com/api/homestatus?home_id=$HOME_ID" -H "accept: application/json" -H "Authorization: Bearer $token" | jq ".body.home.persons"
current_date=$(date +%s)
elapsed=$(($current_date-$last_seen))
echo "last_seen=$last_seen elapsed=$elapsed"
if [ "$(date +%H)" -lt 8 ]; then
  echo "to_early"
  curl -d "m=to_early_no_check $elapsed $last_seen" "https://nosnch.in/$DEADMANSNITCH_ID"
  exit 0;
fi;
if [ "$(date +%H)" -gt 22 ]; then
  echo "to_late"
  curl -d "m=to_late_no_check $elapsed $last_seen" "https://nosnch.in/$DEADMANSNITCH_ID"
  exit 0;
fi;
if [ "$elapsed" -gt "$((6*60*60))" ]; then
  echo "ERROR !"
  exit 1
fi
curl -d "m=$elapsed $last_seen" "https://nosnch.in/$DEADMANSNITCH_ID"
exit 0;
