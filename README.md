Automated builds for:

Dev with Nginx (latest is 1.14.1, not spotted in the CVEs list)

Prepare cert and key and ca.cert in advance and put them to the /etc/nginx/ in docker image

deployments.app

```
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: nginx-ldap-auth-proxy
  name: nginx-ldap-auth-proxy
  namespace: NAMESPACE_NAME
spec:
  progressDeadlineSeconds: 600
  replicas: 1
  revisionHistoryLimit: 10
  selector:
    matchLabels:
      app: nginx-ldap-auth-proxy
      release: nginx-ldap-auth
  strategy:
    rollingUpdate:
      maxSurge: 25%
      maxUnavailable: 25%
    type: RollingUpdate
  template:
    metadata:
      creationTimestamp: null
      labels:
        app: nginx-ldap-auth-proxy
        release: nginx-ldap-auth
    spec:
      containers:
      - env:
        - name: LDAP_BIND_PASSWORD
          valueFrom:
            secretKeyRef:
              key: ldapBindPassword
              name: nginx-ldap-auth-proxy
        image: docker.io/verdyr/nginx-ldap:latest
        imagePullPolicy: IfNotPresent
        livenessProbe:
          failureThreshold: 3
          httpGet:
            path: /_ping
            port: 443
            scheme: HTTPS
          periodSeconds: 20
          successThreshold: 1
          timeoutSeconds: 5
        name: nginx-ldap-auth-proxy
        ports:
        - containerPort: 443
          protocol: TCP
        readinessProbe:
          failureThreshold: 3
          httpGet:
            path: /_ping
            port: 443
            scheme: HTTPS
          periodSeconds: 20
          successThreshold: 1
          timeoutSeconds: 5
        resources: {}
        terminationMessagePath: /dev/termination-log
        terminationMessagePolicy: File
        volumeMounts:
        - mountPath: /etc/nginx/nginx.conf
          name: config
          subPath: nginx.conf
      dnsPolicy: Default
      imagePullSecrets:
      - name: YOUR_SECRET_HERE
      restartPolicy: Always
      schedulerName: default-scheduler
      securityContext: {}
      serviceAccount: nginx-operator
      serviceAccountName: nginx-operator
      terminationGracePeriodSeconds: 30
      volumes:
      - configMap:
          defaultMode: 420
          name: nginx-ldap-auth-proxy
        name: config
```


Use nginx.conf via Configmap in K8s namespace of your choice

1. Adjust the LDAPS details according to what you are provided from LDAP
2. Adjust the "server" name and port according to what you want to guard
3. If group based filter is needed then - use group_attribute and group DN
4. Strict validation with - satisfy all

