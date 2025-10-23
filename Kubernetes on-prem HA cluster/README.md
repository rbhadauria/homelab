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

### Phase 1: RKE2 High-Availability Cluster

**Goal:** Install and configure a production-ready RKE2 cluster with an HA control plane.
**Skills:** RKE2, Linux HA.

**Project:**

1.  **Fixed Registration Endpoint:** On `k8s-util`, install and configure **HAProxy** to load balance traffic on port `9345` across the three control plane nodes. This provides a stable registration address for new nodes.
2.  **Install RKE2 Server:** On `k8s-cp-1`, create the RKE2 `config.yaml`. Specify the HAProxy address in the `server` field. Start RKE2.
3.  **Join Control Plane Nodes:** On `k8s-cp-2` and `k8s-cp-3`, create a similar `config.yaml` and start RKE2. They will register via the HAProxy endpoint and form an HA `etcd` cluster.
4.  **Join Worker Nodes:** Get the registration token from a server node and start RKE2 on the worker nodes (`k8s-w-1`, `k8s-w-2`, `k8s-w-3`).
5.  **Verification:** Test HA by powering off a control plane node and a physical host, ensuring cluster access and application uptime.
