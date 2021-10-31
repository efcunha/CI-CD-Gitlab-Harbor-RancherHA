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

# Comandss

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
cdelaitre@ubuntu1 ~/workspace/gitlab-rancher-kubernetes (master) $ ./autodevops.sh

#-----------------------
kubectl check configuration
#-----------------------
kubectl Api Url
API URL => https://192.168.56.101/k8s/clusters/c-6qr44
#-----------------------
kubectl apply account
namespace/gitlab-managed-apps created
serviceaccount/gitlab-sa created
role.rbac.authorization.k8s.io/gitlab-role created
rolebinding.rbac.authorization.k8s.io/gitlab-rb created
#-----------------------
Get Secret
Secret => gitlab-sa-token-q5wmm
#-----------------------
Get CA Certificate
-----BEGIN CERTIFICATE-----
MIICwjCCAaqgAwIBAgIBADANBgkqhkiG9w0BAQsFADASMRAwDgYDVQQDEwdrdWJl
LWNhMB4XDTE5MDQxMDEyMTMwOVoXDTI5MDQwNzEyMTMwOVowEjEQMA4GA1UEAxMH
...
Gxf0CWcfwx9YKZhGjRvLYjDMslR4/56hOZtmG7Irn8+MKCmWSC2Gft3WkTJukRpM
AKF0a+Y6onL23copR2uEB7psRGal++TII08QeeCmIXtz4lc9egtKMrFF0+M5BUMN
W5oimYAS9egkwvdrX/rd/OhfKZdcZO+MkC6YHVH43SAYXC5s9kk=
-----END CERTIFICATE-----
#-----------------------
Token => token:      eyJhbGciOiJSUzI1NiIsImtpZCI6IiJ9.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJnaXRsYWItbWFuYWdlZC1hcHBzIiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZWNyZXQubmFtZSI6InJ1bm5lci1naXRsYWItcnVubmVyLXRva2VuLTl3cGd6Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZXJ2aWNlLWFjY291bnQubmFtZSI6InJ1bm5lci1naXRsYWItcnVubmVyIiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZXJ2aWNlLWFjY291bnQudWlkIjoiN2VlM2IwOTEtNWM2Yy0xMWU5LWJlYjgtMDgwMDI3YWJlZjRlIiwic3ViIjoic3lzdGVtOnNlcnZpY2VhY2NvdW50OmdpdGxhYi1tYW5hZ2VkLWFwcHM6cnVubmVyLWdpdGxhYi1ydW5uZXIifQ.mGgFWyfy9wPnJUfJNLL_XZuPBXJ2u5EZF1MGNb3u8qDVs2Rn7JmMrbLoplDhZJycJ3RdFe_q-fSBzvJvhLeTcjugIKcBHr44-imC8ty_o-QSkHE5kiIG0eFRq6VJVAX1g25DYV7mgV2FyJ8lfLG5fDEQhGUoxD1yDTTjHNQzZc75jBYGuaRhBOsuWsJrZnpHbX9qbTEjfdxzuLWwy4cdU8a8T791Br6ivxVIkz1T5n2bgFWmYoahB3dEoYv5P18GvT7nXxIlJVhhmhcIq8B6mAk7B4Xs_1lsL_3M1isbeZp3Y493G6LcuOokPxdpvPrVLnVCXdh5frqrSg-2tB-82w
#-----------------------
clusterrolebinding.rbac.authorization.k8s.io/permissive-binding created
```

## Noticias
