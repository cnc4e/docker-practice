```
wget https://github.com/ContainX/docker-volume-netshare/releases/download/v0.36/docker-volume-netshare_0.36_linux_amd64.tar.gz
tar -zxvf docker-volume-netshare_0.36_linux_amd64.tar.gz
mv docker-volume-netshare_0.36_linux_amd64/docker-volume-netshare /usr/local/sbin/
docker-volume-netshare -h
docker-volume-netshare efs &
```

```
cat <<EOF > volume-mount.yaml
version: "3.9"

services:
  service:
    image: nginx
    deploy:
      replicas: 2
    volumes:
      - "efs:/data"

volumes:
  efs:
    driver: local
    driver_opts:
      type: "nfs"
      o: nfsvers=4,addr=10.0.1.249,rw
      device: ":/"
EOF

docker stack deploy -c volume-mount.yaml test
docker stack ls
docker stack services test
docker stack ps test

# worker0
docker exec <container id> ls -l /data
docker exec <container id> touch /data/test

# worker1
docker exec <container id> ls /data

# worker0/1
docker volume ls

# master
docker stack rm test

# worker0/1
docker volume ls

# master
docker stack deploy -c volume-mount.yaml test
docker stack ls
docker stack services test
docker stack ps test

# worker0/1
docker exec <container id> ls /data

# master
docker stack rm test

```

```
# worker0/1
docker volume rm test_efs
ps -ef | grep docker-volume-netshare
kill -9 <pid>
```