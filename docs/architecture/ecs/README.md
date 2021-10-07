# ECS concepts
Before we go any further, let’s get familiar with some ECS concepts and terms.

## Cluster
A logical grouping of EC2 container instances. The cluster is a skeleton structure around which you build and operate workloads.

## Container instance(s)
This is actually an EC2 instance running on the ECS agent. The recommended option is to use AWS ECS AMI but any AMI can be used as long as you add the ECS agent to it. The ECS agent is also open source.

## Container agent
This is the agent that runs on EC2 instances to form the ECS cluster. If you’re using the ECS optimized AMI, you don’t need to do anything as the agent comes with it. But if you want to run your own OS/AMI, you will need to install the agent. The container agent is open source and can be found here:
https://github.com/aws/amazon-ecs-agent

## Task definition
An application containing one or more containers. This is where you provide the Docker images, the amount of CPU/Memory to use, ports etc. You can also link containers here, similar to a Docker command line.

## Task
An instance of a task definition running on a container instance.

## Service
A service in ECS allows you to run and maintain a specified number of instances of a task definition. If a task in a service stops, the task is restarted. Services ensure that the desired running tasks are achieved and maintained. Services can also include things like load balancer configuration, IAM roles and placement strategies.

## Container
A Docker container that is executed as part of a task.

## Service auto-scaling
This is similar to the EC2 auto scaling concept but applies to the number of containers you’re running for each service. The ECS service scheduler respects the desired count at all times. Additionally, a scaling policy can be configured to trigger a scale-out based on alarms.

## Reference
https://blog.rackspace.com/working-aws-ecs
