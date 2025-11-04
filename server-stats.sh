#!/bin/bash
# ===========================================================
# SERVER PERFORMANCE STATS SCRIPT (Auto color + portable)
# ===========================================================
# Author: Linet 
# Description: Displays detailed server performance metrics.
# Works on any Linux system; uses advanced tools if available.
# ===========================================================

# ---------- COLOR SETUP ----------
if [ -t 1 ]; then
    CYAN=$(tput setaf 6)
    BOLD=$(tput bold)
    RESET=$(tput sgr0)
else
    CYAN=""
    BOLD=""
    RESET=""
fi

divider="-----------------------------------------------------------"

# ---------- HEADER ----------
echo "${CYAN}${BOLD}==========================================================="
echo "        SERVER PERFORMANCE STATISTICS"
echo "===========================================================${RESET}"
echo "Run date: $(date)"
echo "Hostname: $(hostname)"
echo ""

# ---------- SYSTEM INFO ----------
echo "${CYAN}${BOLD}SYSTEM INFORMATION${RESET}"
echo "$divider"
echo "OS Version: $(grep PRETTY_NAME /etc/os-release | cut -d= -f2 | tr -d '\"')"
echo "Kernel Version: $(uname -r)"
echo "Uptime: $(uptime -p)"
echo "Logged-in Users: $(who | wc -l)"
echo ""

# ---------- CPU STATS ----------
echo "${CYAN}${BOLD}CPU (PROCESSOR) STATS${RESET}"
echo "$divider"

if top -bn1 >/dev/null 2>&1; then
    cpu_idle=$(top -bn1 | grep "Cpu(s)" | sed "s/,/./g" | awk '{print $8}')
    cpu_usage=$(awk "BEGIN {printf \"%.2f\", 100 - $cpu_idle}")
    echo "Total CPU Usage: ${cpu_usage}%"
else
    echo "CPU info unavailable (missing top command)."
fi

echo "Load Average: $(uptime | awk -F'load average: ' '{print $2}')"

if command -v iostat >/dev/null 2>&1; then
    echo "Disk I/O (reads/writes per sec):"
    iostat 1 2 | tail -n +7 | head -n 5
else
    echo "iostat not installed (install with: sudo apt install sysstat)"
fi
echo ""

# ---------- MEMORY STATS ----------
echo "${CYAN}${BOLD}MEMORY (RAM) STATS${RESET}"
echo "$divider"

read mem_total mem_used mem_free <<<$(free -m | awk '/Mem:/ {print $2, $3, $4}')
mem_percent=$(awk "BEGIN {printf \"%.2f\", ($mem_used/$mem_total)*100}")

echo "Total Memory: ${mem_total} MB"
echo "Used Memory:  ${mem_used} MB"
echo "Free Memory:  ${mem_free} MB"
echo "Usage:        ${mem_percent}%"

swap_total=$(free -m | awk '/Swap:/ {print $2}')
swap_used=$(free -m | awk '/Swap:/ {print $3}')
if [ "$swap_total" -gt 0 ]; then
    echo "Swap Usage:   ${swap_used}/${swap_total} MB"
else
    echo "Swap:         Not configured"
fi
echo ""

# ---------- DISK STATS ----------
echo "${CYAN}${BOLD}DISK (STORAGE) STATS${RESET}"
echo "$divider"
df -h --total | grep -E "(Filesystem|total)"
echo ""

# ---------- NETWORK STATS ----------
echo "${CYAN}${BOLD}NETWORK STATS${RESET}"
echo "$divider"
if command -v ip >/dev/null 2>&1; then
    ip -s link | awk '/^[0-9]+: / {print $2} /RX:/ {print "  "$0} /TX:/ {print "  "$0}'
elif command -v netstat >/dev/null 2>&1; then
    netstat -i
else
    echo "Network tools not available (install net-tools or iproute2)."
fi
echo ""

# ---------- PROCESS STATS ----------
echo "${CYAN}${BOLD}TOP PROCESSES${RESET}"
echo "$divider"
echo "Top 5 by CPU Usage:"
ps -eo pid,comm,%cpu,%mem --sort=-%cpu | head -n 6
echo ""
echo "Top 5 by Memory Usage:"
ps -eo pid,comm,%cpu,%mem --sort=-%mem | head -n 6
echo ""

# ---------- SUMMARY ----------
echo "${CYAN}${BOLD}==========================================================="
echo "                 ANALYSIS COMPLETE"
echo "===========================================================${RESET}"
