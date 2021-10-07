[ Home](https://howtodoinjava.com/) / [Spring Core](https://howtodoinjava.com/spring-core/) / Spring – Bean Life Cycle

# Spring Bean 

 A Spring bean is **an object that is instantiated, assembled, and otherwise managed by a** Spring IoC container.

The most common way to define a Spring bean is using the `@Component` annotation:

```java
@Component
class MySpringBean {
  ...
}
```

If Spring’s component scanning is enabled, an object of `MySpringBean` will be added to the application context.

Another way is using Spring’s Java config:

```java
@Configuration
class MySpringConfiguration {

  @Bean
  public MySpringBean mySpringBean() {
    return new MySpringBean();
  }

}
```

## Lifecycle

![Spring Bean Life Cycle Tutorial](https://www.concretepage.com/spring/images/spring-bean-life-cycle-tutorial.jpg)



A bean life cycle includes the following steps.
- **1.** Within IoC container, a spring bean is created using class **constructor**.
- **2.** Now the dependency injection is performed using setter method.
- **3.** Once the dependency injection is completed, `BeanNameAware.setBeanName()` is called. It sets the name of bean in the bean factory that created this bean.
- **4.** Now **BeanClassLoaderAware.setBeanClassLoader()** is called that supplies the bean class loader to a bean instance.
- **5.** Now **BeanFactoryAware.setBeanFactory()** and then **ApplicationContext.setBeanFactory()** is called that provides the owning factory to a bean instance. We can use **getBean** API, to get reference of object and set any property.
- **6.** Now the IoC container calls `BeanPostProcessor.postProcessBeforeInitialization` on the bean. Using this method a wrapper can be applied on original bean. **BeanPostProcessor get called for every bean**
- **7.** Now the method annotated with `@PostConstruct` is called.
- **8.** After `@PostConstruct`, the method `InitializingBean.afterPropertiesSet()` is called.
- **9.** Now the method specified by `init-method` attribute of bean in XML configuration is called.
- **10.** And then `BeanPostProcessor.postProcessAfterInitialization()` is called. It can also be used to apply wrapper on original bean.
- **11.** Now the bean instance is ready to be used. Perform the task using the bean.
- **12.** Now when the `ApplicationContext` shuts down such as by using `registerShutdownHook()` then the method annotated with `@PreDestroy` is called.
- **13.** After that `DisposableBean.destroy()` method is called on the bean.
- **14.** Now the method specified by `destroy-method` attribute of bean in XML configuration is called.
- **15.** Before garbage collection, `finalize()` method of `Object` is called.

For example: It will showcase lifecycle of spring bean.

**Book.java**

```java
package com.concretepage;
import javax.annotation.PostConstruct;
import javax.annotation.PreDestroy;
import org.springframework.beans.BeansException;
import org.springframework.beans.factory.BeanClassLoaderAware;
import org.springframework.beans.factory.BeanFactory;
import org.springframework.beans.factory.BeanFactoryAware;
import org.springframework.beans.factory.BeanNameAware;
import org.springframework.beans.factory.DisposableBean;
import org.springframework.beans.factory.InitializingBean;
public class Book implements  InitializingBean, DisposableBean, BeanFactoryAware, BeanNameAware, BeanClassLoaderAware {
	private String bookName;
	private Book() {
		System.out.println("---inside constructor---");
	}
	@Override
	public void setBeanClassLoader(ClassLoader classLoader) {
	       System.out.println("---BeanClassLoaderAware.setBeanClassLoader---");
	}	
	@Override
	public void setBeanName(String name) {
   	       System.out.println("---BeanNameAware.setBeanName---");
	}	
	public void myPostConstruct() {
	    	 System.out.println("---init-method---");
	}	
	@PostConstruct
	public void springPostConstruct() {
	    	 System.out.println("---@PostConstruct---");
	}
	@Override
	public void setBeanFactory(BeanFactory beanFactory) throws BeansException {
		System.out.println("---BeanFactoryAware.setBeanFactory---");
	}	
	@Override
	public void afterPropertiesSet() throws Exception {
		System.out.println("---InitializingBean.afterPropertiesSet---");
	}	
	public String getBookName() {
		return bookName;
	}
	public void setBookName(String bookName) {
		this.bookName = bookName;
		System.out.println("setBookName: Book name has set.");		
	}
	public void myPreDestroy() {
		System.out.println("---destroy-method---");
	}
	@PreDestroy
	public void springPreDestroy() {
		System.out.println("---@PreDestroy---");
	}
	@Override
	public void destroy() throws Exception {
		System.out.println("---DisposableBean.destroy---");
	}
	@Override
	protected void finalize() {
		System.out.println("---inside finalize---");
	}
} 
```

**MyBeanPostProcessor.java**

```java
package com.concretepage;
import org.springframework.beans.BeansException;
import org.springframework.beans.factory.config.BeanPostProcessor;
public class MyBeanPostProcessor implements BeanPostProcessor {
	@Override
	public Object postProcessAfterInitialization(Object bean, String beanName)
			throws BeansException {
		System.out.println("BeanPostProcessor.postProcessAfterInitialization");
		return bean;
	}
	@Override
	public Object postProcessBeforeInitialization(Object bean, String beanName)
			throws BeansException {
		System.out.println("BeanPostProcessor.postProcessBeforeInitialization");
		return bean;
	}
} 
```

**spring-config.xml**

```xml
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:context="http://www.springframework.org/schema/context"
    xsi:schemaLocation="http://www.springframework.org/schema/beans
        http://www.springframework.org/schema/beans/spring-beans.xsd
        http://www.springframework.org/schema/context
        http://www.springframework.org/schema/context/spring-context.xsd">
    <context:component-scan base-package="com.concretepage"/>
    <bean id="book" class="com.concretepage.Book" init-method="myPostConstruct"
             destroy-method="myPreDestroy">
      <property name="bookName" value="Mahabharat"/>
    </bean>
    <bean class="com.concretepage.MyBeanPostProcessor"/>
</beans> 
```

**SpringDemo.java**

```java
package com.concretepage;
import org.springframework.context.support.AbstractApplicationContext;
import org.springframework.context.support.ClassPathXmlApplicationContext;
public class SpringDemo {
	public static void main(String[] args) {
		AbstractApplicationContext context = new ClassPathXmlApplicationContext("spring-config.xml");
		Book book = (Book)context.getBean("book");
		System.out.println("Book Name:"+ book.getBookName());
	        context.registerShutdownHook();
	}
} 
```

**Output**

```
---inside constructor---
setBookName: Book name has set.
---BeanNameAware.setBeanName---
---BeanClassLoaderAware.setBeanClassLoader---
---BeanFactoryAware.setBeanFactory---
BeanPostProcessor.postProcessBeforeInitialization
---@PostConstruct---
---InitializingBean.afterPropertiesSet---
---init-method---
BeanPostProcessor.postProcessAfterInitialization
Book Name:Mahabharat
---@PreDestroy---
---DisposableBean.destroy---
---destroy-method--- 
```

## Bean Scope

- **singleton**: When we define a bean with the *singleton* scope, the container creates a single instance of that bean; all requests for that bean name will return the same object

  ```java
  @Bean
  @Scope("singleton") //or @Scope(value = ConfigurableBeanFactory.SCOPE_SINGLETON)
  public Person personSingleton() {
      return new Person();
  }
  ```

  

- **prototype**: A bean with the *prototype* scope will return a different instance every time it is requested from the container. 

  ```java
  @Bean
  @Scope("prototype") //or @Scope(value = ConfigurableBeanFactory.SCOPE_PROTOTYPE)
  public Person personPrototype() {
      return new Person();
  }
  ```

  Below scopes are **Web Aware Scopes**

- **request**: A single instance will be created and available during complete lifecycle of an HTTP request.

  ```java
  @Bean
  @RequestScope //or @Scope(value = WebApplicationContext.SCOPE_REQUEST, proxyMode = ScopedProxyMode.TARGET_CLASS)
  public HelloMessageGenerator requestScopedBean() {
      return new HelloMessageGenerator();
  }
  ```

- **session**: A single instance will be created and available during complete lifecycle of an HTTP Session.

  ```java
  @Bean
  @SessionScope // or @Scope(value = WebApplicationContext.SCOPE_SESSION, proxyMode = ScopedProxyMode.TARGET_CLASS)
  public HelloMessageGenerator sessionScopedBean() {
      return new HelloMessageGenerator();
  }
  ```

  

- **application**: In `application` scope, container creates one instance per web application runtime. It is almost similar to `singleton` scope, with only two differences i.e.****

  1. `application` scoped bean is singleton per `ServletContext`, whereas `singleton` scoped bean is singleton per `ApplicationContext`. Please note that there can be multiple application contexts for single application.
  2. `application` scoped bean is visible as a `ServletContext` attribute.

  Java config example of application bean scope –

  ```java
  @Component
  @Scope("application") // or @ApplicationScope or @Scope(
   // value = WebApplicationContext.SCOPE_APPLICATION, proxyMode = ScopedProxyMode.TARGET_CLASS)
  public class BeanClass {
  }
  ```

- **websocket**: *WebSocket* scoped beans are stored in the *WebSocket* session attributes. The same instance of the bean is then returned whenever that bean is accessed during the entire *WebSocket* session.

  ```java
  @Bean
  @Scope(scopeName = "websocket", proxyMode = ScopedProxyMode.TARGET_CLASS)
  public HelloMessageGenerator websocketScopedBean() {
      return new HelloMessageGenerator();
  }
  ```

  

  **Why do we need** `**proxyMode = ScopedProxyMode.TARGET_CLASS**` **?**

  Because, the bean has `request` scope. That means an instance of the bean won’t be created until there is a request. But the classes `auto-wire` this bean (like *Controller* in our case) gets instantiated on the Web Application startup. Spring then creates a Proxy instance and inject in the controller. When the controller receives a request the proxy instance is replaced with actual one