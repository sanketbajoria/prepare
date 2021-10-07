# EC2

- EC2 provides secure, resizable compute capacity.
- Gives you complete control of your computing resources including choice of storage, processor, networking and operating system.
- Allows you to increase/decrease capacity in minutes
- You need to create a key pair — public & private for asymmetric encryption.
- The EC2 Root volume is a virtual disk where the OS is installed, it can only be launched on SSD or Magnetic.
- Termination protection is turned off by default (turn on to make sure user doesn’t accidentally terminate instances)
- On an EBS backed instance, the root EBS volume is deleted when the instance is terminated
- Bootstrap scripts are code that gets ran as soon as your EC2 instance first boots up.

## Pricing

**1. On-Demand** — Fixed rate for compute capacity by hour or second with no commitment or up front costs. Typically used for short term, spiky or unpredictable workloads that can’t be interrupted.

**2. Reserved** — You have a capacity reservation which offers significant discount compared to on-demand, but you are require to have a contact for 1–3 years. Used for applications with steady predictable use. However, you cant move between regions.

Types of Reserved pricing:

- **Standard reserved instances** — Provides the most discount (up to 75% off) and the more you pay upfront /the longer the contact, the cheaper the price.
- **Convertible reserved instances** — up to 54% off and allows you to change between instance types e.g. t1-t4 as long as its of greater or equal value
- **Scheduled reserved instances** — can be launched within a time window to match capacity of a predictable schedule.

|                                                              | **Standard RI**           | **Convertible RI**        |
| ------------------------------------------------------------ | ------------------------- | ------------------------- |
| **Terms**(average discount off On-Demand)                    | 1 year (40%)3 years (60%) | 1 year (31%)3 years (54%) |
| Change Availability Zone, Instance size (for Linux OS), Networking type | Yes                       | Yes                       |
| Change instance families, operating system, tenancy, and payment option |                           | Yes                       |
| Benefit from Price Reductions                                |                           | Yes                       |

**3. Spot** – request unused EC2 instances, which can lower your costs significantly. 

Spot Instances are available at up to a 90% discount compared to On-Demand prices.

- Spot Instances with a defined duration (also known as **Spot blocks**) are designed not to be interrupted and will run continuously for the duration you select. This makes them ideal for jobs that take a finite time to complete, such as batch processing, encoding and rendering, modeling and analysis, and continuous integration, Machine Learning, Big Data (EMR, Spark, Hadoop).
- AWS can “pull the plug” and terminate spot instances with just a 2 minute warning. 
- Don’t use for anything critical that needs to be online all the time.
- A **Spot Fleet** is a collection of Spot Instances and optionally On-Demand Instances. The service attempts to launch the number of Spot Instances and On-Demand Instances to meet your specified target capacity. The request for Spot Instances is fulfilled if there is available capacity and the maximum price you specified in the request exceeds the current Spot price. The Spot Fleet also attempts to maintain its target capacity fleet if your Spot Instances are interrupted.
- A **Spot Instance pool** is a set of unused EC2 instances with the same instance type, operating system, Availability Zone, and network platform.
- You can start and stop your Spot Instances backed by Amazon EBS at will.
- You can modify instance types and weights for a running EC2 Fleet or Spot Fleet without having to recreate it.
- Allocation strategy for Spot Instances
  - **LowestPrice** – The Spot Instances come from the pool with the lowest price. This is the default strategy.
  - **Diversified** – The Spot Instances are distributed across all pools.
  - **CapacityOptimized** – The Spot Instances come from the pool with optimal capacity for the number of instances that are launching.
  - **InstancePoolsToUseCount** – The Spot Instances are distributed across the number of Spot pools that you specify. This parameter is valid only when used in combination with the lowest Price.

