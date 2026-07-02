# Cost Analysis — Capstone Phoenix

## Monthly Infrastructure Cost (AWS us-east-1)

| Resource | Type | Qty | Unit Price | Monthly |
|----------|------|-----|------------|---------|
| EC2 control-plane | t3.medium | 1 | $0.0416/hr | ~$30 |
| EC2 worker-1 | t3.medium | 1 | $0.0416/hr | ~$30 |
| EC2 worker-2 | t3.medium | 1 | $0.0416/hr | ~$30 |
| EBS volumes (20GB each) | gp3 | 3 | $0.08/GB/mo | ~$5 |
| Data transfer (est.) | — | — | $0.09/GB | ~$2 |
| **Total** | | | | **~$97/month** |

## How to Cut It in Half

Switch all three nodes from t3.medium to t3.small ($0.0208/hr each), saving ~$45/month. The control-plane runs only k3s server, ArgoCD, and cert-manager — a t3.small (2GB RAM) is sufficient. For further savings, use spot instances for the two worker nodes (up to 70% discount) and keep only the control-plane as on-demand. Total drops to approximately $47/month.
