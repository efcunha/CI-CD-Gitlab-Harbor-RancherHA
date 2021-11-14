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
```sh
git clone https://github.com/efcunha/Gitlab-Rancher-Kubernetes.git
cd Gitlab-Rancher-Kubernetes
```
# Habilitando Active Directory
Altere os campos com os valores de conexão de seu Actibe Directory
E adicione no final do arquivo 01-secrets.yml
```
gitlab_rails['smtp_enable'] = true
gitlab_rails['smtp_address'] = "smtp.dominio.com.br"
gitlab_rails['smtp_port'] = 25
gitlab_rails['smtp_domain'] = "smtp.dominio.com.br"
gitlab_rails['smtp_tls'] = false;
gitlab_rails['smtp_openssl_verify_mode'] = 'none'
gitlab_rails['smtp_enable_starttls_auto'] = false
gitlab_rails['smtp_ssl'] = false
gitlab_rails['smtp_force_ssl'] = false
gitlab_rails['gitlab_email_from'] = 'noreply@dominio.com.br'
gitlab_rails['gitlab_email_reply_to'] = 'infraestrutura@dominio.com.br'
gitlab_rails['ldap_enabled'] = true
gitlab_rails['ldap_servers'] = {
'main' => {
  'label' => 'GitLab',
  'host' =>  'ACTIVE DIRECTORY',
  'port' => 389,
  'uid' => 'sAMAccountName',
  'encryption' => 'plain',
  'verify_certificates' => false,
  'bind_dn' => 'apache',
  'password' => 'Tce321',
  'active_directory' => true,
  'base' => 'DC=dominio,DC=com,DC=br',
  'group_base' => 'OU=Internet,OU=Grupos,OU=PAI,DC=dominio,DC=com,DC=br',
  'admin_group' => 'AcessoDesenvolvimento'
 }
}
gitlab_rails['ldap_sync_worker_cron'] = "30 1 * * *"
gitlab_rails['ldap_group_sync_worker_cron'] = "0 * * * *"  
```
# Utilizando script para instalação:
```sh
./install.sh
```
# Utilizando script para desinstalação:
```sh
./uninstall.sh
```

# Examplo
```
ubuntu@DESKTOP-9LDMSRO:~/Gitlab-Rancher-Kubernetes/k8s$ ./autodevops.sh
#-----------------------
kubectl check configuration
#-----------------------
kubectl Api Url
API URL => https://rancher.dominio.com.br/k8s/clusters/c-bqn4w
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

# Como configurar um pipeline de implantação contínua com GitLab CI/CD.

# Introdução

GitLab é uma plataforma de colaboração de código aberto que oferece recursos poderosos além de hospedar um repositório de código. Você pode rastrear problemas, hospedar pacotes e registros, manter wikis, configurar integração contínua (CI) e pipelines de implantação contínua (CD) e muito mais.

Neste tutorial, você construirá um pipeline de implantação contínua com GitLab. Você vai configurar o pipeline para construir uma imagem Docker, enviá-la para o registro de contêiner GitLab e implantá-la em seu servidor usando SSH. O pipeline será executado para cada confirmação enviada ao repositório.

Você implantará uma página da web pequena e estática, mas o foco deste tutorial é configurar o pipeline de CD. A página da web estática é apenas para fins de demonstração; você também pode aplicar a mesma configuração de pipeline usando outras imagens do Docker para a implantação.

Ao terminar este tutorial, você pode visitar em um navegador para obter os resultados da implantação automática.http://your_server_IP

Pré-requisitos

Para concluir este tutorial, você precisará de:

Um servidor Ubuntu 18.04 configurado seguindo o guia de configuração inicial do servidor Ubuntu 18.04, incluindo um usuário sudo não root e um firewall. 

Você precisa de pelo menos 1 GB de RAM e 1 CPU.

Docker instalado no servidor seguindo o guia Como instalar e usar o Docker no Ubuntu 18.04.

Uma conta de usuário em uma instância do GitLab com um registro de contêiner ativado. 

O plano gratuito da instância oficial do GitLab atende aos requisitos. 

Você também pode hospedar sua própria instância do GitLab seguindo o guia Como instalar e configurar o GitLab no Ubuntu 18.04 .

# Etapa 1 - Criando o Repositório GitLab

Vamos começar criando um projeto GitLab e adicionando um arquivo HTML a ele. 

Posteriormente, você copiará o arquivo HTML em uma imagem Nginx Docker, que por sua vez, implantará no servidor.

Faça login em sua instância do GitLab e clique em Novo projeto .

![step1a](https://user-images.githubusercontent.com/52961166/141691963-4b161429-d460-4a1b-9d6b-e320e6b49727.png)

1- Dê a ele um nome de projeto adequado.

2- Opcionalmente, adicione uma descrição do projeto.

3- Certifique-se de definir o nível de visibilidade como Privado ou Público, dependendo de seus requisitos.

4- Por fim, clique em Criar projeto

![step1b](https://user-images.githubusercontent.com/52961166/141691980-8e1dc6aa-e4c5-49ac-a786-0850f468067b.png)

Você será redirecionado para a página de visão geral do projeto.

Vamos criar o arquivo HTML. 

Na página de visão geral do seu projeto, clique em Novo arquivo .

![step1c](https://user-images.githubusercontent.com/52961166/141692006-eae543e3-5b8c-4410-9299-bb9b1de94256.png)

Defina o nome do arquivo como index.html e adicione o seguinte HTML ao corpo do arquivo:
```
                                       index.html
