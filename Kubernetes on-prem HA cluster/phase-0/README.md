### Phase 0: The Foundation - Proxmox VM Setup

**Goal:** Create a solid, physically distributed VM foundation.
**VM Allocation:**

- **pve-large (12c/32GB):**
  - `k8s-cp-2`: Control Plane (2 vCPU, 4GB RAM)
  - `k8s-cp-3`: Control Plane (2 vCPU, 4GB RAM)
  - `k8s-w-2`: Worker (2 vCPU, 8GB RAM)
  - `k8s-w-3`: Worker (2 vCPU, 8GB RAM)
  - `k8s-util`: Utility/Bastion VM (2 vCPU, 4GB RAM) - _For HAProxy & CI/CD services._
- **pve-small (4c/8GB):**
  - `k8s-cp-1`: Control Plane (2 vCPU, 4GB RAM)
  - `k8s-w-1`: Worker (2 vCPU, 4GB RAM)

For deleting all vms in a node in case we need to perform cleanup due to failure in terraform

```
for id in $(qm list | awk '/k8s-/ {print $1}'); do
  (qm stop $id --skiplock 1 && qm destroy $id --purge --skiplock 1) &
done
wait
```
