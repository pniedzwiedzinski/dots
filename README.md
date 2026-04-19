# Dots

My homelab and configuration files managed with NixOS, Snowfall Lib, and [home-manager](https://github.com/nix-community/home-manager).

## Homelab Machines

This repository contains the configuration for several machines in my homelab:

- **t14**: My main laptop (Lenovo ThinkPad T14 AMD Gen 2). Configured with GNOME and Hyprland.
- **srv3**: Main server. Hosts various applications, utilizes impermanence. Also runs the central monitoring stack (Grafana, Prometheus) and collects backups.
- **srv2**: Raspberry Pi 3B. Acts as a "KVM" and wake-on-LAN controller for `srv5` based on network traffic.
- **srv5**: Compute server running Ollama and other AI tasks. Controlled by `srv2`.
- **srv4**: Offline. Originally intended to serve static files to the public internet but currently inactive.
- **backup**: Remote backup target (via BorgBackup).

## Monitoring

The monitoring stack follows a unified Prometheus architecture deployed on `srv3`.
- **Telemetry**: Every node runs `prometheus-node-exporter` (with the systemd collector) natively restricted to the Tailscale interface. `srv3` additionally runs a stripped-down `cAdvisor` locally to monitor container workloads without cardinality bloat. Short-lived tasks (like Borg Backup jobs) push metrics via a post-hook to a local `Pushgateway`.
- **Aggregation**: A central Prometheus server on `srv3` pulls these metrics natively using Tailscale DNS.
- **Alerting & Visualization**: Grafana (on `srv3`) automatically provisions Prometheus as its data source, loads pre-defined homelab RED/USE dashboards, and evaluates alerts. When errors occur (e.g., failed systemd units or stale backups), Grafana pushes rich notifications directly via Telegram (with secrets handled locally). All local states are persisted using `impermanence` and backed up daily.

## Network

The homelab machines are connected securely using [Tailscale](https://tailscale.com/). Local services can be accessed using their machine hostname within the Tailscale network (e.g., `srv3`).

## Deployment

Deployments are managed via `deploy-rs`. To apply changes to a machine, run:

```bash
nix run github:serokell/deploy-rs -- .#<hostname>
```

For example, to deploy to `srv3`:

```bash
nix run github:serokell/deploy-rs -- .#srv3
```
