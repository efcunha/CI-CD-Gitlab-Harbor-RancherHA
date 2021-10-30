# GITLAB
Gitlab implantação no Rancher HA e kubernetes<br/>
<br/>
Requerimentos:<br/>
Kubernetes cluster<br/>
Kubectl instalado e configurado nos control machine<br/>
<br/>
### Utilizando script para instalação:
<br/>
<pre>
./install.sh
</pre>
<br/>
### Utilizando script para desinstalação:
<br/>
<pre>
./uninstall.sh
</pre>
<br/>
# Abilitando Active Directory
# Altere os campos com os valores de conexão de seu Actibe Directory
# E adicione no final do arquivo 01-secrets.yml
<br/>
<pre>
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
</pre>
<br/>
