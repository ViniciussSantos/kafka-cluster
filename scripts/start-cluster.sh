#!/bin/bash

echo "fixing flannel network..."
kubectl apply -f config/flannel.yaml >/dev/null 2>&1
echo "Creating kafka namespace"
kubectl create namespace kafka >/dev/null 2>&1
echo "creating kafka cluster"
kubectl apply -f ./config/namespace.yaml -n kafka >/dev/null 2>&1
echo "waiting from the strimzi operator to be ready"
kubectl wait --for=condition=ready pod -l name=strimzi-cluster-operator -n kafka --timeout=300s
kubectl apply -f ./config/kafka.yaml -n kafka >/dev/null 2>&1
echo "waiting for the zookeeper cluster to be ready"
kubectl wait --for=condition=ready pod -l app=my-cluster-zookeeper -n kafka --timeout=300s
echo "waiting for the kafka cluster to be ready"
kubectl wait --for=condition=ready pod -l app=my-cluster-kafka -n kafka --timeout=300s
echo "creating kafka topics"
kubectl apply -f ./config/topic.yaml -n kafka >/dev/null 2>&1
echo "deploying kafka connect"
kubectl apply -f ./config/connect.yaml -n kafka >/dev/null 2>&1
echo "deploying kafka connect nodeport service"
kubectl apply -f ./config/connect-port.yaml -n kafka >/dev/null 2>&1
