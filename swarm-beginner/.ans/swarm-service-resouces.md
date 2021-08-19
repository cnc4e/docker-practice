```
cat <<EOF > service-resources.yaml
version: "3.9"

services:
  test:
    image: nginx
    deploy:
      replicas: 1
      resources:
        limits:
          cpus: '0.50'
          memory: 500M
        reservations:
          cpus: '0.25'
          memory: 250M
EOF
docker stack deploy -c service-resources.yaml test
docker stack ls
docker stack services test
docker stack ps test
docker service inspect test_test --pretty
sed -i -e 's/replicas\: 1/replicas\: 20/' service-resources.yaml
docker stack deploy -c service-resources.yaml test
docker stack ls
docker stack services test
docker stack ps test
docker stack rm test
```