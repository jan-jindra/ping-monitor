# rebuild docker container for testing

docker build -t test .
docker stop test; docker rm test
docker run -d -p 81:80 -p 4200:4200 -p 8022:22  --name test test

docker container ls -a
sleep 3

docker container ls -a