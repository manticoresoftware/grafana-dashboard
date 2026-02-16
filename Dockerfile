FROM debian:bookworm-slim

ARG GRAFANA_VERSION=10.4.3
ARG PROMETHEUS_VERSION=2.52.0

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      ca-certificates curl supervisor adduser libfontconfig1 musl netcat-openbsd && \
    # Install Grafana
    curl -fsSL "https://dl.grafana.com/oss/release/grafana_${GRAFANA_VERSION}_$(dpkg --print-architecture).deb" -o /tmp/grafana.deb && \
    dpkg -i /tmp/grafana.deb || true && \
    apt-get install -y -f --no-install-recommends && \
    rm /tmp/grafana.deb && \
    # Install Prometheus
    ARCH=$(dpkg --print-architecture) && \
    curl -fsSL "https://github.com/prometheus/prometheus/releases/download/v${PROMETHEUS_VERSION}/prometheus-${PROMETHEUS_VERSION}.linux-${ARCH}.tar.gz" \
      | tar xz -C /tmp && \
    mv /tmp/prometheus-${PROMETHEUS_VERSION}.linux-${ARCH}/prometheus /usr/local/bin/ && \
    mv /tmp/prometheus-${PROMETHEUS_VERSION}.linux-${ARCH}/promtool /usr/local/bin/ && \
    rm -rf /tmp/prometheus-* && \
    mkdir -p /etc/prometheus/rules /var/lib/prometheus && \
    # Clean up curl only, keep all other packages
    apt-get purge -y --auto-remove curl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Grafana provisioning (wipe defaults from deb, copy ours)
RUN rm -rf /etc/grafana/provisioning/*
COPY grafana/provisioning/ /etc/grafana/provisioning/

# Dashboard
COPY grafana/dashboards/manticore-dashboard.json /var/lib/grafana/dashboards/

# Prometheus config and alert rules
COPY prometheus/prometheus.yml /etc/prometheus/prometheus.yml
COPY prometheus/rules/manticore-alerts.yml /etc/prometheus/rules/

# Supervisord config
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Entrypoint
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENV MANTICORE_TARGETS=localhost:9308
ENV GF_PATHS_PROVISIONING=/etc/grafana/provisioning

EXPOSE 3000

ENTRYPOINT ["/entrypoint.sh"]
