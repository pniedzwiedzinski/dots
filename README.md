# Dots

My homelab and configuration files managed with NixOS, Snowfall Lib, and [home-manager](https://github.com/nix-community/home-manager).

## Homelab Machines

This repository contains the configuration for several machines in my homelab:

- **t14**: My main laptop (Lenovo ThinkPad T14 AMD Gen 2). Configured with GNOME.
- **srv3**: Main server. Routing is managed by Traefik. It runs various self-hosted services including Home Assistant, Paperless, Immich, n8n, ChangeDetection, and Open WebUI. It utilizes `disko` for partitioning and `impermanence` for managing state.
- **srv2**: Raspberry Pi 3B. Acts as a "KVM" and wake-on-LAN controller for `srv5`. It runs a custom `wakeonhttp` service that can wake up `srv5` using GPIO 14 based on network activity (such as requests to the Ollama API).
- **srv5**: Compute server running Docker and an Ollama instance powered by an Nvidia GPU. It supports running unpatched binaries via NixLD and is powered on automatically by `srv2`.
- **backup**: Remote ZFS backup target. Uses `borgbackup` repositories to securely store and continuously sync data from `srv3`.

## Architecture & Network

All machines in the homelab are securely connected via a unified [Tailscale](https://tailscale.com/) network, meaning every inner service is natively restricted and communicates within the private mesh.

On the main server (`srv3`), Traefik serves as the reverse proxy. It routes the traffic to respective containers and services.

## Updates & Deployment

Deployments and structure use a modern Nix flake toolchain:
- **`snowfall-lib`**: For structured repository organization.
- **`deploy-rs`**: For deploying remote and local configurations.
- **`disko`**: For declarative disk partitioning.
- **`impermanence`**: For separating persistent state from ephemeral root filesystems.

### Update Process

The system update process is automated. A scheduled GitHub Action runs weekly to update the flake dependencies (`flake.lock`). The individual nodes in the homelab automatically update themselves to match the latest flake definition present in this repository.

To manually deploy changes to a specific machine (e.g., `srv3`), you can run:

```bash
nix run github:serokell/deploy-rs -- .#srv3
```
