Kafka Topics
============

Kafka topics represent specific data streams within a Kafka cluster. A Kafka cluster can contain multiple topics, which can be named anything, like logs, purchases, twitter_tweets, cars_gps, etc. Essentially, a Kafka topic is a data stream. If you compare it to databases, a Kafka topic is somewhat like a database table but without the usual constraints. You can send any data to a Kafka topic without data verification. This concept will be elaborated on later. Kafka topics can handle various message formats, including JSON, Avro, text files, binary, and more. The order of messages in a topic forms a data stream, which is why Kafka is known as a data streaming platform. Topics are not queryable like database tables; instead, data is added to a Kafka topic using Kafka Producers, and to read data from a topic, Kafka Consumers are used. Kafka does not have querying capabilities.

![](https://miro.medium.com/v2/resize:fit:642/1*-ebhkopNwP4-82dnZ2qRLg.png)

Topics: stream of data
----------------------

-   Like a table in a DB (without constraints)
-   No limit of amount of topics
-   A topic identifier `name`
-   Any messages format
-   The sequence of messages is called a `data stream`
-   You can't execute a query to the topic, instead, use Producers to send data and Consumers to read the data

Partitions and offset
=====================

Topics in Kafka are broad categories that can be split into smaller sections called partitions. For instance, a single topic might contain 100 partitions. In this example, we're focusing on a Kafka topic that has three partitions: partitions zero, one, and two.

Messages sent to a Kafka topic are distributed across these partitions. Each message in a partition receives a unique identifier, called ID, which starts at 0 and increments with each new message. So, in partition zero, the first few messages might have IDs like 1, 2, 3, and so on. As more messages are added, this ID continues to increase.

This incrementing ID is known as the `Kafka partition offset.`Throughout this guide, you'll often hear me mention 'offsets.' Each partition maintains its own set of offsets.

![](https://miro.medium.com/v2/resize:fit:1400/1*6dBJSNNT92K2XizTK4G9fw.png)

It's important to note that Kafka topics are immutable. This means that once data is written to a partition, it cannot be altered. You can't delete or update data in Kafka; instead, you continuously add to the partitions.

Example
-------

Imagine you manage a group of cars, each equipped with a GPS. This GPS regularly updates its location to Kafka. Every car sends its position to Kafka approximately every 20 seconds. Each update includes details like the car's ID and its exact location, given as latitude and longitude.

So, we have several cars acting as data sources. They feed information into a Kafka 'topic' (a kind of data channel) named 'cars_gps', which stores all the cars' locations.

![](https://miro.medium.com/v2/resize:fit:1400/1*jfDq_AMrGgIS-Yg6xLytVw.png)

We've set up this 'cars_gps' topic to have multiple sections, known as partitions --- in this case, 10 of them. The number of partitions is chosen based on specific needs, which I'll explain later in the guide.

Once Kafka has this topic ready, we can start using the data. For instance, we might have a dashboard that shows where each car is in real time. Or, we might use the same data for a notification system. This system could alert customers when their delivery is almost there.

The great thing about Kafka is that it lets different services use the same data stream simultaneously.

Conclusion
==========

Okay, so let's summarize some key points about topics, partitions, and offsets in Kafka.

1.  Firstly, once data is written to a partition, it cannot be changed. This principle is known as immutability and is crucial to understand. Kafka stores data for a limited period, typically a week, but this duration is adjustable. After this period, the data disappears.
2.  Each partition's offsets are unique. For instance, offset three in partition zero and offset three in partition one refer to different messages. These offsets continue to increase and aren't recycled, even if previous messages are deleted.
3.  It's essential to note that message order is maintained only within a partition, not across multiple partitions. For ordered messages, we'll explore strategies to achieve this.
4.  When sending data to a Kafka topic, it's assigned to a random partition, like zero, one, or two, unless a key is specified. Topics in Kafka can have numerous partitions, varying from a few to hundreds, and we'll discuss how to choose the right number for our topic.


Producers
=========

So, we've explored the overall topics and data, but we need to create a Kafka producer for writing data on these topics. Producers write to topic partitions, like partition 0 for topic A, followed by partitions 1 and 2. Data is written sequentially, marked by Offsets. Your producer sends data to Kafka topic partitions, knowing in advance the specific partition and Kafka broker (server) to use. We'll soon delve into Kafka brokers.

![](https://miro.medium.com/v2/resize:fit:1400/1*rykBD6l3w8esWi1HRRX17w.png)

It's a misconception that Kafka servers decide which partition receives the data; it's predetermined by the producer, which we'll explore further. If a Kafka server with a specific partition fails, producers can automatically recover. There are a lot of intricate workings in Kafka we'll gradually uncover.

Kafka achieves load balancing as producers distribute data across all partitions using certain mechanisms. This scalability is due to multiple partitions within a topic, each receiving messages from one or more producers.

Producers: Message Keys
=======================

In this explanation, producers have keys in their messages. The message contains data, and you can add an optional key, which can be any type, like a string, number, or binary. There are two scenarios here.

In this example, a producer sends data to a topic with two partitions. If the key is null, data is sent in a round-robin fashion to partitions, ensuring load balancing. A null key indicates no key in the producer's message. But if the key exists, it holds some value, which again could be of various types.

Kafka producers have a crucial feature: messages with the same key always go to the same partition due to a hashing strategy. This is essential in Apache Kafka for maintaining order in messages related to a specific field.

![](https://miro.medium.com/v2/resize:fit:1400/1*2x_5o4Mns5bZtsup3cmTbg.png)

If tracking each car's position in the sequence is important, use the car ID as the message key. For instance, car ID 123 would always go to partition 0, allowing you to track that car's data in order. Similarly, car ID 234 goes to partition 0. Which key goes to which partition is determined by a hashing technique, which will be explained later. Other car IDs, like 345 or 456, would consistently end up in partition 1 of your topic A.

-   The manufacturer has the option to include a key with the message (such as a string, number, or binary).
-   If the key is null, data is distributed evenly.
-   If the key is not null, then messages with that key always go to the same partition due to hashing.
-   A key is usually included if message sequencing is required for a certain field, like car_id.

Messages anatomy
----------------

This is what a Kafka message looks like when created by the producer.

![](https://miro.medium.com/v2/resize:fit:1342/1*CTcWpEFdVP18zv8d1xjp0w.png)

It has a key, which might be null, and is in binary format. The message's value, or content, can also be null but usually isn't. It holds your message's information. You can compress your messages to make them smaller using methods like gzip, snappy, lz4, or zstd. Messages can also include optional headers and a list of key-value pairs, and a timestamp, set by either the system or the user, is added. This forms a Kafka message, which is then stored in Apache Kafka.

Kafka Message Serializer
========================

Kafka accepts only byte sequences from producers and sends byte sequences to consumers.

However, our messages aren't initially in bytes. So, we perform message serialization, converting your data or objects into bytes. It's a straightforward process, and I'll demonstrate it now.

Serializers are used for both the message's key and value. For instance, consider a key object, like a car ID --- let's say 123. The value might simply be a text like "Hello world". These aren't bytes yet but objects in our programming language. We'll designate an integer Serializer for the key. The Kafka producer is then able to convert this key object, 123, into a byte sequence, creating a binary representation of the key.

For the value, we'll specify a string Serializer. The Serializers for the key and value differ, meaning it can smartly convert the text "Hello world" into a byte sequence for the value.

![](https://miro.medium.com/v2/resize:fit:1162/1*PqTSMuP9UpTu5u0-g0Wxag.png)

With both key and value in binary form, the message is ready to be sent to Apache Kafka. Kafka producers include common Serializers like string (including JSON), integer, float, Avro, Protobuf, and more, aiding in this data transformation. There are many message Serializers available.

Key Hashing
===========

In Kafka, there's a system called a partitioner. It's like a set of rules that decides where a message is. When we send a message, this partitioner looks at it and chooses a parking space, says "space one", and then the message is sent there in Apache Kafka.

The way a message key is matched to a parking space involves key hashing. In Kafka's default system, they use a method called the murmur2 algorithm:

targetPartition = Math.abs(Utils.murmur2(keyBytes)) % (numPatririons - 1)

Imagine this algorithm as a formula that looks at the key processes it, and then decides which parking space it should go to.

The important thing to understand is that the producers, or the ones sending the messages, use the key to decide where the message will end up. They do this by hashing the key. That's the main idea.

This explanation is for those interested in more advanced details. The main thing to remember is how messages are directed to their places in Kafka.


We've learned how to send data to a topic. Now, let's focus on retrieving data from it using consumers. Consumers follow a pull model, meaning they request data from Kafka brokers and receive a response. It's not about Kafka brokers pushing data to consumers; they pull the data themselves.

Imagine we have a topic with three partitions full of data. One consumer might read from Topic A's first partition, accessing the data sequentially. Another consumer might opt to read from multiple partitions, like the first and second ones.

Consumers know which Kafka server to contact for data from a specific partition. If a broker fails, consumers are equipped to handle this situation.

![](https://miro.medium.com/v2/resize:fit:1400/1*A2bbZGo-4cUNjuHorQV0WA.png)

The data read from these partitions follows a sequential order, from the lowest to the highest offset within each partition. So, the first consumer will read data in sequence from Topic A's first partition, starting from offset 0 up to offset 6. Similarly, the second consumer will read data in order from the first and second partitions. However, there's no guarantee of sequence between different partitions. Each partition maintains its order.

![](https://miro.medium.com/v2/resize:fit:1400/1*N8Egm5CYcZlhWFW2DlGMcA.png)

1.  Kafka Consumers work by Pull Model
2.  Ordering is supported only inside each partition.
3.  Customers read information from a specific topic (identified by its name).
4.  Customers instinctively understand which broker to access for information.
5.  In situations where a broker malfunctions, customers are aware of the recovery process.
6.  Information is accessed sequentially, from the lowest to the highest offset.

Consumer Deserializer
=====================

Within each partition, there's a specific order. As consumers read messages, they must convert the bytes received from Kafka into usable data or objects. The message in Kafka has a key and a value, both in binary format. To use these in our programming language, they need to be converted into objects. The consumer must know the message format in advance. For instance, if the key is an integer, the consumer uses an integer Deserializer to change the key from bytes to an integer. The key then becomes an integer like 123. Similarly, if the value is expected to be a string, a string Deserializer converts bytes into a string, retrieving the original message like "Hello world." Apache Kafka includes Deserializers for various data types, such as strings (including JSON), integers, floats, Avro, Protobuf, and others, which consumers can use.

![](https://miro.medium.com/v2/resize:fit:1156/1*A8ElEsQ2ohSWpoCJYS55Dg.png)

Once a topic is created, you shouldn't change the data type sent by producers. If you do, it could cause issues for the consumers, who might be expecting different data types, like integers and strings, but receive something else, like Floats or Avro. This can lead to significant problems. Therefore, if you need to change the data type for your topic, it's better to create a new topic. This new topic can have any format you choose, but then you'll need to adjust the consumers slightly to read from these new topics with their new format.

Conclusion
==========

1.  Deserialization is used to transform bytes into objects/data.
2.  Apply to the Key and Value of the message.
3.  Common Deserializers: String (incl, JSON), Int, Float, Avro, Protobuf.
4.  The type for Serialization/Deserialization should remain the same throughout the life of a topic. It's best to start a new topic instead.
