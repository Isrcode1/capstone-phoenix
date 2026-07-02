# Runbook — Capstone Phoenix

## Provision from Zero

```bash
# 1. Terraform
cd infra/terraform
terraform init
terraform apply -auto-approve

# 2. Ansible
cd infra/ansible
ansible-playbook -i inventory.ini playbook.yml

# 3. Verify cluster
kubectl get nodes
```

## Deploy the App

ArgoCD owns the cluster. Push to manifests/taskapp/ on main triggers auto-sync.

```bash
# Manual sync if needed
kubectl -n argocd get app taskapp
```

## Scale the Backend

```bash
kubectl -n taskapp scale deployment backend --replicas=4
kubectl -n taskapp get hpa backend-hpa
```

## Zero-Downtime Rollout

```bash
# Update image tag in manifests/taskapp/04-backend.yaml, push to git
# Verify no downtime:
while true; do curl -sk https://capstoneisrael.duckdns.org/api/health; sleep 1; done
```

## Roll Back a Bad Deploy

```bash
kubectl -n taskapp rollout undo deployment/backend
kubectl -n taskapp rollout status deployment/backend
```

## Recover from a Dead Worker Node

```bash
kubectl drain <dead-node> --ignore-daemonsets --delete-emptydir-data
kubectl get pods -n taskapp -o wide
```

## Recover from a Bad Migration

```bash
kubectl -n taskapp delete job db-migration
kubectl apply -f manifests/taskapp/03-migration-job.yaml
kubectl -n taskapp logs job/db-migration -f
```

## Verify Data Survives Pod Kill

```bash
kubectl -n taskapp delete pod postgres-0
sleep 15
kubectl -n taskapp get pod postgres-0
curl -sk https://capstoneisrael.duckdns.org/api/health
```

## Renew TLS Certificate

```bash
kubectl -n taskapp get certificate taskapp-tls
# cert-manager auto-renews 30 days before expiry
```