<html>
  <body>
     <h1>My Personal Website</h1>
  </body>
</html>
```
Clique em Confirmar alterações na parte inferior da página para criar o arquivo.

Este HTML produzirá uma página em branco com um título mostrando Meu site pessoal quando aberto em um navegador.

Dockerfiles são receitas usadas pelo Docker para construir imagens do Docker. 

Vamos criar um Dockerfilepara copiar o arquivo HTML em uma imagem Nginx.

Volte para a página de visão geral do projeto, clique no botão + e selecione a opção Novo arquivo .

![step1d](https://user-images.githubusercontent.com/52961166/141692084-e2ae5510-24c2-4685-9cea-df74c0d0ad80.png)

Defina o nome do arquivo como Dockerfilee adicione estas instruções ao corpo do arquivo:
```
                                       Dockerfile
FROM nginx:1.18
COPY index.html /usr/share/nginx/html
```
A FROMinstrução especifica a imagem da qual herdar - neste caso, a nginx:1.18 imagem. 1.18 é a marca da imagem que representa a versão do Nginx.

A nginx:latest tag faz referência à versão mais recente do Nginx, mas isso pode interromper seu aplicativo no futuro, e é por isso que as versões fixas são recomendadas.

A COPY instrução copia o index.html arquivo /usr/share/nginx/html na imagem do Docker. 

Este é o diretório onde o Nginx armazena conteúdo HTML estático.

Clique em Confirmar alterações na parte inferior da página para criar o arquivo.

Na próxima etapa, você configurará um executor GitLab para manter o controle de quem executa o trabalho de implantação.

# Etapa 2 - Registrando um executor GitLab

Para acompanhar os ambientes que terão contato com a chave privada SSH, você registrará seu servidor como um executor GitLab.

No pipeline de implantação, você deseja fazer login no servidor usando SSH. Para fazer isso, você armazenará a chave privada SSH em uma variável GitLab CI / CD (Etapa 5). 

A chave privada SSH é um dado muito sensível, porque é o tíquete de entrada para o seu servidor. Normalmente, a chave privada nunca sai do sistema em que foi gerada. 

No caso normal, você geraria uma chave SSH em sua máquina host e, em seguida, a autorizaria no servidor (ou seja, copiava a chave pública para o servidor) para fazer login manualmente e executar a rotina de implantação.

Aqui, a situação muda um pouco: você deseja conceder acesso de autoridade autônoma (GitLab CI / CD) ao seu servidor para automatizar a rotina de implantação. 

Portanto, a chave privada precisa deixar o sistema em que foi gerada e ser fornecida em confiança ao GitLab e outras partes envolvidas. 

Você nunca quer que sua chave privada entre em um ambiente que não seja controlado ou de sua confiança.

Além do GitLab, o executor GitLab é mais um sistema em que sua chave privada entrará. Para cada pipeline, o GitLab usa runners para realizar o trabalho pesado, ou seja, executar as tarefas que você especificou na configuração do CI / CD. Isso significa que o trabalho de implantação será executado em um executor GitLab, portanto, a chave privada será copiada para o executor de forma que ele possa fazer login no servidor usando SSH.

Se você usar GitLab Runners desconhecidos (por exemplo, corredores compartilhados ) para executar o trabalho de implantação, não perceberá que os sistemas estão entrando em contato com a chave privada. Mesmo que os executores do GitLab limpem todos os dados após a execução do trabalho, você pode evitar o envio da chave privada para sistemas desconhecidos registrando seu próprio servidor como um executor do GitLab. A chave privada será então copiada para o servidor controlado por você.

Comece fazendo login em seu servidor:

Comece fazendo login em seu servidor:
```sh
ssh sammy@your_server_IP 
 ```
Para instalar o gitlab-runnerserviço, você adicionará o repositório oficial do GitLab. 

Baixe e inspecione o script de instalação:
```sh
curl -L https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.deb.sh > script.deb.sh 
less script.deb.sh 
```
Quando estiver satisfeito com a segurança do script, execute o instalador:
```sh
sudo bash script.deb.sh 
```
Pode não ser óbvio, mas você precisa inserir sua senha de usuário não root para continuar. 

Ao executar o comando anterior, a saída será como:
```
        Output
       
[sudo] password for sammy:   % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  5945  100  5945    0     0   8742      0 --:--:-- --:--:-- --:--:--  8729
Quando o curlcomando terminar, você receberá a seguinte mensagem:

        Output
       
The repository is setup! You can now install packages.
```
Em seguida, instale o gitlab-runnerserviço:
```sh
sudo apt install gitlab-runner 
```
Verifique a instalação verificando o status do serviço:
```sh
systemctl status gitlab-runner 
``` 
Você terá active (running)na saída:
```     
        Output
       
● gitlab-runner.service - GitLab Runner
   Loaded: loaded (/etc/systemd/system/gitlab-runner.service; enabled; vendor preset: enabled)
   Active: active (running) since Mon 2020-06-01 09:01:49 UTC; 4s ago
 Main PID: 16653 (gitlab-runner)
    Tasks: 6 (limit: 1152)
   CGroup: /system.slice/gitlab-runner.service
           └─16653 /usr/lib/gitlab-runner/gitlab-runner run --working-directory /home/gitlab-runner --config /etc/gitla
