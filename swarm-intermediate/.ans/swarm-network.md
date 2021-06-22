```
docker node update --label-add name=<worker0 or 1> <worker node hostname> 
cat <<EOF > network-overlay.yaml
version: "3.9"

services:
  service1:
    image: nginx
    deploy:
      replicas: 1
      placement:
        constraints:
          - node.labels.name==worker0
  service2:
    image: httpd
    deploy:
      replicas: 1
      placement:
        constraints:
          - node.labels.name==worker1
EOF
docker stack deploy -c network-overlay.yaml test
docker stack ls
docker stack services test
docker stack ps test
docker network ls
docker network inspect test_default
docker service inspect <test_service1 / test_service2>

# worker0
docker ps
docker exec <container id> curl -s test_service2

docker stack deploy -c network-overlay.yaml test2
docker stack ls
docker stack services test2
docker stack ps test2
docker service inspect <test2_service1 / test2_service2>

# worker0
docker ps
docker exec <container id> curl -s test2_service1
docker exec <container id> curl -s test2_service2
docker exec <container id> curl -s <test2_service1 IP>
docker exec <container id> curl -s <test2_service2 IP>

docker stack rm test

```


```
cat <<EOF > network-create.yaml
version: "3.9"

services:
  service1:
    image: nginx
    deploy:
      replicas: 1
    networks:
      - network1
      - common
  service2:
    image: httpd
    deploy:
      replicas: 1
    networks:
      - network2
      - common
  service3:
    image: httpd
    deploy:
      replicas: 1
    networks:
      - network3

networks:
  network1:
    driver: overlay
  network2:
    driver: overlay
  network3:
    driver: overlay
  common:
    driver: overlay

EOF

docker stack ls
docker stack services test
docker stack ps test
docker network ls
docker network inspect test_network1 | grep Subnet
docker network inspect test_network2 | grep Subnet
docker network inspect test_network3 | grep Subnet
docker network inspect test_common | grep Subnet
docker service inspect test_service1 |grep Addr
docker service inspect test_service2 |grep Addr
docker service inspect test_service3 |grep Addr

# worker0
docker ps
docker exec <container id> curl -s test_service2 
docker exec <container id> curl -s test_service3
docker exec <container id> curl -s <test_service2のcommonのIP>
docker exec <container id> curl -s <test_service2のnetwork2のIP>
docker exec <container id> curl -s <test_service3のnetwork3のIP>

cat <<EOF > network-external.yaml
version: "3.9"

services:
  service1:
    image: nginx
    deploy:
      replicas: 1
    networks:
      - test_common

networks:
  test_common:
    driver: overlay
    external: true

EOF

docker stack deploy -c network-external.yaml test2
docker stack ls
docker stack services test2
docker stack ps test2
docker network ls
docker network inspect test2_common | grep Subnet
docker service inspect test2_service1 |grep Addr
docker stack rm test2
```
