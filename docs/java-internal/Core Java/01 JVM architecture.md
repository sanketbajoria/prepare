# JVM Architecture

JVM is only a specification, and its implementation is different from vendor to vendor. For now, let’s understand the commonly-accepted architecture of JVM as defined in the specification.

![img](https://miro.medium.com/max/804/0*GMXQBZCEpGQMBjy-)

JVM Architecture

# 1) Class Loader Subsystem

The **JVM resides on the RAM**. During execution, using the Class Loader subsystem, the class files are brought on to the RAM. This is called Java’s **dynamic class loading** functionality. It loads, links, and initializes the class file (.class) when it refers to a class for the first time at runtime (not compile time).

## 1.1) Loading

Loading compiled classes (.class files) into memory is the major task of Class Loader. Usually, the class loading process starts from loading the main class (i.e. class with `static main()` method declaration). All the subsequent class loading attempts are done according to the class references in the already-running classes as mentioned in the following cases:

- When bytecode make a static reference to a class (e.g. `System.out`)
- When bytecode create a class object (e.g. `Person person = new Person("John")`)

There are 3 types of class loaders (connected with inheritance property) and they follow 4 major principles.

***1.1.1) Visibility Principle\***

This principle states that Child Class Loader can see the class loaded by Parent Class Loader, but a Parent Class Loader cannot find the class loaded by Child Class Loader.

***1.1.2) Uniqueness Principle\***

This principle states that a class loaded by parent should not be loaded by Child Class Loader again and ensure that duplicate class loading does not occur.

***1.1.3) Delegation Hierarchy Principle\***

In order to satisfy above 2 principles, JVM follows a hierarchy of delegation to choose the class loader for each class loading request. Here, starting from the lowest child level, Application Class Loader delegates the received class loading request to Extension Class Loader and then Extension Class Loader delegates the request to Bootstrap Class Loader. If the requested class found in Bootstrap path, the class is loaded. Otherwise the request again transfers back to Extension Class Loader level to find the class from Extension path or custom-specified path. If it also fails, the request comes back to Application Class Loader to find the class from System class path and if Application Class Loader also fails to load the requested class, then we get the run time exception — `java.lang.ClassNotFoundException` .

***1.1.4) No Unloading Principle\***

Even though a Class Loader can load a class, it cannot unload a loaded class. Instead of unloading, the current class loader can be deleted, and a new class loader can be created.