```
Para registrar o executor, você precisa obter o token do projeto e o URL do GitLab:

1 - Em seu projeto GitLab, navegue até Configurações > CI/CD > Executadores .

2 - Na seção Configurar um Runner específico manualmente, você encontrará o token de registro e o URL do GitLab. 

Copie ambos para um editor de texto; você precisará deles para o próximo comando. 

Eles serão chamados de e .https://your_gitlab.comproject_token

![step2anew](https://user-images.githubusercontent.com/52961166/141692172-ba608c4e-1166-4af9-912c-3f7662f8f90d.png)

De volta ao seu terminal, registre o executor para o seu projeto:
```sh
sudo gitlab-runner register --url https://gitlab.dominio.com.br/ \
--registration-token 1Ki1xym3yp82y2k2BsJn \
--executor docker \
--description "Deployment Runner" \
--docker-image "docker:stable" \
--tag-list deployment \
--tls-ca-file /home/ubuntu/tls.crt \
--docker-privileged
```
As opções de comando podem ser interpretadas da seguinte forma:
```
--executa o registercomando de forma não interativa (especificamos todos os parâmetros como opções de comando).
--url é o URL do GitLab que você copiou da página dos corredores no GitLab.
--registration-token é o token que você copiou da página runners no GitLab.
--executoré o tipo de executor. dockerexecuta cada trabalho CI / CD em um contêiner Docker (consulte a documentação do GitLab sobre executores ).
--description é a descrição do corredor, que aparecerá no GitLab.
--docker-image é a imagem Docker padrão a ser usada em jobs de CI / CD, se não for especificada explicitamente.
--tag-listé uma lista de marcas atribuídas ao corredor. As tags podem ser usadas em uma configuração de pipeline para selecionar executores específicos para um trabalho de CI / CD. A deploymenttag permitirá que você consulte este executor específico para executar o trabalho de implantação.
--tls-ca-file especifica o caminha do certificado ssl do gitlab, para evitar o sequinte erro:
  ERROR: Registering runner... failed                 runner=1Ki1xym3 status=couldn't execute POST against https://gitlab.dominio.com.br/api/v4/runners: Post https://gitlab.dominio.com.br/api/v4/runners: x509: certificate signed by unknown authority
  PANIC: Failed to register the runner. You may be having network problems.
--docker-privilegedexecuta o contêiner Docker criado para cada trabalho de CI / CD no modo privilegiado. 
Um contêiner privilegiado tem acesso a todos os dispositivos na máquina host e tem quase o mesmo acesso ao host que os processos que executam contêineres externos (consulte a documentação do Docker sobre privilégios de tempo de execução e recursos do Linux ). 
O motivo da execução no modo privilegiado é que você pode usar o Docker-in-Docker ( dind ) para criar uma imagem do Docker em seu pipeline de CI / CD. É uma boa prática fornecer a um contêiner os requisitos mínimos de que ele precisa. 
Para você, é um requisito executar no modo privilegiado para usar o Docker-in-Docker. 
Esteja ciente de que você registrou o runner apenas para este projeto específico, onde está no controle dos comandos que estão sendo executados no contêiner privilegiado.
```
Depois de executar o gitlab-runner registercomando, você receberá a seguinte saída:
```
        Output
       
