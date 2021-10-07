[TOC]

### Build and List Image

```sh
# Build an image from the Dockerfile in the current directory and tag the image
docker build "<foldername>" -t "<user friendly image name>" 

# List all images that are locally stored with the Docker Engine
docker image ls 

# Delete an image from the local image store
docker image rm alpine:3.4

# Remove all image
docker rmi $(docker images -a -q)
```



### Run/List/Stop Container

#### Run Container

- **it** -- For interactive mode
- **d** -- For daemon mode
- **entrypoint** -- For overriding entrypoint
- **p** -- Mapping host port to local port
- **v** -- Mount /host/foo host path to /foo container path
- **e** -- Update environment variable abc=def
- **rm** -- Automatically clean up the container and remove the anonymous file system when the container exits,
- **restart** -- to specify restart policy. support this value **no**,**on-failure**[:max-retries],**always**,**unless-stopped**
- **name** -- give container name

```sh
docker run --name test --restart always --rm -it -d --entrypoint "/bin/sh" -p 8080:8080 -v /host/foo:/foo -e "abc=def" "<imageName>"
```

```sh
# Stop a running container through SIGTERM
docker container stop test

# Stop a running container through SIGKILL
docker container kill test

# List all running container
docker container ls
# or docker ps

#List all container with stopped one too
docker ps -a

#remove all container
docker rm $(docker ps -a -q)

#stop all container
docker stop $(docker ps -a -q)

```



### Share container

```sh
# Pull an image from a registry
docker pull myimage:1.0

# Retag a local image with a new image name and tag
docker tag myimage:1.0 myrepo/myimage:2.0

# Push an image to a registry
docker push myrepo/myimage:2.0 
```



### Show syslog of docker container

```sh
docker logs -f --until=2s test
```



### System prune, remove all images, all stopped container

```sh
docker system prune
```



### Docker cleanup

```sh
@echo off
FOR /f "tokens=*" %%i IN ('docker ps -aq') DO docker rm %%i
FOR /f "tokens=*" %%i IN ('docker images --format "{{.ID}}"') DO docker rmi %%i
```

