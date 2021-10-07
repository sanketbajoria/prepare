# How Goroutines Work

### Introduction to Go

If you are new to the Go programming language, or if the sentence "Concurrency is not parallelism" means nothing to you, then check out Rob Pike's [excellent talk on the subject](https://www.youtube.com/watch?v=cN_DpYBzKso). Its 30 minutes long, and I guarantee that watching it is 30 minutes well spent.

To summarize the difference - "when people hear the word concurrency they often think of parallelism, a related but quite distinct concept. In programming, concurrency is the composition of independently executing processes, while parallelism is the simultaneous execution of (possibly related) computations. Concurrency is about dealing with lots of things at once. Parallelism is about doing lots of things at once." [1]

Go allows us to write concurrent programs. It provides goroutines and importantly, the ability to communicate between them. I will focus on the former.

### Goroutines usage scenario
- We are doing network bound i/o operation for eg: downloading a file or serving a request (on different goroutine) via HTTP server.
- We are doing system call for eg: reading a file etc...
- Compute intensive operation, then use goroutine, so multiple core can be used, and main goroutine doesn't block. If go version older than 4.5 then, use GOMAXPROCS(n) to tell number of threads to used. By default in older version number of threads used is one.
- Any background job, we want to execute. For eg: if request come to download a file in background, then start downloading in different goroutine.    

### Goroutines and Threads - the differences

Go uses goroutines while a language like Java uses threads. What are the differences between the two? We need to look at 3 factors - memory consumption, setup and teardown and switching time.

#### Memory consumption

The creation of a goroutine does not require much memory - only 2kB of stack space. They grow by allocating and freeing heap storage as required.[2][3] Threads on the other hand start out at 1Mb (500 times more), along with a region of memory called a guard page that acts as a guard between one thread's memory and another.[7]

A server handling incoming requests can therefore create one goroutine per request without a problem, but one thread per request will eventually lead to the dreaded OutOfMemoryError. This isn't limited to Java - any language that uses OS threads as the primary means of concurrency will face this issue.

#### Setup and teardown costs

Threads have significant setup and teardown costs because it has to request resources from the OS and return it once its done. The workaround to this problem is to maintain a pool of threads. In contrast, goroutines are created and destroyed by the runtime and those operations are pretty cheap. The language doesn't support manual management of goroutines.

#### Switching costs

When a thread blocks, another has to be scheduled in its place. Threads are scheduled preemptively, and during a thread switch, the scheduler needs to save/restore ALL registers, that is, 16 general purpose registers, PC (Program Counter), SP (Stack Pointer), segment registers, 16 XMM registers, FP coprocessor state, 16 AVX registers, all MSRs etc. This is quite significant when there is rapid switching between threads.

Goroutines are scheduled cooperatively and when a switch occurs, only 3 registers need to be saved/restored - Program Counter, Stack Pointer and DX. The cost is much lower.

As discussed earlier, the number of goroutines is generally much higher, but that doesn't make a difference to switching time for two reasons. Only runnable goroutines are considered, blocked ones aren't. Also, modern schedulers are O(1) complexity, meaning switching time is not affected by the number of choices (threads or goroutines).[5]

### How goroutines are executed

As mentioned earlier, the runtime manages the goroutines throughout from creation to scheduling to teardown. The runtime is allocated a few threads on which all the goroutines are multiplexed. At any point of time, each thread will be executing one goroutine. If that goroutine is blocked, then it will be swapped out for another goroutine that will execute on that thread instead.[6]

As the goroutines are scheduled cooperatively, a goroutine that loops continuously can starve other goroutines on the same thread. In Go 1.2, this problem is somewhat alleviated by occasionally invoking the Go scheduler when entering a function, so a loop that includes a non-inlined function call can be prempted.

### Scheduling of Goroutines

As I have mentioned in the last paragraph, Goroutines are cooperatively scheduled. In cooperative scheduling there is no concept of scheduler time slice. In such scheduling Goroutines yield the control periodically when they are idle or logically blocked in order to run multiple Goroutines concurrently. The switch between Goroutines happen only at well defined points — when an explicit call is made to the Goruntime scheduler. And those well defined points are:

- Channels send and receive operations, if those operations would block.
- The Go statement, although there is no guarantee that the new Goroutine will be scheduled immediately.
- Blocking syscalls like file and network operations.
- After being stopped for a garbage collection cycle.

