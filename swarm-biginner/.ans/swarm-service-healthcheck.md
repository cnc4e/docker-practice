```
cat << EOF > service-healthcheck.yaml
version: "3.9"

services:
  test:
    image: nginx
    deploy:
      replicas: 2

EOF
docker stack deploy -c service-healthcheck.yaml test
docker stack ls
docker stack services test
docker stack ps test

# worker0
docker ps
docker exec <container id> curl localhost
ps -ef | grep -e nginx | grep -v grep
kill -stop <pid> <pid> <pid>
docker ps
docker exec <container id> curl localhost

# master
cat << EOF > service-healthcheck.yaml
version: "3.9"

services:
  test:
    image: nginx
    deploy:
      replicas: 2
    healthcheck:
      test: ["CMD", "curl", "localhost"]
      interval: 5s
      timeout: 1s
      retries: 3
      start_period: 30s

EOF
docker stack deploy -c service-healthcheck.yaml test
docker stack ls
docker stack services test
docker stack ps test

# worker0
docker ps
docker exec <container id> curl localhost
ps -ef | grep -e nginx | grep -v grep
kill -stop <pid> <pid> <pid>
watch docker ps
docker exec <container id> curl localhost

docker stack rm test

```