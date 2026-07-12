package main

import (
	"fmt"
	"log"
	"math/rand/v2"
	"net/http"
	"os"
	"time"

	"github.com/prometheus/client_golang/prometheus"
	"github.com/prometheus/client_golang/prometheus/promauto"
	"github.com/prometheus/client_golang/prometheus/promhttp"
)

const (
	slowMin = 500 * time.Millisecond
	slowMax = 3000 * time.Millisecond
)

// hostname is read once at startup so handlers can report which instance
// answered a request — makes the ASG self-heal/scale-out demos visible.
var hostname = readHostname()

func readHostname() string {
	h, err := os.Hostname()
	if err != nil {
		return "unknown"
	}
	return h
}

func handleIndex(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "text/plain; charset=utf-8")
	fmt.Fprintf(w, "ok host=%s\n", hostname)
}

func handleError(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "text/plain; charset=utf-8")
	w.WriteHeader(http.StatusInternalServerError)
	fmt.Fprintln(w, "simulated error")
}

// sleepFunc is swapped out in tests so handleSlow's test doesn't actually sleep.
var sleepFunc = time.Sleep

func handleSlow(w http.ResponseWriter, r *http.Request) {
	d := randomDelay(slowMin, slowMax)
	sleepFunc(d)
	w.Header().Set("Content-Type", "text/plain; charset=utf-8")
	fmt.Fprintf(w, "slow ok waited=%s\n", d)
}

// Three metrics, one per LETS axis this workshop cares about: latency,
// traffic + errors (via the "code" label), and saturation.
var (
	reqDuration = promauto.NewHistogramVec(prometheus.HistogramOpts{
		Name:    "http_request_duration_seconds",
		Help:    "Latency of HTTP requests handled by this app.",
		Buckets: prometheus.DefBuckets,
	}, []string{"path"})

	reqCounter = promauto.NewCounterVec(prometheus.CounterOpts{
		Name: "http_requests_total",
		Help: "Count of HTTP requests by path and response code.",
	}, []string{"path", "code"})

	inFlight = promauto.NewGauge(prometheus.GaugeOpts{
		Name: "http_requests_in_flight",
		Help: "Number of HTTP requests currently being served.",
	})
)

// instrument wraps h with path-scoped Prometheus instrumentation. Layered
// outside-in: in-flight count spans the whole request, duration and counter
// sit closest to h since they need the final status code from its response.
func instrument(path string, h http.HandlerFunc) http.Handler {
	duration := reqDuration.MustCurryWith(prometheus.Labels{"path": path})
	counter := reqCounter.MustCurryWith(prometheus.Labels{"path": path})

	return promhttp.InstrumentHandlerInFlight(inFlight,
		promhttp.InstrumentHandlerDuration(duration,
			promhttp.InstrumentHandlerCounter(counter, h)))
}

func main() {
	mux := http.NewServeMux()
	mux.Handle("GET /", instrument("/", handleIndex))
	mux.Handle("GET /slow", instrument("/slow", handleSlow))
	mux.Handle("GET /error", instrument("/error", handleError))
	mux.Handle("GET /metrics", promhttp.Handler())

	srv := &http.Server{
		Addr:              ":8080",
		Handler:           mux,
		WriteTimeout:      5 * time.Second,
		ReadHeaderTimeout: 5 * time.Second,
	}

	log.Printf("listening on %s (host=%s)", srv.Addr, hostname)
	log.Fatal(srv.ListenAndServe())
}

// randomDelay picks a duration in [min, max). Uses math/rand/v2's global
// source, which is auto-seeded and safe for concurrent use, so handlers
// running in per-request goroutines don't need a shared *rand.Rand.
func randomDelay(min, max time.Duration) time.Duration {
	if max <= min {
		return min
	}
	return min + time.Duration(rand.Int64N(int64(max-min)))
}