Runner registered successfully. Feel free to start it, but if it's running already the config should be automatically reloaded!
```
Verifique o processo de registro em Configurações > CI/CD > Runners no GitLab, onde o runner registrado aparecerá.

![step2b](https://user-images.githubusercontent.com/52961166/141692233-fb1c1d45-33d6-46b0-871d-68788bd3d438.png)

Na próxima etapa, você criará um usuário de implantação.

# Etapa 3 - Criação de um usuário de implantação

Você criará um usuário dedicado à tarefa de implantação. 

Posteriormente, você configurará o pipeline de CI / CD para fazer login no servidor com esse usuário.

No seu servidor, crie um novo usuário:
```sh
sudo adduser deployer 
```
Você será guiado pelo processo de criação do usuário. 

Insira uma senha forte e, opcionalmente, qualquer outra informação do usuário que você deseja especificar. 

Por fim, confirme a criação do usuário com Y.

Adicione o usuário ao grupo Docker:
```sh
sudo usermod -aG docker deployer 
```
Isso permite que o implantador execute o dockercomando, que é necessário para realizar a implantação.

Aviso: adicionar um usuário ao grupo Docker concede privilégios equivalentes ao usuário root. 

Para obter mais detalhes sobre como isso afeta a segurança do seu sistema, consulte Docker Daemon Attack Surface .

Na próxima etapa, você criará uma chave SSH para poder fazer login no servidor como implementador .

# Etapa 4 - Configurando uma chave SSH

Você vai criar uma chave SSH para o usuário de implantação. Posteriormente, o GitLab CI/CD usará a chave para fazer login no servidor e executar a rotina de implantação.

Vamos começar mudando para o usuário implantador recém-criado para o qual você gerará a chave SSH:
```sh
su deployer 
```
Você será solicitado a fornecer a senha do implantador para concluir a troca de usuário.

Em seguida, gere uma chave SSH de 4096 bits. É importante responder às perguntas do ssh-keygencomando corretamente:

Primeira pergunta: responda com ENTER, que armazena a chave no local padrão (o restante deste tutorial assume que a chave está armazenada no local padrão).

Segunda pergunta: configura uma senha para proteger a chave privada SSH (a chave usada para autenticação). Se você especificar uma senha, terá que inseri-la cada vez que a chave privada for usada. 

Em geral, uma frase secreta adiciona outra camada de segurança às chaves SSH, o que é uma boa prática. 

Alguém com a chave privada também precisaria da senha para usar a chave. Para os fins deste tutorial, é importante que você tenha uma senha longa vazia, porque o pipeline CI/CD será executado de forma não interativa e, portanto, não permite inserir uma senha longa.

Para resumir, execute o seguinte comando e confirme as duas perguntas com ENTERpara criar uma chave SSH de 4096 bits e armazene-a no local padrão com uma senha longa vazia:
```sh
ssh-keygen -b 4096 
```
Para autorizar a chave SSH para o usuário implantador , você precisa anexar a chave pública ao authorized_keysarquivo:
```sh
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys 
```
~ é a abreviação de usuário inicial no Linux. 

O catprograma imprimirá o conteúdo de um arquivo; aqui você usa o >>operador para redirecionar a saída cate anexá-la ao authorized_keysarquivo.

Nesta etapa, você criou um par de chaves SSH para o pipeline CI/CD para fazer login e implantar o aplicativo. 

Em seguida, você armazenará a chave privada no GitLab para torná-la acessível durante o processo de pipeline.

# Etapa 5 - Armazenar a chave privada em uma variável GitLab CI/CD

Você armazenará a chave privada SSH em uma variável de arquivo CI/CD do GitLab para que o pipeline possa usar a chave para fazer login no servidor.

Quando o GitLab cria um pipeline de CI/CD, ele envia todas as variáveis ​​ao executor correspondente e as variáveis ​​são definidas como variáveis ​​de ambiente durante o trabalho. 

Em particular, os valores das variáveis do arquivo são armazenados em um arquivo e a variável de ambiente conterá o caminho para esse arquivo.

Enquanto estiver na seção de variáveis, você também adicionará uma variável para o IP do servidor e o usuário do servidor, que informará o pipeline sobre o servidor de destino e o usuário para fazer login.

Comece mostrando a chave privada SSH:
```sh
cat ~/.ssh/id_rsa 
```
Copie a saída para sua área de transferência. 

Certifique-se de adicionar uma quebra de linha após -----END RSA PRIVATE KEY-----:
```
~ / .ssh / id_rsa
-----BEGIN RSA PRIVATE KEY-----
...
-----END RSA PRIVATE KEY-----
``` 
Agora navegue para Configurações > CI/CD > Variáveis em seu projeto GitLab e clique em Adicionar variável. 

Preencha o formulário da seguinte forma:
```
- Chave: ID_RSA
- Valor: cole sua chave privada SSH de sua área de transferência (incluindo uma quebra de linha no final).
- Tipo: Arquivo
- Escopo do ambiente: Todos (padrão)
- Proteger variável: verificado
- Variável de máscara: Desmarcada
```
Observação: a variável não pode ser mascarada porque não atende aos requisitos de expressão regular (consulte a documentação do GitLab sobre variáveis ​​mascaradas ). 

No entanto, a chave privada nunca aparecerá no log do console, o que torna o mascaramento obsoleto.

Um arquivo contendo a chave privada será criado no executor para cada trabalho de CI/CD e seu caminho será armazenado na $ID_RSAvariável de ambiente.

Crie outra variável com o IP do seu servidor. 

Clique em Adicionar variável e preencha o formulário da seguinte forma:
```
- Chave: SERVER_IP
- Valor: your_server_IP
- Tipo: Variável
- Escopo do ambiente: Todos (padrão)
- Proteger variável: verificado
- Variável de máscara: verificado
```
Finalmente, crie uma variável com o usuário de login. 

Clique em Adicionar variável e preencha o formulário da seguinte forma:
```
- Chave: SERVER_USER
- Valor: deployer
- Tipo: Variável
- Escopo do ambiente: Todos (padrão)
- Proteger variável: verificado
- Variável de máscara: verificado
```
Agora você armazenou a chave privada em uma variável GitLab CI / CD, que disponibiliza a chave durante a execução do pipeline. 

Na próxima etapa, você passará a configurar o pipeline de CI / CD.

# Etapa 6 - Configurando o .gitlab-ci.yml Arquivo

Você vai configurar o pipeline GitLab CI / CD. O pipeline criará uma imagem Docker e a enviará para o registro do contêiner. 

O GitLab fornece um registro de contêiner para cada projeto. 

Você pode explorar o registro do contêiner acessando Pacotes e Registros > Registro do Contêiner em seu projeto GitLab (leia mais na documentação do registro do contêiner do GitLab ). 

A etapa final do pipeline é fazer login no servidor, obter a imagem Docker mais recente e remover o contêiner antigo e inicie um novo.

Agora você vai criar o .gitlab-ci.ymlarquivo que contém a configuração do pipeline. No GitLab, vá para a página de visão geral do projeto , clique no botão + e selecione Novo arquivo. 

Em seguida, defina o nome do arquivo como .gitlab-ci.yml.

(Alternativamente, você pode clonar o repositório e fazer todas as alterações a seguir .gitlab-ci.ymlem sua máquina local e, em seguida, enviar e enviar para o repositório remoto.)

Para começar, adicione o seguinte:
```
                                                       .gitlab-ci.yml
stages:
  - publish
  - deploy
