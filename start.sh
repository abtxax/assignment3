#!/bin/bash

echo "Starting Minikube..."
minikube start --driver=docker --memory=2048 --cpus=2

echo "Waiting for Minikube..."
kubectl wait --for=condition=Ready node/minikube --timeout=120s

echo "Applying manifests..."

kubectl apply -f k8s/namespace.yml
sleep 2

kubectl apply -f k8s/mysql-secret.yml
kubectl apply -f k8s/flask-configmap.yml
kubectl apply -f k8s/mysql-pv.yml
kubectl apply -f k8s/mysql-pvc.yml

kubectl apply -f k8s/mysql-deployment.yml
kubectl apply -f k8s/mysql-service.yml

echo "Waiting for MySQL..."
kubectl wait --for=condition=Ready pod -l app=mysql -n assignment3 --timeout=180s

kubectl apply -f k8s/flask-deployment.yml
kubectl apply -f k8s/flask-service.yml

kubectl apply -f k8s/nginx-configmap.yml
kubectl apply -f k8s/nginx-deployment.yml
kubectl apply -f k8s/nginx-service.yml

echo "Waiting for all pods..."
kubectl wait --for=condition=Ready pod --all -n assignment3 --timeout=180s

echo ""
echo "=== Pods ==="
kubectl get pods -n assignment3

echo ""
echo "=== Services ==="
kubectl get svc -n assignment3

echo ""
echo "=== URL ==="
minikube service nginx -n assignment3 --url
