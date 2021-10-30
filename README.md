# GITLAB
Gitlab implantação no Rancher HA e kubernetes<br/>
<br/>
Requerimentos:<br/>
Kubernetes cluster<br/>
Kubectl instalado e configurado nos control machine<br/>
<br/>
### Utilizando
<br/>
<pre>
kubectl apply -f ./
</pre>
<br/>
# Abilitando Active Directory
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
