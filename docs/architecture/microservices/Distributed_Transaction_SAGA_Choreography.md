# Choreography Saga Pattern With Spring Boot – Microservice Design Patterns



## **Overview:**

In this tutorial, I would like to show you a simple implementation of ***Choreography Saga Pattern with Spring Boot.***

Over the years, Microservices have become very popular. Microservices are distributed systems. They are smaller, modular, easy to deploy and scale etc. Developing a single microservice application might be interesting! But handling a business transaction which spans across multiple Microservices is not fun! In order to complete an application workflow / a task, multiple Microservices might have to work together.

Lets see how difficult it could be in dealing with transactions / data consistency in the distributed systems in this article.

## **A Simple Transaction:**

Let’s assume that our business rule says, when an user places an order, order will be fulfilled if the product’s price is within the user’s credit limit/balance. Otherwise it will not be fulfilled. It looks really simple.

This is very easy to implement in a monolith application. The entire workflow can be considered as 1 single transaction. It is easy to commit / rollback when everything is in a single DB. With distributed systems with multiple databases, It is going to be very complex! Lets look at our architecture first to see how to implement this.

We have an order-service with its own database which is responsible for order management. Similarly we also have payment-service which is responsible for managing payments. So the order-service receives the request and checks with the payment-service if the user has the balance. If the payment-service responds OK, order-service completes the order and payment-service deducts the payment. Otherwise, the order-service cancels the order. For a very simple business requirement, here we have to send multiple requests across the network.

