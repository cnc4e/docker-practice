```
cat <<EOF > overlay-encrypted.yaml
version: "3.9"

services:
  nginx:
    image: nginx
    deploy:
      replicas: 1
    networks:
      - encrypted
  httpd:
    image: httpd
    deploy:
      replicas: 1
    networks:
      - encrypted

networks:
  encrypted:
    driver: overlay
    driver_opts:
      encrypted: ""
EOF
docker stack deploy -c overlay-encrypted.yaml test
docker stack ls
docker stack services test
docker stack ps test
docker network ls
docker network inspect test_encrypted

# worker
docker exec <container id> curl -s test_httpd

# manager
docker stack rm test
```