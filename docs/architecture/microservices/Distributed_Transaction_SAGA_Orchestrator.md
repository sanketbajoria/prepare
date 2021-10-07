# Microservice Pattern – Orchestration Saga Pattern With Spring Boot + Kafka

## **Overview:**

Over the years, MicroServices have become very popular. MicroServices are distributed systems. They are smaller, modular, easy to deploy and scale etc. Developing a single microservice application might be interesting! But handling a business transaction which spans across multiple microservices is not fun! MicroService architectures have specific responsibilities. In order to complete an application workflow / a task, multiple MicroServices might have to work together.

Lets see how difficult it could be in dealing with transactions / data consistency in the distributed systems in this article.

## **Challenges:**

Let’s assume that our business rule says, when an user places an order, order will be fulfilled if the product’s price is within the user’s credit limit/balance & the inventory is available for the product. Otherwise it will not be fulfilled. It looks really simple. This is very easy to implement in a monolith application. The entire workflow can be considered as 1 single transaction. It is easy to commit / rollback when everything is in a single DB. With distributed systems with multiple databases, It is going to be very complex! Lets look at our architecture first to see how to implement this.

![img](http://www.vinsguru.com/wp-content/uploads/2020/08/Screenshot-from-2020-08-11-16-33-05.png)

We have below microservices with its own DB.

- order-service
- payment-service
- inventory-service

When the order-service receives the request for the new order, It has to check with the payment-service & inventory-service. We deduct the payment, inventory and fulfill the order finally! What will happen if we deducted payment but if inventory is not available? How to roll back? It is difficult with multiple databases involved.

![img](http://www.vinsguru.com/wp-content/uploads/2020/08/Screenshot-from-2020-08-11-16-44-17.png)

## **Saga Pattern:**

Each business transaction which spans multiple microservices are split into micro-service specific local transactions and they are executed in a sequence to complete the business workflow. It is called Saga. It can be implemented in 2 ways.

- Choreography approach
- Orchestration approach

In this article, we will be discussing the Orchestration based saga. For more information on Choreography based saga, check **[here](http://www.vinsguru.com/architectural-design-pattern-saga-pattern-implementation-using-kafka/)**.

## **Orchestration:**

In this pattern, we will have an orchestrator, a separate service, which will be coordinating all the transactions among all the microservices. If things are fine, it makes the order-request as complete, otherwise marks that as cancelled.

Lets see how we could implement this. Our sample architecture will be more or less like this.!

- In this demo, communication between orchestrator and other services would be a simple HTTP in a non-blocking asynchronous way to make this stateless.
- We can also use Kafka topics for this communication. For that we have to use scatter/gather pattern which is more of a stateful style.

![img](http://www.vinsguru.com/wp-content/uploads/2020/08/saga-orchestration.png)

## **Common DTOs:**

- First I create a Spring boot multi module maven project as shown below.

![img](http://www.vinsguru.com/wp-content/uploads/2020/08/Screenshot-from-2020-08-11-16-48-14.png)

- I create common DTOs/models which will be used across all the microservices. (I would suggest you to follow **[this approach](http://www.vinsguru.com/microservices-architecture-how-to-share-dto-data-transfer-objects/)** for DTOs)

![img](http://www.vinsguru.com/wp-content/uploads/2020/08/Screenshot-from-2020-08-11-16-49-57.png)

## **Inventory Service:**

Each microservice which will be coordinated by orchestrator is expected to have at least 2 endpoints for each entity! One is deducting and other one is for resetting the transaction. For example. if we deduct inventory first and then later when we come to know that insufficient balance from payment system, we need to add the inventory back.

**Note**: I used a map as a DB to hold some inventory for few product IDs.

```java
@Service
public class InventoryService {

    private Map<Integer, Integer> productInventoryMap;

    @PostConstruct
    private void init(){
        this.productInventoryMap = new HashMap<>();
        this.productInventoryMap.put(1, 5);
        this.productInventoryMap.put(2, 5);
        this.productInventoryMap.put(3, 5);
    }

    public InventoryResponseDTO deductInventory(final InventoryRequestDTO requestDTO){
        int quantity = this.productInventoryMap.getOrDefault(requestDTO.getProductId(), 0);
        InventoryResponseDTO responseDTO = new InventoryResponseDTO();
        responseDTO.setOrderId(requestDTO.getOrderId());
        responseDTO.setUserId(requestDTO.getUserId());
        responseDTO.setProductId(requestDTO.getProductId());
        responseDTO.setStatus(InventoryStatus.UNAVAILABLE);
        if(quantity > 0){
            responseDTO.setStatus(InventoryStatus.AVAILABLE);
            this.productInventoryMap.put(requestDTO.getProductId(), quantity - 1);
        }
        return responseDTO;
    }

    public void addInventory(final InventoryRequestDTO requestDTO){
        this.productInventoryMap
                .computeIfPresent(requestDTO.getProductId(), (k, v) -> v + 1);
    }

}Copy
```

- controller

```java
@RestController
@RequestMapping("inventory")
public class InventoryController {

    @Autowired
    private InventoryService service;

    @PostMapping("/deduct")
    public InventoryResponseDTO deduct(@RequestBody final InventoryRequestDTO requestDTO){
        return this.service.deductInventory(requestDTO);
    }

    @PostMapping("/add")
    public void add(@RequestBody final InventoryRequestDTO requestDTO){
        this.service.addInventory(requestDTO);
    }

}Copy
```

## **Payment Service:**

It also exposes 2 endpoints like inventory-service. I am showing only the important classes. For more details please check the github link at the end of this article for the complete project source code.

```java
@Service
public class PaymentService {

    private Map<Integer, Double> userBalanceMap;

    @PostConstruct
    private void init(){
        this.userBalanceMap = new HashMap<>();
        this.userBalanceMap.put(1, 1000d);
        this.userBalanceMap.put(2, 1000d);
        this.userBalanceMap.put(3, 1000d);
    }

    public PaymentResponseDTO debit(final PaymentRequestDTO requestDTO){
        double balance = this.userBalanceMap.getOrDefault(requestDTO.getUserId(), 0d);
        PaymentResponseDTO responseDTO = new PaymentResponseDTO();
        responseDTO.setAmount(requestDTO.getAmount());
        responseDTO.setUserId(requestDTO.getUserId());
        responseDTO.setOrderId(requestDTO.getOrderId());
        responseDTO.setStatus(PaymentStatus.PAYMENT_REJECTED);
        if(balance >= requestDTO.getAmount()){
            responseDTO.setStatus(PaymentStatus.PAYMENT_APPROVED);
            this.userBalanceMap.put(requestDTO.getUserId(), balance - requestDTO.getAmount());
        }
        return responseDTO;
    }

    public void credit(final PaymentRequestDTO requestDTO){
        this.userBalanceMap.computeIfPresent(requestDTO.getUserId(), (k, v) -> v + requestDTO.getAmount());
    }

}Copy
```

- controller

```java
@RestController
@RequestMapping("payment")
public class PaymentController {

    @Autowired
    private PaymentService service;

    @PostMapping("/debit")
    public PaymentResponseDTO debit(@RequestBody PaymentRequestDTO requestDTO){
        return this.service.debit(requestDTO);
    }

    @PostMapping("/credit")
    public void credit(@RequestBody PaymentRequestDTO requestDTO){
        this.service.credit(requestDTO);
    }

}Copy
```

## **Order Service:**

Our order service receives the create order command and raises an ***order-created*** event using spring boot kafka binder. It also listens to ***order-updated*** channel/kafka topic and updates order status.

- controller

```java
@RestController
@RequestMapping("order")
public class OrderController {

    @Autowired
    private OrderService service;

    @PostMapping("/create")
    public PurchaseOrder createOrder(@RequestBody OrderRequestDTO requestDTO){
        requestDTO.setOrderId(UUID.randomUUID());
        return this.service.createOrder(requestDTO);
    }

    @GetMapping("/all")
    public List<OrderResponseDTO> getOrders(){
        return this.service.getAll();
    }

}Copy
```

- service

```java
@Service
public class OrderService {

    // product price map
    private static final Map<Integer, Double> PRODUCT_PRICE =  Map.of(
            1, 100d,
            2, 200d,
            3, 300d
    );

    @Autowired
    private PurchaseOrderRepository purchaseOrderRepository;

    @Autowired
    private FluxSink<OrchestratorRequestDTO> sink;

    public PurchaseOrder createOrder(OrderRequestDTO orderRequestDTO){
        PurchaseOrder purchaseOrder = this.purchaseOrderRepository.save(this.dtoToEntity(orderRequestDTO));
        this.sink.next(this.getOrchestratorRequestDTO(orderRequestDTO));
        return purchaseOrder;
    }

    public List<OrderResponseDTO> getAll() {
        return this.purchaseOrderRepository.findAll()
                .stream()
                .map(this::entityToDto)
                .collect(Collectors.toList());
    }

    private PurchaseOrder dtoToEntity(final OrderRequestDTO dto){
        PurchaseOrder purchaseOrder = new PurchaseOrder();
        purchaseOrder.setId(dto.getOrderId());
        purchaseOrder.setProductId(dto.getProductId());
        purchaseOrder.setUserId(dto.getUserId());
        purchaseOrder.setStatus(OrderStatus.ORDER_CREATED);
        purchaseOrder.setPrice(PRODUCT_PRICE.get(purchaseOrder.getProductId()));
        return purchaseOrder;
    }

    private OrderResponseDTO entityToDto(final PurchaseOrder purchaseOrder){
        OrderResponseDTO dto = new OrderResponseDTO();
        dto.setOrderId(purchaseOrder.getId());
        dto.setProductId(purchaseOrder.getProductId());
        dto.setUserId(purchaseOrder.getUserId());
        dto.setStatus(purchaseOrder.getStatus());
        dto.setAmount(purchaseOrder.getPrice());
        return dto;
    }

    public OrchestratorRequestDTO getOrchestratorRequestDTO(OrderRequestDTO orderRequestDTO){
        OrchestratorRequestDTO requestDTO = new OrchestratorRequestDTO();
        requestDTO.setUserId(orderRequestDTO.getUserId());
        requestDTO.setAmount(PRODUCT_PRICE.get(orderRequestDTO.getProductId()));
        requestDTO.setOrderId(orderRequestDTO.getOrderId());
        requestDTO.setProductId(orderRequestDTO.getProductId());
        return requestDTO;
    }

}Copy
```

## **Order Orchestrator:**

This is a microservice which is responsible for coordinating all the transactions. It listens to order-created topic. As and when a new order is created, It immediately builds separate request to each service like payment-service/inventory-service etc and validates the responses. If they are OK, fulfills the order. If one of them is not, cancels the oder. It also tries to reset any of local transactions which happened in any of the microservices.

We consider all the local transactions as 1 single workflow. A workflow will contain multiple workflow steps.

- Workflow step

```java
public interface WorkflowStep {

    WorkflowStepStatus getStatus();
    Mono<Boolean> process();
    Mono<Boolean> revert();

}Copy
```

- Workflow

```java
public interface Workflow {

    List<WorkflowStep> getSteps();

}Copy
```

- In our case, for the Order workflow, we have 2 steps. Each implementation should know how to do local transaction and how to reset.
- Inventory step

```java
public class InventoryStep implements WorkflowStep {

    private final WebClient webClient;
    private final InventoryRequestDTO requestDTO;
    private WorkflowStepStatus stepStatus = WorkflowStepStatus.PENDING;

    public InventoryStep(WebClient webClient, InventoryRequestDTO requestDTO) {
        this.webClient = webClient;
        this.requestDTO = requestDTO;
    }

    @Override
    public WorkflowStepStatus getStatus() {
        return this.stepStatus;
    }

    @Override
    public Mono<Boolean> process() {
        return this.webClient
                .post()
                .uri("/inventory/deduct")
                .body(BodyInserters.fromValue(this.requestDTO))
                .retrieve()
                .bodyToMono(InventoryResponseDTO.class)
                .map(r -> r.getStatus().equals(InventoryStatus.AVAILABLE))
                .doOnNext(b -> this.stepStatus = b ? WorkflowStepStatus.COMPLETE : WorkflowStepStatus.FAILED);
    }

    @Override
    public Mono<Boolean> revert() {
        return this.webClient
                    .post()
                    .uri("/inventory/add")
                    .body(BodyInserters.fromValue(this.requestDTO))
                    .retrieve()
                    .bodyToMono(Void.class)
                    .map(r ->true)
                    .onErrorReturn(false);
    }
}Copy
```

- Payment step

```java
public class PaymentStep implements WorkflowStep {

    private final WebClient webClient;
    private final PaymentRequestDTO requestDTO;
    private WorkflowStepStatus stepStatus = WorkflowStepStatus.PENDING;

    public PaymentStep(WebClient webClient, PaymentRequestDTO requestDTO) {
        this.webClient = webClient;
        this.requestDTO = requestDTO;
    }

    @Override
    public WorkflowStepStatus getStatus() {
        return this.stepStatus;
    }

    @Override
    public Mono<Boolean> process() {
        return this.webClient
                    .post()
                    .uri("/payment/debit")
                    .body(BodyInserters.fromValue(this.requestDTO))
                    .retrieve()
                    .bodyToMono(PaymentResponseDTO.class)
                    .map(r -> r.getStatus().equals(PaymentStatus.PAYMENT_APPROVED))
                    .doOnNext(b -> this.stepStatus = b ? WorkflowStepStatus.COMPLETE : WorkflowStepStatus.FAILED);
    }

    @Override
    public Mono<Boolean> revert() {
        return this.webClient
                .post()
                .uri("/payment/credit")
                .body(BodyInserters.fromValue(this.requestDTO))
                .retrieve()
                .bodyToMono(Void.class)
                .map(r -> true)
                .onErrorReturn(false);
    }

}Copy
```

- service / coordinator

```java
@Service
public class OrchestratorService {

    @Autowired
    @Qualifier("payment")
    private WebClient paymentClient;

    @Autowired
    @Qualifier("inventory")
    private WebClient inventoryClient;

    public Mono<OrchestratorResponseDTO> orderProduct(final OrchestratorRequestDTO requestDTO){
        Workflow orderWorkflow = this.getOrderWorkflow(requestDTO);
        return Flux.fromStream(() -> orderWorkflow.getSteps().stream())
                .flatMap(WorkflowStep::process)
                .handle(((aBoolean, synchronousSink) -> {
                    if(aBoolean)
                        synchronousSink.next(true);
                    else
                        synchronousSink.error(new WorkflowException("create order failed!"));
                }))
                .then(Mono.fromCallable(() -> getResponseDTO(requestDTO, OrderStatus.ORDER_COMPLETED)))
                .onErrorResume(ex -> this.revertOrder(orderWorkflow, requestDTO));

    }

    private Mono<OrchestratorResponseDTO> revertOrder(final Workflow workflow, final OrchestratorRequestDTO requestDTO){
        return Flux.fromStream(() -> workflow.getSteps().stream())
                .filter(wf -> wf.getStatus().equals(WorkflowStepStatus.COMPLETE))
                .flatMap(WorkflowStep::revert)
                .retry(3)
                .then(Mono.just(this.getResponseDTO(requestDTO, OrderStatus.ORDER_CANCELLED)));
    }

    private Workflow getOrderWorkflow(OrchestratorRequestDTO requestDTO){
        WorkflowStep paymentStep = new PaymentStep(this.paymentClient, this.getPaymentRequestDTO(requestDTO));
        WorkflowStep inventoryStep = new InventoryStep(this.inventoryClient, this.getInventoryRequestDTO(requestDTO));
        return new OrderWorkflow(List.of(paymentStep, inventoryStep));
    }

    private OrchestratorResponseDTO getResponseDTO(OrchestratorRequestDTO requestDTO, OrderStatus status){
        OrchestratorResponseDTO responseDTO = new OrchestratorResponseDTO();
        responseDTO.setOrderId(requestDTO.getOrderId());
        responseDTO.setAmount(requestDTO.getAmount());
        responseDTO.setProductId(requestDTO.getProductId());
        responseDTO.setUserId(requestDTO.getUserId());
        responseDTO.setStatus(status);
        return responseDTO;
    }

    private PaymentRequestDTO getPaymentRequestDTO(OrchestratorRequestDTO requestDTO){
        PaymentRequestDTO paymentRequestDTO = new PaymentRequestDTO();
        paymentRequestDTO.setUserId(requestDTO.getUserId());
        paymentRequestDTO.setAmount(requestDTO.getAmount());
        paymentRequestDTO.setOrderId(requestDTO.getOrderId());
        return paymentRequestDTO;
    }

    private InventoryRequestDTO getInventoryRequestDTO(OrchestratorRequestDTO requestDTO){
        InventoryRequestDTO inventoryRequestDTO = new InventoryRequestDTO();
        inventoryRequestDTO.setUserId(requestDTO.getUserId());
        inventoryRequestDTO.setProductId(requestDTO.getProductId());
        inventoryRequestDTO.setOrderId(requestDTO.getOrderId());
        return inventoryRequestDTO;
    }

}Copy
```

I have provided only high level details here. For the complete source, check **[here](https://github.com/vinsguru/vinsguru-blog-code-samples/tree/master/architectural-pattern/saga-orchestration)**.

## **Demo:**

- Once all the services are up and running, I send a POST request to create order. I get the order created status.
  - Do note that user 1 tries to order product id 3 which costs $300
  - The user’s credit limit is $1000

![img](http://www.vinsguru.com/wp-content/uploads/2020/08/Screenshot-from-2020-08-11-11-20-40.png)

- I sent 4 requests. So 3 requests were fulfilled. Not the 4th one as the user would have only $100 left and we can not fulfill the 4th order. So the payment service would have declined.

![img](http://www.vinsguru.com/wp-content/uploads/2020/08/Screenshot-from-2020-08-11-11-21-01.png)

- The user 1 with this available balance $100, he can buy product id 1 as it costs only $100.

![img](http://www.vinsguru.com/wp-content/uploads/2020/08/Screenshot-from-2020-08-11-11-24-35.png)

## **Summary:**

Handling transactions and maintaining data consistency among all the microservices are difficult in general. When multiple services are involved like payment, inventory, fraud check, shipping check…..etc it would be very difficult to manage such a complex workflow with multiple steps without a coordinator. By introducing a separate service for coordinator, order-service is freed up from these responsibilities. We are also not introducing any cyclic dependencies.

Check the project source code **[here](https://github.com/vinsguru/vinsguru-blog-code-samples/tree/master/architectural-pattern/saga-orchestration)**.