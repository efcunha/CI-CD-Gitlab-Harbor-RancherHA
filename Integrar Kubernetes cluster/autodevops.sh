#!/bin/bash

function checkrc() {
  RC=$1
  MSG="$2"
  if [ ${RC} -ne 0 ]; then
    echo "Error ${RC}: [${MSG}]"
    exit ${RC}
  fi
}

echo "#-----------------------"
STEP="kubectl check configuration"
echo ${STEP}
RET=$(kubectl auth can-i '*' '*')
checkrc $? ${STEP}

if [[ "${RET}" -ne "yes" ]]; then
  echo "Error ${STEP}"
  exit 1
fi

echo "#-----------------------"
STEP="kubectl Api Url"
echo ${STEP}
kubectl cluster-info | grep -E 'Kubernetes master|Kubernetes control plane' | awk '/http/ {print $NF}'
checkrc $? ${STEP}
echo "API URL => ${APIURL}"


NAMESPACE=default
echo "#-----------------------"
STEP="kubectl apply account"
kubectl apply -f gitlab-admin-service-account.yaml
echo ${STEP}
checkrc $? ${STEP}

echo "#-----------------------"
STEP="Get CA Certificate"
echo ${STEP}
kubectl get secret default-token -o jsonpath="{['data']['ca\.crt']}" | base64 --decode

echo "#-----------------------"
STEP="Get Token from Secret"
TOKEN=$(kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep gitlab | awk '{print $1}'))
checkrc $? ${STEP}
echo "Token => ${TOKEN}"

echo "#-----------------------"
STEP="Fix clusterrolebinding permissive-binding"
kubectl create clusterrolebinding permissive-binding \
  --clusterrole=cluster-admin \
  --user=admin \
  --user=kubelet \
  --group=system:serviceaccounts
checkrc $? ${STEP}

exit 0