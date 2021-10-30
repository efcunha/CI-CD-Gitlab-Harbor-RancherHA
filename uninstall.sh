#!/bin/bash

kubectl delete -f /k8s/04-gitlab-data-backup.yml
kubectl delete -f /k8s/03-ingress.yml
kubectl delete -f /k8s/02-gitlab.yml
kubectl delete -f /k8s/01-secrets.yml
kubectl delete -f /k8s/00-namespace.yml