![img](http://www.vinsguru.com/wp-content/uploads/2020/04/Screenshot-from-2020-07-11-22-14-16.png)

What if we also need to check with inventory-service for the availability of inventory before making the order as complete! Now you see the problem?

In the traditional system design approach, order-service simply sends a HTTP request to get the information about the user’s credit balance. The problem with this approach is order-service assumes that payment-service will be up and running always. Any network issue or performance issue at the payment-service will be propagated to the order-service. It could lead to poor user-experience & we also might lose revenue. Let’s see how we could handle transactions in the distributed systems with loose coupling by using a pattern called ***Saga Pattern*** with [Event Sourcing](https://martinfowler.com/eaaDev/EventSourcing.html) approach.

## **Saga Pattern:**

Each business transaction which spans multiple Microservices are split into Microservice specific local transactions and they are executed in a sequence to complete the business workflow. It is called ***Saga***. It can be implemented in 2 ways.

- Choreography approach
- Orchestration approach

In this article, we will be discussing the choreography based approach by using ***event-sourcing***. For orchestration based Saga, check **[here](http://www.vinsguru.com/architectural-pattern-orchestration-saga-pattern-implementation-using-kafka/)**.

## **Event Sourcing:**

In this approach every change to the state of an application is captured as an ***event***. This event is stored in the database /event store (for tracking purposes) and is also published in the event-bus for other parties to consume.

![img](http://www.vinsguru.com/wp-content/uploads/2020/04/Screenshot-from-2020-07-11-21-38-45.png)

The order-service receives a command to create a new order. This request is processed and raised as an order-created event. Couple of things to note here.

1. Order created event basically informs that a new order request has been received and kept in the ***PENDING/CREATED*** status by order-service. It is not yet fulfilled.
2. The event object will be named in the past tense always as it already happened!

Now the payment-service/inventory-service could be interested in listening to those events and reserve/reject payment/inventory. Even these could be treated as an event. Payment reserved/rejected event. Order-service might listen to these events and fulfill / cancel the order request it had originally received.

This approach has many advantages.

- There is no service dependency. payment-service/inventory-service do not have to be up and running always.
- Loose coupling
- Horizontal scaling
- Fault tolerant

![Choreography Saga Pattern](https://www.vinsguru.com/wp-content/uploads/2020/12/Screenshot-from-2021-01-28-13-09-26.png)

The business workflow is implemented as shown here.

- order-services receives a POST request for a new order
- It places an order request in the DB in the ORDER_CREATED state and raises an event
- payment-service listens to the event, confirms about the credit reservation
- inventory-service also listens to the order-event and conforms the inventory reservation
- order-service fulfills order or rejects the order based on the credit & inventory reservation status.

## **Implementation:**

- I created a simple ***Spring Boot*** project using kafka-cloud-stream. I have basic project structure which looks like this.

![img](https://www.vinsguru.com/wp-content/uploads/2020/12/Screenshot-from-2021-01-28-13-55-26.png)

- My

   

  **common-dto**

   

  package is as shown below.

  - It contains the basic DTOs, Enums and Event objects.

![img](https://www.vinsguru.com/wp-content/uploads/2020/12/Screenshot-from-2021-01-28-13-58-10.png)

## **Payment Service:**

The payment service consumes order-events from a kafka topic and returns the corresponding payment-event. Take a look at the GitHub link at the end of this article for the complete working project.

```java
@Configuration
public class PaymentConfig {
    
    @Autowired
    private PaymentService service;

    @Bean
    public Function<Flux<OrderEvent>, Flux<PaymentEvent>> paymentProcessor() {
        return flux -> flux.flatMap(this::processPayment);
    }

    private Mono<PaymentEvent> processPayment(OrderEvent event){
        if(event.getOrderStatus().equals(OrderStatus.ORDER_CREATED)){
            return Mono.fromSupplier(() -> this.service.newOrderEvent(event));
        }else{
            return Mono.fromRunnable(() -> this.service.cancelOrderEvent(event));
        }
    }

}Copy
```

## **Inventory Service:**

We also have inventory-service which consumes order-events and returns inventory-events.

```java
@Configuration
public class InventoryConfig {
    
    @Autowired
    private InventoryService service;

    @Bean
    public Function<Flux<OrderEvent>, Flux<InventoryEvent>> inventoryProcessor() {
        return flux -> flux.flatMap(this::processInventory);
    }

    private Mono<InventoryEvent> processInventory(OrderEvent event){
        if(event.getOrderStatus().equals(OrderStatus.ORDER_CREATED)){
            return Mono.fromSupplier(() -> this.service.newOrderInventory(event));
        }
        return Mono.fromRunnable(() -> this.service.cancelOrderInventory(event));
    }

}Copy
```

## **Order Service:**

We first create a Sink through we which we would be publishing events.

```java
@Configuration
public class OrderConfig {

    @Bean
    public Sinks.Many<OrderEvent> orderSink(){
        return Sinks.many().unicast().onBackpressureBuffer();
    }

    @Bean
    public Supplier<Flux<OrderEvent>> orderSupplier(Sinks.Many<OrderEvent> sink){
        return sink::asFlux;
    }

}Copy
```

- order events publisher

```java
@Service
public class OrderStatusPublisher {

    @Autowired
    private Sinks.Many<OrderEvent> orderSink;

    public void raiseOrderEvent(final PurchaseOrder purchaseOrder, OrderStatus orderStatus){
        var dto = PurchaseOrderDto.of(
                purchaseOrder.getId(),
                purchaseOrder.getProductId(),
                purchaseOrder.getPrice(),
                purchaseOrder.getUserId()
        );
        var orderEvent = new OrderEvent(dto, orderStatus);
        this.orderSink.tryEmitNext(orderEvent);
    }

}Copy
```

- Order service also consumes payment and inventory events to take decision on the order.

```java
@Configuration
public class EventHandlersConfig {

    @Autowired
    private OrderStatusUpdateEventHandler orderEventHandler;

    @Bean
    public Consumer<PaymentEvent> paymentEventConsumer(){
        return pe -> {
            orderEventHandler.updateOrder(pe.getPayment().getOrderId(), po -> {
                po.setPaymentStatus(pe.getPaymentStatus());
            });
        };
    }

    @Bean
    public Consumer<InventoryEvent> inventoryEventConsumer(){
        return ie -> {
            orderEventHandler.updateOrder(ie.getInventory().getOrderId(), po -> {
                po.setInventoryStatus(ie.getStatus());
            });
        };
    }

}Copy
@Service
public class OrderStatusUpdateEventHandler {

    @Autowired
    private PurchaseOrderRepository repository;

    @Autowired
    private OrderStatusPublisher publisher;

    @Transactional
    public void updateOrder(final UUID id, Consumer<PurchaseOrder> consumer){
        this.repository
                .findById(id)
                .ifPresent(consumer.andThen(this::updateOrder));

    }

    private void updateOrder(PurchaseOrder purchaseOrder){
        if(Objects.isNull(purchaseOrder.getInventoryStatus()) || Objects.isNull(purchaseOrder.getPaymentStatus()))
            return;
        var isComplete = PaymentStatus.RESERVED.equals(purchaseOrder.getPaymentStatus()) && InventoryStatus.RESERVED.equals(purchaseOrder.getInventoryStatus());
        var orderStatus = isComplete ? OrderStatus.ORDER_COMPLETED : OrderStatus.ORDER_CANCELLED;
        purchaseOrder.setOrderStatus(orderStatus);
        if (!isComplete){
            this.publisher.raiseOrderEvent(purchaseOrder, orderStatus);
        }
    }

}Copy
```

- I am unable to provide the entire project code here. So do check the GitHub link for the complete source code.

## **Demo:**

- Once I start my application, I send an order request. The productId=3 costs $300 and user’s credit limit is $1000.
- As soon as I send a request, I get the immediate response saying the order_created / order_pending.
- I send 4 requests.

![img](http://www.vinsguru.com/wp-content/uploads/2020/04/Screenshot-from-2020-04-24-21-29-06.png)

- If I send /order/all requests to see all the orders, I see that 3 orders in fulfilled and the 4th order in cancelled status as the user does not have enough balance to fulfill the 4th order.

![img](http://www.vinsguru.com/wp-content/uploads/2020/04/Screenshot-from-2020-04-24-21-29-37.png)

- We can add additional services in the same way. For ex: once order-service fulfills the order and raises an another event. A shipping service listening to the event and takes care of packing and shipping to the given user address. Order-service might again listen to those events updates its DB to the order_shipped status.

As we had mentioned earlier, committing/rolling back a transaction which spans multiple microservices is very challenging. Each service should have the event-handlers, for committing / rolling back the transaction to maintain the data consistency, for every event it is listening to!

![img](http://www.vinsguru.com/wp-content/uploads/2020/04/Screenshot-from-2020-07-11-22-24-32.png)

## **Summary:**

We were able to successfully demonstrate the Choreography Saga Pattern with Spring Pattern.