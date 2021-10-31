# Gitlab Rancher Kubernetes

## Contexto
Iremos instalar a versão mais nova do GitLab (Latest).

Para habilitar o recurso AutoDevOps do GitLab, você precisa preencher o formulário "conectando o GitLab a um cluster Kubernetes".
Enquanto escrevo isso, a documentação oficial se concentra na solução de cluster do GKE, portanto, consideramos aqui apenas um cluster existente gerenciado pelo Rancher (que é o meu caso).

O objetivo aqui é fornecer um script para ajudar as pessoas a configurar o cluster existente e preencher os campos obrigatórios do GitLab marcados por (\ *): 
```
- Kubernetes cluster name
- Environment scope
- API URL \*
- CA Certificate \*
- Token \*
- Project namespace (optional, unique)
- RBAC-enabled cluster
```
# Recursos
```
- validate kubectl configuration
- display API URL
- create namespace gitlab-managed-apps
- create service account gitlab-sa
- create role gitlab-role
- create rolebinding gitlab-rb
- displays CA Certificate from secret gitlab-sa-token-XXXX
- displays token from secret gitlab-sa-token-XXXX
- set role permissive-binding
```
# Requirementos
```
- ssh terminal session
- kubectl installed (snap recommended) and configured (~/.kube/config recommended)
```

# Setup

3 VM Ubuntu 18.04 with Docker installed

- worker01 172.16.0.27 : Rancher server stable 2.6.x, nfs server (for persistence volume claim)
- worker02 172.16.0.28 : Rancher server stable 2.6.x, nfs server (for persistence volume claim)
- worker03 172.16.0.29 : Rancher server stable 2.6.x, nfs server (for persistence volume claim)
- worker04 172.16.0.30 : Rancher server stable 2.6.x, nfs server (for persistence volume claim)

# Comandos

# Clone o repositorio:
```
git clone https://github.com/efcunha/Gitlab-Rancher-Kubernetes.git
cd Gitlab-Rancher-Kubernetes
```
# Abilitando Active Directory
# Altere os campos com os valores de conexão de seu Actibe Directory
# E adicione no final do arquivo 01-secrets.yml
```
gitlab_rails['ldap_enabled'] = true
gitlab_rails['ldap_servers'] = {
'main' => {
  'label' => 'ACTIVE DIRECTORY TEST',
  'host' =>  'test.activedirectory.com',
  'port' => 636,
  'uid' => 'sAMAccountName',
  'encryption' => 'simple_tls',
  'verify_certificates' => false,
  'bind_dn' => 'CN=ad-test,OU=Project,DC=example,DC=ng',
  'password' => 'AWsd12nT',
  'active_directory' => true,
  'base' => 'OU=User,DC=example,DC=ng',
  'group_base' => 'OU=User,DC=example,DC=ng',
  'user_filter' => 'memberOf=CN=grp-example,OU=Organisation,OU=User,DC=example,DC=ng',
  'lowercase_usernames' => 'true'
   }
  }
```
# Utilizando script para instalação:
```
./install.sh
```
# Utilizando script para desinstalação:
```
./uninstall.sh
```

# Examplo
```
ubuntu@DESKTOP-9LDMSRO:~/Gitlab-Rancher-Kubernetes/k8s$ ./autodevops.sh
#-----------------------
kubectl check configuration
#-----------------------
kubectl Api Url
API URL => https://rancher.<dominio.com.br>/k8s/clusters/c-bqn4w
#-----------------------
Get Secret
Secret => default-token-zzwsp
#-----------------------
Get CA Certificate
-----BEGIN CERTIFICATE-----
MIIC4TCCAcmgAwIBAgIBADANBgkqhkiG9w0BAQsFADASMRAwDgYDVQQDEwdrdWJl
LWNhMB4XDTIxMTAxNTIyMjYxOFoXDTMxMTAxMzIyMjYxOFowEjEQMA4GA1UEAxMH
a3ViZS1jYTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAM/RFBWwU7OE
y7D6SHbdMSdZ8pVAJ5WtKZNGvvLvZv9w4GeyUN6T9BszaVCAKrPC9/7G+7rbTlrk
90MxeY7jenMqHRiF0GDGorfl1jngavaMIM6fqQKuw2/P9lHYFanUMGN3ga7sLSKw
4M89l4OoXIX82w5D3wQVpANvE/1X
-----END CERTIFICATE-----
#-----------------------
Token => Name:         gitlab-token-7vbww
Namespace:    kube-system
Labels:       <none>
Annotations:  kubernetes.io/service-account.name: gitlab
              kubernetes.io/service-account.uid: 47d461dc-bf12-454f-ac43-37a6bd786a62

Type:  kubernetes.io/service-account-token

Data
====
ca.crt:     1058 bytes
namespace:  11 bytes
token:      iNDdkNDYxZGMtYmYxMi00NTRmLWFjNDMtMzdhNmJkNzg2YTYyIiwic3ViIjoic3lzdGVtOnNlcnZpY2VhY2NvdW50Omt1YmUtc3lzdGVtOmdpdGxhYiJ9.qJdS-
irjtnP9Z4r3shgZ5OxgSYkwdPpF-BIcbakAN7KiNJFdP7E6NVbague1DRdxrC2WKig669-rGabarSAIdvNfUisKDx1oaaPUqSoNj9Utk93h_J0tlhP9-JLVdfCL3Fboz
GdQo2ieY_Y962Ba-XTJJ45yh1G3WVBZ7kCg9tb_C6KAuilUa4OdPDx06YwGhAeFA_BO7_gZdTb50NsUnxHsa0v3qpceoqa4kBp5ab16LRz-sZlTJzYyiHf7MlTRbl13ldzda91TfWKiRIojyRw6K_BxMQ
#-----------------------
clusterrolebinding.rbac.authorization.k8s.io/permissive-binding created
```

## Noticias
