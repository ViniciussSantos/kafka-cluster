#!/bin/bash

echo "fixing flannel network..."
kubectl apply -f config/flannel.yaml >/dev/null 2>&1 

echo "Applying Kubernetes configuration files..."
kubectl create namespace kafka >/dev/null 2>&1
kubectl apply -f ./config/namespace.yaml -n kafka >/dev/null 2>&1
kubectl apply -f ./config/kafka.yaml -n kafka >/dev/null 2>&1
