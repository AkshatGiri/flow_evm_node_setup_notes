#!/bin/bash

while true; do
    sync_data=$(curl -s -X POST http://localhost:8545 \
        -H "Content-Type: application/json" \
    -d '{"jsonrpc":"2.0","method":"eth_syncing","params":[],"id":1}')
    
    current=$(echo $sync_data | jq -r '.result.currentBlock' | sed 's/0x//' | tr '[:lower:]' '[:upper:]' | xargs -I {} printf "%d" 0x{})
    highest=$(echo $sync_data | jq -r '.result.highestBlock' | sed 's/0x//' | tr '[:lower:]' '[:upper:]' | xargs -I {} printf "%d" 0x{})
    
    progress=$(echo "scale=2; ($current / $highest) * 100" | bc)
    
    echo "Progress: $progress% (Block $current of $highest)"
    sleep 5
done