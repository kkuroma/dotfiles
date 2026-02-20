#!/bin/bash

# Get disk usage
disk_info=$(df -h / | awk 'NR==2 {print $3,$2,$5}')
read -r used total percent <<< "$disk_info"
percent_num=${percent%\%}

# Detect the main disk device
if [ -b /dev/nvme0n1 ]; then
    disk_device="nvme0n1"
elif [ -b /dev/sda ]; then
    disk_device="sda"
else
    # Fallback - just show disk usage without I/O
    tooltip="󰋊 Disk: /\n"
    tooltip+="Used: ${used} / ${total} (${percent})"
    echo "{\"text\":\"${percent_num}%\",\"tooltip\":\"$tooltip\"}"
    exit 0
fi

# Get disk I/O stats (column 3 is sectors read, column 7 is sectors written)
stats=$(cat /sys/block/${disk_device}/stat)
read_sectors=$(echo "$stats" | awk '{print $3}')
write_sectors=$(echo "$stats" | awk '{print $7}')

# Calculate speed
cache_file="/tmp/waybar_disk_io"

if [ -f "$cache_file" ]; then
    read -r prev_read prev_write prev_time < "$cache_file"
    current_time=$(date +%s)
    time_diff=$((current_time - prev_time))

    if [ "$time_diff" -gt 0 ]; then
        read_diff=$((read_sectors - prev_read))
        write_diff=$((write_sectors - prev_write))

        # Convert to MB/s (sectors are 512 bytes)
        read_speed=$(echo "$read_diff $time_diff" | awk '{printf "%.1f", ($1 * 512 / 1024 / 1024) / $2}')
        write_speed=$(echo "$write_diff $time_diff" | awk '{printf "%.1f", ($1 * 512 / 1024 / 1024) / $2}')
    else
        read_speed="0.0"
        write_speed="0.0"
    fi
else
    read_speed="0.0"
    write_speed="0.0"
fi

# Save current values
echo "$read_sectors $write_sectors $(date +%s)" > "$cache_file"

# Build tooltip
tooltip="󰋊 Disk: root (/)\n"
tooltip+="Used: ${used} / ${total} (${percent})\n\n"
tooltip+=" Disk I/O\n"
tooltip+="󰇚 Read: ${read_speed} MB/s\n"
tooltip+="󰕒 Write: ${write_speed} MB/s"

echo "{\"text\":\"${percent_num}%\",\"tooltip\":\"$tooltip\"}"
