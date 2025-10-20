#!/bin/bash

gpu_info=$(nvidia-smi --query-gpu=utilization.gpu,memory.used,memory.total --format=csv,noheader,nounits)
gpu_util=$(echo "$gpu_info" | awk -F', ' '{print $1}')
vram_used=$(echo "$gpu_info" | awk -F', ' '{printf "%.1f", $2/1024}')
vram_total=$(echo "$gpu_info" | awk -F', ' '{printf "%.1f", $3/1024}')

echo "{\"text\":\"$gpu_util%\",\"tooltip\":\"GPU: $gpu_util%\\nVRAM: ${vram_used}GB / ${vram_total}GB\"}"
