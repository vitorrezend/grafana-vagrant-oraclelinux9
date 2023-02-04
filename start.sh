#!/bin/bash

dnf update -y

#nginx config
dnf install -y nginx
touch /etc/nginx/conf.d/grafana.conf

cat << EOF > /etc/nginx/conf.d/grafana.conf
server {
    listen 80;
    server_name localhost;

    location /grafana  {
        proxy_pass http://localhost:3000;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
    }
}
EOF


#firewall

firewall-cmd --permanent --add-port=80/tcp
firewall-cmd --permanent --add-port=443/tcp
#selinux
setsebool -P httpd_can_network_connect 1

#grafana
touch /etc/yum.repos.d/grafana.repo

echo "[grafana]
name=grafana
baseurl=https://rpm.grafana.com
repo_gpgcheck=1
enabled=1
gpgcheck=1
gpgkey=https://rpm.grafana.com/gpg.key
sslverify=1
sslcacert=/etc/pki/tls/certs/ca-bundle.crt" > /etc/yum.repos.d/grafana.repo

yum install -y grafana 


systemctl stop nginx
systemctl start nginx
systemctl stop grafana-server
systemctl start grafana-server





