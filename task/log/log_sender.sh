#!/bin/bash

ADDRESS="127.0.0.1"
PORT="2285"

weather_states=("sunny" "rainy" "cloudy" "stormy" "foggy" "windy")

generate_random_longint() {
   echo $(( RANDOM + 1000000000 ))
}

generate_random_shortint() {
   echo $(( RANDOM % 100 + 1 ))
}

while true; do
   timestamp=$(date +"%Y-%m-%d %H:%M:%S")
   population=$(generate_random_longint)
   shortint=$(generate_random_shortint)
   men=$((population / 2))
   women=$((population / shortint))
   hOffset=$((population * 2))
   vOffset=100

   weather_index=$(( RANDOM % ${#weather_states[@]} ))
   weather="${weather_states[$weather_index]}"

   json_message="{\"iran\":{\"city\":\"tehran\",\"population\":$population,\"men\":$men,\"women\":$women,\"hOffset\":$hOffset,\"vOffset\":$vOffset,\"weather\":\"$weather\"}}"

   log_message="myfirstlog : $timestamp hello devops : $json_message"

   echo "$log_message" 

   logger -p user.info -n "$ADDRESS" -P "$PORT" "$log_message"

   sleep 60
done

