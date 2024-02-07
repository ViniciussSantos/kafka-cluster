## About the project

A local emulation of a fleet of VMs running a kubernetes cluster. I use it primarily for deploying kafka clusters

## 💻 Getting started

### Requirements

For running this project, you should have the following technologies installed in your machine:

- Vagrant
- Kubectl
- VirtualBox

Also, you need to have enough memory and CPU cores to run the VMs. Kubeadm asks for at least 2 CPU cores and 2GB of ram memory for each node running.

### How to run the project

With everything installed, start the VMs by running the following command in the same path of the Vagrantfile:

```bash
vagrant up
```

During the initialization of the master01 node/VM, it will print a message asking you to update your .kube/config with the printed information so you can run kubectl commands and have them reflected in your cluster.

After this, run the following command in the project's path

```bash
./scripts/start-cluster.sh
```

It will start the flannel network connecting all the VMs and run a small kafka cluster with a mqtt connector. By default, I don't commit the link for the connector jar because it's ephemeral, but you should upload the jar from this [mqtt source connector repo](https://github.com/johanvandevenne/kafka-connect-mqtt) to an ephemeral download service like filetransfer and update the `config/connect.yaml` file.

Then, run the following script to configure the mqtt source connector

```bash
./scripts/configure-connect.sh
```

You also can use the the docker container by running `docker compose up -d` to access the [kafka CLI tools](https://docs.confluent.io/kafka/operations-tools/kafka-tools.html) and running

```bash
docker compose exec kafka ${insert your kafka CLI command here}
```
