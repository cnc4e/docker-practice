```
cat << EOF > service-env-parameter.yaml
version: "3.9"

services:
  test:
    image: nginx
    deploy:
      replicas: 1
    environment:
      env: dev 
EOF
docker stack deploy -c service-env-parameter.yaml test
docker stack ls
docker stack services test
docker stack ps test

# worker
docker exec <container id> env

docker stack rm test
```

```
cat <<EOF > common.env
parameter=common
env=dev
EOF
cat << EOF > service-env-file.yaml
version: "3.9"

services:
  nginx:
    image: nginx
    deploy:
      replicas: 2
    env_file: 
      - common.env
  httpd:
    image: httpd
    deploy:
      replicas: 2
    env_file: 
      - common.env
EOF
docker stack deploy -c service-env-file.yaml test
docker stack ls
docker stack services test
docker stack ps test

# worker
docker exec <container id> env

docker stack rm test
```