``` sh
cat <<EOF > Dockerfile
FROM fluent/fluentd:v1.9-1

# Use root account to use apk
USER root

RUN apk add --no-cache --update --virtual .build-deps \
        sudo build-base ruby-dev \
 && sudo gem install fluent-plugin-cloudwatch-logs \
 && sudo gem sources --clear-all \
 && apk del .build-deps \
 && rm -rf /tmp/* /var/tmp/* /usr/lib/ruby/gems/*/cache/*.gem
EOF
docker build -t ryotamori/fluentd-cloudwatch:v1.9-1 .
docker push ryotamori/fluentd-cloudwatch:v1.9-1
```

``` sh
cat <<EOF > fluentd.yaml
version: "3.9"

services:
  fluentd:
    image: ryotamori/fluentd-cloudwatch:v1.9-1
    deploy:
      mode: global
    ports:
      - target: 24224
        published: 24224
        protocol: tcp
        mode: host
    configs:
      - source: fluent.conf
        target: /fluentd/etc/fluent.conf

configs:
  fluent.conf:
    file: ./fluent.conf
EOF
docker stack deploy -c fluentd.yaml fluentd
docker stack ls
docker stack services fluentd
docker stack ps fluentd
docker config ls

# worker
docker ps
docker logs <container id>
```

``` sh
cat <<EOF > log-test.yaml
version: "3.9"

services:
  log:
    image: nginx
    deploy:
      replicas: 1
    ports:
      - 8000:80
    logging:
      driver: fluentd
      options:
        fluentd-address: 127.0.0.1:24224
        tag: docker.{{.Name}}.{{.ID}}
EOF
docker stack deploy -c log-test.yaml test
docker stack ls
docker stack services test
docker stack ps test
docker stack rm test
docker stack rm fluentd
```