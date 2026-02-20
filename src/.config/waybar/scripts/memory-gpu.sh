#!/bin/bash

# Get RAM info
mem_info=$(free -h | awk '/^Mem:/ {print $3,$2}')
read -r mem_used mem_total <<< "$mem_info"
mem_percent=$(free | awk '/^Mem:/ {printf "%.0f", $3/$2 * 100}')

# Try to get NVIDIA GPU info
if command -v nvidia-smi &> /dev/null; then
    gpu_info=$(nvidia-smi --query-gpu=utilization.gpu,memory.used,memory.total,temperature.gpu,power.draw,power.limit --format=csv,noheader,nounits 2>/dev/null)

    if [ -n "$gpu_info" ]; then
        IFS=',' read -r gpu_util vram_used vram_total temp power_draw power_limit <<< "$gpu_info"

        # Format VRAM to GB
        vram_used=$(echo "$vram_used" | awk '{printf "%.1f", $1/1024}')
        vram_total=$(echo "$vram_total" | awk '{printf "%.1f", $1/1024}')

        # Trim whitespace
        gpu_util=$(echo "$gpu_util" | xargs)
        temp=$(echo "$temp" | xargs)
        power_draw=$(echo "$power_draw" | awk '{printf "%.0f", $1}')
        power_limit=$(echo "$power_limit" | awk '{printf "%.0f", $1}')

        # Display: RAM% | GPU%
        display_text="󰍛 ${mem_percent}% 󰢮 ${gpu_util}%"

        # Tooltip: RAM info + GPU info
        tooltip="󰍛 RAM: ${mem_used} / ${mem_total} (${mem_percent}%)\n\n"
        tooltip+="󰢮 GPU Utilization: ${gpu_util}%\n"
        tooltip+=" Temperature: ${temp}°C\n"
        tooltip+="󰍛 VRAM: ${vram_used}GB / ${vram_total}GB\n"
        tooltip+="󰚥 Power: ${power_draw}W / ${power_limit}W"
    else
        # nvidia-smi exists but failed - show RAM only
        display_text="${mem_percent}%"
        tooltip="󰍛 RAM: ${mem_used} / ${mem_total} (${mem_percent}%)"
    fi
else
    # No NVIDIA GPU - show RAM only
    display_text="󰍛 ${mem_percent}%"
    tooltip="󰍛 RAM: ${mem_used} / ${mem_total} (${mem_percent}%)"
fi

echo "{\"text\":\"$display_text\",\"tooltip\":\"$tooltip\"}"
