In the Java Consumer API for Kafka, there's an often-overlooked feature concerning consumer offsets. Regular polling in this API leads to the corresponding commitment of offsets. This process primarily facilitates 'at least once' reading patterns under specific conditions.

The key question is: when are these offsets committed? They're committed whenever a poll is called, provided that a set period, defined by the `auto.commit.interval.ms` setting, has passed. For instance, with default settings of `auto.commit.interval.ms=5000` and `enable.auto.commit=true` , offsets commit every five seconds.

To maintain an 'at least once' setting, it's crucial to process all messages from Kafka before polling again. Failing to do so means you might commit offsets before processing messages, which deviates from the 'at least once' scenario.

In cases where `enable.auto.commit `is turned off, manual offset commitment is required. This can be done asynchronously or synchronously.

![](https://miro.medium.com/v2/resize:fit:1400/1*K6tUgNNiVjBGvNkxGmRKCw.png)

Behind the scenes, offsets are continuously committed. Here's a quick rundown of the process: With `enable.auto.commit=true `and` auto.commit.interval.ms=5000`, the consumer calls `.poll()`, starting a timer. The Kafka broker returns messages, and subsequent polls fetch more messages. After about six seconds, the system processes data and commits offsets asynchronously since more than five seconds have elapsed since the last poll. This cycle of polling, processing, and committing repeats.




Auto Offset Commit
------------------

Kafka clients can be configured to automatically commit offsets at regular intervals using the `enable.auto.commit` configuration. The interval is defined by `auto.commit.interval.ms`. This commit process done periodically by a background thread at an interval specified by the config property. An offset becomes eligible to be committed immediately prior to being delivered to the application via the `Consume` method.

```
var config = new ConsumerConfig\
{\
    ...\
    // Enable auto-committing of offsets.\
    EnableAutoCommit = true\
}

...

while (!cancelled)\
{\
    var consumeResult = consumer.Consume(cancellationToken);

    // process message here. Messages will be committed automatically. If processed async, then, in next poll, autocommit may trigger, which will result in at most processing.
    ...\
    Console.WriteLine("Message Processed!")

}
```

This strategy introduces the potential message loss in the case of application failure, because the application may terminate before it finishes processing a particular message, but auto commit may have been made. In this case committed offsets will never be consumed again. Sometimes auto commit could also lead to duplicate processing of messages in case consumer crashes before the next auto commit interval.

Manuel Offset Commit
--------------------

Consumers can also commit offsets manually using APIs like `commitSync()` or `commitAsync()`. This provides more control and allows offsets to be committed after certain application-defined events, such as after processing a batch of records. For committing offsets manually, we have to disable auto offset commit.

```
var config = new ConsumerConfig\
{\
    ...\
    // Disable auto-committing of offsets.\
    EnableAutoCommit = false\
}

...

while (!cancelled)\
{\
    var consumeResult = consumer.Consume(cancellationToken);

    // process message here.\
    ...

    //committing all the offsets we consumed\
    consumer.Commit();

    //or we can commit only offset of the processed message\
    consumer.Commit(consumeResult);

```

One downside of this synchronous commit is that it may have an impact on the application throughput as the application gets blocked until the broker responds to the commit request. Because of that we should generally avoid blocking network calls (including synchronous use of `Commit`).

Storing Offset
==============

Storing an offset refers to the act of keeping the current offset in a local variable or in-memory data structure within the consumer application during processing. You can store the processed offsets in local, and then commit them in bulk. Offset committing and storing offset are not alternatives but complementary to each other.

For same programming languages, there is no storing offset mechanism, so you have to store offsets yourself, then commit in bulk. But for some languages, there are mechanisms that enable this behavior.

For dotnet, we can set EnableAutoOffsetStore config for enable/disable auto storing offset, and we have StoreOffset method to store offset manually in [confluent-kafka-dotnet](https://github.com/confluentinc/confluent-kafka-dotnet) library.

This is the sample code that storing offsets and committing in bulk manually;

```
var config = new ConsumerConfig\
{\
    EnableAutoCommit = false\
    EnableAutoOffsetStore = false\
}

var offsetCount = 0;\
...

while (!cancelled)\
{\
    var consumeResult = consumer.Consume(cancellationToken);

    // process message here.\
    ...

    //Store processed offset\
    consumer.StoreOffset(consumeResult);\
    offsetCount++;

    if(offsetCount == 5)\
    {\
      //commit offsets manually\
      consumer.Commit();\
      offsetCount = 0;\
    }\
}

```

In the code you can see above, we are committing offsets manually periodically in every 5 message. In this scenario, it is possible that we may experience a performance problem due to the blocking network call `consumer.Commit();`

Combining Offset Commit / Store Offset
--------------------------------------

As we said above, these 2 method are not alternatives, but complementary to each other. So we can use them together to create a more effective structure.

We can set auto commit as enabled, so we won't need to commit offsets manually. We will prevent blocking network calls. Also we can set EnableAutoOffsetStore as disabled, because we want to be in full control of what offsets will be committed.

```
var config = new ConsumerConfig\
{\
    EnableAutoCommit = true\
    EnableAutoOffsetStore = false\
}

...

while (!cancelled)\
{\
    var consumeResult = consumer.Consume(cancellationToken);

    // process message here.\
    ...

    //Only store processed offsets. Offset commiting will be done automatically\
    consumer.StoreOffset(consumeResult);

}

```

This approach is effective for many scenarios. Confluent also recommends using this approach instead of manual offset commits. But in today's world where we develop complex applications, this approach may not be sufficient or effective.

Now we have important information about consumers and offset management, we can talk about the frequently talked about message delivery strategies for message brokers and how we can write Kafka consumers that implement these strategies.

At Most One Message Delivery
----------------------------

This message delivery strategy ensures that, message will be published to the consumer at most once. Message might be lost but not redelivered. We can implement this behaviour by following steps:

-   Set kafka producer acknowledgement config as none. (acks = 0). By this configuration, producer will publish message and won't wait for acknowledgement from kafka broker. This means even in case of message delivery failure, producer assumes message has been successfully delivered, and won't retry.
-   In the consumer, fetch message from topic, and commit the offset before processing the message. If the consumer crashes after committed the offset, message won't be re-consume.

```
var config = new ConsumerConfig\
{\
    EnableAutoCommit = false\
}

...

while (!cancelled)\
{\
    var consumeResult = consumer.Consume(cancellationToken);\
    consumer.Commit(consumeResult);

    // process message after committed the offset\
    ...

}

```

At Least One Message Delivery
-----------------------------

This message delivery strategy ensures that, the message will be published to the consumer at least once, with a guarantee that no message should be lost. In the event of a failure or error during message delivery, the message will be redelivered. This strategy comes with a possibility of duplicate message processing. We can implement this behaviour by following steps:

-   Set kafka producer acknowledgement config as leader or all. (acks=1 or acks=all). By this configuration, producer will publish message and will wait for acknowledgement from kafka. Getting acknowledgement means ensure that messages are published successfully to the topic. If message publishing fails, producer will retry the operation.
-   In the consumer, fetch message from topic, process the message, then commit the offset. If the consumer crashes before committed the offset, message will be re-consume. As we said this strategy comes with a possibility of duplicate message, we can use auto offset commit and manuel storing offset mechanisms for max performance.

```
var config = new ConsumerConfig\
{\
    EnableAutoCommit = true\
    EnableAutoOffsetStore = false\
}

...

while (!cancelled)\
{\
    var consumeResult = consumer.Consume(cancellationToken);

    // either process message synchronously or 
    // process message async manner and commit storeOffset\
    ...

    //Store processed offsets. Offset commiting will be done automatically\
    consumer.StoreOffset(consumeResult);

}
```

Exactly Once Message Delivery
-----------------------------

This message delivery strategy ensures that, the message will be delivered to the consumer exactly once, with a guarantee that no message should be lost or reprocessed. For providing this strategy, consumers should be idempotent.

Consumer idempotency can be provided in many different ways, using a locking mechanism, using inbox pattern or writing consumer logics as run idempotent are some popular methods. We can implement this behaviour by following steps:

-   Set kafka producer acknowledgement config as leader or all. (acks=1 or acks=all). By this configuration, producer will publish message and will wait for acknowledgement from kafka. Getting acknowledgement means ensure that messages are published successfully to the broker. If message publishing fails, producer will retry the operation.
-   In the consumer, fetch message from kafka, and check any lock exist for fetched event. process the message if lock not exist, create lock and then commit the offset. With locking check, we won't process a message twice.

```
var config = new ConsumerConfig\
{\
    EnableAutoCommit = true\
    EnableAutoOffsetStore = false\
}

...

while (!cancelled)\
{\
    var consumeResult = consumer.Consume(cancellationToken);\
    var message = JsonSerializer.Deserialize<ComplexType>(consumeResult.message);

    //Check is lock exist with a unique id in message\
    if(_lockManager.LockExist(message.uniqueId) is false)\
    {\
        // process message here.\
        ...

        // add lock after processed the message\
        _lockManager.AcquireLock(message.uniqueId);\
    }

    //Store processed offsets. Offset commiting will be done automatically\
    consumer.StoreOffset(consumeResult);

}
```

In the consumer example above, there will be error cases such as getting error when creating a lock after processing the message. This cases need to be considered and handled. Writing idempotent consumers, using inbox pattern or other idempotency strategies is also an option for this strategy.