Now let’s see how they are scheduled internally. Go uses three entities to explain the Goroutine scheduling.

- Processor (P)
- OSThread (M)
- Goroutines (G)

In any particular Go application the number of threads available for Goroutines to run is equal to the GOMAXPROCS, which by default is equal to the number of cores available for that application. We can use the `runtime` package to change this number at runtime as well. OSThreads are scheduled over processors and Goroutines are scheduled over OSThreads as explained in the Fig 2.

Golang has an M:N scheduler that also utilizes multiple processors. At any time, M goroutines need to be scheduled on N OS threads that runs on at most [GOMAXPROCS](http://localhost:4000/computer science/2018/03/03/Complete-Journey-with-GoRoutines/#gomaxprocs)numbers of processors(`N <= GOMAXPROCS`). Go scheduler distribute runnable goroutines over multiple worker OS threads that runs on one or more processors.

![img](https://miro.medium.com/max/60/1*bGkWfuAGbHK9r1lFpukYpw.png?q=20)

![img](https://miro.medium.com/max/875/1*bGkWfuAGbHK9r1lFpukYpw.png)

Inspired from [here](https://rakyll.org/scheduler/)

Every P has a local Goroutine queue. There’s also a global Goroutine queue which contains runnable Goroutines. Each M should be assigned to a P. Ps may have no Ms if they are blocked or in a system call. At any time, there are at most GOMAXPROCS number of P and only one M can run per P. More Ms can be created by the scheduler if required.

![img](https://miro.medium.com/max/60/1*Q7_pAxBx1q4C8MUTHQ3oDg.png?q=20)

![img](https://miro.medium.com/max/875/1*Q7_pAxBx1q4C8MUTHQ3oDg.png)

Inspired from [here](https://rakyll.org/scheduler/)

In each round of scheduling, scheduler finds a runnable G and executes it. Once a runnable G is found, it gets executed until it is blocked (as explained above).

```
Search in the local queue
        if not found 
            Try to steal from other Ps' local queue //see Fig 3
            if not found 
                Search in the global queue         Also periodically it searches in the global queue (every ~ 1/70)
```

### 

### Goroutines blocking

Goroutines are cheap and do not cause the thread on which they are multiplexed to block if they are blocked on

- network input
- sleeping
- channel operations or
- blocking on primitives in the sync package.

Even if tens of thousands of goroutines have been spawned, it's not a waste of system resources if most of them are blocked on one of these since the runtime schedules another goroutine instead.

In simple terms, goroutines are a lightweight abstraction over threads. A Go programmer does not deal with threads, and similarly the OS is not aware of the existence of goroutines. From the OS's perspective, a Go program will behave like an event-driven C program. [5]

### Threads and processors

Although you cannot directly control the number of threads that the runtime will create, it is possible to set the number of processor cores used by the program. This is done by setting the variable `GOMAXPROCS` with a call to `runtime.GOMAXPROCS(n)`. Increasing the number of cores may not necessarily improve the performance of your program, depending on its design. The profiling tools can be used to find the ideal number of cores for your program. By default, as of 1.5+ or 1.6+, `GOMAXPROCS` is set to `runtime.NumCPU()`. Fun trivia: in older versions of Go, it was set to `1`, because the scheduler wasn’t as smart and GOMAXPROCS > 1 was extremely detrimental to performance.

### Closing thoughts

As with other languages, it is important to prevent simultaneous access of shared resources by more than one goroutine. It is best to transfer data between goroutines using channels, ie, [do not communicate by sharing memory; instead, share memory by communicating](https://blog.golang.org/share-memory-by-communicating).

Lastly, I'd strongly recommend you check out [Communicating Sequential Processes](https://www.cs.cmu.edu/~crary/819-f09/Hoare78.pdf) by C. A. R. Hoare. This man was truly a genius. In this paper (published 1978) he predicted how the single core performance of processors would eventually plateau and chip-makers would instead increase the number of cores. His proposal to exploit this had a deep influence on the design of Go.

### Further Reading

If you're interested in learning more about Go, there are a couple great talks about the language here

- [Go Concurrency Patterns](https://www.youtube.com/watch?v=f6kdp27TYZs‎) by Rob Pike
- [Advanced Go Concurrency Patterns](https://www.youtube.com/watch?v=QDDwwePbDtw) by Sameer Ajmani.