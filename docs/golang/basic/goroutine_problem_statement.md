## Implement simple producer/consumer problem, where producer will produce max of 10 items, but producer will produce only when consumer has consumer that item
```go
package main

import (
	"fmt"
	"strconv"
)

func runProducer(c chan int) {
   for i:=0;i<10;i++{
      c <- i
   }
   close(c)	
}

func runConsumer(c chan int, wait chan bool) {
   for i := range c {
   	fmt.Println("Received - " + strconv.Itoa(i))
   }
   wait <- false
}

func main() {
   // channel is by default blocking queue of size 1, so once producer produce anything to this channel, it has to be consumed, before producer can produce again.
   c := make(chan int)
   // wait channel is used to make main goroutine wait.
   wait := make(chan bool)
   go runProducer(c)
   go runConsumer(c, wait)
   <-wait
}

```
https://play.golang.org/p/9BsYNy31Pbx

## Suppose two goroutine is printing continuously "Hello" and "World". We have to ensure, goroutines print one after another, means output should be in order. For eg: HelloWorldHelloWorld....
```go
package main

import (
	"fmt"
	
)

func printHello(hello chan int, world chan int) {
   for i:=0;i<10;i++{
      <-hello
      fmt.Print("Hello")
      world <- i 
   }
   
}

func printWorld(hello chan int, world chan int, wait chan bool) {
   for i:=0;i<10;i++{
      <-world
      fmt.Print("World")
      hello <- i
   } 
   wait <- false
}

func main() {
   hello := make(chan int,1)
   world := make(chan int,1)
   wait := make(chan bool)
   go printHello(hello,world)
   go printWorld(hello,world, wait)
   hello <- 0
   <-wait
}
```
https://play.golang.org/p/8y8Wcz5K6xi

Another way to solve this problem is to use locks. isHello variable changes is visible, sinc we are changing it inside lock.

```go
package main

import (
	"fmt"
	"sync"
)

//One lock, two condition and one boolean
var m = sync.Mutex{}
var helloCond = sync.NewCond(&m)
var worldCond = sync.NewCond(&m)
var isHello = true


func printHello() {
   for i:=0;i<10;i++{
      m.Lock()
      for !isHello { helloCond.Wait() } 
      fmt.Print("Hello")
      isHello = false
      worldCond.Signal()
      m.Unlock() 
   }
   
}

func printWorld(wait chan bool) {
   for i:=0;i<10;i++{
      m.Lock()
      for isHello { worldCond.Wait() } 
      fmt.Print("World")
      isHello = true
      helloCond.Signal()
      m.Unlock() 
   } 
   wait <- false
}

func main() {
   wait := make(chan bool)
   go printHello()
   go printWorld(wait)
   <-wait
}

```

## Ping pong implemenation
```go
package main

import (
	"fmt"
	"time"
	
)

func print(ch chan int, name string){
	for i:=0; i<10;i++{
	    <-ch
		fmt.Println(name)
		ch <- i
	}
	
}

func main() {
   ch := make(chan int)
   go print(ch, "Ping")
   ch <- 0    
   go print(ch, "Pong")
   time.Sleep(1*time.Second)
   fmt.Println("end")

}
```

## Read Write Lock Implementation
Multiple reader allowed if no writer is present. Writer is allowed only when no reader or other writer is present
### Interface, with NewRWLock (custom init)
```go
package main

import (
	"fmt"
	"sync"
	"time"
)

type RWLock interface {
	AcquireReadLock()
	ReleaseReadLock()
	AcquireWriteLock()
	ReleaseWriteLock()
}

func NewRWLock() *rwLock {
	var l sync.Mutex
	return &rwLock{lock: &l, cond: sync.NewCond(&l)}
}

type rwLock struct {
	writer int
	reader int
	lock    *sync.Mutex
	cond    *sync.Cond
}

func (l *rwLock) AcquireReadLock() {
	l.lock.Lock()
	defer l.lock.Unlock()
	for l.writer > 0 {
		l.cond.Wait()
	}
	l.reader += 1
	fmt.Println("Count -------------------------------- ", l.reader, "  ", l.writer)
}

func (l *rwLock) ReleaseReadLock() {
	l.lock.Lock()
	defer l.lock.Unlock()
	if l.reader > 0 {
		l.reader -= 1
		if l.reader == 0 {
			l.cond.Broadcast()
		}
	}
	fmt.Println("Count -------------------------------- ", l.reader, "  ", l.writer)

}

func (l *rwLock) AcquireWriteLock() {
	l.lock.Lock()
	defer l.lock.Unlock()
	for l.writer > 0 || l.reader > 0 {
		l.cond.Wait()
	}
	l.writer += 1
	fmt.Println("Count -------------------------------- ", l.reader, "  ", l.writer)

}

func (l *rwLock) ReleaseWriteLock() {
	l.lock.Lock()
	defer l.lock.Unlock()
	l.writer -= 1
	l.cond.Broadcast()
	fmt.Println("Count -------------------------------- ", l.reader, "  ", l.writer)
}

var amount = 0

func writer(rw RWLock, n int, name string) {
	for i := 0; i <= 10; i++ {
		rw.AcquireWriteLock()
		amount = amount + n
		//fmt.Println("Writer ", name, " ", amount)
		rw.ReleaseWriteLock()
		time.Sleep(5*time.Millisecond)
	}

}

func reader(rw RWLock, name string) {
	for i := 0; i <= 10; i++ {
		rw.AcquireReadLock()
		//fmt.Println("Reader ", name, " ", amount)
		rw.ReleaseReadLock()
		//time.Sleep(2*time.Millisecond)
	}
}

func main() {
	var rw RWLock = NewRWLock()
	go reader(rw, "Reader 1")
	go reader(rw, "Reader 4")
	go writer(rw, 5, "Writer 1")
	go reader(rw, "Reader 3")
	go writer(rw, -2, "Writer 2")
	go reader(rw, "Reader 2")
	go reader(rw, "Reader 5")
	time.Sleep(5 * time.Second)
}

```

## Convert below asyncExecute to synchronous call

```go
package main

import (
	"fmt"
	"time"
)

func asyncExecute(fn func()) {
   go func(){
     time.Sleep(2 * time.Second)
     fmt.Println("Async task completed")
     fn()
   }()
}

func main() {
    asyncExecute(func(){
	fmt.Println("Callback executed")
    })
}
```

###  Solution
```go
//Change only main

func main() {
    ch := make(chan int)
    asyncExecute(func(){
	fmt.Println("Callback executed")
	ch <- 1
    })
    <-ch
}
```