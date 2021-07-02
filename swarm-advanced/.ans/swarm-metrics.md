``` sh
git clone https://github.com/zabbix/zabbix-docker.git
cd zabbix-docker
cp docker-compose_v3_centos_mysql_latest.yaml docker-compose.yaml
docker-compose --profile all up -d
docker ps
```

``` sh
cat <<EOF > dockbix-agent.yaml
version: "3.9"

services:
  dockbix-agent:
    image: monitoringartist/dockbix-agent-xxl-limited:latest
    deploy:
      mode: global
    volumes:
      - /:/rootfs
      - /var/run:/var/run
    privileged: true
    environment:
      - ZA_Server=10.0.1.229
      - ZA_ServerActive=10.0.1.229
    networks:
      hostnet: {}

networks:
  hostnet:
    external: true
    name: host
EOF

docker stack deploy -c dockbix-agent.yaml zabbix
docker stack ls
docker stack services zabbix
docker stack ps zabbix
```

``` sh
docker stack rm zabbix
docker compose down
cd ../
rm -rf zabbix-docker
```
