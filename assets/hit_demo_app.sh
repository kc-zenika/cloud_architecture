#!/bin/bash

set -uo pipefail

HOST="${1:-localhost:8080}"

demo() {
  local path="$1" desc="$2"
  echo "=================================================="
  echo "GET ${path}"
  echo "${desc}"
  echo "--------------------------------------------------"
  echo "reponse: $(curl -s -w "status=%{http_code} time=%{time_total}s\n" "http://${HOST}${path}")"
  echo
}

demo "/healthz" \
  "Always 200. This is the ALB target group's health check target."

demo "/info" \
  "Reports which instance answered (hostname) plus its current CPU load and memory usage -- useful for watching ALB round-robin across ASG instances during the scaling demo."

demo "/slow" \
  "Simulates latency: sleeps a random 500ms-3000ms before responding 200. Watch ALB's TargetResponseTime metric during this call."

demo "/error" \
  "Simulates a failure: always returns 500. Watch ALB's HTTPCode_Target_5XX_Count and this app's http_requests_total{code=\"500\"} metric."

echo "=================================================="
echo "GET /metrics"
echo "Prometheus exposition format. Not scraped by anything in this workshop -- shown to demonstrate what a real app exposes to a metrics scraper."
echo "The real endpoint also includes ~100 lines of go_*/process_* runtime metrics (free from promauto); filtered here to just this app's own three:"
echo "--------------------------------------------------"
curl -s "http://${HOST}/metrics" | grep -E "^(http_requests_total|http_request_duration_seconds|http_requests_in_flight)"
echo
