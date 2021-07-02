#Stop all container
docker stop $(docker ps -a -q)
#Remove all container
docker rm $(docker ps -a -q)
#Remove all images
docker rmi $(docker images -a -q)

#List all container
docker ps 
#List all stopped container
docker ps -a

#Build image
docker build "<foldername>" -t "<user friendly image name>"


#Run docker
#it -- For interactive mode
#d -- For daemon mode
#entrypoint -- For overriding entrypoint
#port -- Mapping host port to local port
docker run -it -d --entrypoint "/bin/sh" -p 8080:8080 "<imageName>"



#System prune, remove all images, all stopped container
docker system prune
