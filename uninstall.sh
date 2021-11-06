#!/bin/bash

echo "#-----------------------"
STEP="Fix clusterrolebinding permissive-binding"
kubectl delete clusterrolebinding permissive-binding

echo "#-----------------------"
STEP="Removendo o Gitlab"
kubectl delete -f k8s/06-ingress.yml
kubectl delete -f k8s/05-gitlab.yml
kubectl delete -f k8s/04-gitlab-pvc.yml
kubectl delete -f k8s/07-gitlab-data-backup.yml
kubectl delete -f k8s/03-service.yml
kubectl delete -f k8s/02-account.yml
kubectl delete -f k8s/01-secrets.yml

exit 0