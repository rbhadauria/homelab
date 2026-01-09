#!/bin/bash
cd terraform
terraform apply --var-file values.tfvars --auto-approve
terraform output --raw ubuntu_vm_password > password_file
mv password_file ../ansible

terraform output --raw ubuntu_vm_private_key > id_rsa_vm
mv -f id_rsa_vm ../ansible

cd ../ansible

chmod 400 id_rsa_vm 

export ANSIBLE_HOST_KEY_CHECKING=False
ansible-playbook playbook.yaml -i inventory/hosts --private-key id_rsa_vm --become-password-file password_file --become

# sed -i '' -e 's#https://127.0.0.1#https://192.168.1.96#' rke2.yaml
cp rke2.yaml ~/.kube/config

echo "Kubernetes cluster setup is complete. You can access your cluster using kubectl."

echo "Installing ArgoCD..."
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
echo "ArgoCD installation is complete."



# cd ../../p
# helm install --create-namespace --namespace rook-ceph rook-ceph rook-release/rook-ceph -f values.yaml

# sleep 60

# kubectl get pods -n rook-ceph

# kubectl apply -f cluster.yaml