``` 
Cada trabalho é atribuído a um estágio. 

Os trabalhos atribuídos ao mesmo estágio são executados em paralelo (se houver corredores suficientes disponíveis). 

As etapas serão executadas na ordem em que foram especificadas. Aqui, o publishestágio vai primeiro e o deploysegundo. 

Os estágios sucessivos só começam quando o estágio anterior foi concluído com sucesso (ou seja, todos os trabalhos foram aprovados). 

Os nomes das fases podem ser escolhidos arbitrariamente.

Quando você deseja combinar esta configuração de CD com seu pipeline de CI existente, que testa e constrói o aplicativo, você pode adicionar os estágios publishe deployapós os estágios existentes, de forma que a implantação só ocorra se os testes forem aprovados.

Em seguida, adicione ao seu .gitlab-ci.ymlarquivo:
```
                                                          .gitlab-ci.yml
---
variables:
  TAG_LATEST: $CI_REGISTRY_IMAGE/$CI_COMMIT_REF_NAME:latest
  TAG_COMMIT: $CI_REGISTRY_IMAGE/$CI_COMMIT_REF_NAME:$CI_COMMIT_SHORT_SHA
``` 
A seção de variáveis define as variáveis ​​de ambiente que estarão disponíveis no contexto de uma scriptseção de trabalho. 

Essas variáveis ​​estarão disponíveis como variáveis ​​de ambiente Linux usuais; ou seja, você pode referenciá-los no script prefixando com um cifrão, como $TAG_LATEST. 

O GitLab cria algumas variáveis ​​predefinidas para cada trabalho que fornecem informações específicas do contexto, como o nome do branch ou o hash de confirmação no qual o trabalho está trabalhando (leia mais sobre a variável predefinida ). 

Aqui você compõe duas variáveis ​​de ambiente a partir de variáveis ​​predefinidas. Eles representam:
```
CI_REGISTRY_IMAGE: Representa a URL do registro do contêiner vinculado ao projeto específico. 
                   Este URL depende da instância do GitLab. 
	           Por exemplo, URLs de registo para gitlab.com projetos seguem o padrão: 
		   Mas, como o GitLab fornecerá essa variável, você não precisa saber a URL exata.registry.gitlab.com/your_user/your_project

CI_COMMIT_REF_NAME: O nome do branch ou tag para o qual o projeto é construído.

CI_COMMIT_SHORT_SHA: Os primeiros oito caracteres da revisão de commit para a qual o projeto foi construído.
```
Ambas as variáveis ​​são compostas por variáveis ​​predefinidas e serão usadas para marcar a imagem do Docker.
```
TAG_LATEST irá adicionar a latesttag à imagem. Esta é uma estratégia comum para fornecer uma tag que sempre representa a versão mais recente. 
Para cada implantação, a latestimagem será substituída no registro do contêiner pela imagem recém-construída do Docker.

TAG_COMMIT, por outro lado, usa os primeiros oito caracteres do SHA de confirmação sendo implantado como a tag de imagem, criando assim uma imagem Docker exclusiva para cada confirmação. Você poderá rastrear o histórico das imagens do Docker até a granularidade dos commits do Git. 
Esta é uma técnica comum ao fazer implantações contínuas, porque permite que você implante rapidamente uma versão mais antiga do código no caso de uma implantação com defeito.
```
Conforme você explorará nas próximas etapas, o processo de reverter uma implantação para uma revisão Git mais antiga pode ser feito diretamente no GitLab.

$CI_REGISTRY_IMAGE/$CI_COMMIT_REF_NAMEespecifica o nome da base da imagem Docker. De acordo com a documentação do GitLab , o nome de uma imagem Docker deve seguir este esquema:
```
        image name scheme
       
<registry URL>/<namespace>/<project>/<image>
$CI_REGISTRY_IMAGErepresenta a <registry URL>/<namespace>/<project>parte e é obrigatório porque é a raiz do registro do projeto. $CI_COMMIT_REF_NAMEé opcional, mas útil para hospedar imagens Docker para diferentes branches. Neste tutorial, você trabalhará apenas com um branch, mas é bom construir uma estrutura extensível. Em geral, existem três níveis de nomes de repositório de imagem suportados pelo GitLab:

        repository name levels
       
registry.example.com/group/project:some-tag
registry.example.com/group/project/image:latest
registry.example.com/group/project/my/image:rc1
```
Para sua TAG_COMMIT variável, você usou a segunda opção, onde imageserá substituída pelo nome do ramo.

Em seguida, adicione o seguinte ao seu .gitlab-ci.ymlarquivo:
```
                                                      .gitlab-ci.yml
---
publish:
  image: docker:latest
  stage: publish
  services:
    - docker:dind
  script:
    - docker build -t $TAG_COMMIT -t $TAG_LATEST .
    - docker login -u gitlab-ci-token -p $CI_BUILD_TOKEN $CI_REGISTRY
    - docker push $TAG_COMMIT
    - docker push $TAG_LATEST
``` 
A publish seção é o primeiro trabalho em sua configuração de CI / CD. Vamos decompô-lo:

image é a imagem Docker a ser usada para este trabalho. 

O executor GitLab criará um contêiner do Docker para cada trabalho e executará o script dentro desse contêiner. 

docker:latest imagem garante que o docker comando estará disponível.

stage atribui o trabalho ao publish palco.
services especifica Docker-in-Docker -o dind serviço. 

Este é o motivo pelo qual você registrou o executor GitLab no modo privilegiado.

A script seção do publishtrabalho especifica os comandos do shell a serem executados para este trabalho. 

O diretório de trabalho será definido como a raiz do repositório quando esses comandos forem executados.

docker build ...: Constrói a imagem Docker com base no Dockerfilee marca-a com a última marca de confirmação definida na seção de variáveis.
docker login ...: Registra o Docker no registro de contêiner do projeto. 

Você usa a variável predefinida $CI_BUILD_TOKEN como um token de autenticação. 

O GitLab gerará o token e permanecerá válido por toda a vida do trabalho.

docker push  ...: Envia ambas as tags de imagem para o registro do contêiner.

Em seguida, adicione o deploytrabalho ao seu .gitlab-ci.yml:
```
                                               .gitlab-ci.yml
