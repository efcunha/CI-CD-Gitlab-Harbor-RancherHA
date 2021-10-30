# gitlab
gitlab deployment with docker-compose and kubernetes<br/>
<br/>
Requirements:<br/>
Kubernetes cluster<br/>
Kubectl installed and configured on control machine<br/>
<br/>
### usage
<br/>
<pre>
kubectl apply -f ./
</pre>
<br/>
# enabling active directory
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
<pre>
kubectl cluster-info | grep -E 'Kubernetes master|Kubernetes control plane' | awk '/http/ {print $NF}'<br/>
kubectl get secret <secret name> -o jsonpath="{['data']['ca\.crt']}" | base64 --decode<br/>
kubectl get secrets<br/>
kubectl get secret default-token-zzwsp -o jsonpath="{['data']['ca\.crt']}" | base64 --decode<br/>
kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep gitlab | awk '{print $1}')<br/>
</pre>
<br/>
