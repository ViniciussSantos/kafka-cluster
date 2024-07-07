#!/bin/bash

nodetype="$1"

echo "[Step 1- Installing required components]"
sudo apt-get update >/dev/null 2>&1
sudo apt-get install -y apt-transport-https ca-certificates curl gpg >/dev/null 2>&1
sudo mkdir -p -m 755 /etc/apt/keyrings >/dev/null 2>&1
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg >/dev/null 2>&1
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list >/dev/null 2>&1
sudo apt-get update >/dev/null 2>&1
sudo apt-get install -y kubelet kubeadm kubectl >/dev/null 2>&1
sudo apt-mark hold kubelet kubeadm kubectl >/dev/null 2>&1
echo "[>- Install and configure Docker]"
sudo apt install -y docker.io >/dev/null 2>&1
sudo systemctl enable docker >/dev/null 2>&1
sudo cat <<EOF | sudo tee /etc/docker/daemon.json
{ "exec-opts": ["native.cgroupdriver=systemd"],
"log-driver": "json-file",
"log-opts":
{ "max-size": "100m" },
"storage-driver": "overlay2"
}
EOF
sudo systemctl restart docker >/dev/null 2>&1

echo "[>- Disabling swap]"
sed -i '/swap/d' /etc/fstab
swapoff -a

echo "[>- Enable IP_Forward]"

sudo modprobe overlay >/dev/null 2>&1
sudo modprobe br_netfilter >/dev/null 2>&1
sudo tee /etc/sysctl.d/kubernetes.conf <<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF
sudo sysctl --system >/dev/null 2>&1

echo "[>- updating /etc/hosts file]"
cat >>/etc/hosts <<EOF
192.168.60.11   master01.kubernetes.cluster     kmaster
192.168.60.21   worker01.kubernetes.cluster     worker01
192.168.60.22   worker02.kubernetes.cluster     worker02
192.168.60.23   worker03.kubernetes.cluster     worker03
EOF

if [ $1 == "master" ]; then
  echo "[Step 2 - Initializing Master Node]"
  sudo kubeadm init --apiserver-advertise-address 192.168.60.11 --control-plane-endpoint 192.168.60.11 --pod-network-cidr=10.244.0.0/16 >/dev/null 2>&1
  echo "[>- Installing Kubernetes network plugin]"
  echo "[>- Enable ssh password authentication]"
  sed -i 's/^PasswordAuthentication .*/PasswordAuthentication yes/' /etc/ssh/sshd_config
  echo 'PermitRootLogin yes' >>/etc/ssh/sshd_config
  systemctl reload sshd
  echo -e "kubeadmin\nkubeadmin" | passwd root >/dev/null 2>&1
  kubectl --kubeconfig=/etc/kubernetes/admin.conf apply -f https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml
  kubeadm token create --print-join-command >/joincluster.sh 2>/dev/null
  echo -e "---------COPY AND PASTE THE FOLLOWING IN ~/.kube/config ON THE MACHINE YOU WANT TO RUN KUBECTL COMMANDS-------\n"
  cat /etc/kubernetes/admin.conf
  echo -e "\n---------------------"
fi

if [ $1 == "worker" ]; then
  echo "[Join worker to cluster]"
  apt install -qq -y sshpass >/dev/null 2>&1
  sshpass -p "kubeadmin" scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no master01.kubernetes.cluster:/joincluster.sh /joincluster.sh 2>/dev/null
  bash /joincluster.sh >/dev/null 2>&1
fi
