##  **AOP Concepts**

- Aspect – a standard code/feature that is scattered across multiple places in the application and is typically different than the actual Business Logic (for example, Transaction management). Each aspect focuses on a specific cross-cutting functionality
- Joinpoint – it's a particular point during execution of programs like method execution, constructor call, or field assignment
- Advice – the action taken by the aspect in a specific joinpoint
- Pointcut – a regular expression that matches a joinpoint. Each time any join point matches a pointcut, a specified advice associated with that pointcut is executed
- Weaving – the process of linking aspects with targeted objects to create an advised object

## **Spring AOP and AspectJ**

Now, let's discuss Spring AOP and AspectJ across a number of axis – such as capabilities, goals, weaving, internal structure, joinpoints, and simplicity.

### **3.1. Capabilities and Goals**

Simply put, Spring AOP and AspectJ have different goals.

Spring AOP aims to provide a simple AOP implementation across Spring IoC to solve the most common problems that programmers face. **It is not intended as a complete AOP solution** – it can only be applied to beans that are managed by a Spring container. It is based upon **JDK Proxy** (if interface is defined), otherwise **CGlib** is used

On the other hand, **AspectJ is the original AOP technology which aims to provide complete AOP solution.** It is more robust but also significantly more complicated than Spring AOP. It's also worth noting that AspectJ can be applied across all domain objects.

### **3.2. Weaving**

Both AspectJ and Spring AOP uses the different type of weaving which affects their behavior regarding performance and ease of use.

AspectJ makes use of three different types of weaving:

1. **Compile-time weaving**: The AspectJ compiler takes as input both the source code of our aspect and our application and produces a woven class files as output
2. **Post-compile weaving**: This is also known as binary weaving. It is used to weave existing class files and JAR files with our aspects
3. **Load-time weaving**: This is exactly like the former binary weaving, with a difference that weaving is postponed until a class loader loads the class files to the JVM

