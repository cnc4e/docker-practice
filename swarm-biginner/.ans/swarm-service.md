```
docker service create --name test nginx
docker service ls
docker service ps test
docker ps
reboot
docker service ps test
docker service scale test=3
docker service ls
docker service ps test
docker service rm test
```

```
mkdir service;cd service
cat <<EOF > test.yaml
version: "3.9"

services:
  test:
    image: nginx
    deploy:
      replicas: 1
EOF
docker stack deploy -c test.yaml test
docker stack ls
docker stack services test
sed -i -e 's/replicas\: 1/replicas\: 3/' test.yaml
docker stack services test
docker stack ps test
docker stack rm test
```