#!/bin/bash

echo "#-----------------------"
STEP="Criando Namespace Gitlab"
kubectl apply -f k8s/00-namespace.yml

echo "#-----------------------"
STEP="Fix clusterrolebinding permissive-binding"
kubectl create clusterrolebinding permissive-binding --clusterrole=cluster-admin --user=admin --user=kubelet --group=system:serviceaccounts

echo "#-----------------------"
STEP="Instalando o Gitlab"
kubectl apply -f k8s/01-secrets.yml
kubectl apply -f k8s/02-account.yml
kubectl apply -f k8s/03-service.yml
kubectl apply -f k8s/04-gitlab-pvc.yml
kubectl apply -f k8s/05-gitlab.yml
kubectl apply -f k8s/06-ingress.yml
kubectl apply -f k8s/07-gitlab-data-backup.yml

exit 0