As AspectJ uses [compile time](https://www.baeldung.com/cs/compile-load-execution-time) and classload time weaving, **Spring AOP makes use of runtime weaving**.

With runtime weaving, the aspects are woven during the execution of the application using proxies of the targeted object – using either JDK dynamic proxy or CGLIB proxy (which are discussed in next point):

[![img](https://www.baeldung.com/wp-content/uploads/2017/10/springaop-process-300x148.png)](https://www.baeldung.com/wp-content/uploads/2017/10/springaop-process.png)

### **3.3. Internal Structure and Application**

Spring AOP is a proxy-based AOP framework. This means that to implement aspects to the target objects, it'll create proxies of that object. This is achieved using either of two ways:

1. JDK dynamic proxy – the preferred way for Spring AOP. Whenever the targeted object implements even one interface, then JDK dynamic proxy will be used
2. CGLIB proxy – if the target object doesn't implement an interface, then CGLIB proxy can be used

We can learn more about Spring AOP proxying mechanisms from [the official docs](https://docs.spring.io/spring/docs/current/spring-framework-reference/core.html#aop-proxying).

**AspectJ, on the other hand, doesn't do anything at runtime as the classes are compiled directly with aspects.**

And so unlike Spring AOP, it doesn't require any design patterns. To weave the aspects to the code, it introduces its compiler known as AspectJ compiler (ajc), through which we compile our program and then runs it by supplying a small (< 100K) runtime library.

### **3.4. Joinpoints**

In section 3.3, we showed that Spring AOP is based on proxy patterns. Because of this, it needs to subclass the targeted Java class and apply cross-cutting concerns accordingly.

But it comes with a limitation. **We cannot apply cross-cutting concerns (or aspects) across classes that are “final” because they cannot be overridden and thus it would result in a runtime exception.**

The same applies for static and final methods. Spring aspects cannot be applied to them because they cannot be overridden. Hence Spring AOP because of these limitations, only supports method execution join points.

However, **AspectJ weaves the cross-cutting concerns directly into the actual code before runtime.** Unlike Spring AOP, it doesn't require to subclass the targetted object and thus supports many others joinpoints as well. Following is the summary of supported joinpoints:

| Joinpoint                    | Spring AOP Supported | AspectJ Supported |
| ---------------------------- | -------------------- | ----------------- |
| Method Call                  | No                   | Yes               |
| Method Execution             | Yes                  | Yes               |
| Constructor Call             | No                   | Yes               |
| Constructor Execution        | No                   | Yes               |
| Static initializer execution | No                   | Yes               |
| Object initialization        | No                   | Yes               |
| Field reference              | No                   | Yes               |
| Field assignment             | No                   | Yes               |
| Handler execution            | No                   | Yes               |
| Advice execution             | No                   | Yes               |

It's also worth noting that in Spring AOP, aspects aren't applied to the method called within the same class.

That's obviously because when we call a method within the same class, then we aren't calling the method of the proxy that Spring AOP supplies. If we need this functionality, then we do have to define a separate method in different beans, or use AspectJ.

### **3.5. Simplicity**

Spring AOP is obviously simpler because it doesn't introduce any extra compiler or weaver between our build process. It uses runtime weaving, and therefore it integrates seamlessly with our usual build process. Although it looks simple, it only works with beans that are managed by Spring.

However, to use AspectJ, we're required to introduce the AspectJ compiler (ajc) and re-package all our libraries (unless we switch to post-compile or load-time weaving).

This is, of course, more complicated than the former – because it introduces AspectJ Java Tools (which include a compiler (ajc), a debugger (ajdb), a documentation generator (ajdoc), a program structure browser (ajbrowser)) which we need to integrate with either our IDE or the build tool.

### **3.6. Performance**

As far as performance is concerned, **compile-time weaving is much faster than runtime weaving**. Spring AOP is a proxy-based framework, so there is the creation of proxies at the time of application startup. Also, there are a few more method invocations per aspect, which affects the performance negatively.

On the other hand, AspectJ weaves the aspects into the main code before the application executes and thus there's no additional runtime overhead, unlike Spring AOP.

For these reasons, the [benchmarks](https://web.archive.org/web/20150520175004/https://docs.codehaus.org/display/AW/AOP+Benchmark) suggest that AspectJ is almost around 8 to 35 times faster than Spring AOP.

## **4. Summary**

This quick table summarizes the key differences between Spring AOP and AspectJ:

| Spring AOP                                                   | AspectJ                                                      |
| ------------------------------------------------------------ | ------------------------------------------------------------ |
| Implemented in pure Java                                     | Implemented using extensions of Java programming language    |
| No need for separate compilation process                     | Needs AspectJ compiler (ajc) unless LTW is set up            |
| Only runtime weaving is available                            | Runtime weaving is not available. Supports compile-time, post-compile, and load-time Weaving |
| Less Powerful – only supports method level weaving           | More Powerful – can weave fields, methods, constructors, static initializers, final class/methods, etc… |
| Can only be implemented on beans managed by Spring container | Can be implemented on all domain objects                     |
| Supports only method execution pointcuts                     | Support all pointcuts                                        |
| Proxies are created of targeted objects, and aspects are applied on these proxies | Aspects are weaved directly into code before application is executed (before runtime) |
| Much slower than AspectJ                                     | Better Performance                                           |
| Easy to learn and apply                                      | Comparatively more complicated than Spring AOP               |

## 5. AOP Proxying mechanisms

**Spring AOP uses either JDK dynamic proxies or CGLIB** to create the proxy for a given target object. (JDK dynamic proxies are preferred whenever you have a choice).

**If the target object to be proxied implements at least one interface then a JDK dynamic proxy will be used.** All of the interfaces implemented by the target type will be proxied. **If the target object does not implement any interfaces then a CGLIB proxy will be created.**

If you want to force the use of CGLIB proxying (for example, to proxy every method defined for the target object, not just those implemented by its interfaces) you can do so. However, there are some issues to consider:

- `final` methods cannot be advised, as they cannot be overriden.
- You will need the CGLIB 2 binaries on your classpath, whereas dynamic proxies are available with the JDK. Spring will automatically warn you when it needs CGLIB and the CGLIB library classes are not found on the classpath. **Spring Boot default include CGLIB as dependency. It supports both interface or without interface based AOP.**
- The constructor of your proxied object will be called twice. This is a natural consequence of the CGLIB proxy model whereby a subclass is generated for each proxied object. For each proxied instance, two objects are created: the actual proxied object and an instance of the subclass that implements the advice. This behavior is not exhibited when using JDK proxies. Usually, calling the constructor of the proxied type twice, is not an issue, as there are usually only assignments taking place and no real logic is implemented in the constructor.

To force the use of CGLIB proxies set the value of the `proxy-target-class` attribute of the `<aop:config>` element to true:

```
<aop:config proxy-target-class="true">
    <!-- other beans defined here... -->
</aop:config>
```

To force CGLIB proxying when using the @AspectJ autoproxy support, set the `'proxy-target-class'` attribute of the `<aop:aspectj-autoproxy>` element to `true`:

```
<aop:aspectj-autoproxy proxy-target-class="true"/>
```

| ![[Note]](https://docs.spring.io/spring-framework/docs/3.0.0.M3/reference/html/images/note.gif) | Note |
| ------------------------------------------------------------ | ---- |
| Multiple `<aop:config/>` sections are collapsed into a single unified auto-proxy creator at runtime, which applies the *strongest* proxy settings that any of the `<aop:config/>` sections (typically from different XML bean definition files) specified. This also applies to the `<tx:annotation-driven/>` and `<aop:aspectj-autoproxy/>` elements.To be clear: using '`proxy-target-class="true"`' on `<tx:annotation-driven/>`, `<aop:aspectj-autoproxy/>` or `<aop:config/>` elements will force the use of CGLIB proxies *for all three of them*. |      |

### 5.1 Understanding AOP proxies

Spring AOP is *proxy-based*. It is vitally important that you grasp the semantics of what that last statement actually means before you write your own aspects or use any of the Spring AOP-based aspects supplied with the Spring Framework.

Consider first the scenario where you have a plain-vanilla, un-proxied, nothing-special-about-it, straight object reference, as illustrated by the following code snippet.

```
public class SimplePojo implements Pojo {

   public void foo() {
      // this next method invocation is a direct call on the 'this' reference
      this.bar();
   }
   
   public void bar() {
      // some logic...
   }
}
```

If you invoke a method on an object reference, the method is invoked *directly* on that object reference, as can be seen below.

![img](https://docs.spring.io/spring-framework/docs/3.0.0.M3/reference/html/images/aop-proxy-plain-pojo-call.png)

```
public class Main {

   public static void main(String[] args) {
   
      Pojo pojo = new SimplePojo();
      
      // this is a direct method call on the 'pojo' reference
      pojo.foo();
   }
}
```

Things change slightly when the reference that client code has is a proxy. Consider the following diagram and code snippet.

![img](https://docs.spring.io/spring-framework/docs/3.0.0.M3/reference/html/images/aop-proxy-call.png)

```
public class Main {

   public static void main(String[] args) {
   
      ProxyFactory factory = new ProxyFactory(new SimplePojo());
      factory.addInterface(Pojo.class);
      factory.addAdvice(new RetryAdvice());

      Pojo pojo = (Pojo) factory.getProxy();
      
      // this is a method call on the proxy!
      pojo.foo();
   }
}
```

The key thing to understand here is that the client code inside the `main(..)` of the `Main` class *has a reference to the proxy*. This means that method calls on that object reference will be calls on the proxy, and as such the proxy will be able to delegate to all of the interceptors (advice) that are relevant to that particular method call. However, once the call has finally reached the target object, the `SimplePojo` reference in this case, any method calls that it may make on itself, such as `this.bar()` or `this.foo()`, are going to be invoked against the *`this`* reference, and *not* the proxy. This has important implications. **It means that self-invocation is *not* going to result in the advice associated with a method invocation getting a chance to execute.**

Okay, so what is to be done about this? The best approach (the term best is used loosely here) is to refactor your code such that the self-invocation does not happen. For sure, this does entail some work on your part, but it is the best, least-invasive approach. The next approach is absolutely horrendous, and I am almost reticent to point it out precisely because it is so horrendous. You can (choke!) totally tie the logic within your class to Spring AOP by doing this:

```
public class SimplePojo implements Pojo {

   public void foo() {
      // this works, but... gah!
      ((Pojo) AopContext.currentProxy()).bar();
   }
   
   public void bar() {
      // some logic...
   }
}
```

This totally couples your code to Spring AOP, *and* it makes the class itself aware of the fact that it is being used in an AOP context, which flies in the face of AOP. It also requires some additional configuration when the proxy is being created:

```
public class Main {

   public static void main(String[] args) {
   
      ProxyFactory factory = new ProxyFactory(new SimplePojo());
      factory.adddInterface(Pojo.class);
      factory.addAdvice(new RetryAdvice());
      factory.setExposeProxy(true);

      Pojo pojo = (Pojo) factory.getProxy();

      // this is a method call on the proxy!
      pojo.foo();
   }
}
```

Finally, **it must be noted that AspectJ does not have this self-invocation issue because it is not a proxy-based AOP framework.**