#!/bin/bash
# Purpose: Debug server load
# Author:  Muhammad Hamza Zaheer
# Usage: wget https://raw.githubusercontent.com/hamza0495/CW-Automation-Scripts/server_monitoring.sh

#!/bin/bash

echo "Hi, how may I help you?"
echo "1. High CPU/RAM Usage on the Server"
echo "2. Applications/Website taking ages to load"
echo "3. Are you experiencing some issue on specific app?"
read -p "Please enter your option (1-3): " option

case $option in
  1)
    echo ""
    echo "=============================="
    echo "Checking High CPU/RAM Usage..."
    echo "=============================="

    echo ""
    echo ">>> Checking Web Traffic Stats (last 1h)"
    for A in $(ls -l /home/master/applications/ | awk '/^d/ {print $NF}'); do
      echo ""
      echo "Application: $A"
      awk 'NR==1 {print "URL: " substr($NF, 1, length($NF)-1)}' /home/master/applications/$A/conf/server.nginx
      sudo apm -s $A traffic -l 1h
    done

    echo ""
    echo ">>> Checking PHP Stats (last 1h)"
    for A in $(ls -l /home/master/applications/ | awk '/^d/ {print $NF}'); do
      echo ""
      echo "Application: $A"
      awk 'NR==1 {print "URL: " substr($NF, 1, length($NF)-1)}' /home/master/applications/$A/conf/server.nginx
      sudo apm -s $A php -l 1h
    done

    echo ""
    echo ">>> Checking MySQL Stats (last 1h)"
    for A in $(ls -l /home/master/applications/ | awk '/^d/ {print $NF}'); do
      echo ""
      echo "Application: $A"
      awk 'NR==1 {print "URL: " substr($NF, 1, length($NF)-1)}' /home/master/applications/$A/conf/server.nginx
      sudo apm -s $A mysql -l 1h
    done

    echo ""
    echo ">>> Checking for OOM (Out of Memory) Events"
    tail -n 100 /var/log/syslog | grep 'OOM' || echo "No OOM events found in recent logs."

    ;;
  2)
    echo "This option will be implemented later."
    ;;
  3)
    echo "This option will be implemented later."
    ;;
  *)
    echo "Invalid option selected."
    ;;
esac
