# Understanding Java Garbage Collection

Java Garbage Collection (GC) is the process of tracking the live objects while destroying unreferenced objects in the Heap memory in order to reclaim space for future object allocation. 

## Importance of understanding GC

GC enables faster development with less boilerplate code (no need for manually allocating and releasing memory) and eliminates memory-related issues. However, in reality, JVM performs garbage collection by creating and removing too many objects, which results in serious performance problems. In order to effectively manage garbage collection and memory issues in JVM, you need to understand how garbage collection really works under the hood.

# How GC works

Java Garbage Collector runs as a Daemon Thread (i.e. a low priority thread that runs in the background to provide services to user threads or perform JVM tasks). From time to time, it looks into all the objects in Heap memory and identifies objects that are no longer referenced by any part of your program (such unreferenced objects can no longer be reachable by the application code). Then all these unreferenced objects are destroyed and space will be reclaimed for newly-creating objects.

We can explain the Java garbage collection process using the following simple approach.

1. **Mark**: Identifying objects that are currently in use and not in use
2. **Normal Deletion**: Removing the unused objects and reclaim the free space
3. **Deletion with Compacting**: Moving all the survived objects to one survivor space (to increase the performance of allocation of memory to newer objects)

However, this approach has the following issues.

- Not efficient because by nature most of the newly created objects will become unused
- Long-lived objects are most likely to be in use for future GC cycles too

