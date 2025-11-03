#!/bin/bash
# ===========================================================
# SERVER PERFORMANCE STATS SCRIPT (CYAN TITLES)
# ===========================================================
# Author: Linet
# Description: Displays detailed server performance metrics.
# Works on any modern Linux system.
# ===========================================================

# ---------- Color Setup ----------
TITLE=$(tput setaf 6)  # Cyan for titles
RESET=$(tput sgr0)

echo "${TITLE}==========================================================="
echo "  SERVER PERFORMANCE STATS"
echo "Run date: $(date)"
echo "===========================================================${RESET}"

# ---------- System Info ----------
echo ""
echo "${TITLE}SYSTEM INFORMATION${RESET}"
echo "-----------------------------------------------------------"
echo "Hostname: $(hostname)"
echo "OS Version: $(grep PRETTY_NAME /etc/os-release | cut -d= -f2 | tr -d '\"')"
echo "Kernel Version: $(uname -r)"
echo "Uptime: $(uptime -p)"
echo "Logged-in Users: $(who | wc -l)"
echo ""

# ---------- CPU Stats ----------
echo "${TITLE}CPU (Processor) STATS${RESET}"
echo "-----------------------------------------------------------"

# CPU usage (robust version)
cpu_idle=$(top -bn1 | grep "Cpu(s)" | sed "s/,/./g" | awk '{print $8}')
cpu_usage=$(awk "BEGIN {printf \"%.2f\", 100 - $cpu_idle}")

# Load average
load_avg=$(uptime | awk -F'load average: ' '{print $2}')
# Context switches
context_switches=$(vmstat 1 2 | tail -1 | awk '{print $12}')

echo "Total CPU Usage: ${cpu_usage}%"
echo "Load Average (1,5,15 min): $load_avg"
echo "Context Switches per second: $context_switches"
echo ""

# ---------- Memory Stats ----------
echo "${TITLE}MEMORY (RAM) STATS${RESET}"
echo "-----------------------------------------------------------"
mem_total=$(free -m | awk '/Mem:/ {print $2}')
mem_used=$(free -m | awk '/Mem:/ {print $3}')
mem_free=$(free -m | awk '/Mem:/ {print $4}')
mem_percent=$(awk "BEGIN {printf \"%.2f\", ($mem_used/$mem_total)*100}")
swap_used=$(free -m | awk '/Swap:/ {print $3}')
swap_total=$(free -m | awk '/Swap:/ {print $2}')

echo "Total Memory: ${mem_total} MB"
echo "Used Memory: ${mem_used} MB"
echo "Free Memory: ${mem_free} MB"
echo "Memory Usage: ${mem_percent}%"
echo "Swap Usage: ${swap_used}/${swap_total} MB"
echo ""

# ---------- Disk Stats ----------
echo "${TITLE}DISK (Storage) STATS${RESET}"
echo "-----------------------------------------------------------"
df -h --total | grep -E "(Filesystem|total)"
echo ""

# Check if iostat exists
if command -v iostat >/dev/null 2>&1; then
    echo "Disk I/O (reads/writes per sec):"
    iostat 1 2 | tail -n +7 | head -n 5
else
    echo "iostat not installed (install with 'sudo apt install sysstat')."
fi
echo ""

# ---------- Network Stats ----------
echo "${TITLE}NETWORK STATS${RESET}"
echo "-----------------------------------------------------------"
if command -v sar >/dev/null 2>&1; then
    echo "Bandwidth usage (sent/received in KB/s):"
    sar -n DEV 1 1 | grep Average | grep -v IFACE
else
    echo "sar not installed (install with 'sudo apt install sysstat')."
fi
echo ""
echo "Network errors/drops:"
netstat -i | grep -v "Iface"
echo ""

# ---------- Process Stats ----------
echo "${TITLE}PROCESS AND APPLICATION STATS${RESET}"
echo "-----------------------------------------------------------"
total_procs=$(ps -e --no-headers | wc -l)
echo "Active Processes: $total_procs"
echo ""
echo "Top 5 Processes by CPU Usage:"
ps -eo pid,comm,%cpu,%mem --sort=-%cpu | head -n 6
echo ""
echo "Top 5 Processes by Memory Usage:"
ps -eo pid,comm,%cpu,%mem --sort=-%mem | head -n 6
echo ""

# ---------- Web/API Stats (optional) ----------
echo "${TITLE}WEB / API PERFORMANCE STATS${RESET}"
echo "-----------------------------------------------------------"
if systemctl is-active --quiet nginx; then
    echo "Nginx is running"
    echo "Requests per second (approx):"
    echo "(Run 'sudo nginx -V' or check access logs for detailed RPS)"
elif systemctl is-active --quiet apache2; then
    echo "Apache is running"
    echo "Requests per second (approx):"
    echo "(Run 'apachectl status' or check /var/log/apache2/access.log)"
else
    echo "No web server detected."
fi
echo ""

# ---------- Summary ----------
echo "${TITLE}==========================================================="
echo " ANALYSIS COMPLETE"
echo "===========================================================${RESET}"