```
apiVersion: v1
kind: ConfigMap
metadata:
  labels:
    app: nginx-ldap-auth-proxy
  name: nginx-ldap-auth-proxy
  namespace: NAMESPACE_NAME
data:
  nginx.conf: |-
    worker_processes 10;
    worker_rlimit_nofile 16384;
    events {
        worker_connections 1024;
    }
    http {
 
        upstream backend-server {
            server APP_BACKEND_SERVER_FQDN:PORT_NUM;
        }
        ldap_server ldapserver {
            url ldaps://LDAPS_FQDN:636/OU=Users,DC=subdomain,DC=domain,DC=com?sAMAccountName?sub?(&(objectClass=person));
            binddn "CN=SVC_ACCOUNT_NAME_USED,OU=Applications,DC=subdomain,DC=domain,DC=com";
            binddn_passwd PASSWORD_HERE_TO_SET;
            group_attribute memberOf;
            group_attribute_is_dn on;
            require group "CN=All_Internal_Users,CN=GroupName,OU=OU_NAME,OU=OU_NAME,DC=subdomain,DC=domain,DC=Com";
            require valid_user;
            satisfy all;
        }
 
        server {
 
            listen                  443 ssl;
            ssl_verify_client       off;
            server_name             ldapauth-proxy;
            add_header              'Strict-Transport-Security' "max-age=1728000; includeSubDomains" always;
 
            ssl_certificate         k8s_nodes.crt;
            ssl_certificate_key     k8s_nodes.key;
            ssl_client_certificate  k8s_nodes.ca.crt;
            ssl_protocols           TLSv1.2;
            ssl_ciphers             HIGH:!aNULL:!MD5;
 
            error_log /var/log/nginx/error.log debug;
            access_log /var/log/nginx/access.log;
 
            client_max_body_size 0;
 
            chunked_transfer_encoding on;
 
            location / {
                auth_ldap "Auth Required";
                auth_ldap_servers ldapserver;
                proxy_set_header  X-Ldap-Starttls "true";
                proxy_pass                       https://backend-server;
                proxy_ssl_verify                 off;
                proxy_set_header  Host           $http_host;   # required for docker client's sake
                proxy_set_header  X-Real-IP      $remote_addr; # pass on real client's IP
                proxy_set_header  Authorization  ""; # see https://github.com/dotcloud/docker-registry/issues/170
                proxy_set_header  X_FORWARDED_PROTO https;
                proxy_read_timeout               900;
 
                if ($request_method = 'OPTIONS') {
                   add_header 'Access-Control-Allow-Origin' '*.domain2.com, *.domain1.com';
                   add_header 'Access-Control-Allow-Methods' 'GET, POST, OPTIONS';
                   #
                   # Custom headers and headers various browsers *should* be OK with but aren't
                   #
                   add_header 'Access-Control-Allow-Headers' 'DNT,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Range';
                   #
                   # Tell client that this pre-flight info is valid for 20 days
                   #
                   add_header 'Access-Control-Max-Age' 1728000;
                   add_header 'Content-Type' 'text/plain; charset=utf-8';
                   add_header 'Content-Length' 0;
                   add_header 'Strict-Transport-Security' "max-age=1728000; includeSubDomains" always;
                   return 204;
                }
                if ($request_method = 'POST') {
                   add_header 'Access-Control-Allow-Origin' '*.domain2.com, *.domain1.com';
                   add_header 'Access-Control-Allow-Methods' 'GET, POST, OPTIONS';
                   add_header 'Access-Control-Allow-Headers' 'DNT,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Range';
                   add_header 'Access-Control-Expose-Headers' 'Content-Length,Content-Range';
                   add_header 'Strict-Transport-Security' "max-age=1728000; includeSubDomains" always;
                }
                if ($request_method = 'GET') {
                   add_header 'Access-Control-Allow-Origin' '*.domain2.com, *.domain1.com';
                   add_header 'Access-Control-Allow-Methods' 'GET, POST, OPTIONS';
                   add_header 'Access-Control-Allow-Headers' 'DNT,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Range';
                   add_header 'Access-Control-Expose-Headers' 'Content-Length,Content-Range';
                   add_header 'Strict-Transport-Security' "max-age=1728000; includeSubDomains" always;
                }
 
            }
 
            location /_ping {                   # NB!: use this location ONLY during dev/test, - remove entire block before stage/production
                auth_basic off;
                root   /usr/share/nginx/html;
                stub_status on;
            }
 
            location ~* "(eval\()"  { deny all; }
            location ~* "(127\.0\.0\.1)"  { deny all; }
            location ~* "([a-z0-9]{2000})"  { deny all; }
            location ~* "(javascript\:)(.*)(\;)"  { deny all; }
            location ~* "(base64_encode)(.*)(\()"  { deny all; }
            location ~* "(GLOBALS|REQUEST)(=|\[|%)"  { deny all; }
            location ~* "(<|%3C).*script.*(>|%3)" { deny all; }
            location ~ "(\\|\.\.\.|\.\./|~|`|<|>|\|)" { deny all; }
            location ~* "(boot\.ini|etc/passwd|self/environ)" { deny all; }
            location ~* "(thumbs?(_editor|open)?|tim(thumb)?)\.php" { deny all; }
            location ~* "(\'|\")(.*)(drop|insert|md5|select|union)" { deny all; }
            location ~* "(https?|ftp|php):/" { deny all; }
            location ~* "(=\\\'|=\\%27|/\\\'/?)\." { deny all; }
            location ~* "/(\$(\&)?|\*|\"|\.|,|&|&amp;?)/?$" { deny all; }
            location ~ "(\{0\}|\(/\(|\.\.\.|\+\+\+|\\\"\\\")" { deny all; }
            location ~ "(~|`|<|>|:|;|%|\\|\s|\{|\}|\[|\]|\|)" { deny all; }
            location ~* "/(=|\$&|_mm|(wp-)?config\.|cgi-|etc/passwd|muieblack)" { deny all; }
            location ~* "(&pws=0|_vti_|\(null\)|\{\$itemURL\}|echo(.*)kae|etc/passwd|eval\(|self/environ)" { deny all; }
            location ~* "\.(aspx?|bash|bak?|cfg|cgi|dll|exe|git|hg|ini|jsp|log|mdb|out|sql|svn|swp|tar|rdf)$" { deny all; }
            location ~* "/(^$|mobiquo|phpinfo|shell|sqlpatch|thumb|thumb_editor|thumbopen|timthumb|webshell)\.php" { deny all; }
 
        }
 
    }
```

