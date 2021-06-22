```
cat <<EOF > service-expose.yaml
version: "3.9"

services:
  test:
    image: nginx
    deploy:
      replicas: 1
    ports:
      - 8000:80
EOF
docker stack deploy -c service-expose.yaml test
docker stack ls
docker stack services test
docker stack ps test
curl <work IP>:8000
curl <work IP>:8000
curl <managaer IP>:8000
docker service scale test_test=2

# worke0/1
docker exec -it <container id> sh
echo <worker0/1> > /usr/share/nginx/html/index.html

curl <work IP>:8000
docker stack deploy -c service-expose.yaml test2
docker stack rm test test2
```