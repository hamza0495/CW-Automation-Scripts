#!/bin/bash

echo "👋 Hi, how may I help you today?"
read -p "Is the server experiencing High CPU/RAM usage? (yes/no): " high_usage

if [ "$high_usage" == "yes" ]; then
    echo ""
    echo "🔍 Checking system usage..."
    # Your CPU/RAM check commands here
else
    echo ""
    echo "Skipping system usage check..."
fi

# Loop to allow user to re-run or quit
while true; do
    read -p "Would you like to continue checking? (press 'q' to quit or Enter to continue): " user_input

    if [[ "$user_input" == "q" || "$user_input" == "Q" ]]; then
        echo "Exiting diagnostics. 👋"
        break
    fi

    echo ""
    echo "Continuing diagnostic checks..."

    # Now prompt for duration
    read -p "Enter duration (e.g., 30min, 1h, 3h): " duration

    # Web traffic stats
    for A in $(ls -l /home/master/applications/ | awk '/^d/ {print $NF}'); do
        echo $A && awk 'NR==1 {print substr($NF, 1, length($NF)-1)}' /home/master/applications/$A/conf/server.nginx
        apm -s "$A" traffic -l "$duration"
    done

    # PHP stats
    for A in $(ls -l /home/master/applications/ | awk '/^d/ {print $NF}'); do
        echo $A && awk 'NR==1 {print substr($NF, 1, length($NF)-1)}' /home/master/applications/$A/conf/server.nginx
        apm -s "$A" php -l "$duration"
    done

    # MySQL stats
    for A in $(ls -l /home/master/applications/ | awk '/^d/ {print $NF}'); do
        echo $A && awk 'NR==1 {print substr($NF, 1, length($NF)-1)}' /home/master/applications/$A/conf/server.nginx
        apm -s "$A" mysql -l "$duration"
    done

done
