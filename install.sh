#!/bin/bash

kubectl apply -f k8s/00-namespace.yml
kubectl apply -f k8s/01-secrets.yml
kubectl apply -f k8s/02-account.yml
kubectl apply -f k8s/03-gitlab.yml
kubectl apply -f k8s/04-ingress.yml
kubectl apply -f k8s/05-gitlab-data-backup.yml

./k8s/autodevops.sh*
