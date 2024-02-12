## About the project

A local emulation of a fleet of VMs running a kubernetes cluster. I use it primarily for deploying kafka clusters

## 💻 Getting started

### Requirements

For running this project, you should have the following technologies installed in your machine:

- [Vagrant](https://www.vagrantup.com/)
- [Kubectl](https://kubernetes.io/docs/tasks/tools/#kubectl)
- [VirtualBox](https://www.virtualbox.org/)

Also, you need to have enough memory and CPU cores to run the VMs. Kubeadm asks for at least 2 CPU cores and 2GB of ram memory for each node running.

### How to run the project

With everything installed, create a private network at the VirtualBox Host network manager with the ipv4 address 192.168.60.1 and update the Vagrantfile to use it (node.vm.network). By default, the script uses the host-only network called "vboxnet0".

start the VMs by running the following command in the same path of the Vagrantfile:

```bash
vagrant up
```

During the initialization of the master01 node/VM, vagrant will print a message asking you to update your .kube/config with the printed information so you can run kubectl commands and have them reflected in your cluster.

After this, run the following command in the project's path

```bash
./scripts/start-cluster.sh
```

It will start the flannel network connecting all the VMs and run a small kafka cluster with a mqtt connector.

also, start the mqtt container with the following command

```bash
docker compose up -d
```

You also can use the the docker container to access the [kafka CLI tools](https://docs.confluent.io/kafka/operations-tools/kafka-tools.html) by running

```bash
docker compose exec kafka ${insert your kafka CLI command here}
```

before setting up the mqtt connector, check to see if it was deployed correctly with the following command

```bash
curl $(kubectl get node worker01 -o=jsonpath='{range .status.addresses[?(@.type=="InternalIP")]}{.address}{"\n"}'):$(kubectl get service kafka-connect-port -o=jsonpath='{.spec.ports[0].nodePort}{"\n"}' -n kafka)/connector-plugins | jq
```

Then, after everything is up and running, run the following script to configure the mqtt source connector

```bash
./scripts/configure-connect.sh
```
