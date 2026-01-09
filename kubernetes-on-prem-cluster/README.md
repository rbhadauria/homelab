### Phase 0: The Foundation - Proxmox VM Setup

**Goal:** Create a solid, physically distributed VM foundation.
**VM Allocation:**

- **pve-large (12c/32GB):**
  - `k8s-cp-1`: Control Plane (4 vCPU, 6GB RAM)
  - `k8s-w-1`: Worker (4 vCPU, 12GB RAM)
  - `k8s-w-2`: Worker (4 vCPU, 12GB RAM)
- **pve-small (8c/24GB):**
  - `k8s-cp-2`: Control Plane (4 vCPU, 6GB RAM)
  - `k8s-cp-3`: Control Plane (4 vCPU, 6GB RAM)
  - `k8s-w-3`: Worker (4 vCPU, 12GB RAM)
- **node1 (4c/12GB):**
  - `k8s-util`: Utility/Bastion VM (2 vCPU, 2GB RAM) - _For HAProxy & CI/CD services._

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

### Phase 2: On-Premise CI/CD & Storage Foundations

**Goal:** Deploy the core infrastructure for self-hosted CI/CD and storage.
**Skills:** Harbor, MinIO, Rook-Ceph.

**Project:**

1.  **Distributed Storage (Rook-Ceph):** Deploy the Rook-Ceph operator to create a replicated storage layer using the disks on your worker nodes.
2.  **S3 Object Storage (MinIO):** Deploy a standalone, HA MinIO cluster inside Kubernetes. Use a `StatefulSet` with `PersistentVolumeClaims` pointing to your Rook-Ceph `StorageClass`.
3.  **Private Registry (Harbor):** Deploy Harbor into Kubernetes. Configure it to use your in-cluster MinIO deployment for its backend storage.