![Amazon elastic compute cloud (EC2)](https://k2y3h8q6.stackpathcdn.com/wp-content/uploads/2018/12/Amazon-elastic-compute-cloud-EC2-1024x506.png)

**4. Dedicated Hosts** – pay for a physical host that is fully dedicated to running your instances, and bring your existing per-socket, per-core, or per-VM software licenses to reduce costs.

**5. Dedicated Instances** – pay, by the hour, for instances that run on single-tenant hardware.

**6. On-Demand Capacity Reservations** – reserve capacity for your Amazon EC2 instances in a specific Availability Zone for any duration.

- Unlike Reserved instances, you don’t need to have one-year or three-year term commitment.
- When you create a Capacity Reservation, you specify:
  - The Availability Zone in which to reserve the capacity
  - The number of instances for which to reserve capacity
  - The instance attributes, including the instance type, tenancy, and platform/OS
- Your Savings Plans and regional Reserved Instances can be applied with your capacity reservations to receive discounts. Without these, your capacity reservations do not have billing discounts.
- Capacity Reservations can’t be created in placement groups
- Capacity Reservations can’t be used with Dedicated Hosts
- Your capacity reservation usage metrics can be monitored in Amazon Cloudwatch.

- There is a data transfer charge when copying AMI from one region to another
- EBS pricing is different from instance pricing. (see AWS storage services)
- AWS imposes a small hourly charge if an Elastic IP address is not associated with a running instance, or if it is associated with a stopped instance or an unattached network interface.
- You are charged for any additional Elastic IP addresses associated with an instance.
- If data is transferred between these two instances, it is charged at “Data Transfer Out from EC2 to Another AWS Region” for the first instance and at “Data Transfer In from Another AWS Region” for the second instance.

## Instance Type

![EC2 Instance Info ](https://p2zk82o7hr3yb6ge7gzxx4ki-wpengine.netdna-ssl.com/wp-content/uploads/Screen-Shot-2020-02-21-at-1.29.51-PM.png)

## Instance Lifecycle

![         The instance lifecycle       ](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/images/instance_lifecycle.png)

| Instance state  | Description                                                  | Instance usage billing                                       |
| :-------------- | :----------------------------------------------------------- | :----------------------------------------------------------- |
| `pending`       | The instance is preparing to enter the `running` state. An instance enters the `pending` state when it launches for the first time, or when it is started after being in the `stopped` state. | Not billed                                                   |
| `running`       | The instance is running and ready for use.                   | Billed                                                       |
| `stopping`      | The instance is preparing to be stopped or stop-hibernated.  | Not billed if preparing to stopBilled if preparing to hibernate |
| `stopped`       | The instance is shut down and cannot be used. The instance can be started at any time. | Not billed                                                   |
| `shutting-down` | The instance is preparing to be terminated.                  | Not billed                                                   |
| `terminated`    | The instance has been permanently deleted and cannot be started. | Not billed<br />**Note: **Reserved Instances that applied to terminated instances are billed until the end of their term according to their payment option. For more information, see [Reserved Instances](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-reserved-instances.html) |

- To prevent accidental termination, enable termination protection.

### Differences between reboot, stop, hibernate, and terminate

The following table summarizes the key differences between rebooting, stopping, hibernating, and terminating your instance.

| Characteristic                    | Reboot                                                      | Stop/start (Amazon EBS-backed instances only)                | Hibernate (Amazon EBS-backed instances only)                 | Terminate                                                    |
| :-------------------------------- | :---------------------------------------------------------- | :----------------------------------------------------------- | :----------------------------------------------------------- | :----------------------------------------------------------- |
| Host computer                     | The instance stays on the same host computer                | We move the instance to a new host computer (though in some cases, it remains on the current host). | We move the instance to a new host computer (though in some cases, it remains on the current host). | None                                                         |
| Private and public IPv4 addresses | These addresses stay the same                               | The instance keeps its private IPv4 address. The instance gets a new public IPv4 address, unless it has an Elastic IP address, which doesn't change during a stop/start. | The instance keeps its private IPv4 address. The instance gets a new public IPv4 address, unless it has an Elastic IP address, which doesn't change during a stop/start. | None                                                         |
| Elastic IP addresses (IPv4)       | The Elastic IP address remains associated with the instance | The Elastic IP address remains associated with the instance  | The Elastic IP address remains associated with the instance  | The Elastic IP address is disassociated from the instance    |
| IPv6 address                      | The address stays the same                                  | The instance keeps its IPv6 address                          | The instance keeps its IPv6 address                          | None                                                         |
| Instance store volumes            | The data is preserved                                       | The data is erased                                           | The data is erased                                           | The data is erased                                           |
| Root device volume                | The volume is preserved                                     | The volume is preserved                                      | The volume is preserved                                      | The volume is deleted by default                             |
| RAM (contents of memory)          | The RAM is erased                                           | The RAM is erased                                            | The RAM is saved to a file on the root volume                | The RAM is erased                                            |
| Billing                           | The instance billing hour doesn't change.                   | You stop incurring charges for an instance as soon as its state changes to `stopping`. Each time an instance transitions from `stopped` to `running`, we start a new instance billing period, billing a minimum of one minute every time you start your instance. | You incur charges while the instance is in the `stopping` state, but stop incurring charges when the instance is in the `stopped` state. Each time an instance transitions from `stopped` to `running`, we start a new instance billing period, billing a minimum of one minute every time you start your instance. | You stop incurring charges for an instance as soon as its state changes to `shutting-down`. |

## EC2 Metadata and Userdata

AWS makes information about your instance available via URLs. User Data is data that is set when your instance is launched. Metadata is data about your running instance.  You can view, by hitting below endpoint inside running instance.

- You can view your metadata at http://169.254.169.254/latest/meta-data/  For eg: instance type, ami etc..
- You can view user data at http://169.254.169.254/latest/user-data. Startup Script used to launch instance

Note that the ip address 169.254.169.254 is ALWAYS reserved in EC2 instances (as is the few numbers). 

You can pass two types of user data to Amazon EC2: 

- **shell scripts**: User data shell scripts must start with the `#!` (commonly **/bin/bash)**.

  ```shell
  #!/bin/bash
  yum update -y
  amazon-linux-extras install -y lamp-mariadb10.2-php7.2 php7.2
  yum install -y httpd mariadb-server
  ```

- **cloud-init: ** `#cloud-config` line at the top is required in order to identify the commands as cloud-init directives.

  ```yaml
  #cloud-config
  repo_update: true
  repo_upgrade: all
  
  packages:
   - httpd
   - mariadb-server
  
  runcmd:
   - [ sh, -c, "amazon-linux-extras install -y lamp-mariadb10.2-php7.2 php7.2" ]
   - systemctl start httpd
   - sudo systemctl enable httpd
  ```

The cloud-init output log file (`/var/log/cloud-init-output.log`) captures console output of startup script (userdata script).

- User data is limited to 16 KB.
- Instance metadata and user data are not protected by cryptographic methods.
- If you stop an instance, modify its user data, and start the instance, the updated user data is not executed when you start the instance.

### **AMI**

- Includes the following:
  - A template for the root volume for the instance (OS, application server, and applications)
  - Launch permissions that control which AWS accounts can use the AMI to launch instances
  - A block device mapping that specifies the volumes to attach to the instance when it’s launched

 ![AWS Training Amazon EC2 2](https://k2y3h8q6.stackpathcdn.com/wp-content/uploads/2018/12/AWS-Training-Amazon-EC2-2.jpg)

- Backed by Amazon EBS – root device for an instance launched from the AMI is an Amazon EBS volume. AMIs backed by Amazon EBS snapshots can use EBS encryption.
- Backed by Instance Store – root device for an instance launched from the AMI is an instance store volume created from a template stored in S3.

![AWS Training Amazon EC2 3](https://k2y3h8q6.stackpathcdn.com/wp-content/uploads/2018/12/AWS-Training-Amazon-EC2-3.jpg)

- AMI are regional by default.
- You can copy AMIs to different regions.
- You can share an AMI with specific AWS accounts
- You are only charged for the storage of the bits that make up your AMI, **there are no charges for creating an AMI**. EBS-backed AMIs are made up of snapshots of the EBS volumes that form the AMI. You will pay storage fees for those snapshots
- Provision EC2 using custom AMI for faster deployment.



# Security Groups

- Basically a virtual firewall for your EC2 Instances
- All inbound traffic is blocked by default, but all outbound traffic is allowed.
- You add rules to the security group to allow traffic in.
- Changes to a security groups rules take effect immediately and are automatically applied to all instances associated with that group.
- Security Groups = **STATEFUL**; when you create an inbound rule, an outbound one is created by default.
- Security groups are only permissive — you can’t create rules to deny access, only allow access.
- You can have more than one security group attached to an EC2 instance and in this case the rules from each are aggregated.

# EC2 Hibernate

- Allows you to hibernate your EC2 instances, so that you can stop them and pick back up where you left off again.
- It does this by saving the content from the in-memory state of the instance (RAM) to your EBS root volume.
- Useful for long running services and services that take long to boot.
- Can’t hibernate for more than **60 days**
- Once in hibernation mode there is no hourly charge — you only pay for the elastic IP Address & other attached volumes
- Boots up a lot faster after hibernation as it does not need to reload the operating system.

# EC2 Placement Groups

- A way of placing EC2 Instances so that instances are spread across the underlying hardware to minimise failures.
- Placement group names need to be unique within your account
- Only certain instances can be launched in placement groups e.g compute optimised, CPU, memory optimised & storage optimised.
- You can’t merge placement groups, but you can move an existing instance into a placement group.
- There is no charge associated with creating placement groups

**3 Types of placement groups:**

1. **Clustered Placement:**

Grouping instances close together within a single Availability Zone. Typically used to achieve low network latency & high throughput. Recommended you have the same type on instances in the cluster.

**2. Spread Placement:**

Opposite to clustered placement group, instances are placed on distinct racks on the underlying hardware. Typically used for small numbers of critical instances that should be kept separate from each other, so that one failure would not affect another. Spread placement groups can span multiple Availability Zones.

**3. Partitioned:**

EC2 creates partitions by dividing each group into logical segments. Each partition has its own set of racks, network and power source to help isolate the impact of a hardware failure. Can be multi AZ.

# Storage

### ![AWS Training Amazon EC2 5](https://k2y3h8q6.stackpathcdn.com/wp-content/uploads/2018/12/AWS-Training-Amazon-EC2-5.jpg)

- EBS 

  - EBS is persistent storage volumes for EC2

  - EBS volumes are automatically replicated within an Availability Zone and therefore are highly available and can be used for mission critical applications.

  - Very performant and can be used for throughput intensive workloads. Storage can also be increase without disturbing any current workloads.

  - The EBS volume needs to be mounted to an EC2 instance within the same Availability Zone.

  - You can take snapshots of your volumes which are point-in-time copies, these copies can then also be restored into new regions. The snapshots themselves are stored in S3.

  - Snapshots are incremental — only blocks that have changed since your last snapshot are moved to S3.

  - When snapshotting root device — best practice to terminate it first.

  - You can create an EBS volume as encrypted and then also any snapshot taken of that volume will therefore be encrypted as well.

    ### Types of EBS

    There are a number different types of EBS volumes all varying in price and performance, below are some more details about them:

    **General Purpose SSD (GP2)**

    - Balances price and performance and can be used for most workloads
    - Good for up to **16,000 IOPS** per volume

    **Provisioned IOPS SSD (IO1)**

    - High performance SSD for mission critical applications
    - Commonly used for databases
    - Can go to **64,000 IOPS** per volume

    **Throughput Optimised HDD (St1)**

    - Low cost hard disk drive (magnetic storage)
    - Used for throughout intensive and frequently access workloads
    - Typically used for big data, data warehouses and log processing
    - Max **500 IOPS** per volume

    **Cold HDD (SC1)**

    - **Lowest cost** hard disk drive (magnetic storage)
    - Used for less frequently accessed workloads and when lowest storage cost is important.
    - Common use could be for file servers
    - Max **250 IOPS** per volume

    **EBS Magnetic (Standard)**

    - Previous generation hard disk drive typically used for infrequently accessed workloads.
    - Max **40–200 IOPS** per volume

- Instance Store

  - Provides temporary block-level storage for instances.
  - The data on an instance store volume persists only during the life of the associated instance; if you stop or terminate an instance, any data on instance store volumes is lost.

- Elastic File System (EFS) 
  - Provides scalable file storage for use with Amazon EC2. You can create an EFS file system and configure your instances to mount the file system.
  - You can use an EFS file system as a common data source for workloads and applications running on multiple instances.

- S3 
  - Provides access to reliable and inexpensive data storage infrastructure.
  - Storage for EBS snapshots and instance store-backed AMIs.