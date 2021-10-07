# Digging into Docker layers

While running a Docker container recently I wanted to **view the contents** of each layer that made up the image.

Being relatively new to Docker, I needed to answer these questions first:

- What are layers?
- Where are they found?
- Why use layers?

**TLDR;** Layers of a Docker image are essentially just files generated from running some command. You can view the contents of each layer on the Docker host at `/var/lib/docker/aufs/diff`. Layers are neat because they can be re-used by multiple images saving disk space and reducing time to build images while maintaining their integrity.

## **What are the layers?**

Docker containers are building blocks for applications. Each container is an image with a readable/writeable layer on top of a bunch of read-only layers.

These layers (also called intermediate images) are generated when the commands in the Dockerfile are executed during the Docker image build.

For example, here is a Dockerfile for creating a [node.js web app](https://nodejs.org/en/docs/guides/nodejs-docker-webapp/) image . It shows the commands that are executed to create the image.

```
FROM node:argon# Create app directory
RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app# Install app dependencies
COPY package.json /usr/src/app/
RUN npm install# Bundle app source
COPY . /usr/src/appEXPOSE 8080
CMD [ "npm", "start" ]
```

Shown below, when Docker builds the container from the above Dockerfile, each step corresponds to a command run in the Dockerfile. And each layer is made up of the file generated from running that command. Along with each step, the layer created is listed represented by its random generated ID. For example, the layer ID for step 1 is `530c750a346e`.

```
$ docker build -t expressweb .
Step 1 : FROM node:argon
argon: Pulling from library/node...
...
Status: Downloaded newer image for node:argon
 ---> 530c750a346e
Step 2 : RUN mkdir -p /usr/src/app
 ---> Running in 5090fde23e44
 ---> 7184cc184ef8
Removing intermediate container 5090fde23e44
Step 3 : WORKDIR /usr/src/app
 ---> Running in 2987746b5fba
 ---> 86c81d89b023
Removing intermediate container 2987746b5fba
Step 4 : COPY package.json /usr/src/app/
 ---> 334d93a151ee
Removing intermediate container a678c817e467
Step 5 : RUN npm install
 ---> Running in 31ee9721cccb
 ---> ecf7275feff3
Removing intermediate container 31ee9721cccb
Step 6 : COPY . /usr/src/app
 ---> 995a21532fce
Removing intermediate container a3b7591bf46d
Step 7 : EXPOSE 8080
 ---> Running in fddb8afb98d7
 ---> e9539311a23e
Removing intermediate container fddb8afb98d7
Step 8 : CMD npm start
 ---> Running in a262fd016da6
 ---> fdd93d9c2c60
Removing intermediate container a262fd016da6
Successfully built fdd93d9c2c60
```

Once the image is built, you can **view all the layers** that make up the image with the docker history command. The “Image” column (i.e intermediate image or layer) shows the randomly generated UUID that correlates to that layer.

```
docker history <image>$ docker history expressweb
IMAGE         CREATED    CREATED BY                       SIZE      
fdd93d9c2c60  2 days ago /bin/sh -c CMD ["npm" "start"]   0 B
e9539311a23e  2 days ago /bin/sh -c EXPOSE 8080/tcp       0 B
995a21532fce  2 days ago /bin/sh -c COPY dir:50ab47bff7   760 B
ecf7275feff3  2 days ago /bin/sh -c npm install           3.439 MB
334d93a151ee  2 days ago /bin/sh -c COPY file:551095e67   265 B
86c81d89b023  2 days ago /bin/sh -c WORKDIR /usr/src/app  0 B
7184cc184ef8  2 days ago /bin/sh -c mkdir -p /usr/src/app 0 B
530c750a346e  2 days ago /bin/sh -c CMD ["node"]          0 B
```

An image becomes a container when the `docker run` command is executed.

```
docker run expressweb
```

The image below is a diagram of the container created from the `run` command. The container has a writeable layer that stacks on top of the image layers. This writeable layer allows you to “make changes” to the container since the lower layers in the image are read-only.

![img](https://miro.medium.com/max/60/1*kTDjPNUqGX8ZdLidbukheA.png?q=20)

![img](https://miro.medium.com/max/563/1*kTDjPNUqGX8ZdLidbukheA.png)

Docker container displaying the image layers created by each command in the Dockerfile with the UUID of the each layer. The writable container layer is on top.

**Where are the layers found?**

To dig down into each layer of the image and view its contents you need to view the layers on the Docker host at:

```
/var/lib/docker/aufs
```

At the time of this writing, if running Docker on OSX, the Docker host is actually a linux virtual machine called docker machine. On OSX you can ssh into the docker machine to view the `aufs` directory:

```
$ docker-machine ssh default
                        ##         .
                  ## ## ##        ==
               ## ## ## ## ##    ===
           /"""""""""""""""""\___/ ===
      ~~~ {~~ ~~~~ ~~~ ~~~~ ~~~ ~ /  ===- ~~~
           \______ o           __/
             \    \         __/
              \____\_______/
 _                 _   ____     _            _
| |__   ___   ___ | |_|___ \ __| | ___   ___| | _____ _ __
| '_ \ / _ \ / _ \| __| __) / _` |/ _ \ / __| |/ / _ \ '__|
| |_) | (_) | (_) | |_ / __/ (_| | (_) | (__|   <  __/ |
|_.__/ \___/ \___/ \__|_____\__,_|\___/ \___|_|\_\___|_|
Boot2Docker version 1.12.3, build HEAD : 7fc7575 - Thu Oct 27 17:23:17 UTC 2016
Docker version 1.12.3, build 6b644ecdocker@default:~$ df -h
Filesystem   Size    Used Available Use% Mounted on
tmpfs      896.2M  192.1M 704.1M 21% /
tmpfs      497.9M       0  497.9M 0% /dev/shm
/dev/sda1   17.9G    2.4G   14.6G 14% /mnt/sda1
cgroup     497.9M       0  497.9M 0% /sys/fs/cgroup
Users      464.8G  110.0G  354.8G 24% /Users
/dev/sda1   17.9G    2.4G   14.6G 14% /mnt/sda1/var/lib/docker/aufs

docker@default:~$ ls /mnt/sda1/var/lib/docker/aufs
diff    layers  mnt
```

The `/var/lib/docker/aufs` directory points to three other directories: `diff`, `layers` and `mnt`.

- Image layers and their contents are stored in the `diff` directory.
- How image layers are stacked is in the `layers` directory.
- Running containers are mounted below the `mnt` directory (more explained below about mounts).

To get a better idea about how the layers work, I think it’s fun to talk about the [AUFS storage driver](https://docs.docker.com/engine/userguide/storagedriver/aufs-driver/). If you aren’t familiar with this, here are a few key words I think are good to know:

- **Union Mount** is a way of combining numerous directories into one directory that looks like it contains the content from all the them.
- **AUFS** stands for Another union filesystem or Advanced multi-layered unification filesystem (as of version 2). AUFS implements a union mount for Linux file systems.
- **AUFS storage driver** implements Docker image layers using the union mount system.
- **AUFS Branches —** each Docker image layer is called a AUFS branch.

Using Union filesystems is **super cool** because they merge all the files for each image layer together and presents them as one single read-only directory at the union mount point. If there are duplicate files in different layers, the file on the higher level layer is what is displayed.

An image I really like from the [Docker docs](https://docs.docker.com/engine/userguide/storagedriver/aufs-driver/) shown below, shows each layer of the Ubuntu image as an AUFS branch and where its files are stored on the Docker host in the union filesystem. Additionally it shows those layers as the unified view in the union mount point that is exposed in the writeable container layer.

![img](https://miro.medium.com/max/60/1*st_fZmKOMykQGF8kZKglvA.png?q=20)

![img](https://miro.medium.com/max/875/1*st_fZmKOMykQGF8kZKglvA.png)

**Why use a union mount system for Docker?**

Using a union filesystem allows each layer that is created to be reused by an unlimited number of images. This saves a lot of disk space and allows images to be built faster since it is just re-using an existing layer. Additionally, the read/write top layer gives the appearance that you can modify the image, but the read-only layers below actually maintain their integrity of the container by isolating the contents of the filesystem.

As an example of saving disk space, I always want to design my docker images to be as light weight as possible. Say I need to create a [named data volume container](https://docs.docker.com/engine/tutorials/dockervolumes/#/creating-and-mounting-a-data-volume-container) for my log files for my web app. The first thing I think of, is what base image can I use that will be the most light weight for this volume container. I decide to use [tianon/true ](https://hub.docker.com/r/tianon/true/)image since it’s super light weight at 125 bytes. But then I remember that I’m using an Ubuntu base for my web app. So if I already have an Ubuntu image, it’s actually better to just reuse that base image for my data volume container instead of creating more layers with the use of tianon/true.

If you think all of this is as cool as I do, here are a few fun resources:

- [OverlayFS](https://docs.docker.com/engine/userguide/storagedriver/overlayfs-driver/) as the possible successor to AUFS
- The docs for [Images and Containers](https://docs.docker.com/engine/userguide/storagedriver/imagesandcontainers/) and the [AUFS driver](https://docs.docker.com/engine/userguide/storagedriver/aufs-driver/)
- [Anatomy of a Container](http://www.slideshare.net/jpetazzo/anatomy-of-a-container-namespaces-cgroups-some-filesystem-magic-linuxcon)
- Anything by [Nigel Poulton](http://blog.nigelpoulton.com/)