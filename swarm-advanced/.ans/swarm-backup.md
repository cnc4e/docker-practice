```
## 準備
# manager0
echo backup data > index.html
cat <<EOF > backup.yaml
version: "3.9"

services:
  backup:
    image: nginx
    deploy:
      replicas: 1
    configs:
      - source: index
        target: /usr/share/nginx/html/index.html
    ports:
      - 8000:80

configs:
  index:
    file: ./index.html

EOF
docker stack deploy -c backup.yaml test
docker stack ls
docker stack services test
docker stack ps test
docker config ls

# worker
docker exec <container id> curl -s localhost

# manager0/1/2
ls -ld /var/lib/docker/swarm*
systemctl stop docker

# worker
docker ps

## バックアップ
# manager0/1/2
cp -r /var/lib/docker/swarm /var/lib/docker/swarm-bk
ls -ld /var/lib/docker/swarm*
systemctl start docker

## 疑似障害
# manager0
docker stack rm test
docker stack ls

## リストア
# manager0/1/2
systemctl stop docker
rm -rf /var/lib/docker/swarm 
cp -r /var/lib/docker/swarm-bk /var/lib/docker/swarm
ls -ld /var/lib/docker/swarm*
systemctl start docker

# manager0
docker stack ls
docker stack services test
docker stack ps test
docker config ls

# worker
docker exec <container id> curl -s localhost

# manager0
docker stack rm test

```

