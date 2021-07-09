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

```
docker run --rm aquasec/trivy httpd:2.4.47
docker run --rm aquasec/trivy httpd:2.4.47-alpine
```

```
docker run --rm --net host --pid host --userns host --cap-add audit_control \
    -e DOCKER_CONTENT_TRUST=$DOCKER_CONTENT_TRUST \
    -v /etc:/etc:ro \
    -v /usr/bin/containerd:/usr/bin/containerd:ro \
    -v /usr/bin/runc:/usr/bin/runc:ro \
    -v /usr/lib/systemd:/usr/lib/systemd:ro \
    -v /var/lib:/var/lib:ro \
    -v /var/run/docker.sock:/var/run/docker.sock:ro \
    --label docker_bench_security \
    docker/docker-bench-security

systemctl status auditd
auditctl -l

cat <<EOF >> /etc/audit/rules.d/audit.rules
-w /usr/bin/docker -p wa
-w /var/lib/docker -p wa
-w /etc/docker -p wa
-w /usr/lib/systemd/system/docker.service -p wa
-w /usr/lib/systemd/system/docker.socket -p wa
-w /var/run/docker.sock -p wa
-w /usr/bin/docker-containerd -p wa
-w /usr/bin/docker-runc -p wa
EOF

sudo service auditd restart
systemctl status auditd
auditctl -l

docker run --rm --net host --pid host --userns host --cap-add audit_control \
    -e DOCKER_CONTENT_TRUST=$DOCKER_CONTENT_TRUST \
    -v /etc:/etc:ro \
    -v /usr/bin/containerd:/usr/bin/containerd:ro \
    -v /usr/bin/runc:/usr/bin/runc:ro \
    -v /usr/lib/systemd:/usr/lib/systemd:ro \
    -v /var/lib:/var/lib:ro \
    -v /var/run/docker.sock:/var/run/docker.sock:ro \
    --label docker_bench_security \
    docker/docker-bench-security
```