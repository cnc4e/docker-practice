```
echo config desuyo > index.html
cat <<EOF > config-file.yaml
version: "3.9"

services:
  service:
    image: nginx
    deploy:
      replicas: 1
    configs:
      - source: index
        target: /usr/share/nginx/html/index.html
    ports:
      - 8000:80

configs:
  index:
    file: ./index.html

EOF
docker stack deploy -c config-file.yaml test
docker stack ls
docker stack services test
docker stack ps test
docker config ls
curl 127.0.0.1:8000

cat <<EOF > config-file.yaml
version: "3.9"

services:
  service1:
    image: nginx
    deploy:
      replicas: 1
    configs:
      - source: index2
        target: /usr/share/nginx/html/index.html
    ports:
      - 8000:80

configs:
  index2:
    file: ./index.html

EOF
docker stack deploy -c config-file.yaml test
docker stack ls
docker stack services test
docker stack ps test
docker config ls
curl 127.0.0.1:8000
docker config rm test_index
docker stack rm test
```
