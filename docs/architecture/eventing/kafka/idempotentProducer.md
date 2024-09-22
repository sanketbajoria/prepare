Introduction
------------

When an application publishes events to a Kafka topic there is a risk that duplicate events can be written in failure scenarios, and consequently message ordering can be lost. This can be avoided by configuring the Kafka Producer to be idempotent. This article describes how duplicate events can be published and how to make the Producer idempotent.

Duplicate Messages
------------------

Duplicate messages can occur in the scenario where:

-   A Producer attempts to write a message to a topic partition.
-   The broker does not acknowledge the write due to some transient failure scenario.
-   The Producer should retry as it does not know whether the write succeeded or not.
-   If the Producer is not idempotent and the original write did succeed then the message would be duplicated.

This is illustrated in the following diagram:

![No alt text provided for this image](https://media.licdn.com/dms/image/v2/C4D12AQFEASau7zjcdQ/article-inline_image-shrink_1500_2232/article-inline_image-shrink_1500_2232/0/1637697821287?e=1732752000&v=beta&t=wBrU8ZUisy7J5XZyiwWnIpGV4wKxRYHshP62r1ykKrk)

By configuring the Producer to be idempotent, each Producer is assigned a unique Id (PID) and each message is given a monotonically increasing sequence number. The broker tracks the PID + sequence number combination for each partition, rejecting any duplicate write requests it receives.

![No alt text provided for this image](https://media.licdn.com/dms/image/v2/C4D12AQFIKu6qYgaPqg/article-inline_image-shrink_1500_2232/article-inline_image-shrink_1500_2232/0/1637697842341?e=1732752000&v=beta&t=PwmliN-roz11xSZws68nkx1fDWWEA3ZHJe7nNcBBrFw)

Idempotent Producer Configuration
---------------------------------

The Kafka Producer configuration  enable.idempotence  determines whether the producer may write duplicates of a retried message to the topic partition when a retryable error is thrown. Examples of such transient errors include leader not available and not enough replicas exceptions. It only applies if the  retries  configuration is greater than 0 (which it is by default).

To ensure the idempotent behaviour then the Producer configuration  acks  must also be set to  all. The leader will wait until at least the minimum required number of in-sync replica partitions have acknowledged receipt of the message before itself acknowledging the message. The minimum number is based on the configuration parameter  min.insync.replicas.

By configuring  acks  equal to  all  it favours durability and deduplicating messages over performance. The performance hit is usually considered insignificant.

If  retries  is set to zero then the Producer will not re-attempt to send the message and will instead dead-letter the message (depending on the application error handling logic). This is not recommended, as problems that are otherwise recoverable are not recovered, and the dead lettered messages instead need resolving. Meanwhile the write to the topic partition may in fact have succeeded, just not having been acknowledged by the Broker.

Unlike other concerns such as implementing an Idempotent Consumer, there is no code change required to enable the Idempotent Producer. It is just a case of providing the necessary configuration.

Producer & Consumer Timeouts
----------------------------

The recommendation is to leave the  retries  as the default (the maximum integer value) and limit retries by time, using the Producer configuration  delivery.timeout.ms  (defaulted to 2 minutes). If the message publish is being triggered by the consumption of a message, take care to ensure that this timeout does not contribute to the poll timeout being exceeded. If it does exceed the poll timeout then the Broker will remove the consumer from the consumer group as it believes it may have died, the consumer group will rebalance, and the message re-polled by the new consumer instance assigned to the partition. Meanwhile the first consumer instance will continue to try producing the event which may or may not succeed. In this situation downstream services will now be consuming two resulting events, themselves each unique, which would have to be mitigated for.

Guaranteed Message Ordering
---------------------------

The  max.in.flight.requests.per.connection  setting can be used to increase throughput by allowing the client to send multiple unacknowledged requests before blocking. However if the Producer is not Idempotent, max inflight requests is greater than 1, there is the risk of message re-ordering occurring when retrying due to transient errors. With the Idempotent Producer then up to 5 in-flight requests can be configured with message ordering guaranteed by Kafka.

For an Idempotent Producer, message ordering is guaranteed during retries by Kafka so long as the  max.in.flight.requests.per.connection  is not configured to be greater than 5. This configuration setting can be used to increase throughput by allowing the client to send multiple unacknowledged requests before blocking.

If this setting is configured to more than 5 for an Idempotent Producer, or the Producer is not Idempotent and it is configured to greater than 1, then there is the risk of message re-ordering occurring when retrying due to transient errors. This is because a later event could be written to the log before an earlier event if that earlier event is retrying, effectively switching their ordering.

![No alt text provided for this image](https://media.licdn.com/dms/image/v2/C4D12AQEXePij5BZxjg/article-inline_image-shrink_1500_2232/article-inline_image-shrink_1500_2232/0/1637697872683?e=1732752000&v=beta&t=yMbnyRcvj-addE3QLdlFsHpiQMnlm7ZmRChQ0SUuwmA)

Recommended Configuration
-------------------------

Recommended configuration for the Java Apache Kafka client library:

![No alt text provided for this image](https://media.licdn.com/dms/image/v2/C4D12AQGw0RIaghNN5A/article-inline_image-shrink_1500_2232/article-inline_image-shrink_1500_2232/0/1637697739516?e=1732752000&v=beta&t=YZEsHQIx0jTduju2f4yHdUVA9OmG4uW8mqHoxDqsnr8)

Client Library Support
----------------------

In the Java Apache client library the  enable.idempotence  configuration has been defaulted to false, with  acks  defaulting to  1, up until the most recent release of 3.0.0 (released in September 2021). In version 3.0.0 these defaults were changed to  true  and  all  respectively, favouring durability over availability. If using a pre-3.0.0 version the recommendation in the majority of cases would be to override the defaults to enable idempotency and set  acks  equal to  all  (i.e. in line with 3.0.0).

In KafkaJS (version 1.1.50 is the most recent at the time of writing) the flag to enable an idempotent Producer is marked as 'Experimental'. It is recommended to not rely on an experimental flag to give the behaviour required in Production as there is no guarantee as to its correctness or possibility of unexpected side-effects. If using KafkaJS then the design and implementation must cater for the Producer being non-idempotent.

In the librdkafka library full support for exactly-once-semantics, for which the idempotent producer is a key element, was announced as being added in April 2020 (v1.4.0). If using a binding library wrapping librdkafka then analysis would be required to determine if this feature is now supported in that library.
