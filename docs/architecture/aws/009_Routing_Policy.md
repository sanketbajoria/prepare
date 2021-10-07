# AWS — Amazon Route 53 — Routing Policies Overview

Introduction to AWS Route 53 Routing Policy types — Getting started guide.

When you create a record, you choose a routing policy, which determines how Amazon Route 53 responds to queries:

- **Simple routing policy** — Use for a single resource that performs a given function for your domain, for example, a web server that serves content for the example.com website.
- **Weighted routing policy** — Use to route traffic to multiple resources in proportions that you specify.
- **Latency routing policy** — Use when you have resources in multiple AWS Regions and you want to route traffic to the region that provides the best latency.
- **Failover routing policy** — Use when you want to configure active-passive failover.
- **Geolocation routing policy** — Use when you want to route traffic based on the location of your users.
- **Geoproximity routing policy** — Use when you want to route traffic based on the location of your resources and, optionally, shift traffic from resources in one location to resources in another.
- **Multivalue answer routing policy** — Use when you want Route 53 to respond to DNS queries with up to eight healthy records selected at random.

## **Simple Routing Policy**

![img](https://miro.medium.com/max/625/0*FPFopCbPx1990nlR)

Amazon Route 53 — Simple Routing Policy

Simple Routing Policy is the most basic routing policy defined using an A record to resolve to a single resource always without any specific rules. For instance, a DNS record can be created to resolve the domain to an ALIAS record that routes the traffic to an ELB load balancing a set of EC2 instances.

## **Weighted Routing Policy**

![img](https://miro.medium.com/max/625/0*TrK0aNKVkXOqefT1)

Amazon Route 53 — Weighted Routing Policy

Weighted Routing Policy is used when there are multiple resources for the same functionality and the traffic needs to be split across the resources based on some predefined weights.

## **Latency Routing Policy**

![img](https://miro.medium.com/max/625/0*DRv3YAgbX2RhNYZm)

Amazon Route 53 — Latency Routing Policy

Latency Routing Policy is used when there are multiple resources for the same functionality and you want Route 53 to respond to DNS queries with answers that provide the best latency i.e. the region that will give the fastest response time.

## **Failover Routing Policy**

![img](https://miro.medium.com/max/625/0*MZY6EwU1i-tPKdzE)

Amazon Route 53 — Failover Routing Policy

Failover Routing Policy is used to create Active/Passive set-up such that one of the site is active and serve all the traffic while the other Disaster Recover (DR) site remains on the standby. Route 53 monitors the health of the primary site using the health check.

## **Geolocation Routing Policy**

![img](https://miro.medium.com/max/625/0*lC2uBYsexGfwVpwF)

Amazon Route 53 — Geolocation Routing Policy

Geolocation Routing Policy is used to route the traffic based on the geographic location from where the DNS query is originated. This policy allows to send the traffic to resources in the same region from where the request was originated i.e. it allows to have site affinity based on the location of the users.

## Geoproximity Routing Policy (Traffic Flow Only)

![img](https://miro.medium.com/max/625/1*6GcYFwCTWJ6096usx9l9gQ.png)

Amazon Route 53 — Geoproximity Routing Policy (source AWS docs)

Geoproximity routing lets Amazon Route 53 route traffic to your resources based on the geographic location of your users and your resources. You can also optionally choose to route more traffic or less to a given resource by specifying a value, known as a *bias*. A bias expands or shrinks the size of the geographic region from which traffic is routed to a resource. To use geoproximity routing, you must use Route 53 [traffic flow](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/traffic-flow.html).

## Multivalue Answer Routing Policy

![img](https://miro.medium.com/max/625/0*FPFopCbPx1990nlR)

Amazon Route 53 —Multivalue Answer Routing Policy

Multivalue answer Routing Policy is like Simple Routing Policy but it can return multiple values, such as IP addresses for your web servers, in response to DNS queries. You can specify multiple values for almost any record, but multivalue answer routing also lets you check the health of each resource, so Route 53 returns only values for healthy resources. It’s not a substitute for a load balancer, but the ability to return multiple health-checkable IP addresses is a way to use DNS to improve availability and load balancing.