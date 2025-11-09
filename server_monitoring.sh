#!/bin/bash
# Purpose: Debug server load
# Author:  Muhammad Hamza Zaheer
# Usage: wget https://raw.githubusercontent.com/hamza0495/CW-Automation-Scripts/server_monitoring.sh

#!/bin/bash

LOG_FILE="/tmp/server_diagnostic_$(date +%F_%H-%M).log"

exec > >(tee -a "$LOG_FILE") 2>&1

echo "👋 Hi, how may I help you?"
echo ""
echo "1. High CPU/RAM Usage on the Server"
echo "2. Applications/Websites taking ages to load"
echo "3. Experiencing an issue on a specific app?"
echo "4. Server keeps going down (OOM / crash check)"
echo ""

read -p "Enter option [1-4]: " option

case $option in
  1)
    echo ""
    echo "=============================="
    echo " Checking High CPU/RAM Usage "
    echo "=============================="

    echo ""
    echo ">>> Checking Web Traffic Stats (last 1h)"
    for A in $(ls -l /home/master/applications/ | awk '/^d/ {print $NF}'); do
      echo ""
      echo "Application: $A"
      awk 'NR==1 {print "URL: " substr($NF, 1, length($NF)-1)}' /home/master/applications/$A/conf/server.nginx
      sudo apm -s "$A" traffic -l 1h
    done

    echo ""
    echo ">>> Checking PHP Stats (last 1h)"
    for A in $(ls -l /home/master/applications/ | awk '/^d/ {print $NF}'); do
      echo ""
      echo "Application: $A"
      awk 'NR==1 {print "URL: " substr($NF, 1, length($NF)-1)}' /home/master/applications/$A/conf/server.nginx
      sudo apm -s "$A" php -l 1h
    done

    echo ""
    echo ">>> Checking MySQL Stats (last 1h)"
    for A in $(ls -l /home/master/applications/ | awk '/^d/ {print $NF}'); do
      echo ""
      echo "Application: $A"
      awk 'NR==1 {print "URL: " substr($NF, 1, length($NF)-1)}' /home/master/applications/$A/conf/server.nginx
      sudo apm -s "$A" mysql -l 1h
    done

    echo ""
    echo ">>> Checking for OOM (Out of Memory) Events"
    tail -n 100 /var/log/syslog | grep 'OOM' || echo "No OOM events found."
    ;;

  3)
    read -p "Enter Application Name: " app
    echo ""
    echo "🔍 Checking $app performance (APM & logs)..."

    if [ -d "/home/master/applications/$app" ]; then
      awk 'NR==1 {print "URL: " substr($NF, 1, length($NF)-1)}' /home/master/applications/$app/conf/server.nginx
      sudo apm -s "$app" traffic -l 1h
      sudo apm -s "$app" php -l 1h
      sudo apm -s "$app" mysql -l 1h
    else
      echo "❌ Application '$app' not found under /home/master/applications/"
    fi
    ;;
    
  4)
    echo ""
    echo ">>> Checking for OOM (Out of Memory) Events"
    tail -n 200 /var/log/syslog | grep 'OOM' || echo "No OOM events found."
    ;;
    
  2)
    echo "This option will be added next (worker exhaustion check)."
    ;;
    
  *)
    echo "Invalid option selected."
    ;;
esac

echo ""
echo "Logs saved to: $LOG_FILE"
