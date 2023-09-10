#!/bin/bash

minikube_status=$(minikube status -b=0 | grep -o "type: Control Plane host: Running kubelet: Running apiserver: Running kubeconfig: Configured")

if [ -z "$minikube_status" ]; then
    echo "Starting Minikube..."
    minikube start
fi

echo "Applying Kubernetes configuration files..."
kubectl apply -f ./config/00-namespace.yaml -n default
kubectl apply -f ./config/01-kafka.yaml

echo "Waiting for the Kafka cluster to be ready..."
kubectl wait kafka/my-cluster --for=condition=Ready --timeout=300s -n default

node_port=$(kubectl get service my-cluster-kafka-external-bootstrap -o=jsonpath='{.spec.ports[0].nodePort}')
internal_ip=$(kubectl get node minikube -o=jsonpath='{.status.addresses[?(@.type=="InternalIP")].address}')

echo "You can access the Kafka cluster at $internal_ip:$node_port"
