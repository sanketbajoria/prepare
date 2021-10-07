# Optimizing Dockerfile for Node.js

Let's say you've just built an amazing Node.js application and want to distribute it as a Docker image. You write a **`Dockerfile`**, run [`docker build`](https://docs.docker.com/engine/reference/commandline/build/), and distribute the generated image on a **Docker registry** like [**Docker Hub**](https://hub.docker.com/).

You pat yourself on the back and utter to yourself "Not too shabby!". But being the perfectionist that you are, you want to make sure that your Docker image and `Dockerfile` are as optimized as possible.

[TOC]

Later on, we will publish a dedicated article on *securing* our Docker image, where we will cover:

- Following the Principle of Least Privilege
- Signing and verifying Docker Images
- Use `.dockerignore` to ignore sensitive files
- Vulnerability Scanning

> Although this article deals with a Node.js application, the principles outlined here applies to applications written in other languages and frameworks too!

## Background

For this article, we will work to optimize the `Dockerfile` associated with a basic front-end application. Start by cloning the repository at [github.com/d4nyll/docker-demo-frontend](https://github.com/d4nyll/docker-demo-frontend). Specifically, we want to use the [`docker/basic`](https://github.com/d4nyll/docker-demo-frontend/tree/docker/basic) branch.

```bash
$ git clone -b docker/basic https://github.com/d4nyll/docker-demo-frontend.git
```

Next, open up the [`Dockerfile`](https://github.com/d4nyll/docker-demo-frontend/blob/docker/basic/Dockerfile) to see what instructions are already there.

```dockerfile
FROM node
WORKDIR /root/
COPY . .
RUN npm install
RUN npm run build
CMD npm run serve
```

> Each line inside a `Dockerfile` is called an **instruction**. You can find all valid instructions at the [Dockerfile reference](https://docs.docker.com/engine/reference/builder/) page.

Pretty basic stuff. But for those new to Docker, here's a brief overview:

- ```dockerfile
  FROM node
  ```

  - we want to build our Docker image based on the [`node`](https://hub.docker.com/_/node/) **base image**

- ```dockerfile
  WORKDIR /root/
  ```

  - we want all subsequent instructions in this `Dockerfile` to be carried out inside the specified directory. It's similar to runnin `cd /root/` on your terminal.

- ```dockerfile
  COPY . .
  ```

  - copy everything from the **build context** to the current `WORKDIR`. Don't know what a build context is? Check out the documentation on [`docker build`](https://docs.docker.com/engine/reference/commandline/build/).

- ```dockerfile
  RUN npm install
  ```

  - run `npm install` to install all the application's dependencies, as specified inside the `dependencies` property of the `package.json`, as well as the `package-lock.json` file

- ```dockerfile
  RUN npm build
  ```

  - run the `build` npm script inside `package.json`, which simply uses Webpack to build the application

- ```dockerfile
  CMD npm run serve
  ```

  - whilst all the previous instructions are executed during the `docker build` process, the `CMD` command is executed when you run `docker run`. It specifies which process should run inside the container as the first process.

Try running `docker build` to build our image.

```bash
$ docker build -t demo-frontend:basic .
...
Removing intermediate container a3d5032b851b
 ---> 703e723acecf
Successfully built 703e723acecf
Successfully tagged demo-frontend:basic
```

You should now be able to see the `demo-frontend:basic` image when you run `docker images`.

```bash
$ docker images
REPOSITORY     TAG     IMAGE ID      SIZE
demo-frontend  basic   703e723acecf  939MB
node           latest  b18afbdfc458  908MB
```

Next, run `docker run` to run our application.

```bash
$ docker run --name demo-frontend demo-frontend:basic

> frontend@1.0.0 serve /root
> http-server ./dist/

Starting up http-server, serving ./dist/
Available on:
  http://127.0.0.1:8080
Hit CTRL-C to stop the server
```



## Reducing the Number of Processes

With our Docker container running, we can run `docker exec` on another terminal to see what processes are running inside our container.

```bash
$ docker exec demo-frontend ps -eo pid,ppid,user,args --sort pid
  PID  PPID USER  COMMAND
    1     0 root  /bin/sh -c npm run serve
    6     1 root  npm
   17     6 root  sh -c http-server ./dist/
   18    17 root  node /root/node_modules/.bin/http-server ./dist/
   25     0 root  ps -eo pid,ppid,user,args --sort pid
```

We can see an `/bin/sh` shell (with **process ID** (**PID**) of `1`) is invoked to execute `npm` (PID `6`), which invokes another `sh` shell (PID `17`) to run our npm `serve` script, which then executes the `node` command (PID `18`) that we actually want.

> The `ps` command is the same one that we are running with `docker exec`. It would not normally be running inside the container, and we can ignore it here.

That's a lot of processes that are not needed to run our application, and each one takes up a large amount of memory *relative to the total memory usage of the container*. It would be ideal if we can just run the `node /root/node_modules/.bin/http-server ./dist/` command and nothing else.

### Avoid using npm script

It's best not to use `npm` as the `CMD` command because, as you saw above, `npm` will invoke a sub-shell and execute the script inside that sub-shell, yielding a redundant process. Instead, you should specify the command *directly* as the value of our `CMD` instruction.

Update the `CMD` instruction inside your `Dockerfile` to invoke our `node` process directly.

```dockerfile
FROM node
WORKDIR /root/
COPY . .
RUN npm install
RUN npm run build
CMD node /root/node_modules/.bin/http-server ./dist/
```

Next, try stopping our existing `http-server` instance by pressing Ctrl + C. Hmmm, it seems like it's not working! We will explain the reason shortly, but for now, run `docker stop demo-frontend` and `docker rm demo-frontend` on a separate terminal to stop and remove the container.

With a clean slate, let's build and run our image again.

```bash
$ docker build -t demo-frontend:no-npm .
$ docker run --name demo-frontend demo-frontend:no-npm
```

Once again, run `docker exec` on a separate terminal. This time, the number of processes have been reduced from 4 to 2.

```bash
$ docker exec demo-frontend ps -eo pid,ppid,user,args --sort pid
  PID  PPID USER  COMMAND
    1     0 root  /bin/sh -c node /root/node_modules/.bin/http-server ./dist/
    6     1 root  node /root/node_modules/.bin/http-server ./dist/
   13     0 root  ps -eo pid,ppid,user,args --sort pid
```

If we calculate the 'real memory' used by the container before and after the change, you'll find that we've saved ~16MB, just by removing the superfluous `npm` and `sh` functions.

> If you are interested in how to calculate the 'real memory' usage, have a read around the topic of [**proportional set size** (**PSS**)](https://en.wikipedia.org/wiki/Proportional_set_size).

However, our `node` command is still being ran inside of a `/bin/sh` shell. How do we get rid of that shell and invoke `node` as the first *and only* process inside our container? To answer that, we must understand and use the exec form syntax in our `Dockerfile`.

### Using the Exec Form

Docker supports two different syntax when specifying instructions inside your `Dockerfile` - the **shell form**, which is what we've been using, and the **exec form**.

The exec form specifies the command and its options and arguments in the form of a JSON array, rather than a simple string. Our `Dockerfile` using the exec form would look like this:

```dockerfile
FROM node
WORKDIR /root/
COPY . .
RUN ["npm", "install"]
RUN ["npm", "run", "build"]
CMD ["node", "/root/node_modules/.bin/http-server" , "./dist/"]
```

#### Shell vs. Exec Form

The practical difference is that with the shell form, Docker will *implicitly* invoke a shell and run the `CMD` command inside that shell (this is what we saw earlier). With the exec form, the command we specified is run *directly*, without first invoking a shell.

Again, stop and remove the existing `demo-frontend` container, update your `Dockerfile` to use the exec form, build it, run it, and run `docker exec` to query the container's process(es).

```bash
$ docker stop demo-frontend && docker rm demo-frontend
$ docker build -t demo-frontend:exec .
$ docker run --name demo-frontend demo-frontend:exec
$ docker exec demo-frontend ps -eo pid,ppid,user,args --sort pid
  PID  PPID USER     COMMAND
    1     0 root     node /root/node_modules/.bin/http-server ./dist/
   12     0 root     ps -eo pid,ppid,user,args --sort pid
```

Great, now the only process running inside our container is the `node` process we care about! We have succesfully reduced the number of running processes to just one!

## Signal Handling

However, saving a single process is *not* the reason why we prefer the exec form over the shell form. The *real* reason is because of **signal handling**.

On Linux, different processes can communicate with each other through [**inter-process communication** (**IPC**)](https://en.wikipedia.org/wiki/Inter-process_communication). One method of IPC is [**signalling**](https://en.wikipedia.org/wiki/Signal_(IPC)). If you use the command line, you've probably used signals without realizing it. For example, when you press Ctrl + C, you're actually instructing the kernel to send a `SIGINT` signal to the process, requesting it to stop.

Remember previously, when we tried to stop our container by ressing Ctrl + C, it didn't work. But now, let's try that again. With the `demo-frontend:exec` image running, try pressing Ctrl + C on the terminal running `http-server`. This time, the `http-server` stops successfully.

```bash
$ docker run --name demo-frontend demo-frontend:exec
Starting up http-server, serving ./dist/
Available on:
  http://127.0.0.1:8080
  http://172.17.0.2:8080
Hit CTRL-C to stop the server
^Chttp-server stopped.
```

So why did it work this time, but not earlier? This is because when we send the `SIGINT` signal from our terminal, we are actually sending it to the to the first process ran inside the container. This process is known as the **init process**, and has the PID of `1`.

Therefore, the init process must have the ability to listen for the `SIGINT` signal. When it receives the signal, it must try to shutdown gracefully. For example, for a web server, the server must stop accepting any new requests, wait for any remaining requests to finish, and then exit.

With the shell form, the init process is `/bin/sh`. When `/bin/sh` receives the `SIGINT` signal, it'll simply ignore it. Therefore, our container and the `http-server` process won't be stopped.

When we run `docker stop demo-frontend`, the Docker daemon similarly sends a `SIGTERM` signal to the container's init process, but again, `/bin/sh` ignores it. After a time period of around 10 seconds, the Docker daemon realizes the container is not responding to the `SIGTERM` signal, and issues a `SIGKILL` signal, which *forcefully* kills the process. The `SIGKILL` signal cannot be handled; this means processes within the container do not get a chance to shut down gracefully. For a web server, it might mean that existing requests won't have a chance to run to completion, and your client might have to retry that request again.

If we measure the time it takes to stop a container where the init process is `/bin/sh`, you can see that it takes just over 10 seconds, which is the timeout period Docker will wait before sending a `SIGKILL`.

```bash
$ time docker stop demo-frontend

real  0m10.443s
user  0m0.072s
sys      0m0.022s
```

In comparison, when we use the exec form, `node` is the init process and it *will* handle the `SIGINT` and `SIGTERM` signals. You can either include a `process.on('SIGINT')` handler yourself, or the [default one](https://github.com/nodejs/node/blob/master/src/node.cc#L527) will be used. The point is, with `node` as the first command, you have the ability to catch signals and handle them.

To demonstrate, with the new image built using the exec form `Dockerfile`, the container can be stopped in under half a second.

```bash
$ time docker stop demo-frontend

real  0m0.420s
user  0m0.053s
sys      0m0.026s
```

> If the application you are running cannot handle signals, you should run `docker run` with the [`--init` flag](https://docs.docker.com/engine/reference/run/#specify-an-init-process), which will execute [`tini`](https://github.com/krallin/tini) as its first process. Unlike `sh`, `tini` is a minimalistic init system that *can* handle and propagate signals.

## Caching Layers

So far, we've looked at techniques that improves the function of our Docker image whilst it's running. In this section, we'll look at how we can use Docker's **build cache** to make the build process faster.

When we run `docker build`, Docker will run the base image as a container, execute each instruction sequentially (one after the other) on top of it, and save the resulting state of the container in a **layer**, and use that as the base image for the next instruction. The final image is built this way - layer by layer.

> You can conceptualize a layer as a *diff* from the previous layer.

![img](https://buddy.works/tutorials/assets/posts/optimizing-dockerfile-for-node-js-part-1/container-layers.jpg)(Taken from the [About images, containers, and storage drivers](https://docs.docker.com/v17.09/engine/userguide/storagedriver/imagesandcontainers/) page)

However, pulling or building an image from scratch every single time can be time-consuming. This is why Docker will try to use an existing, cached layer whenever possible. If Docker determines that the next instruction will yield the same result as an existing layer, it will use the cached layer.

For example, let's say we've updated something inside the `src` direcotry; when we run `docker build` again, Docker will use the cached layer associated with the `FROM node` and `WORKDIR /root/` instructions.

When it gets to the `COPY` instruction, it will notice that the source code has changed, and invalidates the cached layer and builds it from scratch. This will also invalidate every layer that comes after it. Therefore, every instruction after the `COPY` instruction must be built again. In this instance, this build process takes ~10 seconds.

```bash
$ time docker build -t demo-frontend:exec .
Sending build context to Docker daemon    511kB
Step 1/6 : FROM node
 ---> a9c1445cbd52
Step 2/6 : WORKDIR /root/
 ---> Using cache
 ---> 7ac595062ce2
Step 3/6 : COPY . .
 ---> 3c2f3cfb6f92
Step 4/6 : RUN ["npm", "install"]

...
Successfully built 326bf48a8488
Successfully tagged demo-frontend:exec

real  0m10.387s
user  0m0.187s
sys   0m0.089s
```

However, making a small change in our source code (e.g. fixing a typo) shouldn't affect the dependencies of our application, and so there's really no need to run `npm install` again. However, because the cache is invalidated in an earlier step, every subsequent step must be re-ran from scratch.

To optimize this, we should copy only what is needed for the next *immediate* step. This means if the next step is `npm install`, we should `COPY` only the `package.json` and `package-lock.json`, and *nothing else*.

Update our `Dockerfile` to copy only what is needed for the next immediate step:

```dockerfile
FROM node
WORKDIR /root/
COPY ["package.json", "package-lock.json", "./"]
RUN ["npm", "install"]
COPY ["webpack.config.js", "./"]
COPY ["src/", "./src/"]
RUN ["npm", "run", "build"]
CMD ["node", "/root/node_modules/.bin/http-server" , "./dist/"]
```

By `COPY`ing only what is needed *immediately*, we allow more layers of the image to be cached. Now, if we update the `/src` direcotry again, every instructions and layers up until `COPY ["src/", "./src/"]` are cached.

```bash
$ time docker build -t demo-frontend:cache .
Step 1/8 : FROM node
Step 2/8 : WORKDIR /root/
 ---> Using cache
Step 3/8 : COPY ["package.json", "package-lock.json", "./"]
 ---> Using cache
Step 4/8 : RUN ["npm", "install"]
 ---> Using cache
Step 5/8 : COPY ["webpack.config.js", "./"]
 ---> Using cache
Step 6/8 : COPY ["src/", "./src/"]
Step 7/8 : RUN ["npm", "run", "build"]
...
Successfully tagged demo-frontend:cache

real    0m3.175s
user    0m0.193s
sys    0m0.132s
```

Now, instead of taking ~10 seconds to build, it takes only ~3 seconds (your mileage may vary, but using the build cache will *always* be faster.

> You can find more details on caching, including how Docker determines when a cache is invalidated, on the [Dockerfile Best Practices](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/#leverage-build-cache) page.

## Using ENTRYPOINT and CMD together

Right now, the command that's ran by `docker run` is specified by the `CMD` instruction. This command can be overriden by the user of the image (the one executing `docker run`). For example, if I want to use a different port (e.g. `4567`) rather than the default (`8080`), then I can run:

```bash
$ docker run --name demo-frontend demo-frontend:cache node /root/node_modules/.bin/http-server ./dist/ -p 4567

Starting up http-server, serving ./dist/
Available on:
  http://127.0.0.1:4567
  http://172.17.0.2:4567
Hit CTRL-C to stop the server
```

However, we have to specify the whole command in its entirety. This requires the user of the image to know where the executable is located within the container (i.e. `/root/node_modules/.bin/http-server`). We should make it as easy as possible for the user to run our application. Wouldn't it be nice if they can run the containerized application in the same way as the non-containerized application?

You guessed it! We can!

Instead of using the `CMD` instruction only, we can use the `ENTRYPOINT` instruction to specify the *default* command and options to run, and use the `CMD` instruction to specify any additional options that are commonly overridden.

Update our `Dockerfile` to make use of the `ENTRYPOINT` instruction.

```dockerfile
FROM node
WORKDIR /root/
COPY ["package.json", "package-lock.json", "./"]
RUN ["npm", "install"]
COPY ["webpack.config.js", "./"]
COPY ["src/", "./src/"]
RUN ["npm", "run", "build"]
ENTRYPOINT ["node", "/root/node_modules/.bin/http-server" , "./dist/"]
```

And build the image.

```bash
$ docker build -t demo-frontend:entrypoint .
```

Using this method, the user can run the image *as if it was the `http-server` command*, and does not need to know the underlying file structure of the container.

```bash
$ docker run --name demo-frontend demo-frontend:entrypoint -p 4567
```

The command specified by the `ENTRYPOINT` instruction can also be overriden using the `--entrypoint` flag of `docker run`. For example, if we want to run a `/bin/sh` shell inside the container to explore, we can run:

```bash
$ docker run --name demo-frontend -it --entrypoint /bin/sh demo-frontend:entrypoint

# hostname
1b64852541eb
```

## Using EXPOSE to document exposed ports

Lastly, let's finish up the first part of this article with some documentation. By default, our `http-server` listens on port `8080`; however, a user of our image won't know this without looking up the documentation for `http-server`. Likewise, if we are running our own application, the user would have to look inside our implementation code to know which port the application listens on.

We can make it easier for the users by using an `EXPOSE` instruction to document which ports and protocol (TCP or UDP) the application expects to listen on. This way, the user can easily figure out which ports needs to be published.

```dockerfile
FROM node
WORKDIR /root/
COPY ["package.json", "package-lock.json", "./"]
RUN ["npm", "install"]
COPY ["webpack.config.js", "./"]
COPY ["src/", "./src/"]
RUN ["npm", "run", "build"]
ENTRYPOINT ["node", "/root/node_modules/.bin/http-server" , "./dist/"]
EXPOSE 8080/tcp
```

Once again, build the image using `docker build`.

```bash
$ docker build -t demo-frontend:expose .
```

Now a user can see which ports are exposed either by looking at the `Dockerfile`, or by using `docker inspect` on the image.

```bash
$ docker inspect --format '{{range $key, $value := .ContainerConfig.ExposedPorts}}{{ $key }}{{end}}' demo-frontend:expose
8080/tcp
```

Note that the `EXPOSE` instruction does not publish the port. If the user wishes to publish the port, he/she would have to either:

- use the `-p` flag on `docker run` to individually specify each host-to-container port mapping, or
- use the `-P` flag to automatically map all exposed container port(s) to an ephemeral high-ordered host port(s)

## Reducing the Docker Image file size

If we take a look at our image now, you'll find that it's *huge* (939MB to be exact).

```sh
$ docker images demo-frontend:expose
REPOSITORY     TAG     IMAGE ID      SIZE
demo-frontend  expose  9ffa262cf2ce  939MB
```

For us to deploy this image to a remote server and run it, at least 939MB must be transferred over. Imagine a scenario where you need to rollback to a previous deployment in production; if your Docker image is large, there may be a noticeable downtime before the Docker image finish being transferred onto the servers and the rollback is complete. Therefore, reducing the file size of our Docker image is important.

### Removing Obsolete Files

If we examine the contents of our container, we will find many files that were required for the build process, but not during runtime.

```sh
$ docker exec -it demo-frontend du -ahd1
16K    ./dist
36K    ./src
4.0K   ./webpack.config.js
55M    ./node_modules
15M    ./.npm
4.0K   ./package.json
164K   ./package-lock.json
70M    .
```

In fact, out of the files above, only `dist/` and `node_modules/` are needed. We should remove the rest.

A naive approach would be to add an extra `RUN` instruction to remove these files.

```dockerfile
FROM node
WORKDIR /root/
COPY ["package.json", "package-lock.json", "./"]
RUN ["npm", "install"]
COPY ["webpack.config.js", "./"]
COPY ["src/", "./src/"]
RUN ["npm", "run", "build"]
RUN ["/bin/bash", "-c", "find . ! -name dist ! -name node_modules -maxdepth 1 -mindepth 1 -exec rm -rf {} \\;"]
ENTRYPOINT ["node", "/root/node_modules/.bin/http-server" , "./dist/"]
EXPOSE 8080
```

Whilst this *does* get rid of the files, it does will not reduce the file size of our image. This is because Docker images are built layer by layer; once a layer is added, it cannot be removed from the image. Adding an additional `RUN` instruction will actually *increase* the image's file size.

Another approach would be to combine the build and cleanup steps into a single instruction.

```dockerfile
FROM node
WORKDIR /root/
COPY [".", "./"]
RUN ["/bin/sh", "-c", "npm install && npm run build && find . ! -name dist ! -name node_modules -maxdepth 1 -mindepth 1 -exec rm -rf {} \\;"]
ENTRYPOINT ["node", "/root/node_modules/.bin/http-server" , "./dist/"]
EXPOSE 8080
```

Whilst this *does* reduce the image size, it undoes all the good work we've done leveraging the build cache.

Instead, we can use **multi-stage builds** to remove obsolete files, whilst still taking advantage of the build cache.

#### Using Multi-stage Builds

Multi-stage build is a `Dockerfile` feature introduced in v17.05 that allows you to specify *multiple* images (stages) within the *same* `Dockerfile`. More importantly, you are able to `COPY` build artifacts from one stage to another stage.

Therefore, inside our `Dockerfile`, we can have a *builder stage*, where we install dependencies and build our application, splitting that process into multiple instructions to leverage the build cache. Then, we copy only what is needed to run the image from the builder stage to the final image.

```dockerfile
FROM node as builder
WORKDIR /root/
COPY ["package.json", "package-lock.json", "./"]
RUN ["npm", "install"]
COPY ["webpack.config.js", "./"]
COPY ["src/", "./src/"]
RUN ["npm", "run", "build"]
RUN ["/bin/bash", "-c", "find . ! -name dist ! -name node_modules -maxdepth 1 -mindepth 1 -exec rm -rf {} \\;"]

FROM node
WORKDIR /root/
COPY --from=builder /root/ ./
ENTRYPOINT ["node", "/root/node_modules/.bin/http-server" , "./dist/"]
EXPOSE 8080
```

Note that we specified a `--from` option to `COPY` to signify that it should copy from the `builder` stage, and not from the build context.

Using multi-stage builds allows us to leverage the build cache, whilst keeping our final image size small.

If we build our image again, you'll see that we'ved saved ~9MB from the image.

```sh
$ docker build -t demo-frontend:multi-stage .
$ docker images
REPOSITORY     TAG          IMAGE ID      SIZE
demo-frontend  multi-stage  cf57206dc983  930MB
<none>         <none>       8874c0fec4c9  939MB
```

The `<none>:<none>` image is the intermediate builder stage image, which can be safely discarded, although doing so will also remove the cached layers.

> We will outline a way to easily clean up intermediate images later in this article.

### Using a lighter base image

Even though we've gotten rid of unnecessary build artifacts, 9MB is not a lot relative to the size of the image. We can reduce the size of the image more significantly by using a lighter base image.

At the moment, we are using the `node` base image, which is, itself, 904MB.

```sh
$ docker images node
REPOSITORY  TAG     IMAGE ID      SIZE
node        latest  a9c1445cbd52  904MB
```

This means no matter how much we minimize our `demo-frontend` image, it will *never* get smaller than 904MB. So why is it so large?

If we look inside the `Dockerfile` for the `node` base image, we'll find that it's based on the [`buildpack-deps`](https://hub.docker.com/_/buildpack-deps/) image, which contains a large number of common Debian packages, including build tools, system libraries, and system utilities. We might need these utilities when building our `demo-frontend` image, but we won't need them to run our `node` process.

Fortunately, there's a variant of the `node` image called [`node:alpine`](https://github.com/nodejs/docker-node#nodealpine). The `node:alpine` image is based off the [`alpine`](https://hub.docker.com/_/alpine) (Linux Alpine) image, which is a much smaller base image (5.53MB).

```sh
$ docker images alpine
REPOSITORY  TAG     IMAGE ID      SIZE
alpine      latest  5cb3aa00f899  5.53MB
```

The `alpine` image doesn't include any build tools or libraries (it doesn't even have Bash!), allowing it to have a much smaller image size than the `node:latest` image.

```sh
$ docker images node
REPOSITORY  TAG     IMAGE ID      SIZE
node        slim    e52c23bbdd87  148MB
node        latest  a9c1445cbd52  904MB
node        alpine  953c516e1466  76.1MB
```

Therefore, we should update our `Dockerfile` to use `node:alpine` instead of `node` for our final image (but keep using `node` for our `builder` stage).

```dockerfile
FROM node as builder
WORKDIR /root/
COPY ["package.json", "package-lock.json", "./"]
RUN ["npm", "install"]
COPY ["webpack.config.js", "./"]
COPY ["src/", "./src/"]
RUN ["npm", "run", "build"]
RUN ["/bin/bash", "-c", "find . ! -name dist ! -name node_modules -maxdepth 1 -mindepth 1 -exec rm -rf {} \\;"]

FROM node:alpine
WORKDIR /root/
COPY --from=builder /root/ ./
ENTRYPOINT ["node", "/root/node_modules/.bin/http-server" , "./dist/"]
EXPOSE 8080
```

When we build our image again, you should notice the size of the image decreased drastically!

```sh
$ docker images demo-frontend:alpine
REPOSITORY     TAG     IMAGE ID      SIZE
demo-frontend  alpine  97373fdcb697  102MB
```

## Removing Intermediate Images

Mutli-stage build is a great feature, as it allows you to keep images small *and* make use of the build cache. But this also means a lot of intermediate images are going to be generated.

These intermediate images are a type of **dangling image**, which are images that does not have a name. Generally, you should keep these dangling images, as they are the basis of the build cache. But having them littered across the output of your `docker images` output can be annoying; or if you are maintaining a CI/CD server, you may also want to clean up dangling images regularly.

You can output a list of dangling images by using the `--filter` flag of `docker images`.

```sh
$ docker images --filter dangling=true
REPOSITORY  TAG     IMAGE ID      SIZE
<none>      <none>  8874c0fec4c9  939MB
```

And you can remove them by running `docker rmi $(docker images --filter dangling=true --quiet)`. However, this indiscriminately removes *all* dangling images. What if you just want to remove dangling images generated from a certain build? Enter labels!

### Using labels (LABEL)

The `LABEL` instruction allows you to specify metadata (as key-value pairs) to your image. You can use labels to:

- document contact details of the author and/or maintainer of the image (this replaces the deprecated [`MAINTAINER`](https://docs.docker.com/engine/reference/builder/#maintainer-deprecated) instruction)
- the build date of the image
- add licensing information

In our case, we can use labels to mark an image as intermediate and belonging to the `demo-frontend` build.

```dockerfile
FROM node as builder
LABEL name=demo-frontend
LABEL intermediate=true
WORKDIR /root/
COPY ["package.json", "package-lock.json", "./"]
RUN ["npm", "install"]
COPY ["webpack.config.js", "./"]
COPY ["src/", "./src/"]
RUN ["npm", "run", "build"]
RUN ["/bin/bash", "-c", "find . ! -name dist ! -name node_modules -maxdepth 1 -mindepth 1 -exec rm -rf {} \\;"]

FROM node:alpine
LABEL name=demo-frontend
WORKDIR /root/
COPY --from=builder /root/ ./
ENTRYPOINT ["node", "/root/node_modules/.bin/http-server" , "./dist/"]
EXPOSE 8080
```

Now, when we build our image, it will be labelled, and we can filter the output of `docker images` using the labels.

```sh
$ docker build -t demo-frontend:labels .
$ docker images --filter label=name=demo-frontend
REPOSITORY     TAG     IMAGE ID      SIZE
demo-frontend  labels  6965537afe54  102MB
<none>         <none>  0cbce2a3844b  939MB
```

It also allows us to remove the intermediate image of our `demo-frontend` build(s) by running `docker rmi $(docker images --filter label=name=demo-frontend --filter label=intermediate=true --quiet)`.

## Adding Semantics to Labels

Above, we picked two strings - `name` and `intermediate` - as our label key values. This is fine for now, but what if the author of another Docker image decides to use these labels as well? This is why Docker [recommends](https://docs.docker.com/config/labels-custom-metadata/#key-format-recommendations) that all `LABEL` instructions should have keys that are **namespaced** with the reverse DNS name of a domain that you own. This will avoid clashes in label key names. Therefore, we should update our labels accordingly.

```dockerfile
FROM node as builder
LABEL works.buddy.name=demo-frontend
LABEL works.buddy.intermediate=true
WORKDIR /root/
COPY ["package.json", "package-lock.json", "./"]
RUN ["npm", "install"]
COPY ["webpack.config.js", "./"]
COPY ["src/", "./src/"]
RUN ["npm", "run", "build"]
RUN ["/bin/bash", "-c", "find . ! -name dist ! -name node_modules -maxdepth 1 -mindepth 1 -exec rm -rf {} \\;"]

FROM node:alpine
LABEL works.buddy.name=demo-frontend
WORKDIR /root/
COPY --from=builder /root/ ./
ENTRYPOINT ["node", "/root/node_modules/.bin/http-server" , "./dist/"]
EXPOSE 8080
```

Whilst namespacing prevent label keys from clashing, it lacks a common semantics - how would a user know what `works.buddy.intermediate` mean? Or whether `works.buddy.intermediate` conveys the same meaning as `com.acme.intermediate`?

In the past, Docker users and organizations have came up with multiple conventions for imposing semantics to label key names, including:

- [**Label Schema**](http://label-schema.org/rc1/), which uses a shared `org.label-schema` namespace
- [Generic labels suggested by Project Atomic](https://github.com/projectatomic/ContainerApplicationGenericLabels)

However, both have been superseded by [**annotations**](https://github.com/opencontainers/image-spec/blob/master/annotations.md) defined in the [**Open Container Initiative (OCI)**](https://www.opencontainers.org/) [**Image Format Specification**](https://github.com/opencontainers/image-spec). This specification defines multiple [pre-defined annotation keys](https://github.com/opencontainers/image-spec/blob/master/annotations.md#pre-defined-annotation-keys), each prefixed with the `org.opencontainers.image.` namespace.

For example, the annotations specification specifies that the `org.opencontainers.image.title` label be used to specify the "human-readable title of the image", and the `org.opencontainers.image.vendor` label be used for the "name of the distributing entity, organization or individual".

So let's update the label keys in our `Dockerfile` with these *standardized* label keys wherever possible.

```dockerfile
FROM node as builder
LABEL org.opencontainers.image.vendor=demo-frontend
LABEL works.buddy.intermediate=true
WORKDIR /root/
COPY ["package.json", "package-lock.json", "./"]
RUN ["npm", "install"]
COPY ["webpack.config.js", "./"]
COPY ["src/", "./src/"]
RUN ["npm", "run", "build"]
RUN ["/bin/bash", "-c", "find . ! -name dist ! -name node_modules -maxdepth 1 -mindepth 1 -exec rm -rf {} \\;"]

FROM node:alpine
LABEL org.opencontainers.image.vendor=demo-frontend
LABEL org.opencontainers.image.title="Buddy Team"
WORKDIR /root/
COPY --from=builder /root/ ./
ENTRYPOINT ["node", "/root/node_modules/.bin/http-server" , "./dist/"]
EXPOSE 8080
```

## Linting your Dockerfile

The last thing we will do in this article is to lint our `Dockerfile`. There are multiple tools available for linting `Dockerfile`s:

- Haskell Dockerfile Linter, or

   

  **hadolint**

  - written in Haskell

- `dockerfilelint`

  - written in JavaScript, and has an online version at [fromlatest.io](https://www.fromlatest.io/)

- RedHat's Project Atomic's

   

  `dockerfile_lint`

  - also written in JavaScript

- `dockerlint`

  - another linter written in JavaScript

In this article, we will use hadolint, with a brief mention of `dockerfilelint` at the end.

### Hadolint

Hadolint parses the `Dockerfile` into an **abstract syntax tree** (**AST**), which is a structured object representing the contents of the `Dockerfile`. It is similar *in concept* to how your browser parses HTML source code into the Document Object Model (DOM).

Hadolint will then test the AST against a list of [rules](https://github.com/hadolint/hadolint#rules) to detect places in the `Dockerfile` which does not follow best practices. Let's run it against our `Dockerfile` to see where we can improve.

The easiest way to run hadolint is by running the `hadolint/hadolint` image using Docker.

```sh
$ docker pull hadolint/hadolint
$ docker run --rm -i hadolint/hadolint < Dockerfile
/dev/stdin:1 DL3006 Always tag the version of an image explicitly
```

Hadolint displayed the [`DL3006`](https://github.com/hadolint/hadolint/wiki/DL3006) error, which says that the first line (`/dev/stdin:1`) of the `Dockerfile` should use a tagged image. So let's update our `FROM` instruction to give our `node` base image the `latest` tag.

```dockerfile
FROM node:latest as builder
LABEL org.opencontainers.image.vendor=demo-frontend
...
```

We can run hadolint again; this time, it gives another error.

```sh
$ docker run --rm -i hadolint/hadolint < Dockerfile
/dev/stdin:1 DL3007 Using latest is prone to errors if the image will ever update. Pin the version explicitly to a release tag
```

The [`DL3007`](https://github.com/hadolint/hadolint/wiki/DL3007) error informs us that we shouldn't use the `latest` tag, as `node:latest` can reference different images over time. Instead, we should pick a more specific tag. We could be as specific as possible and use a tag like `10.15.3-stretch`. However, I've found using the `lts` tag is often sufficient, as it follows the latest Long Term Support (LTS) version of Node.js.

```sh
FROM node:lts as builder
LABEL org.opencontainers.image.vendor=demo-frontend
...
```

Now, when we run hadolint again, it doesn't generate any errors anymore!

In general, where using hadolint, there are two types of [rules](https://github.com/hadolint/hadolint#rules):

- Rules which begins with `DL` implies errors in the `Dockerfile` syntax
- Rules which begins with `SC` implies errors in some of the script(s) you specified within the `Dockerfile`. These are picked up by another tool called [ShellCheck](https://github.com/koalaman/shellcheck), which performs static analysis on your shell scripts.

### Using a Second Linter

Linting your `Dockerfile` ensures you are following best practices; but you don't have to limit yourself to a single linter! For instance, you can also use the `dockerfilelint` npm package alongside hadolint.

Using `dockerfilelint` with our pre-linted `Dockerfile` yields a similar result, although `dockerfilelint` outputs in CLI format by default, which might be better for everyday use.

```sh
$ dockerfilelint Dockerfile 

File:   Dockerfile
Issues: 1

Line 1: FROM node as builder
Issue  Category  Title               Description
    1  Clarity   Base Image Missing  Base images should specify a tag to use.
                 Tag
```

`dockerfilelint` can also output as JSON, which may be advantagous for programmatic use.

```sh
$ dockerfilelint Dockerfile -o json | jq .files[0].issues
[
  {
    "line": "1",
    "content": "FROM node as builder",
    "category": "Clarity",
    "title": "Base Image Missing Tag",
    "description": "Base images should specify a tag to use."
  }
]
```

When the issues are fixed, this is the output from `dockerfilelint`.

```sh
$ dockerfilelint Dockerfile

File:   Dockerfile
Issues: None found 👍
```

Using multiple linters have the advantage of discovering errors missed by other linters. To finish up, let's build our image using the (double-)linted `Dockerfile`!

```sh
$ docker build -t demo-frontend:oci-annotations .
```

## Run Containers using unprivileged (non-root) users

By default, a containerized application will run as the `root` user (UID `0`) inside the container; this is the reason why we were able to copy files into `/root/` and run our application from there. Another way to demonstrate this is by running the `whoami` command from within the container; we can do this by overriding the entrypoint with the `--entrypoint` flag when invoking `docker run`.

```sh
$ docker run --rm --name demo-frontend --entrypoint=whoami  demo-frontend:oci-annotations
root
```

All your Docker containers are started by the Docker daemon, which runs as the `root` user on your host system. This is not what we are talking about here. We are talking about what user the application *within* the container is running as. Now, this may make you question - But they're only `root` *inside* of the container, why does it matter?

To understand why running as `root` *inside* a container can be insecure, we must first understand namespaces.

### Understanding Namespaces

Docker provides isolation through the use of **cgroups** (a.k.a. **control groups**) and **namespaces**. Control groups slices up a portion of the system's resources (e.g. CPU, memory, PID), and namespaces map these host system resources with an equivalent ID/path within the container. I like to use the following analogy:

> Imagine if your system is a cake. Control groups slice up the cake and distribute it to different people; namespaces try to convince you that your slice is the whole cake.

For example, Docker uses PID namespaces to 'trick' the first process within your container to think it is the init process, when, in fact, it is just a normal process on the host system. PID namespaces *remaps* the PID within the container to the 'real' host PID. Using PID namespaces prevents processes from different containers from communicating with each other, and to the host.

#### User Namesapces

However, with Docker, user namespaces are *not* enabled by default. This means that the `root` user inside your container maps to the same `root` user as your host machine.

> You can enable user remapping by default by editing `/etc/docker/daemon.json`. See more details by reading [*Enable userns-remap on the daemon*](https://docs.docker.com/engine/security/userns-remap/#enable-userns-remap-on-the-daemon)

#### Host Networking

User namespaces is just one example. Users of your image often opt to use [**host networking**](https://docs.docker.com/network/host/), which means a network namespace is not created for the container, further reducing the level of isolation.

When using host networking, Docker does not provide any isolation *at all* to the networking stack, which means a process within your container, *running as `root`*, can change the firewall settings on your host, bind to privileged ports, and configure other network settings. Running as a non-privileged user will limit the amount of changes an attacker can make.

#### Bind Mounts

Lastly, users often uses [**bind mounts**](https://docs.docker.com/storage/bind-mounts/) to synchronize files on the host with files within the container. However, doing so will exposes part of your host's filesystem to processes within the container.

For example, a common requirement for some images is to bind mount `/var/run/docker.sock`. This allows the process within your container to interact with the Docker daemon on the host. However, doing so allows for the `root` user, and any users within the `docker` group, to break out of the container and gain `root` access *on the host*. See the [Docker Breakout](https://youtu.be/CB9Aa6QeRaI) video on YouTube for a demonstration of this.

### Principle of Least Privilege

But regardless of whether namespaces are enabled or if bind mounts are used, you should always follow the [**Principle of Least Privilege**](https://en.wikipedia.org/wiki/Principle_of_least_privilege). If you program doesn't need root privileges to run, then why give it root privileges in the first place? If your application, with root access, is somehow compromised, the attacker will have a much easier time discovering related services, reading sensitive information, and performing privilege escalation.

So, how do we go about running our application as a unprivileged user? There are 2 ways:

- Specify a `USER` instruction to set the default user. This is specified by the image author.
- Using the `--user`/`-u` flag. This is specified by the *user* of the image, and overrides the `USER` instruction.

### Using the USER instruction

The `USER` instruction allows you to specify a different user to use. By default, all `node` images comes with a `node` user.

```sh
$ docker run --rm --name demo-frontend --entrypoint="cat" demo-frontend:oci-annotations /etc/passwd | grep node
node:x:1000:1000:Linux User,,,:/home/node:/bin/sh
```

So let's use that instead of `root`.

```dockerfile
FROM node:lts as builder
LABEL org.opencontainers.image.vendor=demo-frontend
LABEL works.buddy.intermediate=true
USER node
WORKDIR /home/node/
COPY --chown=node:node ["package.json", "package-lock.json", "./"]
RUN ["npm", "install"]
COPY --chown=node:node ["webpack.config.js", "./"]
COPY --chown=node:node ["src/", "./src/"]
RUN ["npm", "run", "build"]
RUN ["/bin/bash", "-c", "find . ! -name dist ! -name node_modules -maxdepth 1 -mindepth 1 -exec rm -rf {} \\;"]

FROM node:alpine
LABEL org.opencontainers.image.vendor=demo-frontend
LABEL org.opencontainers.image.title="Buddy Team"
USER node
WORKDIR /home/node/
COPY --chown=node:node --from=builder /home/node/ ./
ENTRYPOINT ["node", "/home/node/node_modules/.bin/http-server" , "./dist/"]
EXPOSE 8080
```

First, we specified the `USER node` instruction. Every instruction after this will be ran as the `node` user. An exception is the `COPY` instruction, which creates files and directories with a UID and GID of `0` (the `root` user); that's why we used the `--chown` flag to re-assign the owner of the files/directories after they've been copied. Lastly, we also changed the `WORKDIR` to be the home directory for the `node` user.

Build this image, and whenever it's ran, it will default to using the `node` user.

```sh
$ docker build -t demo-frontend:user-node .
$ docker run --rm --name demo-frontend --entrypoint="whoami" demo-frontend:user-node
node
```

### Using the --user/-u flag

The user of your Docker image can also specify the user to use with the `--user` flag. If the user exists within the container (like the `node` user), you can specify the user by name; otherwise, you must specify the numeric UID and GID of the user.

```sh
$ docker run --rm --user 4567:4567 --name demo-frontend --entrypoint="id" demo-frontend:user-node
uid=4567 gid=4567
```

> If your application does require root access within the container, but you still want to isolate it from affecting the host, you can [set up user namespaces](https://docs.docker.com/engine/security/userns-remap/#enable-userns-remap-on-the-daemon) that remap the `root` user to a less-privileged user on the Docker host.

### Limit who is in the docker group

In a similar vein, any user within the `docker` group is able to send API requests to the Docker daemon through `/var/run/docker.sock`, which runs as `root`. Therefore, any user within the `docker` group can, by jumping through a few hoops, run any command as `root`. Therefore, you should limit the number of users who are within the `docker` group on the Docker host.

## Signing and Verifying Docker Images

Running your containers as an non-privileged used prevents privilege escalation attacks. However, there's a different kind of attack that can undermine all our hard work; and that's a Man-in-the-Middle (MitM) attack.

If you look inside the `package-lock.json` and `yarn.lock` files, you'll see that there's an [`integrity`](https://docs.npmjs.com/files/package-lock.json#integrity) field for every package, which specifies the [Subresource Integrity ](https://w3c.github.io/webappsec-subresource-integrity/)of the package tarball.

```sh
jest-matcher-one-of@^0.1.2:
  version "0.1.2"
  resolved "https://registry.yarnpkg.com/jest-matcher-one-of/-/jest-matcher-one-of-0.1.2.tgz#4d9a428c489c55275f69e058c91fb33f61c327b7"
  integrity sha512-vJIXaex/pGMLPC/Td44S2CZMU4efRAFhjgG6u9Zz2ZogeJVtLStmoEkaczcgojmHCYCPIZuw10Tq3uo7VdN4Ww==
```

The subresource integrity is a mechanism by which the `npm` client can verify that the package has been downloaded from the registry *without manipulation*. For a tarball, the subresource integrity is the SHA512 digest of the file. After `npm` downloads the tarball, it will generate the SHA512 digest of the tarball, and if it matches with what it should be, `npm` trusts that the package has not been modified.

In contrast, Docker, by default, does not verify the integrity of images it pulls - it'll implicitly trust them. This introduces a security risk whereby a malicious party can perform a Man-in-the-Middle (MitM) attack, and feed our client with images that contains malicious code.

### Introducing Docker Content Trust (DCT)

Therefore, just as `npm` uses subresource integrity to verify packages, Docker provides a mechanism known as [**Docker Content Trust** (**DCT**)](https://docs.docker.com/engine/security/trust/content_trust/). DCT is a mechanism for digitally signing and verifying images pushed and pulled from Docker registries; it allows us to verify that the Docker images we download came from the intended publisher (authenticity) and no malicious party have modified it in any way (integrity).

To enable DCT, simply set the `DOCKER_CONTENT_TRUST` environment variable to `1`.

```sh
export DOCKER_CONTENT_TRUST=1
```

> You must run `export DOCKER_CONTENT_TRUST=1` on every terminal, or to enable DCT by default, add the `export` line to your `.profile`, `.bashrc`, or similar files.

When pulling an image, DCT prevents clients from downloading an image unless it contains a verified signature. Now, when we try to download an unsigned image (e.g. [`abiosoft/caddy`](https://hub.docker.com/r/abiosoft/caddy)), `docker` will error.

```sh
$ DOCKER_CONTENT_TRUST=1 docker pull abiosoft/caddy
Using default tag: latest
Error: remote trust data does not exist for docker.io/abiosoft/caddy: notary.docker.io does not have trust data for docker.io/abiosoft/caddy
```

On the other hand, when we try to pull a signed image (e.g. `redis:5`), it will succeed.

```sh
$ DOCKER_CONTENT_TRUST=1 docker pull redis:5
Pull (1 of 1): redis:5@sha256:9755880356c4ced4ff7745bafe620f0b63dd17747caedba72504ef7bac882089
sha256:9755880356c4ced4ff7745bafe620f0b63dd17747caedba72504ef7bac882089: Pulling from library/redis
1ab2bdfe9778: Pull complete 
966bc436cc8b: Pull complete 
c1b01f4f76d9: Pull complete 
8a9a85c968a2: Pull complete 
8e4f9890211f: Pull complete 
93e8c2071125: Pull complete 
Digest: sha256:9755880356c4ced4ff7745bafe620f0b63dd17747caedba72504ef7bac882089
Status: Downloaded newer image for redis@sha256:9755880356c4ced4ff7745bafe620f0b63dd17747caedba72504ef7bac882089
Tagging redis@sha256:9755880356c4ced4ff7745bafe620f0b63dd17747caedba72504ef7bac882089 as redis:5
docker.io/library/redis:5
```

#### Mechanism

Under the hood, DCT integrates with [**The Update Framework**](https://theupdateframework.github.io/) (**TUF**) to ensure the authenticity of the images you download. The TUF is able to uphold this requirement even in the case of the signing key being compromised. To integrate with TUF, DCT uses a tool called [**Docker Notary**](https://github.com/theupdateframework/notary), a product of the TUF project.

Therefore, as a pre-requisite to using DCT, the Docker registry that you're pushing to must have a Notary server attached. Currently, Docker Hub and the [**Docker Trusted Registry**](https://docs.docker.com/ee/dtr/) (**DTR**, a private registry available for Docker Enterprise users) have its Notary servers at [notary.docker.io](https://notary.docker.io/), whilst content trust support is still on the [roadmap](https://github.com/aws/containers-roadmap/issues/43) for Amazon Elastic Container Registry (ECR). So we will be using Docker Hub for this article.

The workflow starts with the image author singing the image and pushing it to the repository. To do this, he/she/they must follow these steps:

1. Generate a

    

   delegation key pair

   - a pair of public and private key

2. Add the private key to the local Docker trust repository (typically at `~/.docker/trust/`)

3. When using Docker Hub as the registry, tag the image using the format `<username>/<image-name>:<tag>` (e.g. `d4nyll/demo-frontend:dct`)

4. Add the public key to the Notary server attached to the Docker registry

5. Sign the image using the private key

6. Push the image to the repository

Now, when a developer wants to use the signed image: draft: yes

1. Docker Engine obtains the public key from the Notary server
2. Uses the public key to verify the image has not been tampered with

So let's sign and distribute our `demo-frontend:oci-annotations` image by following the same steps.

### Signing our Image

Signing Docker images with DCT involves the use of the `docker trust` command. Locally, we can generate a delegation key pair (1) *and* move it into the trust repository (2) using a single command - `docker trust key generate <name>`, where `<name>` would make up the name of the key pair files.

```sh
$ docker trust key generate demo
Generating key for demo...
Enter passphrase for new demo key with ID 12d7966: 
Repeat passphrase for new demo key with ID 12d7966: 
Successfully generated and loaded private key.
Corresponding public key available: ~/docker-demo-frontend/demo.pub
```

The private key would automatically be moved to `~/.docker/trust/private/`, and the public key would be saved in the current directory. You need to enter a passphrase for the private key, which acts as a second form of authentication - you must have *possession* of the private, as well as *knowledge* of the passphrase.

```sh
$ ls ~/.docker/trust/private/
12d79661f14a06444e2b7e6b265ba4a7684106c3ca71eac0410fbd02b60a0439.key
```

Next, we need to sign in to Docker Hub.

```sh
$  docker login -u <username> -p <password>
```

> Note the space before the `docker` command - this will prevent your username and password from being logged in your shell's history. Also, if you do not specify a particular registry, `docker login` will default to Docker Hub.

Next, we need to tag our image using the format `<username>/<image-name>:<tag>` (3)

```sh
$ docker images demo-frontend:oci-annotations
REPOSITORY     TAG              IMAGE ID      SIZE
demo-frontend  oci-annotations  5aa923714af1  103MB

$ docker tag 5aa923714af1 d4nyll/demo-frontend:dct
```

Adding the public key to the Notary server (4), signing the image (5), and pushing the image (6) can all be done using the `docker push` command with DCT enabled.

```sh
$ DOCKER_CONTENT_TRUST=1 docker push d4nyll/demo-frontend:dct
The push refers to repository [docker.io/d4nyll/demo-frontend]
b5f2176dd36f: Layer already exists 
f55c5975798b: Layer already exists 
f43135499101: Layer already exists 
232f3b596574: Layer already exists 
f1b5933fe4b5: Layer already exists 
dct: digest: sha256:9b7ba375b469f14deac5fafdfca382c791cb212feb6a293e2f25d10398831ec3 size: 1369
Signing and pushing trust metadata
Enter passphrase for repository key with ID 12b89d8: 
Successfully signed docker.io/d4nyll/demo-frontend:dct
```

As a test, let's also push the same image *without* signing it, using a different tag name.

```sh
$ docker tag 5aa923714af1 d4nyll/demo-frontend:untrusted
$ docker push --disable-content-trust d4nyll/demo-frontend:untrusted
The push refers to repository [docker.io/d4nyll/demo-frontend]
b5f2176dd36f: Layer already exists 
f55c5975798b: Layer already exists 
f43135499101: Layer already exists 
232f3b596574: Layer already exists 
f1b5933fe4b5: Layer already exists 
untrusted: digest: sha256:9b7ba375b469f14deac5fafdfca382c791cb212feb6a293e2f25d10398831ec3 size: 1369
```

### Pulling Our Image

Now, when we try to pull the unsigned image, `docker` will issue and error.

```sh
$ DOCKER_CONTENT_TRUST=1 docker pull d4nyll/demo-frontend:untrusted
No valid trust data for untrusted
```

But pulling the signed image will succeed.

```sh
$ DOCKER_CONTENT_TRUST=1 docker pull d4nyll/demo-frontend:dct
Pull (1 of 1): d4nyll/demo-frontend:dct@sha256:9b7ba375b469f14deac5fafdfca382c791cb212feb6a293e2f25d10398831ec3
sha256:9b7ba375b469f14deac5fafdfca382c791cb212feb6a293e2f25d10398831ec3: Pulling from d4nyll/demo-frontend
e7c96db7181b: Pull complete 
fd66aa3596b7: Pull complete 
519bc7b8873f: Pull complete 
a29cbe9067fa: Pull complete 
819e5d5df42d: Pull complete 
Digest: sha256:9b7ba375b469f14deac5fafdfca382c791cb212feb6a293e2f25d10398831ec3
Status: Downloaded newer image for d4nyll/demo-frontend@sha256:9b7ba375b469f14deac5fafdfca382c791cb212feb6a293e2f25d10398831ec3
Tagging d4nyll/demo-frontend@sha256:9b7ba375b469f14deac5fafdfca382c791cb212feb6a293e2f25d10398831ec3 as d4nyll/demo-frontend:dct
docker.io/d4nyll/demo-frontend:dct
```

With signed images, the consumers of our images can be reassured that the image they download have not been tampered with. However, the image may still contain security vulnerabilities that are unaddressed by the image developers. In the next section, we will outline the process image developers can take to ensure the image they publish do not have any obvious vulnerabilities.

## Vulnerability Scanning

Docker provides the **Docker Security Scanning** service, which will automatically scan images in your repository to identify known vulnerabilities. However, this service exists as a paid add-on to Docker Trusted Registry (DTR), a Docker Enterprise-only feature. Because most of our readers won't be paying for Docker Enterprise, we won't cover Docker Security Scanning here, but simply refer you to the [documentation](https://docs.docker.com/ee/dtr/user/manage-images/scan-images-for-vulnerabilities/).

Fortunately, there are a lot of open source tools out there. In this section of the article, we will cover 2 tools - [Docker Bench for Security](https://github.com/docker/docker-bench-security) and the [Anchore Engine](https://github.com/anchore/anchore-engine)

### Docker Bench for Security

Docker Bench for Security is a script that runs a large array of tests against the [CIS Docker Community Edition Benchmark v1.1.0](https://benchmarks.cisecurity.org/tools2/docker/CIS_Docker_Community_Edition_Benchmark_v1.1.0.pdf) - a set of guidelines that should serve as a baseline for securing our Docker installation and images. Note that Docker Bench for Security does not check any vulnerability database for the latest vulnerabilities - it only serves as a basic benchmark.

The Docker Bench for Security script is available as its own Docker image `docker/docker-bench-security`, which you can run using the following command:

```sh
$ docker run -it --net host --pid host --userns host --cap-add audit_control \
    -e DOCKER_CONTENT_TRUST=$DOCKER_CONTENT_TRUST \
    -v /etc:/etc \
    -v /usr/bin/docker-containerd:/usr/bin/docker-containerd \
    -v /usr/bin/docker-runc:/usr/bin/docker-runc \
    -v /usr/lib/systemd:/usr/lib/systemd \
    -v /var/lib:/var/lib \
    -v /var/run/docker.sock:/var/run/docker.sock \
    --label docker_bench_security \
    docker/docker-bench-security
```

Because Docker Bench for Security does only check your images, but also your Docker installation, running `docker/docker-bench-security` requires a lot of privileges that you should not normally allow for containers. For instance, the `--net host --pid host --userns host` flags mean to use the host's network, PID, and user namespaces, removing the isolation that these namespaces provide. You should not do this for the containers that run your applications.

The tests and results are categorized into these numbered groups:

- ```
  1.x
  ```

  - Host configuration - checking that a recent version of Docker is installed and all the relevant files exists

- ```
  2.x
  ```

  - Docker Daemon configuration

- ```
  3.x
  ```

  - Docker Daemon Configuration Files - check that the configuration files (e.g. `/etc/default/docker`) have the correct permissions

- ```
  4.x
  ```

  - Container Images and Build Files - whether our `Dockerfile` follows security best practices

- ```
  5.x
  ```

  - Container Runtime - whether containers are being ran with the proper isolation using namespaces and cgroups

- ```
  6.x
  ```

  - Docker Security Operations - a checklist of manual operations you should do regularly

For securing our Docker image, we are most interested in section 4 of the log output.

```sh
...
[WARN] 4.6  - Add HEALTHCHECK instruction to the container image
[WARN]      * No Healthcheck found: [d4nyll/demo-frontend:dct d4nyll/demo-frontend:untrusted]
[INFO] 4.9  - Use COPY instead of ADD in Dockerfile
[INFO]      * ADD in image history: [d4nyll/demo-frontend:dct d4nyll/demo-frontend:untrusted]
[INFO]      * ADD in image history: [d4nyll/demo-frontend:dct d4nyll/demo-frontend:untrusted]
...
```

In `4.6`, it recommends that we add a [`HEALTHCHECK`](https://docs.docker.com/engine/reference/builder/#healthcheck) instruction to the Dockerfile that allows Docker to periodically probe the container to ensure it is not just running, but healthy and functional. In `4.9`, it recommands that we use the `COPY` instruction over the [`ADD`](https://docs.docker.com/engine/reference/builder/#add) instruction, as `ADD` can be used to copy files from remote URLs, which can be insecure. If your image does require files from remote sources, you should download them manually, verify their authenticity and integrity, before using the `COPY` instruction to copy it into the image.

However, we won't be making changes to our `Dockerfile` here, because `HEALTHCHECK` isn't strictly security-related, and we don't have an `ADD` instruction in our Dockerfile - that instruction comes from the base image (`node:alpine`). But for your own images, run Docker Bench for Security to ensure you follow the baseline best practices.

### Anchore Engine

The next tool we will cover is the Anchore Engine. The Anchore Engine is an open-source application that is used to inspect, analyse and certify container images. Whilst Docker Bench for Security only provides basic checks, the Anchore Engine actually consult up-to-date security vulnerability databases and test your image for the latest vulnerabilities.

#### Installing Anchore Engine

The Anchore Engine is composed of many services, all of which are provided as a single Docker image - [`anchore/anchore-engine`](https://hub.docker.com/r/anchore/anchore-engine/). So let's download it using `docker pull`.

```sh
$ docker pull docker.io/anchore/anchore-engine:latest
```

The Anchore Engine developers provides a Docker Compose file at `/docker-compose.yaml` *inside the container*. We can use this Docker Compose file to deploy a quick installation of the all the constituent services that makes up the Anchore Engine. To extract this Docker Compose file, we can:

- Create a container from the `anchore/anchore-engine` image using [`docker create`](https://docs.docker.com/engine/reference/commandline/create/) (instead of `docker run`, which will create *and* run the container)
- Copy the `/docker-compose.yaml` file from within the container to our host machine
- Destroy the container as it's no longer needed

```sh
docker create --name <arbitrary-name> docker.io/anchore/anchore-engine:latest
docker cp <arbitrary-name>:/docker-compose.yaml ~/aevolume/docker-compose.yaml
docker rm <arbitrary-name>
```

Now, to deploy Anchore Engine locally, run `docker-compose up -d`

```sh
$ docker-compose up -d
Pulling engine-catalog (anchore/anchore-engine:v0.4.2)...
v0.4.2: Pulling from anchore/anchore-engine
5dfdb3f0bcc0: Pull complete
99f178453a43: Pull complete
407869f9917c: Pull complete
9276f4f2efa1: Pull complete
e2d442bae8a6: Pull complete
68e5bf4a6762: Pull complete
5dca5ab24b88: Pull complete
c0b52354123e: Pull complete
Digest: sha256:17b1ec4fd81193b2d5e371aeb5fc00775725f17af8338b4a1d4e1731dd69df6f
Status: Downloaded newer image for anchore/anchore-engine:v0.4.2
Creating aevolume_anchore-db_1 ... done
Creating aevolume_engine-catalog_1 ... done
Creating aevolume_engine-simpleq_1       ... done
Creating aevolume_engine-policy-engine_1 ... done
Creating aevolume_engine-api_1           ... done
Creating aevolume_engine-analyzer_1      ... done
```

This installation runs an API server, which exposes endpoints we can hit to interact with the Anchore Engine. However, instead of sending HTTP requests, we can install and use the Anchore CLI to interface with the API on our behalf.

#### Installing Anchore CLI

The Anchore CLI is provided as the [`anchorecli`](https://pypi.org/project/anchorecli/) Python package. Make sure you have the [`pip`](https://pypi.org/project/pip/) package manager installed, and then run:

```sh
$ pip install anchorecli
```

The `anchore-cli` command is now available. We can run `anchore-cli image add <image>` to add our image to Anchore Engine for it to be analyse. By default, the API server we ran also sets up basic anthentication, and so we need to pass in our username and password using the `--u` and `--p` flags respectively (use the username `admin` and password `foobar`).

```sh
$ anchore-cli --u admin --p foobar image add docker.io/d4nyll/demo-frontend:dct
Image Digest: sha256:9b7ba375b469f14deac5fafdfca382c791cb212feb6a293e2f25d10398831ec3
Parent Digest: sha256:9b7ba375b469f14deac5fafdfca382c791cb212feb6a293e2f25d10398831ec3
Analysis Status: not_analyzed
Image Type: docker
Analyzed At: None
Image ID: 5aa923714af111bae67025f2f98c6166d7f0c7c7d989a61212a09d8453f72180
Dockerfile Mode: None
Distro: None
Distro Version: None
Size: None
Architecture: None
Layer Count: None

Full Tag: docker.io/d4nyll/demo-frontend:dct
Tag Detected At: 2019-08-29T18:30:15Z
```

You can confirm that the image has been added successfully by listing out all the images Anchore Engine knows about.

```sh
$ anchore-cli --u admin --p foobar image list
Full Tag                            Image Digest       Analysis Status        
docker.io/d4nyll/demo-frontend:dct  sha256:9b7b..1ec3  analyzing
```

The image has a status of `analyzing`, but it can take some time for it to update its vulnerabilities from external databases and to run the analysis. In the mean time, you can run the `image wait <image>:<tag>` sub-command to be updated about the state of the image.

```sh
$ anchore-cli --u admin --p foobar image wait docker.io/d4nyll/demo-frontend:dct
```

Once analysed, its state will change from `analyzing` to `analyzed`.

```sh
Image Digest: sha256:9b7ba375b469f14deac5fafdfca382c791cb212feb6a293e2f25d10398831ec3
Parent Digest: sha256:9b7ba375b469f14deac5fafdfca382c791cb212feb6a293e2f25d10398831ec3
Analysis Status: analyzed
Image Type: docker
Analyzed At: 2019-08-29T18:32:06Z
Image ID: 5aa923714af111bae67025f2f98c6166d7f0c7c7d989a61212a09d8453f72180
Dockerfile Mode: Guessed
Distro: alpine
Distro Version: 3.9.4
Size: 121374720
Architecture: amd64
Layer Count: 5

Full Tag: docker.io/d4nyll/demo-frontend:dct
Tag Detected At: 2019-08-29T18:30:15Z
```

You can now retrieve the results of the vulnerability scan by running the [`anchore-cli image vuln  `](https://docs.anchore.com/current/docs/using/cli_usage/images/viewing_security_vulnerabilities/) subcommand. The security vulnerabilities are grouped into 3 types:

- ```
  os
  ```

  - vulnerabilities of the operating system and system packages

- ```
  non-os
  ```

  - non-system packages, such as those from JavaScript npm packages, Ruby Gems, Java Archive files, Python pip packages, etc.

- ```
  all
  ```

  - a combination of both `os` and `non-os`

We should use the `all` type to list out all vulnerabilities.

```sh
$ anchore-cli --u admin --p foobar image vuln docker.io/d4nyll/demo-frontend:dct all
```

Running the command does not return anything, which means the Anchore Engine did not find any security vulnerabilities for the image at the moment. Which is reassuring!

However, our application is a very simple one. The more complicated an application and image is, the more likely it is to contain a vulnerability. For your images, make sure you use a vulnerability scanner like Anchore to scan your images before you publish them.

## .dockerignore

Lastly, just like we have `.gitignore` to prevent us from accidentally committing sensitive information (e.g. passwords/keys/tokens) to Git, there's a `.dockerignore` file for Docker. You can add a `.dockerignore` file at the *root* of the build context directory, and the relevant files would not be included as part of the build context, and thus won't be accidentally be included into the image via `ADD` or `COPY` instructions.

The syntax for `.dockerignore` is very similar to `.gitignore`. You specify files/directories to ignore using a newline-separated list, and the file glob patterns are matched using Go's [`filepath.Match`](https://golang.org/pkg/path/filepath/#Match) rules. For more information about `.dockerignore`, refer to the [documentation](https://docs.docker.com/engine/reference/builder/#dockerignore-file).