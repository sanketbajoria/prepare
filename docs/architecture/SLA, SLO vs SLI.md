Below is a concise and hopefully memorable framework for understanding SLI, SLO and SLA. These three concepts have a relationship that is hierarchical in nature. You can think of it as a pyramid.

![](https://miro.medium.com/v2/resize:fit:1400/1*4spwNeRCegHLXE3YrkX4Gg.png)

Note this article will explain these concepts in terms of a web/HTTP based micro services. The examples and metrics can differ greatly for other types of applications. For example an AI system or a storage service would focus on different metrics than the examples below.

Service Level Indicators (SLI)
==============================

This answers the question, what are we going to measure? To summarize it in one word, metrics.

Here are some common examples of metrics for HTTP based microservices

-   Response time *(the amount of time it takes between sending a request and getting a response)*
-   Throughput *(max number of requests the system needs to handle)*
-   Error rate *(ration of failed requests to successful requests)*

Service Level Objective (SLO)
=============================

This answers the question, what values of SLIs matter? To summarize it in one phrase, SLI + thresholds.

Below are some common SLO metrics.

![](https://miro.medium.com/v2/resize:fit:1400/1*au0HZRRDVhUlxPx7CnG1Lw.png)

Note availability assumes a definition of what being down means. For example having an error rate ≥ 10% could mean the service is down. Also for those not familiar with percentiles see [this post](https://www.dynatrace.com/news/blog/why-averages-suck-and-percentiles-are-great/).

Service Level Agreement (SLA)
=============================

This answers the question, what happens if we don't stay within the thresholds of the SLOs? In other words what happens if we don't live up to the bar set by our SLOs? To summarize it in one phrase SLO + consequences.

It is worth mentioning that many software teams that have internal stakeholders don't have formal SLAs. These are usually between a company and its customers. For example an SLA for [Google compute](https://cloud.google.com/compute/sla) mentions that customers are entitled to financial compensation *(in terms of compute credits)* if Google doesn't meet the SLA agreement.
