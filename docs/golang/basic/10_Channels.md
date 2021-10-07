# Channels
Channels are the pipes, which help goroutines to send and receive messages, with each other.

## Two type of Channels
- **Unbuffered channels**: In this type of channels, the sender does wait for the receiver to receive the message. So, by default, sends and receives block, until the sender and receiver are ready. So, we can assume this channel with zero capacity
```go
// Unbuffered channels
messages := make(chan string)
//Sending a Hello message from another goroutine
go func() { messages <- "Hello" }()
//Receiving message in main goroutine.
fmt.Println(<-messages) //Hello
```
- **Buffered channels**: This channel, do have limited capacity as defined. So, Sender will only get block, once the capacity has been filled, and we try to send new item. And, receiver will get block, if there is no item in the channel.
```go
// Buffered channels with capacity 1
messages := make(chan string, 1)
messages <- "Hello"
fmt.Println(<-messages) //Hello
```
Above example we can send and receive on same goroutine since both sender and receiver doesn't get block.

## Deadlock all goroutines are asleep
if sender is blocked and there is no receiver to consume the message, then it will result in deadlock. Similarly if receiver is block, and there is no sender to send the message, then also deadlock.
```go
// Unbuffered channels deadlock
messages := make(chan string)
<-messages //Deadlock since there is no sender to send the message
// if we also write below sending message, still deadlock, since below line won't get executed, so no sender.
messages <- "Hello"
```
```go
// Buffered channels deadlock
messages := make(chan string, 1)
messages <- "Hello"
messages <- "World" //Deadlock since channel is over capacity, and sender is blocked to send new message, and there is no receiver avaible.

fmt.Println(<-messages) //still deadlock, since this line not executed.
```
## Use cases
Apart from sending and receiving messages, Channel can be used for 
- **synchronization**: To synchronize goroutines.
```go
func worker(done chan bool) {
    fmt.Print("working...")
    time.Sleep(time.Second)
    fmt.Println("done")
    done <- true
}
func main() {
    done := make(chan bool)
    go worker(done)
    <-done
}
```
- **semaphore**: To limit the number of goroutines running at a time.
```go
type empty {}
type semaphore chan empty
sem = make(semaphore, N)
// acquire n resources
func (s semaphore) Acquire(n int) {
    e := empty{}
    for i := 0; i < n; i++ {
        s <- e
    }
}
// release n resources
func (s semaphore) Release(n int) {
    for i := 0; i < n; i++ {
        <-s
    }
}
```
As a sidenote, we do Semaphore package in Go
https://pkg.go.dev/golang.org/x/sync/semaphore

## Select
The select statement lets a goroutine wait on multiple communication operations.

A select blocks until one of its cases can run, then it executes that case. It chooses one at random if multiple are ready.

```go
package main

import "fmt"

func fibonacci(c, quit chan int) {
	x, y := 0, 1
	for {
		select {
		case c <- x:
			x, y = y, x+y
		case <-quit:
			fmt.Println("quit")
			return
		}
	}
}

func main() {
	c := make(chan int)
	quit := make(chan int)
	go func() {
		for i := 0; i < 10; i++ {
			fmt.Println(<-c)
		}
		quit <- 0
	}()
	fibonacci(c, quit)
}

```

With default statement in select, it become none blocking.
```go
func main() {
	c := make(chan int)
	var m int;
	select {
		case m = <- c:
			fmt.Println("Received message")
		default:
			fmt.Println("No message received")
	}
	
	select {
		case c <- m:
			fmt.Println("Send message")
		default:
			fmt.Println("No message send")
	}
}
//output
//No message received
//No message send
```