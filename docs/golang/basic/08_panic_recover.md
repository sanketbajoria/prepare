### What is Panic?

The idiomatic way of handling abnormal conditions in a Go program is using [errors](https://golangbot.com/error-handling/). Errors are sufficient for most of the abnormal conditions arising in the program.

**But there are some situations where the program cannot continue execution after an abnormal condition. In this case, we use `panic` to prematurely terminate the program. When a [function](https://golangbot.com/functions/) encounters a panic, its execution is stopped, any [deferred](https://golangbot.com/defer/) functions are executed and then the control returns to its caller. This process continues until all the functions of the current [goroutine](https://golangbot.com/goroutines/) have returned at which point the program prints the panic message, followed by the stack trace and then terminates.** This concept will be more clear when we write an example program.

**It is possible to regain control of a panicking program using `recover`** which we will discuss later in this tutorial.

panic and recover can be considered similar to try-catch-finally idiom in other languages such as Java except that they are rarely used in Go.

### When Should Panic Be Used?

One important factor is that you should avoid panic and recover and use [errors](https://golangbot.com/error-handling/) where ever possible. Only in cases where the program just cannot continue execution should panic and recover mechanism be used.

There are two valid use cases for panic.

1. **An unrecoverable error where the program cannot simply continue its execution.**
   One example is a web server that fails to bind to the required port. In this case, it's reasonable to panic as there is nothing else to do if the port binding itself fails. Or maybe expected environment variable is not present, which help in functioning of web server.
2. **A programmer error.(passing wrong type)**
   Let's say we have a [method](https://golangbot.com/methods/) that accepts a pointer as a parameter and someone calls this method using a `nil` argument. In this case, we can panic as it's a programmer error to call a method with `nil` argument which was expecting a valid pointer.

### Panic Example

The signature of the built-in `panic` function is provided below,

```go
func panic(interface{})  
```

The argument passed to the panic function will be printed when the program terminates. The use of this will be clear when we write a sample program. So let's do that right away.

We will start with a contrived example which shows how panic works.

```go
package main

import (  
    "fmt"
)

func fullName(firstName *string, lastName *string) {  
    if firstName == nil {
        panic("runtime error: first name cannot be nil")
    }
    if lastName == nil {
        panic("runtime error: last name cannot be nil")
    }
    fmt.Printf("%s %s\n", *firstName, *lastName)
    fmt.Println("returned normally from fullName")
}

func main() {  
    firstName := "Elon"
    fullName(&firstName, nil)
    fmt.Println("returned normally from main")
}
```

The above is a simple program to print the full name of a person. The `fullName` function in line no. 7 prints the full name of a person. This function checks whether the firstName and lastName pointers are `nil` in line nos. 8 and 11 respectively. If it is `nil` the function calls `panic` with a corresponding message. This message will be printed when the program terminates.

Running this program will print the following output,

```
panic: runtime error: last name cannot be nil

goroutine 1 [running]:  
main.fullName(0xc00006af58, 0x0)  
    /tmp/sandbox210590465/prog.go:12 +0x193
main.main()  
    /tmp/sandbox210590465/prog.go:20 +0x4d
```

Let's analyze this output to understand how panic works and how the stack trace is printed when the program panics.

In line no. 19 we assign `Elon` to `firstName`. We call `fullName` function with `lastName` as `nil` in line no. 20. Hence the condition in line no. 11 will be satisfied and the program will panic. When panic is encountered, the program execution terminates, the argument passed to the panic function is printed followed by the stack trace. Since the program terminates following the panic function call in line no. 12, the code in line nos. 13, 14, and 15 will not be executed.

This program first prints the message passed to the `panic` function,

```
panic: runtime error: last name cannot be nil  
```

and then prints the stack trace.

The program panicked in line no. 12 of `fullName` function and hence,

```
goroutine 1 [running]:  
main.fullName(0xc00006af58, 0x0)  
    /tmp/sandbox210590465/prog.go:12 +0x193
```

will be printed first. Then the next item in the stack will be printed. In our case, line no. 20 where the `fullName` is called is the next item in the stack trace. Hence it is printed next.

```
main.main()  
    /tmp/sandbox210590465/prog.go:20 +0x4d
```

Now we have reached the top level function which caused the panic and there are no more levels above, hence there is nothing more to print.

### One More Example

Panics can also be caused by errors that happen during the runtime such as trying to access an index that is not present in a slice.

Let's write a contrived example which creates a panic due to out of bounds slice access.

```go
package main

import (  
    "fmt"
)

func slicePanic() {  
    n := []int{5, 7, 4}
    fmt.Println(n[4])
    fmt.Println("normally returned from a")
}
func main() {  
    slicePanic()
    fmt.Println("normally returned from main")
}
```

[Run in playground](https://play.golang.org/p/__PAabvchxt)

In the program above, in line no. 9 we are trying to access `n[4]` which is an invalid index in the [slice](https://golangbot.com/arrays-and-slices/#slices). This program will panic with the following output,

```
panic: runtime error: index out of range [4] with length 3

goroutine 1 [running]:  
main.slicePanic()  
    /tmp/sandbox942516049/prog.go:9 +0x1d
main.main()  
    /tmp/sandbox942516049/prog.go:13 +0x22
```

### Defer Calls During a Panic

Let's recollect what panic does. **When a function encounters a panic, its execution is stopped, any deferred functions are executed and then the control returns to its caller. This process continues until all the functions of the current goroutine have returned at which point the program prints the panic message, followed by the stack trace and then terminates.**

In the example above, we did not defer any function calls. If a deferred function call is present, it is executed and then the control returns to its caller.

Let's modify the example above a little and use a defer statement.

```go
package main

import (  
    "fmt"
)

func fullName(firstName *string, lastName *string) {  
    defer fmt.Println("deferred call in fullName")
    if firstName == nil {
        panic("runtime error: first name cannot be nil")
    }
    if lastName == nil {
        panic("runtime error: last name cannot be nil")
    }
    fmt.Printf("%s %s\n", *firstName, *lastName)
    fmt.Println("returned normally from fullName")
}

func main() {  
    defer fmt.Println("deferred call in main")
    firstName := "Elon"
    fullName(&firstName, nil)
    fmt.Println("returned normally from main")
}
```

[Run in playground](https://play.golang.org/p/oUFnu-uTmC)

The only changes made are the addition of the deferred function calls in line nos. 8 and 20.

This program prints,

```
deferred call in fullName  
deferred call in main  
panic: runtime error: last name cannot be nil

goroutine 1 [running]:  
main.fullName(0xc00006af28, 0x0)  
    /tmp/sandbox451943841/prog.go:13 +0x23f
main.main()  
    /tmp/sandbox451943841/prog.go:22 +0xc6
```

When the program panics in line no. 13, any deferred function calls are first executed and then the control returns to the caller whose deferred calls are executed and so on until the top level caller is reached.

In our case, `defer` statement in line no. 8 of `fullName` function is executed first. This prints the following message.

```
deferred call in fullName  
```

And then the control returns to the `main` function whose deferred calls are executed and hence this prints,

```
deferred call in main  
```

Now the control has reached the top level function and hence the program prints the panic message followed by the stack trace and then terminates.

### Recovering from a Panic

*recover* is a builtin function that is used to regain control of a panicking program.

The signature of recover function is provided below,

```go
func recover() interface{}  
```

Recover is useful only when called inside deferred functions. Executing a call to recover inside a deferred function stops the panicking sequence by restoring normal execution and retrieves the error message passed to the panic function call. If recover is called outside the deferred function, it will not stop a panicking sequence.

Let's modify our program and use recover to restore normal execution after a panic.

```go
package main

import (  
    "fmt"
)

func recoverFullName() {  
    if r := recover(); r!= nil {
        fmt.Println("recovered from ", r)
    }
}

func fullName(firstName *string, lastName *string) {  
    defer recoverFullName()
    if firstName == nil {
        panic("runtime error: first name cannot be nil")
    }
    if lastName == nil {
        panic("runtime error: last name cannot be nil")
    }
    fmt.Printf("%s %s\n", *firstName, *lastName)
    fmt.Println("returned normally from fullName")
}

func main() {  
    defer fmt.Println("deferred call in main")
    firstName := "Elon"
    fullName(&firstName, nil)
    fmt.Println("returned normally from main")
}
```

[Run in playground](https://play.golang.org/p/enCM-dd5DUr)

The `recoverFullName()` function in line no. 7 calls `recover()` which returns the value passed to `panic` function call. Here we are just printing the value returned by recover in line no. 9. `recoverFullName()` is being deferred in line no. 14 of the `fullName` function.

When `fullName` panics, the deferred function `recoverName()` will be called which uses `recover()` to stop the panicking sequence.

This program will print,

```
recovered from  runtime error: last name cannot be nil  
returned normally from main  
deferred call in main  
```

When the program panics in line no. 19, the deferred `recoverFullName` function is called which in turn calls `recover()` to regain control of the panicking sequence. The call to `recover()` in line no. 8 returns the argument passed to `panic()` and hence it prints,

```
recovered from  runtime error: last name cannot be nil  
```

After execution of `recover()`, the panicking stops and the control returns to the caller, in this case, the `main` function. The program continues to execute normally from line 29 in `main` since the panic has been recovered 😃. It prints `returned normally from main` followed by `deferred call in main`

Let's look at one more example where we recover from a panic caused by accessing an invalid index of a slice.

```go
package main

import (  
    "fmt"
)

func recoverInvalidAccess() {  
    if r := recover(); r != nil {
        fmt.Println("Recovered", r)
    }
}

func invalidSliceAccess() {  
    defer recoverInvalidAccess()
    n := []int{5, 7, 4}
    fmt.Println(n[4])
    fmt.Println("normally returned from a")
}

func main() {  
    invalidSliceAccess()
    fmt.Println("normally returned from main")
}
```

Running the above program will output,

```
Recovered runtime error: index out of range [4] with length 3  
normally returned from main  
```

From the output, you can understand that we have recovered from the panic.

### Getting Stack Trace after Recover

If we recover from a panic, we lose the stack trace about the panic. Even in the program above after recovery, we lost the stack trace.

There is a way to print the stack trace using the [PrintStack](https://golang.org/pkg/runtime/debug/#PrintStack) function of the Debug [package](https://golangbot.com/go-packages/)

```go
package main

import (  
    "fmt"
    "runtime/debug"
)

func recoverFullName() {  
    if r := recover(); r != nil {
        fmt.Println("recovered from ", r)
        debug.PrintStack()
    }
}

func fullName(firstName *string, lastName *string) {  
    defer recoverFullName()
    if firstName == nil {
        panic("runtime error: first name cannot be nil")
    }
    if lastName == nil {
        panic("runtime error: last name cannot be nil")
    }
    fmt.Printf("%s %s\n", *firstName, *lastName)
    fmt.Println("returned normally from fullName")
}

func main() {  
    defer fmt.Println("deferred call in main")
    firstName := "Elon"
    fullName(&firstName, nil)
    fmt.Println("returned normally from main")
}
```

In the program above, we use `debug.PrintStack()` in line no.11 to print the stack trace.

This program will print,

```
recovered from  runtime error: last name cannot be nil  
goroutine 1 [running]:  
runtime/debug.Stack(0x37, 0x0, 0x0)  
    /usr/local/go-faketime/src/runtime/debug/stack.go:24 +0x9d
runtime/debug.PrintStack()  
    /usr/local/go-faketime/src/runtime/debug/stack.go:16 +0x22
main.recoverFullName()  
    /tmp/sandbox771195810/prog.go:11 +0xb4
panic(0x4a1b60, 0x4dc300)  
    /usr/local/go-faketime/src/runtime/panic.go:969 +0x166
main.fullName(0xc0000a2f28, 0x0)  
    /tmp/sandbox771195810/prog.go:21 +0x1cb
main.main()  
    /tmp/sandbox771195810/prog.go:30 +0xc6
returned normally from main  
deferred call in main  
```

From the output, you can understand that the panic is recovered and `recovered from runtime error: last name cannot be nil` is printed. Following that, the stack trace is printed. Then

```
returned normally from main  
deferred call in main  
```

is printed after the panic has recovered.

### Panic, Recover and Goroutines

Recover works only when it is called from the same [goroutine](https://golangbot.com/goroutines/) which is panicking. **It's not possible to recover from a panic that has happened in a different goroutine.** Let's understand this using an example.

```go
package main

import (  
    "fmt"
)

func recovery() {  
    if r := recover(); r != nil {
        fmt.Println("recovered:", r)
    }
}

func sum(a int, b int) {  
    defer recovery()
    fmt.Printf("%d + %d = %d\n", a, b, a+b)
    done := make(chan bool)
    go divide(a, b, done)
    <-done
}

func divide(a int, b int, done chan bool) {  
    fmt.Printf("%d / %d = %d", a, b, a/b)
    done <- true

}

func main() {  
    sum(5, 0)
    fmt.Println("normally returned from main")
}
```

In the program above, the function `divide()` will panic in line no. 22 since b is zero and it is not possible to divide a number by zero. The `sum()` function calls a deferred function `recovery()` which is used to recover from panic. The function `divide()` is called as a separate goroutine in line no. 17. We wait on the `done` [channel](https://golangbot.com/channels) in line no. 18 to ensure that `divide()` completes execution.

What do you think will be the output of the program. Will the panic be recovered? The answer is no. The panic will not be recovered. This is because the `recovery` function is present in the different goroutine and the panic is happening in the `divide()` function in a different goroutine. Hence recovery is not possible.

Running this program will print,

```
5 + 0 = 5  
panic: runtime error: integer divide by zero

goroutine 18 [running]:  
main.divide(0x5, 0x0, 0xc0000a2000)  
    /tmp/sandbox877118715/prog.go:22 +0x167
created by main.sum  
    /tmp/sandbox877118715/prog.go:17 +0x1a9
```

You can see from the output that the recovery has not happened.

If the `divide()` function is called in the same goroutine, we would have recovered from the panic.

If line no. 17 of the program is changed from

```go
go divide(a, b, done)  
```

to

```go
divide(a, b, done)  
```

the recovery will happen since the panic is happening in the same goroutine. If the program is run with the above change, it will print

```
5 + 0 = 5  
recovered: runtime error: integer divide by zero  
normally returned from main  
```

This brings us to the end of this tutorial.