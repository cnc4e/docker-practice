```
echo config desuyo > index.html
cat <<EOF > secret-file.yaml
version: "3.9"

services:
  service:
    image: nginx
    deploy:
      replicas: 1
    secrets:
      - test-secret
    configs:
      - test-config

secrets:
  test-secret:
    file: ./secret

configs:
  test-config:
    file: ./config

EOF
docker stack deploy -c secret-file.yaml test
docker stack ls
docker stack services test
docker stack ps test
docker secret ls
docker config ls
docker secret inspect test_test-secret
docker config inspect test_test-config

docker exec <container id> ls /run/secrets/test-secret
docker exec <container id> cat /run/secrets/test-secret
docker exec <container id> ls /test-config
docker exec <container id> cat /test-config

docker stack rm test
```