To solve the above issues, in reality, new objects are stored in separate generational spaces of the Heap in a way that each generational space indicates the lifetime of objects stored in it. Then, the garbage collection happens in 2 major phases called **Minor GC** and **Major GC** and objects are scanned and moved among generational spaces before complete deletion. This division in the Heap memory has already been discussed in my previous post — [Java Memory Model](https://medium.com/platform-engineer/understanding-java-memory-model-1d0863f6d973).

![img](https://miro.medium.com/max/38/0*ukUA0gxy5g1TjsTY?q=20)

![img](https://miro.medium.com/max/875/0*ukUA0gxy5g1TjsTY)

*JVM Heap Memory*

## Mark and Sweep Model

Mark & Sweep Model is the underlying implementation in J

a garbage collection. It has two major phases.

1. **Mark**: identify and mark all object references (starting with the GC roots) that are still used and reachable (a.k.a. live objects), and the rest is considered garbage.
2. **Sweep**: traverse Heap and find unoccupied spaces between the live objects, these spaces are recorded in a free list and are made available for future object allocation.

## Java Garbage Collection Roots

You now know that when there is no reference to an object, it becomes unreachable by the application code and hence becomes eligible for garbage collection too. Wait, what does that even mean? Reference what? If so, what’s the first reference? I also had the same questions at the first place. Let me explain how these referencing and reachability happen under the hood.

For your application code to reach an object, there should be a root object which is connected to your object as well as capable of accessing from outside the heap. Such root objects that are accessible from outside the Heap are called **Garbage Collection (GC) roots**. There are several types of GC roots such as Local variables, Active Java threads, Static variables, JNI References etc. (Just take the ideology here, if you do a quick google search, you may find many conflicting classifications of GC roots) What we need to learn here is that **as long as our object is directly or indirectly referenced by one of these GC roots and the GC root remains alive, our object can be considered as a reachable object. The moment our object loses its reference to a GC root, it becomes unreachable, hence eligible for garbage collection**.

![img](https://miro.medium.com/max/38/0*Qj99auTbTws8HQoQ?q=20)

![img](https://miro.medium.com/max/574/0*Qj99auTbTws8HQoQ)

*GC Roots are objects that are themselves referenced by the JVM and thus keep every other object from being garbage-collected (Image: dynatrace.com)*

# Eligibility for GC

Garbage collector only destroys the objects that are unreachable. It is an automatic process happening in the background and in general programmers are not supposed to do anything regarding it.

> Note: Before destroying an object, Garbage Collector calls finalize() method at most one time on that object (finalize() method never gets invoked more than once for any given object). The default finalize() method has empty implementation. By overriding it, we can perform our cleanup activities like closing a database connection or verify the end of that object as I have written below. Once finalize() method completes, Garbage Collector destroys that object.

Consider the following Person class with an object constructor and the finalize() method.

```
class Person {   
    // to store person (object) name
    String name;
     
    public Person(String name) {
        this.name = name;
    }
     
    @Override
    /* Overriding finalize method to check which object is garbage collected */
    protected void finalize() throws Throwable {
        // will print name of person (object)
        System.out.println("Person object - " + this.name + " -> successfully garbage collected");
    }
}
```

An object can immediately become unreachable if one of the following cases occurs (no need to wait for generational ageing in the Heap).

## **Case 1: Nullifying the reference variable**

When a reference variable of an object are changed to NULL, the object becomes unreachable and eligible for GC.

```
// create a Person object
// new operator dynamically allocates memory for an object and returns a reference to it
Person p1 = new Person("John Doe");
 
// some meaningful work happens while p1 is in use
...
...
...
 
// p1 is no longer in use
// make p1 eligible for gc
p1 = null;
 
// calling garbage collector
System.gc(); // p1 will be garbage-collected
```

The output would be:

```
Person object - John Doe -> successfully garbage collected
```

## Case 2: Re-assigning the reference variable

When a reference id of one object is referenced to a reference id of some other object, then the previous object will have no reference to it any longer. The object becomes unreachable and eligible for GC.

```
// create two Person objects
// new operator dynamically allocates memory for an object and returns a reference to it
Person p1 = new Person("John Doe");
Person p2 = new Person("Jane Doe");
 
// some meaningful work happens while p1 are p2 are in use
...
...
...
 
// p1 is no longer in use
// make p1 eligible for gc
p1 = p2; 
// p1 now referred to p2
 
// calling garbage collector
System.gc(); // p1 will be garbage-collected
```

The output would be:

```
Person object - John Doe -> successfully garbage collected
```

## Case 3: Object created inside the method

In the [previous post](https://platformengineer.com/java-ecosystem-java-memory-model), we understood how methods are stored inside a Stack in LIFO (Last In — First Out) order. When such a method is popped out from the Stack, all its members die and if some objects were created inside it, then these objects also become unreachable, thus eligible for GC.

```
class PersonTest {    
    static void createMale() {
        //object p1 inside method becomes unreachable after createMale() completes
        Person p1 = new Person("John Doe"); 
        createFemale();
        
        // calling garbage collector
        System.out.println("GC Call inside createMale()");
        System.gc(); // p2 will be garbage-collected
    }
 
    static void createFemale() {
        //object p2 inside method becomes unreachable after createFemale() completes
        Person p2 = new Person("Jane Doe"); 
    }
     
    public static void main(String args[]) {
        createMale();
         
        // calling garbage collector
        System.out.println("\nGC Call inside main()");
        System.gc(); // p1 will be garbage-collected
    }
}
```

The output would be:

```
GC Call inside createMale()
Person object - Jane Doe -> successfully garbage collected
 
GC Call inside main()
Person object - John Doe -> successfully garbage collected
```

## Case 4: Anonymous object

An object becomes unreachable and eligible for GC when its reference id is not assigned to a variable.

```
// create a Person object
// new operator dynamically allocates memory for an object and returns a reference to it
new Person("John Doe");
 
// object cannot be used since no variable assignment, thus it becomes eligible for gc
// calling garbage collector
System.gc(); // object will be garbage-collected
```

The output would be:

```
Person object - John Doe -> successfully garbage collected
```

## Case 5: Objects with only internal references (*Island of Isolation*)

Carefully observe how the following two objects lose their external references and become eligible for GC.

![img](https://miro.medium.com/max/38/0*XY9nzQPR3LXWWmZj?q=20)

![img](https://miro.medium.com/max/875/0*XY9nzQPR3LXWWmZj)

*Island of Isolation*

## Programmatically Calling GC

Even though an object becomes eligible for garbage collection, it won’t get immediately destroyed by the garbage collector since JVM runs GC with some time intervals. However, using any of the following methods, we can programmatically request from JVM to run garbage collector (But still there is no guarantee that any of these methods will definitely run the garbage collector. GC is solely decided by JVM).

- Using **System.gc()** method
- Using **Runtime.getRuntime().gc()** method

```
// create two Person objects
// new operator dynamically allocates memory for an object and returns a reference to it
Person p1 = new Person("John Doe");
Person p2 = new Person("Jane Doe");
 
// some meaningful work happens while p1 are p2 are in use
...
...
...
 
// p1 and p2 are no longer in use
// make p1 eligible for gc
p1 = null; 
 
// calling garbage collector
System.gc(); // p1 will be garbage-collected
 
// make p2 eligible for gc 
p2 = null; 
 
// calling garbage collector 
Runtime.getRuntime().gc(); // p2 will be garbage-collected
```

The output would be:

```
Person object - John Doe -> successfully garbage collected
Person object - Jane Doe -> successfully garbage collected
```

# GC Execution Strategies

The following JVM switch options will help you to choose a GC strategy at the JVM startup.

- **Serial GC [-XX:+UseSerialGC]** — simple mark-sweep-compact approach with young and old gen garbage collections (a.k.a. Minor GC and Major GC). Suitable for simple stand-alone client-machine applications running with low memory footprint and less CPU power.
- **Parallel GC [-XX:+UseParallelGC]** — parallel version of mark-sweep-compact approach for Minor GC with multiple threads (Major GC still happens with a single thread in a serial manner). –XX:ParallelGCThreads=n option is used to define the number of parallel threads that need to be spawned to run Minor GC (normally n=number of CPU cores)
- **Parallel Old GC [-XX:+UseParallelOldGC]** — parallel version of mark-sweep-compact approach for both Minor and Major GCs.
- **Concurrent Mark Sweep (CMS) Collector [-XX:+UseConcMarkSweepGC]** — Garbage collection normally happens with pauses (Major GC takes a long time), which makes it problematic for highly responsive applications where we can’t afford long pause times. CMS Collector minimizes the impact of these pauses by doing most of the garbage collection work (i.e. Major GC) concurrently within the application threads (Minor GC still follows the usual parallel algorithm without any concurrent progress with application threads). **–XX:ParallelCMSThreads=n** option can be used to define the number of parallel threads.
- **G1 Garbage Collector [-XX:+UseG1GC]** — Garbage First (G1) Collector divides the Heap into multiple equal-sized regions and when GC is invoked, first collects the region with lesser live data (young gen and old gen implementations don’t apply here). This collector is a parallel, concurrent and incrementally compact low-pause garbage collector which intends to replace the CMS Collector.

# Memory Leaks

Here comes the major purpose of learning how GC works. By its design, Java garbage collection is dedicated to track live objects, remove unused, and free up the Heap for future objects, which is the most important memory management mechanism in the JVM. However, programmers can screw up this automatic process by leaving a reference to an unused object, making it still reachable, hence not getting eligible for GC. Accumulation of such unused-but-still-referenced objects consumes the Heap memory inefficiently and this situation is called a memory leak.

![img](https://miro.medium.com/max/38/0*KhPovKuIHnUY3Acl?q=20)

![img](https://miro.medium.com/max/543/0*KhPovKuIHnUY3Acl)

*GC Roots with a possible Memory Leak (Image: dynatrace.com)*

Detecting this type of a logical memory leak in a large-scale application can be the worst nightmare for a developer. There are sophisticated analysis tools and methods today, but they only can highlight suspicious objects. The detection and removal of memory leaks has been always an exhaustive process and it is highly advised for developers to be very conscious when you play with object references in your code.