# Architecture — Capstone Phoenix: TaskApp on Kubernetes

## Node Topology

3-node k3s cluster on AWS EC2 (us-east-1):

| Node | Role | Private IP | Public IP |
|------|------|------------|-----------|
| ip-10-0-1-147 | control-plane | 10.0.1.147 | 34.235.150.4 |
| ip-10-0-1-126 | worker-1 | 10.0.1.126 | 98.92.176.178 |
| ip-10-0-2-54 | worker-2 | 10.0.2.54 | (private only) |

## Request Flow

Browser → capstoneisrael.duckdns.org → 98.92.176.178 (worker-1)
→ svclb-traefik (host port 443)
→ Traefik pod (TLS termination, Let's Encrypt cert)
→ /api/* → backend Service → Flask pod → postgres-0 (StatefulSet)
→ /*    → frontend Service → nginx pod

## Core Requirements — What Single-Server Assumption Each Fixes

| Requirement | Single-server problem fixed |
|---|---|
| StatefulSet + PVC | Data lost on container restart — PVC survives pod deletion |
| 2 replicas + topologySpreadConstraints | One crash = total downtime — replicas spread across nodes |
| Migration Job | Race condition — 2+ replicas would race on alembic upgrade head at startup |
| Liveness/Readiness/Startup probes | Bad pods silently receive traffic — probes gate traffic to healthy pods only |
| RollingUpdate maxUnavailable:0 | Deploy = downtime — new pod Ready before old removed |
| Ingress + TLS cert-manager | Manual nginx/SSL per server — automated cert issuance and renewal |
| HPA | Manual scaling — CPU-based autoscaler adds/removes replicas |
| NetworkPolicy | All pods talk to all — postgres only reachable from backend |
| PodDisruptionBudget | Node drain kills all replicas — minAvailable:1 guarantees survival |
| ArgoCD GitOps | Manual kubectl apply = drift — git is source of truth |

## Components Per Node

| Component | Node |
|-----------|------|
| k3s server, ArgoCD, cert-manager, CoreDNS | control-plane (ip-10-0-1-147) |
| Traefik, backend x2, postgres-0, frontend x1 | worker-1 (ip-10-0-1-126) |
| frontend x1 | worker-2 (ip-10-0-2-54) |

## Networking

- CNI: flannel (VXLAN, UDP 8472 between nodes)
- Ingress: Traefik v3 (k3s built-in)
- TLS: cert-manager + Let's Encrypt HTTP-01
- DNS: CoreDNS forwarding to 1.1.1.1
