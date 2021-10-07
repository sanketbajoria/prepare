# Go
Go also known as Golang is an open source, compiled and statically typed programming language developed by Google. The key people behind the creation of Go are Rob Pike, Ken Thompson and Robert Griesemer. 

### Advantages of Go

Why would you choose Go as your server side programming language when there are tonnes of other languages such as python, ruby, nodejs... that do the same job.

Here are some of the pros which I found when choosing Go.

##### Performant
Low memory footprint and faster execution, since natively compiled.

##### Simple syntax

The syntax is simple and concise and the language is not bloated with unnecessary features. This makes it easy to write code that is readable and maintainable.

##### Easy to write concurrent programs

[Concurrency](https://golangbot.com/concurrency/) is an inherent part of the language. As a result, writing multithreaded programs is a piece of cake. This is achieved by [Goroutines](https://golangbot.com/goroutines/) and [channels](https://golangbot.com/channels/) which we will discuss in the upcoming tutorials.

##### Compiled language

Go is a compiled language. The source code is compiled to a native binary. This is missing in interpreted languages such as JavaScript used in nodejs.

##### Fast compilation

The Go compiler is pretty amazing and it has been designed to be fast right from the beginning.

##### Static linking

The Go compiler supports static linking. The entire Go project can be statically linked into one big fat binary and it can be deployed in cloud servers easily without worrying about dependencies.

##### Go Tooling

Tooling deserves a special mention in Go. Go comes bundled with powerful tools that help developers write better code. Few of the commonly used tools are,

- gofmt - [gofmt](https://golang.org/cmd/gofmt/) is used to automatically format go source code. It uses tabs for indentation and blanks for alignment.
- vet - [vet](https://golang.org/cmd/vet/) analyses the go source code and reports possible suspicious code. Everything reported by vet is not a genuine problem but it has the capability to catch errors that are not reported by the compiler such as incorrect format specifiers when using [Printf](https://golang.org/pkg/fmt/#Printf).
- golint - [golint](https://github.com/golang/lint) is used to identify styling issues in the code.

##### Garbage collection

Go uses garbage collection and hence memory management is pretty much taken care automatically and the developer doesn't need to worry about managing memory. This also helps to write concurrent programs easily.

##### Simple language specification

The language spec is pretty simple. The [entire spec](https://golang.org/ref/spec) fits in a page and you can even use it to write your own compiler :)

##### Opensource

Last but not least, Go is an open source project. You can participate and contribute to the [Go project](https://golang.org/doc/contribute.html).



#### A short explanation of the hello world program

Here is the hello world program we just wrote

```go
package main 

import "fmt" 

func main() {  
    fmt.Println("Hello World") 
}
```

We will discuss in brief what each line of the program does. We will dwell deep into each section of the program in the upcoming tutorials.

**package main** - **Every go file must start with the `package name` statement.** Packages are used to provide code compartmentalization and reusability. The package name **`main`** is used here. The main function should always reside in the main package.

**import "fmt"** - The import statement is used to import other packages. In our case, `fmt` package is imported and it will be used inside the main function to print text to the standard output.

**func main()** - The `func` keyword marks the beginning of a function. The `main` is a special function. The program execution starts from the `main` function. The `{` and `}` braces indicate the start and end of the main function.

**fmt.Println("Hello World")** - The `Println` function of the `fmt` package is used to write text to the standard output. `package.function()` is the syntax to call a function in a package.

# Lvalue and Rvalue
**lvalue**: Expressions that refer to the memory location is called “lvalue” expression. The lvalue may appear as either the left-hand or right-hand side of the assignment. Designated to a variable and not a constant.
**rvalue**: The term rvalue refers to the data value that is stored at some address in memory. The rvalue is an expression that cannot have a value assigned to it, which means an rvalue may appear on the right but not a left-hand side of the assignment. It can be a constant variable or data literal.

**By Go Convention** 

**Mandatory**

- go files in the same package AKA folder must have the same package name. **The only exception are tests that can have a _test extension in the test go file**. The rule is 1 folder , 1 package therefore the same package name for all go files in the same folder.

  **Strategy 1:**

  File name: github.com/user/myfunc.go

  ```go
  package myfunc
  ```

  Test file name: github.com/user/myfunc_test.go

  ```go
  package myfunc
  ```

  See [bzip2](http://golang.org/src/pkg/compress/bzip2/bzip2_test.go) for an example.

  **Strategy 2:**

  File name: github.com/user/myfunc.go

  ```go
  package myfunc
  ```

  Test file name: github.com/user/myfunc_test.go

  ```go
  package myfunc_test
  
  import (
      "github.com/user/myfunc"
  )
  ```

  See [wire](https://github.com/btcsuite/btcd/blob/master/wire/msgtx_test.go) for an example.

**Non Mandatory**

- **package name would match the parent directory name.** For eg: asset folder containing multiple go file will contain **package asset** in every file

