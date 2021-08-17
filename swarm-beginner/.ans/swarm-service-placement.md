```
cat <<EOF > service-placement-replica.yaml
version: "3.9"

services:
  test:
    image: nginx
    deploy:
      mode: replicated
      replicas: 1
EOF
docker stack deploy -c service-placement-replica.yaml test
docker stack ls
docker stack services test
docker stack ps test
docker stack rm test
```

```
docker node update --label-add name=<worker0 or 1> <worker node hostname> 
docker node inspect <worker node hostname> 
```

```
cat <<EOF > service-placement-constraint.yaml
version: "3.9"

services:
  test:
    image: nginx
    deploy:
      replicas: 2
      placement:
        constraints:
          - node.labels.name==worker0
EOF
docker stack deploy -c service-placement-constraint.yaml test
docker stack ls
docker stack services test
docker stack ps test
docker stack rm test
sed -i -e 's/worker0/hoge/' service-placement-constraint.yaml
docker stack deploy -c service-placement-constraint.yaml test
docker stack rm test
```

```
cat <<EOF > service-placement-pref.yaml
version: "3.9"

services:
  test:
    image: nginx
    deploy:
      replicas: 2
      placement:
        preferences:
          - spread: node.labels.name
EOF
docker stack deploy -c service-placement-pref.yaml test
docker stack ls
docker stack services test
docker stack ps test
docker stack rm test
sed -i -e 's/name/hoge/' service-placement-pref.yaml
docker stack deploy -c service-placement-pref.yaml test
docker stack ls
docker stack services test
docker stack ps test
docker stack rm test
```

```
cat <<EOF > service-placement-global.yaml
version: "3.9"

services:
  test:
    image: nginx
    deploy:
      mode: global
EOF
docker stack deploy -c service-placement-global.yaml test
docker stack ls
docker stack services test
docker stack ps test
docker stack rm test
```