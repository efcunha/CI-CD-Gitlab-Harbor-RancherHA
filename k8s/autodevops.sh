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
APIURL=$(kubectl cluster-info | grep -E 'Kubernetes master|Kubernetes control plane' | awk '/http/ {print $NF}')
checkrc $? ${STEP}
echo "API URL => ${APIURL}"

echo "#-----------------------"
STEP="Get Secret"
echo ${STEP}
SECRET=$(kubectl get secrets | grep ^default-token-* | awk '{print $1}')
checkrc $? ${STEP}
echo "Secret => ${SECRET}"

echo "#-----------------------"
STEP="Get CA Certificate"
echo ${STEP}
kubectl get secrets $SECRET -o jsonpath="{['data']['ca\.crt']}" | base64 --decode

echo "#-----------------------"
STEP="Get Token from Secret"
TOKEN=$(kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep default | awk '{print $1}'))
checkrc $? ${STEP}
echo "Token => ${TOKEN}"

exit 0
