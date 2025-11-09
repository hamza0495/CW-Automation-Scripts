#!/bin/bash
# Purpose: Debug server load
# Author:  Muhammad Hamza Zaheer
# Usage: wget https://raw.githubusercontent.com/hamza0495/CW-Automation-Scripts/server_monitoring.sh

set -euo pipefail

LOGFILE="/home/master/server_diagnostic_$(date +%F_%H-%M).log"
exec > >(tee -a "$LOGFILE") 2>&1

echo -e "\n👋 Hi, how may I help you?\n"
echo "1. High CPU/RAM Usage on the Server"
echo "2. Applications/Websites taking ages to load"
echo "3. Experiencing an issue on a specific app?"
echo "4. Server keeps going down (OOM / crash check)"
echo
read -p "Enter option [1-4]: " choice

# === Function: High CPU/RAM Usage ===
check_cpu_ram() {
    echo -e "\n🔍 Checking CPU and RAM usage...\n"
    echo "Top 10 processes by CPU and memory:"
    ps -eo pid,comm,%cpu,%mem --sort=-%cpu | head -n 11
    echo
    echo "Memory summary:"
    free -h
    echo
    echo "Load average:"
    uptime
    echo
    echo "Disk space:"
    df -h /
    echo
    echo "Running apm info for server:"
    sudo apm info || echo "⚠️ Unable to fetch APM info"
}

# === Function: Apps/Websites Loading Slowly ===
check_apps_slow() {
    echo -e "\n🔍 Checking web server logs for resource issues...\n"
    tail -n 15 /var/log/apache2/error.log | grep -E "AH03104|unable to create worker thread" && {
        echo -e "\n🚨 Apache worker thread exhaustion detected!"
        echo "Recommendation: Ask senior to increase worker threads."
    } || echo "✅ No Apache worker exhaustion errors found."

    echo -e "\n📊 Checking top slow applications using APM...\n"
    cd /home/master/applications/
    for app in */; do
        app=${app%/}
        echo -e "\nApp: $app"
        sudo apm -s "$app" php -n3 --slow_pages -l 30min
        sudo apm -s "$app" mysql -n3 -l 30min
        echo
    done
}

# === Function: Specific Application ===
check_specific_app() {
    read -p "Enter Application Name: " app
    cd /home/master/applications/ || exit
    if [ ! -d "$app" ]; then
        echo "❌ App '$app' not found!"
        exit 1
    fi
    echo -e "\n🔍 Checking $app performance (APM & logs)..."
    sudo apm -s "$app" traffic -l 30min -n5
    sudo apm -s "$app" php --slow_pages -l 30min -n5
    sudo apm -s "$app" mysql -l 30min -n5

    slow_plugins=$(grep -ai 'wp-content/plugins' "$app/logs/php-app.slow.log" 2>/dev/null | cut -d '/' -f8 | sort | uniq -c | sort -nr)
    if [ -n "$slow_plugins" ]; then
        echo -e "\n🚨 Slow plugins detected:\n$slow_plugins"
    else
        echo -e "\n✅ No slow plugins found."
    fi
}

# === Function: Server Keeps Going Down (OOM check) ===
check_oom() {
    echo -e "\n🔍 Checking syslog for Out-Of-Memory errors...\n"
    tail -n 50 /var/log/syslog | grep -i 'oom' && {
        echo -e "\n🚨 OOM killer detected! A process used excessive memory."
        echo "Check which process caused it and optimize or restart services."
    } || echo "✅ No recent OOM events found."
}

# === Optional: AI-powered Insights (Gemini integration) ===
analyze_with_gemini() {
    if [ -z "${GEMINI_API_KEY:-}" ]; then
        echo "⚠️ Gemini API key not set. Skipping AI analysis."
        return
    fi

    echo -e "\n🤖 Sending last 50 log lines to Gemini for insights..."
    response=$(curl -s -X POST \
      -H "Content-Type: application/json" \
      -H "Authorization: Bearer $GEMINI_API_KEY" \
      -d "{\"contents\": [{\"parts\": [{\"text\": \"Analyze these logs for performance or configuration issues: $(tail -n 50 $LOGFILE)\"}]}]}" \
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent")

    echo "$response" | jq -r '.candidates[0].content.parts[0].text' || echo "No Gemini insights found."
}

# === Menu Handler ===
case $choice in
    1) check_cpu_ram ;;
    2) check_apps_slow ;;
    3) check_specific_app ;;
    4) check_oom ;;
    *) echo "Invalid option."; exit 1 ;;
esac

# Uncomment below if you want Gemini AI summary after every check:
# analyze_with_gemini

echo -e "\n✅ All done! Log saved at: $LOGFILE"