![img](https://miro.medium.com/max/38/0*MCf4PciEbMGwOL6L?q=20)

![img](https://miro.medium.com/max/800/0*MCf4PciEbMGwOL6L)

*Java Class Loaders — Delegation Hierarchy Principle (Image: StackOverflow.com)*

- **Bootstrap Class Loader** loads standard JDK classes from rt.jar such as core Java API classes present in the bootstrap path — $JAVA_HOME/jre/lib directory (e.g. java.lang.* package classes). It is implemented in native languages like C/C++ and acts as parent of all class loaders in Java.
- **Extension Class Loader** delegates class loading request to its parent, Bootstrap and if unsuccessful, loads classes from the extensions directories (e.g. security extension functions) in extension path — $JAVA_HOME/jre/lib/ext or any other directory specified by the java.ext.dirs system property. This Class Loader is implemented in Java by the sun.misc.Launcher$ExtClassLoader class.
- **System/Application Class Loader** loads application specific classes from system class path, that can be set while invoking a program using -cp or -classpath command line options. It internally uses Environment Variable which mapped to java.class.path. This Class Loader is implemented in Java by the sun.misc.Launcher$AppClassLoader class.

*NOTE: Apart from the 3 major Class Loaders discussed above, a programmer can directly create a* ***User-defined Class Loader\*** *on the code itself. This guarantees the independence of applications through class loader delegation model. This approach is used in web application servers like Tomcat to make web apps and enterprise solutions run independently.*

Each Class Loader has its **namespace** that stores the loaded classes. When a Class Loader loads a class, it searches the class based on **FQCN** (**Fully Qualified Class Name**) stored in the namespace to check whether or not the class has been already loaded. Even if the class has an identical FQCN but a different namespace, it is regarded as a different class. A different namespace means that the class has been loaded by another Class Loader.

## 1.2) Linking

Linking involves in verifying and preparing a loaded class or interface, its direct superclasses and superinterfaces, and its element type as necessary, while following the below properties.

- A class or interface must be completely loaded before it is linked.
- A class or interface must be completely verified and prepared before it initialized (in the next step).
- If an error occurs during linking, it is thrown at a point in the program where some action will be taken by the program that might, directly or indirectly, require linkage to the class or interface involved in the error.

Linking occurs in 3 stages as below.

- **Verification**: ensure the correctness of .class file (is the code properly written according to Java Language Specification? is it generated by a valid compiler according to JVM specifications?). This is the most complicated test process of the class load processes, and takes the longest time. Even though linking slows down the class loading process, it avoids the need to perform these checks for multiple times when executing bytecode, hence makes the overall execution efficient and effective. If verification fails, it throws runtime errors (java.lang.VerifyError). For instance, the following checks are performed.

```
- consistent and correctly formatted symbol table
- final methods / classes not overridden
- methods respect access control keywords
- methods have correct number and type of parameters
- bytecode doesn’t manipulate stack incorrectly
- variables are initialized before being read
- variables are a value of the correct type
```

- **Preparation:** allocate memory for static storage and any data structures used by the JVM such as method tables. Static fields are created and initialized to their default values, however, no initializers or code is executed at this stage as that happens as part of initialization.
- **Resolution:** replace symbolic references from the type with direct references. It is done by searching into method area to locate the referenced entity.

## 1.3) Initialization

Here, the initialization logic of each loaded class or interface will be executed (e.g. calling the constructor of a class). Since JVM is multi-threaded, initialization of a class or interface should happen very carefully with proper synchronization to avoid some other thread from trying to initialize the same class or interface at the same time (i.e. make it **thread safe**).

This is the final phase of class loading where all the static variables are assigned with their original values defined in the code and the static block will be executed (if any). This is executed line by line from top to bottom in a class and from parent to child in class hierarchy.

# 2) Runtime Data Area

Runtime Data Areas are the memory areas assigned when the JVM program runs on the OS. In addition to reading .class files, the Class Loader subsystem generates corresponding binary data and save the following information in the Method area for each class separately.

- Fully qualified name of the loaded class and its immediate parent class
- Whether .class file is related to a Class/Interface/Enum
- Modifiers, static variables, and method information etc.

Then, for every loaded .class file, it creates exactly one object of Class to represent the file in the Heap memory as defined in java.lang package. This Class object can be used to read class level information (class name, parent name, methods, variable information, static variables etc.) later in our code.

## 2.1) Method Area (Shared among Threads)

This is a shared resource (only 1 method area per JVM). All JVM threads share this same Method area, so the **access to the Method data and the process of dynamic linking must be thread safe**.

Method area stores **class level data** (including **static variables**) such as:

- Classloader reference
- Run time constant pool — Numeric constants, field references, method references, attributes; As well as the constants of each class and interface, it contains all references for methods and fields. When a method or field is referred to, the JVM searches the actual address of the method or field on the memory by using the runtime constant pool.
- Field data — Per field: name, type, modifiers, attributes
- Method data — Per method: name, return type, parameter types (in order), modifiers, attributes
- Method code — Per method: bytecodes, operand stack size, local variable size, local variable table, exception table; Per exception handler in exception table: start point, end point, PC offset for handler code, constant pool index for exception class being caught

## 2.2) Heap Area (Shared among Threads)

This is also a shared resource (only 1 heap area per JVM). Information of all **objects** and their corresponding **instance variables and arrays** are stored in the Heap area. Since the Method and Heap areas share memory for multiple threads, the **data stored in Method & Heap areas are not thread safe**. Heap area is a great target for GC.

## 2.3) Stack Area (per Thread)

This is not a shared resource. For every JVM thread, when the thread starts, a separate **runtime stack** gets created in order to store **method calls**. For every such method call, one entry will be created and added (pushed) into the top of runtime stack and such entryit is called a **Stack Frame**.

Each stack frame has the reference for local variable array, Operand stack, and runtime constant pool of a class where the method being executed belongs. The size of local variable array and Operand stack is determined while compiling. Therefore, the size of stack frame is fixed according to the method.

The frame is removed (popped) when the method returns normally or if an uncaught exception is thrown during the method invocation. Also note that if any exception occurs, each line of the stack trace (shown as a method such as printStackTrace()) expresses one stack frame. The **Stack area is thread safe** since it is not a shared resource.

![img](https://miro.medium.com/max/38/0*9GyWqgKUyoo-F2_g?q=20)

![img](https://miro.medium.com/max/471/0*9GyWqgKUyoo-F2_g)

*JVM Stack Configuration (Image: Cubrid.org)*

A Stack Frame is divided into three sub-entities:

- **Local Variable Array** — It has an index starting from 0. For a particular method, how many local variables are involved and the corresponding values are stored here. 0 is the reference of a class instance where the method belongs. From 1, the parameters sent to the method are saved. After the method parameters, the local variables of the method are saved.
- **Operand Stack** — This acts as a runtime workspace to perform any intermediate operation if there’s a requirement. Each method exchanges data between the Operand stack and the local variable array, and pushes or pops other method invoke results. The necessary size of the Operand stack space can be determined during compiling. Therefore, the size of the Operand stack can also be determined during compiling.
- **Frame Data** — All symbols related to the method are stored here. For exceptions, the catch block information will also be maintained in the frame data.

Since these are runtime stack frames, after a thread terminates, its stack frame will also be destroyed by JVM.

A stack can be a dynamic or fixed size. If a thread requires a larger stack than allowed a StackOverflowError is thrown. If a thread requires a new frame and there isn’t enough memory to allocate it then an OutOfMemoryError is thrown.

## 2.4) PC Registers (per Thread)

For each JVM thread, when the thread starts, a separate PC (Program Counter) Register gets created in order to hold the address of currently-executing instruction (memory address in the Method area). If the current method is native then the PC is undefined. Once the execution finishes, the PC register gets updated with the address of next instruction.

## 2.5) Native Method Stack (per Thread)

**There is a direct mapping between a Java thread and a native operating system thread**. After preparing all the state for a Java thread, a separate native stack also gets created in order to store native method information (often written in C/C++) invoked through JNI (Java Native Interface).

Once the native thread has been created and initialized, it invokes the run()method in the Java thread. When the run() method returns, uncaught exceptions (if any) are handled, then the native thread confirms whether the JVM needs to be terminated as a result of the thread terminating (i.e. is it the last non-deamon thread). When the thread terminates, all resources for both the native and Java threads are released.

The native thread is reclaimed once the Java thread terminates. The operating system is therefore responsible for scheduling all threads and dispatching them to any available CPU.

# 3) Execution Engine

The actual execution of the bytecode occurs here. Execution Engine executes the instructions in the bytecode line-by-line by reading the data assigned to above runtime data areas.

## 3.1) Interpreter

The interpreter interprets the bytecode and executes the instructions one-by-one. Hence, it can interpret one bytecode line quickly, but executing the interpreted result is a slower task. The disadvantage is that when one method is called multiple times, each time a new interpretation and a slower execution are required.

## 3.2) Just-In-Time (JIT) Compiler

If only the interpreter is available, when one method is called multiple times, each time the interpretation will also occur, which is a redundant operation if handled efficiently. This has become possible with JIT compiler. First, it compiles the entire bytecode to native code (machine code). Then for repeated method calls, it directly provides the native code and the execution using native code is much faster than interpreting instructions one by one. The native code is stored in the cache, thus the compiled code can be executed quicker.

However, even for JIT compiler, it takes more time for compiling than for the interpreter to interpret. For a code segment that executes just once, it is better to interpret it instead of compiling. Also the native code is stored in the cache, which is an expensive resource. With these circumstances, JIT compiler internally checks the frequency of each method call and decides to compile each only when the selected method has occurred more than a certain level of times. This idea of **adaptive compiling** has been used in Oracle Hotspot VMs.

Execution Engine qualifies to become a key subsystem when introducing performance optimizations by JVM vendors. Among such efforts, the following 4 components can largely improve its performance.

- **Intermediate Code Generator** produces **intermediate code**.
- **Code Optimizer** is responsible for optimizing the intermediate code generated above.
- **Target Code Generator** is responsible for generating **Native Code** (i.e. **Machine Code**).
- **Profiler** is a special component, responsible for finding performance bottlenecks a.k.a. **hotspots** (e.g. instances where one method is called multiple times)

## Vendor Approaches for Compiling Optimizations

***Oracle Hotspot VMs\***

Oracle has 2 implementations of their standard Java VMs with a popular JIT compiler model called **Hotspot Compiler**. Through **profiling**, it can identify the hotspots that require JIT compiling the most and then compile those performance critical portions of the code to native code. Over time, if such compiled method is no longer frequently invoked, it identifies the method as no longer a hotspot and quickly removes the native code from the cache and starts running in interpreter mode. This methodology creates a boost in performance , while avoiding unnecessary compilation of seldom used code. Additionally, on the fly, the Hotspot Compiler decides how best to optimize compiled code with techniques such as in lining. The run time analysis performed by the compiler allows it to eliminate guesswork in determining which optimizations will yield the largest performance benefit.

These VMs use an identical runtime (interpreter, memory, threads), but custom built implementations of the JIT compiler as mentioned below.

- **Oracle Java Hotspot Client VM** is the default VM technology for Oracle JDK and JRE. It is tuned for best performance when running applications in a client environment by reducing application start up time and memory footprint.
- **Oracle Java Hotspot Server VM** is designed for maximum program execution speed for applications running in a server environment. The JIT compiler used here is called Advanced Dynamic Optimizing Compiler and uses more complex and diverse performance optimization techniques. The Java HotSpot Server VM is invoked by using the server command line option (e.g. java server MyApp)

The Oracle’s Java Hotspot technology is famous for its rapid memory allocation, fast and efficient GC, and readily-scalable thread-handling capability in large shared memory multiprocessor servers.

***IBM AOT (Ahead-Of-Time) Compiling\***

The specialty here is that these JVMs share the native code compiled through the shared cache, thus the code that has been already compiled through the AOT compiler can be used by another JVM without compiling. In addition, IBM JVM provides a fast way of execution by pre-compiling code to JXE (Java Executable) file format using the AOT compiler.

## 3.3) Garbage Collector (GC)

As long as an object is being referenced, the JVM considers it alive. Once an object is no longer referenced and therefore is not reachable by the application code, the garbage collector removes it and reclaims the unused memory. In general, garbage collection happens under the hood, however we can trigger it by calling System.gc() method (Again the execution is not guaranteed. Hence, call Thread.sleep(1000) and wait for GC to complete).

# 4) Java Native Interface (JNI)

This interface is used to interact with Native Method Libraries required for the execution and provide the capabilities of such Native Libraries (often written in C/C++). This enables JVM to call C/C++ libraries and to be called by C/C++ libraries which may be specific to hardware.

# 5) Native Method Libraries

This is a collection of C/C++ Native Libraries which is required for the Execution Engine and can be accessed through the provided Native Interface.

# JVM Threads

We discussed on how a Java program gets executed, but didn’t specifically mention about the executors. Actually to perform each task we discussed earlier, the JVM concurrently runs multiple threads. Some of these threads carry the programming logic and are created by the program (**application threads**), while the rest is created by JVM itself to undertake background tasks in the system (**system threads**).

The major application thread is the **main thread** which is created as part of invoking public static void main(String[]) and all other application threads are created by this main thread. Application threads perform tasks such as executing instructions starting with main() method, creating objects in Heap area if it finds new keyword in any method logic etc.

The major system threads are as follows.

- **Compiler threads**: At runtime, compilation of bytecode to native code is undertaken by these threads.
- **GC threads**: All the GC related activities are carried out by these threads.
- **Periodic task thread**: The timer events (i.e. interrupts) to schedule execution of periodic operations are performed by this thread.
- **Signal dispatcher thread**: This thread receives signals sent to the JVM process and handle them inside the JVM by calling the appropriate JVM methods.
- **VM thread**: As a pre-condition, some operations need the JVM to arrive at a safe point where modifications to the Heap area does no longer happen. Examples for such scenarios are “stop-the-world” garbage collections, thread stack dumps, thread suspension and biased locking revocation. These operations can be performed on a special thread called VM thread.

# Some Pointers for Understanding

- Java is considered as both interpreted and compiled Language.
- By design, Java is slow due to dynamic linking and run-time interpreting.
- JIT compiler compensate for the disadvantages of the interpreter for repeating operations by keeping a native code instead of bytecode.
- The latest Java versions address performance bottlenecks in its original architecture.
- JVM is only a specification. Vendors are free to customize, innovate, and improve its performance during the implementation.