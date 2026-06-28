package main

import (
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"
	"time"

	"github.com/prometheus/client_golang/prometheus/promhttp"
)

func TestMetricsSmoke(t *testing.T) {
	req := httptest.NewRequest(http.MethodGet, "/healthz", nil)
	rec := httptest.NewRecorder()
	instrument("/healthz", handleHealthCheck).ServeHTTP(rec, req)

	metricsReq := httptest.NewRequest(http.MethodGet, "/metrics", nil)
	metricsRec := httptest.NewRecorder()
	promhttp.Handler().ServeHTTP(metricsRec, metricsReq)

	body := metricsRec.Body.String()
	if !strings.Contains(body, "http_requests_total") {
		t.Errorf("expected /metrics to contain http_requests_total after an instrumented request, got:\n%s", body)
	}
}

func TestHandleError(t *testing.T) {
	req := httptest.NewRequest(http.MethodGet, "/error", nil)
	rec := httptest.NewRecorder()

	handleError(rec, req)

	if rec.Code != http.StatusInternalServerError {
		t.Fatalf("status = %d, want %d", rec.Code, http.StatusInternalServerError)
	}
	if !strings.Contains(rec.Body.String(), "simulated error") {
		t.Errorf("body = %q, want it to contain %q", rec.Body.String(), "simulated error")
	}
}

func TestHandleSlow(t *testing.T) {
	var recorded time.Duration
	original := sleepFunc
	sleepFunc = func(d time.Duration) { recorded = d }
	defer func() { sleepFunc = original }()

	req := httptest.NewRequest(http.MethodGet, "/slow", nil)
	rec := httptest.NewRecorder()

	handleSlow(rec, req)

	if rec.Code != http.StatusOK {
		t.Fatalf("status = %d, want %d", rec.Code, http.StatusOK)
	}
	if recorded < slowMin || recorded >= slowMax {
		t.Errorf("slept %v, want within [%v, %v)", recorded, slowMin, slowMax)
	}
	if !strings.Contains(rec.Body.String(), "slow ok") {
		t.Errorf("body = %q, want it to contain %q", rec.Body.String(), "slow ok")
	}
}

func TestHandleHealthCheck(t *testing.T) {
	req := httptest.NewRequest(http.MethodGet, "/healthz", nil)
	rec := httptest.NewRecorder()

	handleHealthCheck(rec, req)

	if rec.Code != http.StatusOK {
		t.Fatalf("status = %d, want %d", rec.Code, http.StatusOK)
	}
	body := rec.Body.String()
	if !strings.Contains(body, "ok") {
		t.Errorf("body = %q, want it to contain %q", body, "ok")
	}
}

func TestHandleInfo(t *testing.T) {
	req := httptest.NewRequest(http.MethodGet, "/info", nil)
	rec := httptest.NewRecorder()

	handleInfo(rec, req)

	if rec.Code != http.StatusOK {
		t.Fatalf("status = %d, want %d", rec.Code, http.StatusOK)
	}
	body := rec.Body.String()
	if !strings.Contains(body, hostname) {
		t.Errorf("body = %q, want it to contain hostname %q", body, hostname)
	}
}

func TestRandomDelay_WithinBounds(t *testing.T) {
	min := 500 * time.Millisecond
	max := 3000 * time.Millisecond

	for i := 0; i < 1000; i++ {
		d := randomDelay(min, max)
		if d < min || d >= max {
			t.Fatalf("randomDelay(%v, %v) = %v, want within [%v, %v)", min, max, d, min, max)
		}
	}
}

func TestRandomDelay_MinEqualsMax(t *testing.T) {
	d := randomDelay(500*time.Millisecond, 500*time.Millisecond)
	if d != 500*time.Millisecond {
		t.Fatalf("randomDelay(500ms, 500ms) = %v, want 500ms", d)
	}
}
