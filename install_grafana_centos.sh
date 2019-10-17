#!/bin/bash



## Dependencias

yum -y install fontconfig
yum -y install freetype*
yum -y install urw-fonts

## Instalação do repositorio

cat <<EOF > /etc/yum.repos.d/grafana.repo

[grafana]
name=grafana
baseurl=https://packagecloud.io/grafana/stable/el/7/\$basearch
repo_gpgcheck=1
enabled=1
gpgcheck=1
gpgkey=https://packagecloud.io/gpg.key https://grafanarel.s3.amazonaws.com/RPM-GPG-KEY-grafana
sslverify=1
sslcacert=/etc/pki/tls/certs/ca-bundle.crt

EOF


## Instalar grafana

yum -y install grafana



## Ativando o serviço

systemctl daemon-reload
systemctl enable grafana-server
systemctl start grafana-server
systemctl status grafana-server




## Backup database

cat <<EOF > /etc/cron.daily/backup-grafana.sh
#!/bin/sh

#Debug
set +x

NOW=\`date +%y_%m_%d\`


tar -zcf /backup/grafana/grafana\${NOW}.tar.gz /var/lib/grafana/grafana.db
EXITVALUE=\$?
if [ \$EXITVALUE != 0 ]; then
    /usr/bin/logger -t GRAFANA "ALERT exited abnormally with \$EXITVALUE"
    exit \$EXITVALUE
fi


find /backup/grafana -mtime +30 -delete
EXITVALUE=\$?
if [ \$EXITVALUE != 0 ]; then
    /usr/bin/logger -t GRAFANA "ALERT exited abnormally with \$EXITVALUE"
    exit \$EXITVALUE
fi


exit 0


EOF