---
deploy:
  image: alpine:latest
  stage: deploy
  tags:
    - deployment
  script:
    - chmod og= $ID_RSA
    - apk update && apk add openssh-client
    - ssh -i $ID_RSA -o StrictHostKeyChecking=no $SERVER_USER@$SERVER_IP "docker login -u gitlab-ci-token -p $CI_BUILD_TOKEN $CI_REGISTRY"
    - ssh -i $ID_RSA -o StrictHostKeyChecking=no $SERVER_USER@$SERVER_IP "docker pull $TAG_COMMIT"
    - ssh -i $ID_RSA -o StrictHostKeyChecking=no $SERVER_USER@$SERVER_IP "docker container rm -f my-app || true"
    - ssh -i $ID_RSA -o StrictHostKeyChecking=no $SERVER_USER@$SERVER_IP "docker run -d -p 80:80 --name my-app $TAG_COMMIT"
``` 
Alpine é uma distribuição Linux leve e é suficiente como uma imagem Docker aqui. Você atribui o trabalho ao deploypalco. 

A tag de implantação garante que o trabalho será executado em corredores marcados deployment, como o corredor que você configurou na Etapa 2.

A scriptseção do deploytrabalho começa com dois comandos configurativos:
```
chmod og=$ID_RSA: Revoga todas as permissões para o grupo e outros da chave privada, de forma que apenas o proprietário possa usá-la. 
```
Este é um requisito, caso contrário, o SSH se recusa a trabalhar com a chave privada.
```sh
apk update && apk add openssh-client: 
```
Atualiza o gerenciador de pacotes da Alpine (apk) e instala o openssh-client, que fornece o sshcomando.

ssh Seguem quatro comandos consecutivos. 

O padrão para cada um é:
```
        ssh connect pattern for all deployment commands
       
ssh -i $ID_RSA -o StrictHostKeyChecking=no $SERVER_USER@$SERVER_IP "command"
```
Em cada sshinstrução que você está executando commandno servidor remoto. 

Para fazer isso, você se autentica com sua chave privada.

As opções são as seguintes:
```
-i significa arquivo de identidade e $ID_RSAé a variável GitLab que contém o caminho para o arquivo de chave privada.
-o StrictHostKeyChecking=no certifique-se de ignorar a questão, se você confia ou não no host remoto. 
```
Esta pergunta não pode ser respondida em um contexto não interativo, como o pipeline.
```
$SERVER_USER e $SERVER_IP são as variáveis ​​do GitLab que você criou na Etapa 5. 
```
Eles especificam o host remoto e o usuário de login para a conexão SSH.

command será executado no host remoto.

Em última análise, a implantação ocorre executando estes quatro comandos em seu servidor:
```
docker login        ...: Registra o Docker no registro do contêiner.
docker pull         ...: Extrai a imagem mais recente do registro do contêiner.
docker container rm ...: Exclui o contêiner existente, se houver. || true garante que o código de saída seja sempre bem-sucedido, mesmo se não houver nenhum contêiner em                                  execução com o nome my-app. 
                         Isso garante uma rotina de exclusão se existe sem quebrar o pipeline quando o contêiner não existe (por exemplo, para a primeira implantação).
docker run          ...: Inicia um novo contêiner usando a imagem mais recente do registro. 
```
O contêiner será nomeado my-app. 

A porta 80 no host será vinculada à porta 80 do contêiner (o pedido é -p host:container). -d inicia o contêiner no modo desanexado, caso contrário, o pipeline ficaria preso esperando o comando terminar.

Observação: pode parecer estranho usar SSH para executar esses comandos em seu servidor, considerando que o executor GitLab que executa os comandos é exatamente o mesmo servidor. 

Ainda assim, é necessário, porque o executor executa os comandos em um contêiner Docker, portanto, você implantaria dentro do contêiner em vez do servidor se executasse os comandos sem o uso de SSH. 

Alguém poderia argumentar que, em vez de usar o Docker como um executor runner, você poderia usar o executor do shellpara executar os comandos no próprio host. 

Mas, isso criaria uma restrição para o pipeline, ou seja, o executor deve ser o mesmo servidor que você deseja implantar. 

Esta não é uma solução sustentável e extensível porque um dia você pode querer migrar o aplicativo para um servidor diferente ou usar um servidor runner diferente. 

Em qualquer caso, faz sentido usar SSH para executar os comandos de implantação, seja por motivos técnicos ou relacionados à migração.

Vamos continuar adicionando isso ao trabalho de implantação em .gitlab-ci.yml:
```
                                                      .gitlab-ci.yml
. . .
deploy:
. . .
  environment:
    name: production
    url: http://your_server_IP
  only:
    - master
