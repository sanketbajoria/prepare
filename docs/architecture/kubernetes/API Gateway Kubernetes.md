# Can you expose your microservices with an API gateway in Kubernetes?

PUBLISHED IN APRIL 2019

 UPDATED IN DECEMBER 2019

------

![Can you expose your microservices with an API gateway in Kubernetes?](https://learnk8s.io/a/73405a2f789beb486d9a7ec108f630bb.svg)

------

**Welcome to Bite-sized Kubernetes learning** — a regular column on the most interesting questions that we see online and during our workshops answered by a Kubernetes expert.

> Today's answers are curated by [Daniele Polencic](https://linkedin.com/in/danielepolencic). Daniele is an instructor and software engineer at Learnk8s.

*If you wish to have your question featured on the next episode, [please get in touch via email](mailto:hello@learnk8s.io) or [you can tweet us at @learnk8s](https://twitter.com/learnk8s).*

Did you miss the previous episodes? [You can find them here.](https://learnk8s.io/bite-sized)

## Can you expose your microservices with an API gateway in Kubernetes?

> **TL;DR:** yes, you can. Have a look at the [Kong](https://konghq.com/blog/kong-kubernetes-ingress-controller/), [Ambassador](https://www.getambassador.io/) and [Gloo](https://gloo.solo.io/) Ingress controllers. You can also use service meshes such as [Istio](https://istio.io/) API gateways, but you should be *careful*.

Table of content:

- The king of API Gateways: Kong
- Ambassador, the modern API gateway
- Gloo things together
- Istio as an API gateway

In Kubernetes, an Ingress is a component that routes the traffic from outside the cluster to your services and Pods inside the cluster.

In simple terms, **the Ingress works as a reverse proxy** or a load balancer: all external traffic is routed to the Ingress and then is routed to the other components.

![Ingress as a load balancer](https://learnk8s.io/a/6a5258830682e5052b931fcfe938a172.svg)

While the most popular ingress is the [ingress-nginx project](https://github.com/kubernetes/ingress-nginx), there are several other options when it comes to selecting and using an Ingress.

You can choose from Ingress controllers that:

- handle HTTP traffic such as [Contour](https://github.com/heptio/contour) or [Treafik Ingress](https://docs.traefik.io/user-guide/kubernetes/)
- support UDP and TCP traffic such as [Citrix Ingress](https://github.com/citrix/citrix-k8s-ingress-controller)
- support Websockets such as [HAProxy Ingress](https://github.com/jcmoraisjr/haproxy-ingress)

There are also other hybrid Ingress controllers that can integrate with existing cloud providers such as [Zalando's Skipper Ingress](https://opensource.zalando.com/skipper/).

When it comes to API gateways in Kubernetes, there are a few popular choices to select from.

## The king of API Gateways: Kong

If you are building an API, you might be interested in what [Kong Ingress](https://konghq.com/blog/kong-kubernetes-ingress-controller/) has to offer.

**Kong is an API gateway built on top of Nginx.**

Kong is focused on API management and offers features such as authentication, rate limiting, retries, circuit breakers and more.

What's interesting about Kong is that it comes packaged as a Kubernetes Ingress.

So it could be used in your cluster as a gateway between your users and your backend services.

You can expose your API to external traffic with the standard Ingress object:

ingress.yaml

```
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: my-ingress
spec:
  rules:
    - host: example.com
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: api-service
                port:
                  number: 80
```

*But there's more.*

As part of the installation process, Kong's controller registers Custom Resource Definitions (CRDs).

One of these custom extensions is related to Kong's plugins.

If you wish to limit the requests to your Ingress by IP address, you can create a definition for the limit with:

limit-by-ip.yaml

```
apiVersion: configuration.konghq.com/v1
kind: KongPlugin
metadata:
  name: rl-by-ip
config:
  hour: 100
  limit_by: ip
  second: 10
plugin: rate-limiting
```

And you can reference the limit with an annotation in your ingress with:

ingress.yaml

```
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: my-ingress
  annotations:
    plugins.konghq.com: rl-by-ip
spec:
  rules:
    - host: example.com
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: api-service
                port:
                  number: 80
```

You can [explore the Custom Resource Definitions (CRDs) for Kong](https://github.com/Kong/kubernetes-ingress-controller/blob/master/docs/custom-resources.md) on the official documentation.

*But Kong isn't the only choice.*

## Ambassador, the modern API gateway

[Ambassador is another Kubernetes Ingress](https://www.getambassador.io/) built on top of Envoy that offers a robust API Gateway.

The Ambassador Ingress is a modern take on Kubernetes Ingress controllers, which offers robust protocol support as well as rate-limiting, an authentication API and observability integrations.

The main difference between Ambassador and Kong is that Ambassador is built for Kubernetes and integrates nicely with it.

> Kong was open-sourced in 2015 when the Kubernetes ingress controllers weren't so advanced.

Even if Ambassador is designed with Kubernetes in mind, it doesn't leverage the familiar Kubernetes Ingress.

Instead, services are exposed to the outside world using annotations:

service.yaml

```
apiVersion: v1
kind: Service
metadata:
  labels:
    service: api-service
  name: api-service
  annotations:
    getambassador.io/config: |
      ---
      apiVersion: ambassador/v0
      kind: Mapping
      name: example_mapping
      prefix: /
      service: example.com:80
      host_rewrite: example.com
spec:
  type: LoadBalancer
  ports:
    - port: 80
      targetPort: 80
  selector:
    service: api-backend
```

The novel approach is convenient because, in a single place, you can define all the routing for your Deployments and Pods.

**However, having YAML as free text within an annotation could lead to errors and confusion.**

It's hard to get the formatting right in standard YAML, let alone as a string inside more YAML.

If you wish to apply rate-limiting to your API, this is what it looks like in Ambassador.

You have a RateLimiting object that defines the requirements:

rate-limit.yaml

```
apiVersion: getambassador.io/v1beta1
kind: RateLimit
metadata:
 name: basic-rate-limit
spec:
 domain: ambassador
 limits:
  - pattern: [{x_limited_user: "false"}, {generic_key: "qotm"}]
    rate: 5
    unit: minute
  - pattern: [{x_limited_user: "true"}, {generic_key: "qotm"}]
    rate: 5
    unit: minute
```

You can reference the rate limit in your Service with:

service.yaml

```
apiVersion: v1
kind: Service
metadata:
  name: api-service
  annotations:
    getambassador.io/config: |
      ---
      apiVersion: ambassador/v1
      kind: RateLimitService
      name: basic-rate-limit
      service: "api-service:5000"
spec:
  type: ClusterIP
  selector:
    app: api-service
  ports:
    - port: 5000
      targetPort: http-api
```

Ambassador has an excellent tutorial about rate limiting, so if you are interested in using that feature, you can head over to [Ambassador's official documentation](https://www.getambassador.io/user-guide/rate-limiting-tutorial/).

You can extend Ambassador with [custom filters for routing](https://www.getambassador.io/docs/guides/filter-dev-guide), but it doesn't offer a vibrant plugin ecosystem as Kong.

## Gloo things together

Ambassador is not the only Envoy-powered ingress which can be used as API Gateway.

[Gloo is a Kubernetes Ingress](https://gloo.solo.io/) that is also an API gateway. It is capable of providing rate limiting, circuit breaking, retries, caching, external authentication and authorisation, transformation, service-mesh integration and security.

**The selling point for Gloo is that it is capable of auto-discovering API endpoints for your application and automatically understands arguments and parameters.**

It might be hard to believe (and sometimes their documentation doesn't help either), so here's an example.

Imagine you have a REST API for an address book.

The app exposes the following endpoints:

- `GET /users/{id}`, get the profile for a user
- `GET /users`, get all users
- `POST /users/find`, find a particular user

If your API is developed using standard tools such as the OpenAPI, then Gloo automatically uses the OpenAPI definition to introspect your API and store the three endpoints.

If you list all the endpoint served by Gloo after the discovery phase, this is what you see:

gloo

```
upstreamSpec:
  kube:
    selector:
      app: addressbook
    serviceName: addressbook
    serviceNamespace: default
    servicePort: 8080
    serviceSpec:
      rest:
        swaggerInfo:
          url: http://addressbook.default.svc.cluster.local:8080/swagger.json
        transformations:
          findUserById:
            body:
              text: '{"id": {{ default(id, "") }}}'
            headers:
              :method:
                text: POST
              :path:
                text: /users/find
              content-type:
                text: application/json
          getUser:
            body: {}
            headers:
              :method:
                text: GET
              :path:
                text: /user/{{ default(id, "") }}
              content-length:
                text: '0'
              content-type: {}
              transfer-encoding: {}
          getUsers:
            body: {}
            headers:
              :method:
                text: GET
              :path:
                text: /users
              content-length:
                text: '0'
              content-type: {}
              transfer-encoding: {}
```

Once Gloo has a list of endpoints, you can use that list to apply transformations to the incoming requests before they reach the backend.

As an example, you may want to collect all the headers from the incoming requests and add them to the JSON payload before the request reaches the app.

Or you could expose a JSON API and let Gloo apply a transformation to render the message as SOAP before it reaches a legacy component.

Being able to discover APIs and apply transformations makes Gloo particularly suitable for an environment with diverse technologies — or when you're in the middle of a migration from an old legacy system to a newer stack.

**Gloo can discover other kinds of endpoints such as AWS Lambdas.**

Which makes it the perfect companion when you wish to mix and match Kubernetes and serverless.

## I've heard I could use Istio as an API gateway

*What's the difference between an API gateway and a service mesh?*

*Aren't both doing the same thing?*

Both offer:

- traffic routing
- authentication such as OAuth, JWT, etc.
- rate-limiting
- circuit breakers
- retries
- etc.

However, there's a distinction.

**API gateways such as Kong and Ambassador are mostly focussed on handling external traffic and routing it inside the cluster.**

External traffic is quite a broad label that includes things such as:

- slow and fast clients and
- well behaved and malicious users

In other words, API gateways are designed to protect your apps from the outside world.

![API gateways focus on handling external traffic](https://learnk8s.io/a/2ed8fd694bfdfd979cff4be0d9ca77d3.svg)

**Service meshes, instead, are mostly used to observe and secure applications within your infrastructure.**

Typical uses of service meshes include:

- monitoring and observing requests between apps
- securing the connection between services using encryption (mutual TLS)
- improving resiliency with circuit breakers, retries, etc.

Since service meshes are deployed alongside your apps, they benefit from:

- low latency and high bandwidth
- unlikely to be targeted for misuse by bad actors

In other words, **a service mesh's primary purpose is to manage internal service-to-service communication**, while **an API Gateway is primarily meant for external client-to-service communication.**

![Service meshes focus on internal service-to-service communitcation](https://learnk8s.io/a/b5e622d396d8e23f590851513926d7b8.svg)

| API gateway                                   | Service mesh                                        |
| --------------------------------------------- | --------------------------------------------------- |
| Exposes internal services to external clients | Manages and controls the traffic inside the network |
| Maps external traffic to internal resources   | Focuses on brokering internal resources             |

*But that doesn't mean that you can't use [Istio](https://istio.io/) as an API gateway.*

What might stop you, though, is the fact that Istio's priority isn't to handle external traffic.

Let's have a look at an example.

It's common practice to secure your API calls behind an API gateway with JWT or OAuth authentication.

Istio offers JWT, but you have to [inject custom code in Lua to make it work with OAuth](https://gist.github.com/oahayder/1d8fc8b19660fac1aebce59ea6d171ad#file-envoyfilter-yaml).

On the other hand, [Kong offers a plugin for that](https://docs.konghq.com/hub/kong-inc/oauth2/) as this is a common request.

Enterprise API gateways such as [Google Apigee include billing capabilities](https://docs.apigee.com/api-platform/monetization/basics-monetization).

It's unlikely that those features will be replicated in a service mesh because the focus isn't on managing APIs.

*What if you don't care about billing, can you still use a service mesh as an API gateway?*

Yes, you can, and there's something else that you should know.

## A general note on API gateways and service meshes

Depending on what you are trying to achieve, service meshes and API gateways could overlap significantly in functionality.

They might overlap even more in the future since every major API gateway vendor is expanding into service meshes.

- Kong announced [Kuma](https://kuma.io/) a service mesh that can integrate with [Kong](https://konghq.com/blog/kong-kubernetes-ingress-controller/) or [Istio](https://istio.io/)
- Solo.io announced a service mesh that integrates with [Gloo](https://github.com/solo-io/gloo) called [SuperGloo](https://github.com/solo-io/supergloo)
- Containous announced [Maesh a service mesh](https://containo.us/blog/announcing-maesh-a-lightweight-and-simpler-service-mesh-made-by-the-traefik-team-cb866edc6f29/) that integrates with [Traefik](https://containo.us/traefik/)

And it would not be surprising to see more service meshes deciding to launch an API gateway as Istio did.

## Recap

*If you had to pick an API gateway for Kubernetes, which one should you use?*

- **If you want a battle-tested API gateway, Kong is still your best option.** It might not be shiniest but the documentation is excellent with plenty of resources online. It also has the most production mileage than any other gateway.
- **If you need a flexible API gateway** that can play nicely with new and old infrastructure, you should have a look at **Gloo**. The ability to auto-discover APIs and transform requests is compelling.
- **If you want the simplicity of setting all the networking in your Services, you should consider Ambassador**. It has excellent tutorials and documentation to get started. Be aware of the YAML indentation as a free string.

*If you had to pick an API gateway or a service mesh, which one should you use?*

**Starting with an API gateway is still the best choice** to secure your internal apps from external clients.

As the number of apps grow in size, you could explore how to leverage a service mesh to observe, monitor and secure the traffic between them.

## More options

If neither Ambassador, Kong or Gloo is suitable for the API gateway that you had in mind, you should check out the following alternatives:

- [Tyk](https://tyk.io/) is an open-source API gateway which can be deployed as an Ingress.
- You could [build your API gateway Ingress using Ballerina](https://ballerina.io/learn/by-guide/api-gateway/) — a Cloud-Native programming language

## That's all folks

*Do you have any recommendation when it comes to API Gateways on Kubernetes?*

[Let us know in an email](mailto:hello@learnk8s.io) or [tweet us @learnk8s](https://twitter.com/learnk8s).

A special thank you goes to [Irakli Natsvlishvili](https://www.linkedin.com/in/irakli/) who offered some invaluable feedback and helped me put together the above table. Also, thanks to:

- Idit Levine and Scott Weiss from [the Solo.io team](https://www.solo.io/) for answering my questions about the Gloo Ingress controller
- [Daniel Bryant](https://twitter.com/danielbryantuk) from Datawire who kindly helped me understand Ambassador better
- [Marco Palladino](https://www.linkedin.com/in/marcopalladino) from Kong Inc. for offering some detailed feedback about the article

If you enjoyed this article, you might find the following articles interesting:

- [Scaling Microservices with Message Queues, Spring Boot and Kubernetes.](https://learnk8s.io/blog/scaling-spring-boot-microservices) You should design your service so that even if it is subject to intermittent heavy loads, it continues to operate reliably. But how do you build such applications? And how do you deploy an application that scales dynamically?
- [Boosting your kubectl productivity.](https://learnk8s.io/blog/kubectl-productivity) If you work with Kubernetes, then kubectl is probably one of your most-used tools. Whenever you spend a lot of time working with a specific tool, it is worth to get to know it very well and learn how to use it efficiently.