# Thread

## ThreadPoolExecutor
### Properties
- Core and maximum pool sizes
  When a new task is submitted and fewer than corePoolSize threads are running, a new thread is created to handle the request, even if other worker threads are idle.  If there are more than corePoolSize but less than maximumPoolSize threads running, a new thread will be created only if the queue is full.
- Keep-alive times
  If the pool currently has more than corePoolSize threads, excess threads will be terminated if they have been idle for more than the keepAliveTime
- Queue
  SynchronousQueue - Hands off tasks to threads, directly, without otherwise holding them
  LinkedBlockingQueue - Using an unbounded queue without a predefined capacity) will cause new tasks to wait in the queue when all corePoolSize threads are busy. Thus, no more than corePoolSize threads will ever be created.
  ArrayBlockingQueue - Bounded Queue with predefined capacity, will cause new task to wait in the queue. If queue is full, then it will create more thread upto maximum pool sizes
- Rejected Task - Once, queue is full, and maximum pool size has been reached, task get rejected. Which can be handled via RejectionHandler. Few predefined RejectedHandler such as 
  - AbortPolicy - Rejected task, by throwing RejectedExecutionException
  - CallerRunsPolicy - Rejected task, will be invoked in main thread, (which is submitted the task)
  - DiscardPolicy - Rejected task, will be drop silently, without throwing exception.
  - DiscardOldestPolicy - Oldest task in the queue, will be discarded. Now, Rejected task, will be added to queue.
- Thread Factory - Factory for creating new thread. All thread are getting created using this factory. By default, DefaultThreadFactory is used.

### Default ThreadPoolExecutor
- newSingleThreadExecutor() – a thread pool with only one thread with an unbounded queue, which only executes one task at a time
- newFixedThreadPool() – a thread pool with a fixed number of threads which share an unbounded queue; if all threads are active when a new task is submitted, they will wait in queue until a thread becomes available
- newCachedThreadPool() – a thread pool that creates new threads as they are needed
- newWorkStealingThreadPool() – a thread pool based on a “work-stealing” algorithm which will be detailed more in a later section

### Extending ThreadPoolExecutor Behaviour
- Override Hook methods
  - beforeExecute(Thread, Runnable) - Method invoked, before worker thread can execute a Runnable task.
  - afterExecute(Thread, Runnable) - Method invoked, after worker thread completed a Runnable task.
  - terminated - Method invoked, when ther executor has terminated. 
  - finalize - Invokes {@code shutdown} when this executor is no longer referenced and it has no threads.
- Extend ThreadFactory - Provide your own threadFactory, which can create your own custom thread. Example usage, if thread has to bind with external process. Then in thread constructor, we can create a process, And, override the run method to do cleanup after super.run()
```java
  public class CustomThread implements Runnable {
      public void run(){
      //Before any thread start do any process
      super.run(); // It will call Worker thread internally, which will loop infinitely for task from queue.
      //do cleanup here after thread complete, 
      }
  }
```
  
Can override RunnerThread, Task (Runnable), ThreadFactory and ThreadPoolExecutor

Override a RunnerThread to bind some external process