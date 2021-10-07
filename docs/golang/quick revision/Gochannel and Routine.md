From the very first article of Golang tutorial series, I had mentioned about the advantages of this language which is very good concurrency management. It means that you can create a program with concurrency by using Go easily, and the program will work with high performance. In this article, I will show you how to create the programs with concurrency by using **Goroutines** and **Channels** which are the Go’s features. So, let’s do it!

![Image for post](https://miro.medium.com/max/60/1*T5jMd4XuassSyTVfGxgDjg.jpeg?q=20)

![Image for post](https://miro.medium.com/max/1800/1*T5jMd4XuassSyTVfGxgDjg.jpeg)

# Goroutines

> A *goroutine* is a lightweight thread managed by the Go runtime.

The message above is from Go official website, but if you still can’t understand it. Let you see the example below.

```go
package main

import (
  "fmt"
  "time"
)

func main() {
  go waitAndPrint("Hello")
  printAndWait("Bye")
}

func waitAndPrint(msg string) {
  time.Sleep(time.Second)
  fmt.Println(msg)
}

func printAndWait(msg string) {
  fmt.Println(msg)
  time.Sleep(2 * time.Second)
}

/*
>>> OUTPUT <<<
Bye
Hello
*/
```



As you can see, there are two functions called *waitAndPrint* which will wait for one second and display a message and *printAndWait* which will display a message before waiting for two seconds, and there is statement **go** in front of the *waitAndPrint* function to run this function on new lightweight thread which is called **goroutine**. While *printAndWait* function runs on main thread. So, instead of printing “Hello” before “Bye”, the output will be “Bye” before “Hello” because “Hello” need to wait for 2 seconds before being printed.

```go
package main

import (
  "fmt"
  "time"
)

func main() {
  go print1()
  fmt.Println("0")
  time.Sleep(2 * time.Second)
}

func print1() {
  go print2()
  fmt.Println("1")
}

func print2() {
  time.Sleep(time.Second)
  fmt.Println("2")
}

/*
>>> OUTPUT <<<
0
1
2
*/
```



A goroutine won’t be terminated, even the caller function/goroutine is already terminated. A goroutine will be terminated only if main function is already terminated, or the goroutine has already done its job. Like what happens in the example above, *print1* function which is the caller of *print2* is terminated before *print2,* but the message from *print2* is still printed.

# Channels

Now we know how to create goroutine, but it must be better if we can communicate between each goroutine or between goroutine and main thread. **Channel** is the feature that will help us do that. Let take a look at the example below.

```go
package main

import "fmt"

func main() {
  c := make(chan int)
  go print(c)
  n := <-c
  fmt.Println(n)
}

func print(c chan int) {
  c <- 10
}

/*
>>> OUTPUT <<<
10
*/
```



It’s very easy to declare channels by putting **chan** statement in front of data type. You can pass a value in form of any data type via a channel. As you can see in the example, data (10) is pass into the channel (c <- 10) and the data is received by putting an arrow in front of the channel.

Sending (c <- ) statement will be blocking until these is receiving (<- c) statement, and it also happens in the other way around.

## Buffered Channels

If you don’t want your program to be blocked by sending statement, a buffered channel is your choice.

```go
package main

import (
  "fmt"
  "time"
)

const n = 3

func main() {
  c := make(chan int)
  go sender(c)
  go receiver(c)
  time.Sleep(10 * time.Second)
}

func sender(c chan int) {
  for i := 0; i < n; i++ {
    c <- i
  }
  fmt.Println("SENDER DONE")
}

func receiver(c chan int) {
  for i := 0; i < n; i++ {
    time.Sleep(time.Millisecond)
    fmt.Println(<-c)
  }
  fmt.Println("RECEIVER DONE")
}

/*
>>> OUTPUT <<<
0
1
2
RECEIVER DONE
SENDER DONE
*/

/*
>>> OUTPUT (can be like this sometimes) <<<
0
1
RECEIVER DONE
2
SENDER DONE
*/
```



The example above is the blocking case, means that sender needs to wait for receiver to get the data out of the channel. You can see from the output the message “SENDER DONE” is printed after the receiver prints all the numbers.

```go
package main

import (
  "fmt"
  "time"
)

const n = 3

func main() {
  c := make(chan int, n)
  go sender(c)
  go receiver(c)
  time.Sleep(10 * time.Second)
}

func sender(c chan int) {
  for i := 0; i < n; i++ {
    c <- i
  }
  fmt.Println("SENDER DONE")
}

func receiver(c chan int) {
  for i := 0; i < n; i++ {
    time.Sleep(time.Millisecond)
    fmt.Println(<-c)
  }
  fmt.Println("RECEIVER DONE")
}

/*
>>> OUTPUT <<<
SENDER DONE
0
1
2
RECEIVER DONE
*/
```



The example above is almost the same as the previous one, but the different thing is that there is the second parameter in the **make** function (c := make(chan int, n)). This number is the size of buffer. The sender can keep sending data in to the buffered channel without waiting for receiver until the buffer is full. As you can see the output, the message “SENDER DONE” is the first line, it means that the sender already finished its job before the receiver starts working.

## Range and Close

```go
package main

import (
  "fmt"
  "time"
)

const n = 3

func main() {
  c := make(chan int, n)
  go sender(c)
  go receiver(c)
  time.Sleep(10 * time.Second)
}

func sender(c chan int) {
  for i := 0; i < n; i++ {
    c <- i
  }
  close(c)
  fmt.Println("SENDER DONE")
}

func receiver(c chan int) {
  for i := range c {
    time.Sleep(time.Millisecond)
    fmt.Println(i)
  }
  fmt.Println("RECEIVER DONE")
}

/*
>>> OUTPUT <<<
SENDER DONE
0
1
2
RECEIVER DONE
*/
```



We can improve the sender-receiver code by using **range** statement and **close** function with a channel. Like other iterable variable, you can use **range** with channels to iterate through them. And using **close** to inform the receiver that the channel is already closed to stop getting data from it.

## Select

```go
package main

import (
  "fmt"
  "time"
)

const n = 3

func main() {
  a := make(chan int, n)
  b := make(chan int, n)
  c := make(chan int)
  go sender(a, 0, 3)
  go sender(b, 3, 6)
  go receiver(a, b, c)
  time.Sleep(time.Millisecond)
  c <- 0
  time.Sleep(time.Second)
}

func sender(c chan int, x, y int) {
  for i := x; i < y; i++ {
    c <- i
  }
}

func receiver(a, b, c chan int) {
  ok := true
  for ok {
    select {
    case n := <-a:
      fmt.Println(n)
    case n := <-b:
      fmt.Println(n)
    case <-c:
      ok = false
    default:
      time.Sleep(time.Millisecond)
    }
  }
  fmt.Println("RECEIVER DONE")
}

/*
>>> OUTPUT (the order might be like this) <<<
0
3
4
5
1
2
RECEIVER DONE
*/
```



**Select** statement is the feature that allows you to wait for multiple channels at the same time. It works like switch-case statement, but for each case it needs to be a channel receiver statement. And there is **default** statement, you can use it if there is no data from any channel at that moment.

# Mutual Exclusion

To control the concurrency, we need to prevent multiple goroutines to access or modify any shared data at the same time.

```go
package main

import (
  "fmt"
  "time"
)

var n = 0

func main() {
  for i := 0; i < 1000; i++ {
    go increase()
  }
  time.Sleep(time.Second)
  fmt.Println(n)
}

func increase() {
  n++
}

/*
>>> OUTPUT (can be different from this but should be lower than 1000) <<<
943
*/
```



From the example, the program tries to increase *n* for 1000 times. So the result what we expected is 1000 but it’s not like that because there are multiple goroutines try to update the value at the same time, so the value they have might not be up-to-date.

```go
package main

import (
  "fmt"
  "time"
  "sync"
)

var n = 0
var lock sync.Mutex

func main() {
  for i := 0; i < 1000; i++ {
    go incrase()
  }
  time.Sleep(time.Second)
  fmt.Println(n)
}

func incrase() {
  lock.Lock()
  defer lock.Unlock()
  n++
}

/*
>>> OUTPUT <<<
1000
*/
```



And this is how to solve that problem, we can use **sync.Mutex** to prevent multiple goroutines to access the critical session which is increasing the number at the same. Anyway, you need to be careful when you are using mutex because you might face [deadlock](https://en.wikipedia.org/wiki/Deadlock) problem accidentally, and it is kind of hard to solve. Another thing you need to care about is that overusing mutex can slower you program. Instead of being concurrency, mutex can make your program runs sequentially.

And all of these features can help you to create a program with concurrency and help you to control it in Go. I hope you can see how easy it is, compare to other languages. Anyway, it still depends on how you design the concurrency in your program. If your design is good, your program will be fast and have no bugs. On the other hand, if your design is bad, I think you should know what will happen no matter what language you use. 😂