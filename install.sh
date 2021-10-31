#!/bin/bash

kubectl apply -f /k8s/00-namespace.yml
kubectl apply -f /k8s/01-secrets.yml
kubectl apply -f /k8s/02-gitlab.yml
kubectl apply -f /k8s/03-ingress.yml
kubectl apply -f /k8s/04-gitlab-data-backup.yml
kubectl apply -f /k8s/05-gitlab-sa.yaml

./k8s/autodevops.sh*
