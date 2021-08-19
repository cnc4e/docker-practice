```
cat <<EOF > service-bind.yaml
version: "3.9"

services:
  test:
    image: nginx
    deploy:
      replicas: 2
    volumes:
      - type: bind
        source: /tmp/mount
        target: /tmp
EOF

or

cat <<EOF > service-bind.yaml
version: "3.9"

services:
  test:
    image: nginx
    deploy:
      replicas: 2
    volumes:
      - "/tmp/mount:/tmp"
EOF

docker stack deploy -c service-bind.yaml test
docker stack ls
docker stack services test
docker stack ps test

# worker0/worker1
docker ps
docker exec -it <container id> cat /tmp/test.txt
docker exec -it <container id> touch /tmp/hoge
docker rm -f <container id>
docker exec -it <container id> ls /tmp

docker stack rm test
```