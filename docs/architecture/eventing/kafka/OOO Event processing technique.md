In this fast world, each operations and functions involved with huge amount of data without depending on the area of interest. For instance, if we considered a bank there will be huge money transfers, savings, transactions via debit or credit cards and withdrawals will occur. A single customer may connect with several transactions or financial activities. In this sense, each incident that will contribute to the operation of bank can be considered as an event. Following image illustrates a network with sensors, gateway to handle sensors and other components. Events can also be related here. Sensors can collect data regarding traffic or accessing parties and may send to service providers via appropriate gateway. These collection of data can be referred to as events.

![](https://miro.medium.com/v2/resize:fit:1200/1*y1quK_VRcyNvgnWoRC95HQ.png)

Sensor network

We can state another example. Consider a cricket match, there will be several sensors nearby the pitch. Each of them will send data regarding the position of players, speed of the ball and direction of the ball, etc. These kind of data can be considered as events and processed in order to generate some high level events like determination of run out. Several lower level events can contribute to generate high level events.

What is out of order events?

Each events will have time stamps based on their generated time. It means the time at which the event was generated. Some events can arrive the processor or aggregate operator lately because of delays in networks.This late arrival of events that are having smaller time stamp values is known as out of order event occurrence. Following figure shows some out of order events in a stream.

![](https://miro.medium.com/v2/resize:fit:1222/1*kDr_ypp5aPHtsSBx445CnQ.png)

Out of order event stream

Here, event-5 is having time stamp value --- four and arrived after event-4 which is having time stamp value-five. Same as event-9 also arrived later,may be because of the delays in networks.

What are the issues involved with out-of-order events?

In the processing of events, wrong results can be generated due to this out of order events. We can see through an example. Three sensors are placed nearby the pitch to track the speed, direction and acceleration of the ball. It can be concluded that the batsman hits the ball, based on following events:

-   Increase in the speed of the ball
-   Sudden change in the direction of the ball
-   Peak acceleration

But, above mentioned events should be received consecutively in an order to generate a higher level event. It ensures the need of events order in processing. There are four main approaches to handle these out of order events.

1.  Buffer based approach
2.  Punctuation based approach
3.  Speculation based approach
4.  Approximation based approach

Buffer based approach
=====================

As its name implies, buffer based approach involved in employing a buffer to store events for some amount of time and reorder them according to their time stamp and emit. For example, suppose that sensor S1 is generating A and sensor S2 is generating B. There is an event generator G, which generates an event C, if it receives 'A,B,A" consecutively.

![](https://miro.medium.com/v2/resize:fit:1138/0*IbU33idaS3Oie1CF.png)

At a particular instance, events are generated in the order --- A, B, A, A, B, B. But it has been received as A, A, B, A, A, A which results in incorrect timing of generation of event C. It will produce inaccurate results in further processing. We can use a buffer here, to store these 6 events and sort them according to their time stamp and then release.

Punctuation based approach
==========================

In this approach, data stream will have special punctuation within it to handle disorders. Using the punctuation as an indicator, it can be determined that no more events that are having smaller time stamp value than time stamp of punctuation, will arrive in future. It means once a punctuation is received then events that are having smaller time stamps than punctuation will be discarded by the receiver.

We are not able to achieve the highest accuracy in this case. But, on the other hand accuracy of punctuation will determine the accuracy of handling out of order events. Both of this approaches are having a trade-off between latency and accuracy of query results. In the case of buffer based approach, if we needed a higher accuracy, then we need to have a large buffer size which results in latency. Same as, time stamp of punctuation should have a higher value to accommodate required late arrivals that are corresponding to a window.

Speculation based approach
==========================

It is little bit different from previous cases. Query results are produced when events are received by assuming that only ordered events are arrived. When an out of order event is received, previously calculated results will be discarded and new query results will be generated.

Greater inefficiency is presented here as it revises aggregate operation over same window scope. It is not suitable for data streams where high disorder is presented. Thus, it will increase the memory requirement, hence becomes expensive.

Approximation based approach
============================

Approximation based approach is related with computing approximate aggregate over the data streams. Raw data stream is summarized using a special data structure ( Ex: Histograms) and then approximately aggregate operation is calculated.

In all of the approaches, a quality driven method can be employed based on the user specifications. Accommodating user specifications (Regarding latency and accuracy) into disorder handling is technically named as Quality Driven Disorder Handling (QDDH).
