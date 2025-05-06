#!/bin/bash

# Системный мониторинг - простой скрипт для проверки состояния системы

echo "======= System Monitoring ======="
echo ""

# 1. Информация о CPU
cpu_usage=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1"%"}')
cpu_cores=$(nproc)
echo "CPU Usage: $cpu_usage (cores: $cpu_cores)"
echo ""

# 2. Информация о RAM
ram_total=$(free -h | grep Mem | awk '{print $2}')
ram_used=$(free -h | grep Mem | awk '{print $3}')
ram_percent=$(free | grep Mem | awk '{print $3/$2 * 100.0}' | cut -c1-4)
echo "RAM Usage: $ram_used/$ram_total ($ram_percent%)"
echo ""

# 3. Информация о диске
disk_total=$(df -h / | awk 'NR==2 {print $2}')
disk_used=$(df -h / | awk 'NR==2 {print $3}')
disk_free=$(df -h / | awk 'NR==2 {print $4}')
disk_percent=$(df -h / | awk 'NR==2 {print $5}')
echo "Disk Space:"
echo "Total: $disk_total  Used: $disk_used  Free: $disk_free ($disk_percent)"
echo ""

# 4. Топ-5 процессов по CPU
echo "Top 5 CPU Processes:"
ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%cpu | head -n 6 | awk '{print $1, $2, $5"%", $4"%", $3}'
echo ""

# 5. Топ-5 процессов по RAM
echo "Top 5 RAM Processes:"
ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%mem | head -n 6 | awk '{print $1, $2, $4"%", $5"%", $3}'
echo ""
echo "======= Monitoring Done ======="