``` 
Os ambientes GitLab permitem que você controle as implantações dentro do GitLab. Você pode examinar os ambientes em seu projeto GitLab acessando Operações> Ambientes . 

Se o pipeline ainda não foi concluído, não haverá ambiente disponível, pois nenhuma implantação ocorreu até o momento.

Quando um trabalho de pipeline define uma environmentseção, o GitLab cria uma implantação para o ambiente fornecido (aqui production) cada vez que o trabalho é concluído com sucesso. 

Isso permite que você rastreie todas as implantações criadas pelo GitLab CI/CD. 

Para cada implantação, você pode ver o commit relacionado e o branch para o qual foi criado.

Também há um botão disponível para reimplantação que permite reverter para uma versão mais antiga do software. 

O URL que foi especificado na environmentseção será aberto ao clicar no botão Exibir implantação .

A only seção define os nomes das ramificações e marcas para as quais o trabalho será executado. 

Por padrão, o GitLab iniciará um pipeline para cada push para o repositório e executará todos os trabalhos (desde que o .gitlab-ci.ymlarquivo exista). 

A only seção é uma opção de restringir a execução do trabalho a certas ramificações/tags. 

Aqui você deseja executar o trabalho de implantação masterapenas para a filial. 

Para definir regras mais complexas sobre se um trabalho deve ser executado ou não, dê uma olhada na sintaxe das regras .

Observação: em outubro de 2020, o GitHub mudou sua convenção de nomenclatura para o branch padrão de masterpara main. 

Outros provedores, como o GitLab e a comunidade de desenvolvedores em geral, estão começando a seguir essa abordagem. 

O termo masterbranch é usado neste tutorial para denotar o branch padrão para o qual você pode ter um nome diferente.

Seu .gitlab-ci.yml arquivo completo terá a seguinte aparência:
```
                                                     .gitlab-ci.yml

stages:
  - publish
  - deploy

variables:
  TAG_LATEST: $CI_REGISTRY_IMAGE/$CI_COMMIT_REF_NAME:latest
  TAG_COMMIT: $CI_REGISTRY_IMAGE/$CI_COMMIT_REF_NAME:$CI_COMMIT_SHORT_SHA

publish:
  image: docker:latest
  stage: publish
  services:
    - docker:dind
  script:
    - docker build -t $TAG_COMMIT -t $TAG_LATEST .
    - docker login -u gitlab-ci-token -p $CI_BUILD_TOKEN $CI_REGISTRY
    - docker push $TAG_COMMIT
    - docker push $TAG_LATEST

deploy:
  image: alpine:latest
  stage: deploy
  tags:
    - deployment
  script:
    - chmod og= $ID_RSA
    - apk update && apk add openssh-client
    - ssh -i $ID_RSA -o StrictHostKeyChecking=no $SERVER_USER@$SERVER_IP "docker login -u gitlab-ci-token -p $CI_BUILD_TOKEN $CI_REGISTRY"
    - ssh -i $ID_RSA -o StrictHostKeyChecking=no $SERVER_USER@$SERVER_IP "docker pull $TAG_COMMIT"
    - ssh -i $ID_RSA -o StrictHostKeyChecking=no $SERVER_USER@$SERVER_IP "docker container rm -f my-app || true"
    - ssh -i $ID_RSA -o StrictHostKeyChecking=no $SERVER_USER@$SERVER_IP "docker run -d -p 80:80 --name my-app $TAG_COMMIT"
  environment:
    name: production
    url: http://your_server_IP
  only:
    - master
``` 
Por fim, clique em Commit changes na parte inferior da página no GitLab para criar o .gitlab-ci.ymlarquivo. Como alternativa, quando você clonar o repositório Git localmente, envie e envie o arquivo para o remoto.

Você criou uma configuração GitLab CI / CD para construir uma imagem Docker e implantá-la em seu servidor. Na próxima etapa, você está validando a implantação.

# Etapa 7 - Validando a implantação

Agora você validará a implantação em vários locais do GitLab, bem como em seu servidor e em um navegador.

Quando um .gitlab-ci.ymlarquivo é enviado ao repositório, o GitLab o detecta automaticamente e inicia um pipeline de CI / CD. 

No momento em que você criou o .gitlab-ci.ymlarquivo, o GitLab iniciou o primeiro pipeline.

Acesse CI/CD > Pipelines em seu projeto GitLab para ver o status do pipeline. 

Se os trabalhos ainda estiverem em execução / pendentes, espere até que sejam concluídos. 

Você verá um pipeline Aprovado com duas marcas de seleção verdes, indicando que o trabalho de publicação e implantação foi executado com êxito.

A página de visão geral do pipeline mostrando um pipeline aprovado

Vamos examinar o pipeline. Clique no botão aprovado na coluna Status para abrir a página de visão geral do pipeline. 

Você obterá uma visão geral das informações gerais, como:

Duração da execução de todo o pipeline.

Para o qual commit e branch o pipeline foi executado.

Solicitações de mesclagem relacionadas. 

Se houver uma solicitação de mesclagem aberta para a filial responsável, ela aparecerá aqui.

Todos os trabalhos executados neste pipeline, bem como seu status.

Em seguida, clique no botão de implantação para abrir a página de resultados do trabalho de implantação.

![step7c](https://user-images.githubusercontent.com/52961166/141692491-52200bfd-bec0-4b18-a341-8c2d9e6ec8fb.png)

Na página de resultados do trabalho, você pode ver a saída do shell do script do trabalho. 

Este é o lugar para procurar ao depurar um pipeline com falha. Na barra lateral direita, você encontrará a tag de implantação que adicionou a este trabalho e que ela foi executada em seu Deployment Runner .

Se você rolar para o topo da página, encontrará a mensagem Este trabalho foi implantado para produção. 

O GitLab reconhece que uma implantação ocorreu por causa da seção do ambiente de trabalho. 

Clique no link de produção para ir para o ambiente de produção.

![step7b](https://user-images.githubusercontent.com/52961166/141692507-68e4eaad-46e6-43a3-af14-f281cd5f0088.png)

Você terá uma visão geral de todas as implantações de produção. 

Houve apenas uma implantação até agora. Para cada implantação, há um botão de reimplantação disponível à direita. 

Uma reimplantação repetirá o trabalho de implantação desse pipeline específico.

Se uma reimplantação funciona conforme o esperado depende da configuração do pipeline, porque ela não fará mais do que repetir o trabalho de implantação nas mesmas circunstâncias. 

Como você configurou para implantar uma imagem Docker usando o SHA de confirmação como uma tag, uma reimplantação funcionará para seu pipeline.

Observação: o registro do contêiner GitLab pode ter uma política de expiração. 

A política de expiração remove regularmente imagens e tags mais antigas do registro do contêiner. 

Como consequência, uma implantação mais antiga do que a política de expiração não seria reimplantada, porque a imagem Docker para esse commit terá sido removida do registro. 

Você pode gerenciar a política de expiração em Configurações> CI/CD> Política de expiração de tag do Container Registry . 

O intervalo de expiração geralmente é definido como algo alto, como 90 dias. 

Mas quando você se depara com o caso de tentar implantar uma imagem que foi removida do registro devido à política de expiração, você pode resolver o problema executando novamente a publicação trabalho desse pipeline específico também, que recriará e enviará a imagem para o commit fornecido ao registro.

Em seguida, clique no botão Exibir implantação , que será aberto em um navegador e você deverá ver o título Meu site pessoal .http://your_server_IP

Por fim, queremos verificar o contêiner implantado em seu servidor. 

Vá para o seu terminal e certifique-se de fazer login novamente, se você já tiver desconectado (funciona para ambos os usuários, sammy e implantador ):
```
ssh sammy@your_server_IP 
``` 
Agora liste os contêineres em execução:
```sh
docker container ls 
 
