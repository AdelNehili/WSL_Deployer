response=$(curl -s http://localhost:8000/generate \
  -X POST \
  -H "Content-Type: application/json" \
  -d '{"prompt":"Explain Docker simply.","max_new_tokens":120}')

model=$(echo "$response" | jq -r '.model')
output=$(echo "$response" | jq -r '.output')
latency=$(echo "$response" | jq -r '.meta.latency_seconds')

echo "MODEL: $model"
echo "OUTPUT: $output"

echo "LATENCY: $latency"