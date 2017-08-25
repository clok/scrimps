#!/bin/bash
df -h | sed "1 d" | while read line; do
  # 0:device 1:size 2:used 3:avail 4:per_used 5:mount
  IFS=' ' read -a myarray <<< "$line"
  echo "${myarray[0]} ${myarray[5]} - ${myarray[4]::-1}"
  # docker.container.disk.in_use
  currenttime=$(date +%s)
  curl  -X POST -H "Content-type: application/json" \
  -d "{ \"series\" :
           [{\"metric\":\"test.disk\",
            \"points\":[[$currenttime, ${myarray[4]::-1}]],
            \"type\":\"gauge\",
            \"tags\":[\"device:${myarray[0]}\",\"mount:${myarray[5]}\"]}
          ]
      }" \
  'DATADOG_WEBHOOK'
done
