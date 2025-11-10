#!/bin/bash

echo "👋 Hi, how may I help you today?"
read -p "Is the server experiencing High CPU/RAM usage? (yes/no): " cpu_issue

if [[ "$cpu_issue" =~ ^[Yy][Ee][Ss]$ || "$cpu_issue" =~ ^[Yy]$ ]]; then
    echo ""
    read -p "Enter the duration you’d like to check (e.g. 30m, 1h, 6h, 1d): " duration
    echo ""
    echo "📊 Fetching APM data for duration: $duration"
    echo ""

    # Web Traffic stats
    echo ">>> Checking Web Traffic Stats (past $duration)"
    for A in $(ls -l /home/master/applications/ | awk '/^d/ {print $NF}'); do
        echo ""
        echo "Application: $A"
        awk 'NR==1 {print "URL: " substr($NF, 1, length($NF)-1)}' /home/master/applications/$A/conf/server.nginx
        sudo apm -s "$A" traffic -l "$duration"
    done

    # PHP stats
    echo ""
    echo ">>> Checking PHP Stats (past $duration)"
    for A in $(ls -l /home/master/applications/ | awk '/^d/ {print $NF}'); do
        echo ""
        echo "Application: $A"
        awk 'NR==1 {print "URL: " substr($NF, 1, length($NF)-1)}' /home/master/applications/$A/conf/server.nginx
        sudo apm -s "$A" php -l "$duration"
    done

    # MySQL stats
    echo ""
    echo ">>> Checking MySQL Stats (past $duration)"
    for A in $(ls -l /home/master/applications/ | awk '/^d/ {print $NF}'); do
        echo ""
        echo "Application: $A"
        awk 'NR==1 {print "URL: " substr($NF, 1, length($NF)-1)}' /home/master/applications/$A/conf/server.nginx
        sudo apm -s "$A" mysql -l "$duration"
    done

    # Ask user if they want to continue
    echo ""
    read -p "Would you like to continue checking? (press 'q' to quit or Enter to continue): " choice
    if [[ "$choice" == "q" || "$choice" == "Q" ]]; then
        echo "👋 Exiting... Have a great day!"
        exit 0
    else
        echo ""
        echo "Continuing diagnostic checks..."
        # (You can add next diagnostic sections here later)