Que listará o my-appcontêiner:

        Output
       
CONTAINER ID        IMAGE                                                          COMMAND                  CREATED             STATUS              PORTS                NAMES
5b64df4b37f8        registry.your_gitlab.com/your_gitlab_user/your_project/master:your_commit_sha   "nginx -g 'daemon of…"   4 hours ago         Up 4 hours          0.0.0.0:80->80/tcp   my-app
```
Leia o guia Como instalar e usar o Docker no Ubuntu 18.04 para saber mais sobre o gerenciamento de contêineres do Docker.

Agora você validou a implantação. 

Na próxima etapa, você passará pelo processo de reversão de uma implantação.

# Etapa 8 - Revertendo uma implantação

Em seguida, você atualizará a página da web, que criará uma nova implantação e, em seguida, reimplantará a implantação anterior usando ambientes GitLab. 

Isso cobre o caso de uso de uma reversão de implantação no caso de uma implantação defeituosa.

Comece fazendo uma pequena alteração no index.html arquivo:

No GitLab, vá para a visão geral do projeto e abra o index.html arquivo.

Clique no botão Editar para abrir o editor online.

Altere o conteúdo do arquivo para o seguinte:
```
                                                             index.html

<html>
  <body>
    <h1>My Enhanced Personal Website</h1>
  </body>
</html>
``` 
Salve as alterações clicando em Confirmar alterações na parte inferior da página.

Um novo pipeline será criado para implantar as mudanças. 

No GitLab, vá para CI/CD> Pipelines. 

Quando o pipeline for concluído, você pode abrir em um navegador a página da web atualizada que agora mostra Meu site pessoal aprimorado em vez de Meu site pessoal .http://your_server_IP

Ao passar para Operações> Ambientes> produção, você verá a implantação recém-criada. 

Agora clique no botão reimplantar da implantação inicial mais antiga:

![step8a](https://user-images.githubusercontent.com/52961166/141692562-6d125b60-8fd8-4988-8d0b-ca11871e0250.png)

Confirme o pop-up clicando no botão Reverter .

O trabalho de implantação desse pipeline mais antigo será reiniciado e você será redirecionado para a página de visão geral do trabalho. 

Aguarde a conclusão do trabalho e abra em um navegador, onde verá o título inicial Meu site pessoal aparecendo novamente.http://your_server_IP

Vamos resumir o que você conseguiu ao longo deste tutorial.

Conclusão

Neste tutorial, você configurou um pipeline de implantação contínua com GitLab CI/CD. 

Você criou um pequeno projeto da web que consiste em um arquivo HTML e um Dockerfile. 

Em seguida, você configurou a configuração do .gitlab-ci.yml pipeline para:

Crie a imagem Docker.

Envie a imagem do Docker para o registro do contêiner.

Efetue login no servidor, obtenha a imagem mais recente, pare o contêiner atual e inicie um novo.

O GitLab agora implantará a página da web em seu servidor para cada envio para o repositório.

Além disso, você verificou uma implantação no GitLab e em seu servidor. 

Você também criou uma segunda implantação e voltou para a primeira implantação usando ambientes GitLab, o que demonstra como você lida com implantações defeituosas.

Neste ponto, você automatizou toda a cadeia de implantação. Agora você pode compartilhar alterações de código com mais frequência com o mundo e/ou o cliente. 

Como resultado, os ciclos de desenvolvimento tendem a se tornar mais curtos, pois menos tempo é necessário para coletar feedback e publicar as mudanças no código.
