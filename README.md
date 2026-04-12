# Dots

My homelab and configuration files managed with NixOS, Snowfall Lib, and [home-manager](https://github.com/nix-community/home-manager).

## Homelab Machines

This repository contains the configuration for several machines in my homelab:

- **t14**: My main laptop (Lenovo ThinkPad T14 AMD Gen 2). Configured with GNOME and Hyprland.
- **srv3**: Main server. Hosts various applications, utilizes impermanence. Also runs the central monitoring stack (Grafana, Loki) and collects backups.
- **srv2**: Raspberry Pi 3B. Acts as a "KVM" and wake-on-LAN controller for `srv5` based on network traffic.
- **srv5**: Compute server running Ollama and other AI tasks. Controlled by `srv2`.
- **srv4**: Offline. Originally intended to serve static files to the public internet but currently inactive.
- **backup**: Remote backup target (via BorgBackup).

## Network

The homelab machines are connected securely using [Tailscale](https://tailscale.com/). Local services can be accessed using their machine hostname within the Tailscale network (e.g., `srv3`).

## Monitoring & Logs

A centralized logging and alerting system is deployed using the PLG stack:
- **Alloy**: Runs on each server (`srv2`, `srv3`, `srv5`) to collect logs from `systemd-journald`.
- **Loki**: Runs on `srv3` to aggregate logs sent by Alloy.
- **Grafana**: Runs on `srv3` (port 3000) for visualization and alerting. Alerts for failed backup jobs are sent via Telegram.

## Deployment

Deployments are managed via `deploy-rs`. To apply changes to a machine, run:

```bash
nix run github:serokell/deploy-rs -- .#<hostname>
```

For example, to deploy to `srv3`:

```bash
nix run github:serokell/deploy-rs -- .#srv3
```
