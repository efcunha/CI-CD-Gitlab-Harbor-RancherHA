#!/bin/bash

kubectl delete clusterrolebinding permissive-binding
kubectl delete -f k8s/05-gitlab-data-backup.yml
kubectl delete -f k8s/04-ingress.yml
kubectl delete -f k8s/03-gitlab.yml
kubectl delete -f k8s/02-account.yml
kubectl delete -f k8s/01-secrets.yml
kubectl delete -f k8s/00-namespace.yml
