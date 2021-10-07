Nowadays there are so many popular programming languages that are used to build services and systems such as Node.js, PHP, and Python. And all of them have their advantages and disadvantages, so it depends on what a programmer will use a particular programming language for. If you need to write a program with very efficient concurrency but still readable, I will introduce you to this language, ***Go (aka Golang).\***

![Image for post](https://miro.medium.com/max/60/1*csVL0iPHy_pVEAwtq0TnZA.jpeg?q=20)

![Image for post](https://miro.medium.com/max/3240/1*csVL0iPHy_pVEAwtq0TnZA.jpeg)

The objective of this article is to show you how to write a program with Go. I will explain to you about the frequently used syntax and show some tips and tricks you might not know about in Go. Anyway, you also can find the official tutorial of Go from https://tour.golang.org/ for more details, but if you want to learn and understand Go quickly and get some tricks, this article is what you want.

Before you’re going to learn and understand why Golang is good at managing concurrency, I think it’s better to start with something basic which is **syntax**.

First of all, if you don’t have Go compiler in your system, you should go to https://golang.org/dl/ to download your suitable installer with your system and install into it then you will be able to build and run Go code.

# Initial Flow

```go
package main

import "fmt"

func main() {
  fmt.Println("Bye, asteroid!")
}
```



```bash
$ go run bye_asteroid.go // build and run
Bye, asteroid!

$ go build -o bin test.go // build
$ ./bin // and run
Bye, asteroid!
```

How to execute a Go program

Go is compiled language like C/C++, that’s why it’s faster than some interpreted languages like Node.JS and Python. The provided script shows how to run the code without building its binary file (Golang builds the binary for *run* command but the binary is hidden) and also shows how to build and run its binary file.

The code above is a very basic program for displaying text “Bye, asteroid!” (since the asteroid just went pass our earth on August 10). Golang has a package concept which allows programmers to create their packages and let other packages import them. You can see the package in the code, it is the *main* package which is the root package for every Go program. And inside the main package, there is a *main* function which is also the (second) first function to be run after executing a Go program.

> Why did I say “second”? Because there is a *“init”* function which is the actual first function to be executed before executing the *“main”* function.

```go
package main

import "fmt"

func init() {
  fmt.Println("Hello, world!")
}

func main() {
  fmt.Println("Bye, asteroid!")
}

/*
>>> RESULT <<<
Hello, world!
Bye, asteroid!
*/
```

As you can see, the message from the init function is displayed before the main’s message. **The purpose why the init function exists is to initialize data for any packages with init function, not only for the main package.** It means that if your program calls a package with an init function in the package, the init function will be executed right away when you import the package.

# Packages

Package is where functions are kept and one package can contain many files that you can name them freely.

![Image for post](https://miro.medium.com/max/60/1*jyDWJesWGvSxZcs3IJHz7Q.png?q=20)

![Image for post](https://miro.medium.com/max/2376/1*jyDWJesWGvSxZcs3IJHz7Q.png)

![Image for post](https://miro.medium.com/max/60/1*IDynluO8gutBZIyazmrQHQ.png?q=20)

![Image for post](https://miro.medium.com/max/473/1*IDynluO8gutBZIyazmrQHQ.png)

![Image for post](https://miro.medium.com/max/60/1*FkJhBQHU3DjAKJmspwnizw.png?q=20)

![Image for post](https://miro.medium.com/max/1469/1*FkJhBQHU3DjAKJmspwnizw.png)

Folder structure and script to run Go code

> One important rule for constructing a package is “there must be only one package per one folder”

No worries!, You might not understand the code in the example, but I will explain to you about it in the next sections.

# Variables

Go is a statically typed language. It means that you have to declare variable type when you declare variable, and it can’t be changed. This point also makes Golang fast, because the compiler doesn’t need to identify variable type at run time.

## Variable Declaration

```go
package main

import "fmt"

const globalConstant = 2.72
const ExportedGlobalConstant = 3.14

func main() {
  var first string
  first = "This is first string"
  
  var second = "This is second string"
  
  third := "This is third string"
  
  fmt.Println(first, second, third)
}
```

There are three ways of declaring a variable. From the example above, the first one is declaration with manually specifying type to the variable, the second and third one are declaration without manually specifying types but it uses the statement after the equals sign defines the type instead. For the third one, it needs to have a colon (:) to declare the variable. Without the colon, the compiler will throw an error if you haven’t declared the variable before.

You can also declare a global variable by declaring a variable outside a function to allow all the functions inside the package access the global variable. Moreover, you can allow a package to access another package’s global variable by **capitalizing** the first letter of the global variable.

```go
// ./main.go
package main

import (
  "fmt"
  "./data"
)

func main() {
  fmt.Println(data.Message)
}

// ./data/data.go
package data

Message := "This is message from data package"
```



## Variable Types

```go
package main

import "fmt"

func main() {
  a := 1    // var a int
  b := 3.14 // var b float
  c := "hi" // var c string
  d := true // var d bool
  fmt.Println(a, b, c, d)

  e := []int{1, 2, 3} // slice
  e = append(e, 4)
  fmt.Println(e, len(e), e[0], e[1:3], e[1:], e[:2])
  
  f := make(map[string]int) // map
  f["one"] = 1
  f["two"] = 2
  fmt.Println(f, len(f), f["one"], f["three"])
}

/*
>>> OUTPUT <<<
1 3.14 hi true
[1 2 3 4] 4 1 [2 3] [2 3 4] [1 2]
map[one:1 two:2] 2 1 0
*/
```



There are many variable types in Go, but I will show you only frequently used variable types in the code above. Like other languages, Go has *int, float, string, and boolean* as primitive types.

Go has *slice* which is something like *vector* in C++ or *list* in Python that you can append its element into the back of it. Go actually has an *array* which is very similar to *slice* but fixed length.

And the last variable type in the example code is ***map\*** (like *map* in C++ or *dict* in Python). *Map* is used to map key and value. **And remember that you need to use “\*make”\* function to assign “\*map”\* variable before using it.**

```go
package main

import "fmt"

type Person struct{
  Name    string `json:"name"`
  Age     int    `json:"age"`
  isAdmin bool
}

func main() {
  p := Person{
    Name:    "Mike",
    Age:     16,
    isAdmin: false,
  }
  fmt.Println(p, p.Name, p.Age, p.isAdmin)
}

/*
>>> OUTPUT <<<
{Mike 16 false} Mike 16 false
*/
```

The next variable type is *“struct”.* It allows programmers to define a new data type that contains other data types (called *field*) in itself. Each field can be exported by the same rule as the global variable which is capitalizing the first letter of the field. It means that from the code *Name* and *Age* fields can be accessed by other packages while *isAdmin* cannot. A field can be assigned “*tag”* (*`json:“name”`*) as a metadata for some libraries like JSON library (https://golang.org/pkg/encoding/json/) that uses “*tag”* to map Go struct field and JSON field.

## Type Conversion

```go
package main

import (
  "fmt"
  "strconv"
  "reflect"
)

func main() {
  a := 3.14
  b := int(a)
  fmt.Println(b, reflect.TypeOf(b))
  
  c := "12.34"
  d, _ := strconv.ParseFloat(c, 64)
  fmt.Println(d, reflect.TypeOf(d))
  
  e := false
  f := fmt.Sprint(e)
  fmt.Println(f, reflect.TypeOf(f))
}

/*
>>> OUTPUT <<<
3 int
12.34 float64
false string
*/
```

Some pairs of type can convert by casting directly (int(1.23), float(3), uint32(5)), but for some require an extra library to do a conversion such as string-int, int-string, bool-string, and string-bool.

## Zero Values

```go
package main

import "fmt"

func main() {
  var a int
  var b float64
  var c bool
  var d string
  fmt.Println(a, b, c, d)
  
  var e []int
  var f map[string]float64
  fmt.Println(e, f)
  
  type person struct{
    name string
    age int
  }
  var g person
  var h *person
  fmt.Println(g, h)
}

/*
>>> OUTPUT <<<
0 0 false
[] map[]
{ 0} <nil>
*/
```



If you declare a variable without assigning any value to it, the value of the variable will be set to **zero value** of its type. (You may curious what is **person* and *nil.* It is a **pointer** and zero value of it which I will create a separated article for this, I think it will be next article 😂).

# Control Flow Statements

## Conditions

```go
package main

import "fmt"

func main() {
  // if, else
  a := 5
  if a > 3 {
    a = a - 3
  } else if a == 3 {
    a = 0
  } else {
    a = a + 3
  }
  fmt.Println(a)
  
  // switch, case
  b := "NO"
  switch b {
  case "YES":
    b = "Y"
  case "NO":
    b = "N"
  default:
    b = "X"
  }
  fmt.Println(b)
}

/*
>>> OUTPUT <<<
2
N
*/
```



In Go, there are control flow statements like other languages: *if, else, switch, case*, but there is only one looping statement in Go which is “*for”.* Because you can replace “*while”* statement with “*for”* statement like the example below.

## Loop

```go
package main

import "fmt"

func main() {
  // for
  c := 3
  for i := 0; i < c; i++ {
    fmt.Print(i, " ")
  }
  fmt.Println()
  
  // replace while with for
  for c > 0 {
    fmt.Print(c, " ")
    c--
  }
  fmt.Println()

  // for with range
  d := []int{0, 1, 1, 2, 3, 5, 8}
  for _, i := range d {
    fmt.Print(i, " ")
  }
  fmt.Println()
}

/*
>>> OUTPUT <<<
0 1 2 
3 2 1 
0 1 1 2 3 5 8 
*/
```

As you can see in the example, you can use *“for”* for the same purpose of *“while”* in other languages. Moreover, you can iterate on some iterable variable such as *array*, *slice*, and *map* by using *“range”*, it return two values which are index/key and value.

## Defer

```go
package main

import "fmt"

func main() {
  f()
}

func f() (int, error) {
  defer fmt.Println("DEFER 1")
  defer fmt.Println("DEFER 2")
  defer fmt.Println("DEFER 3")
  fmt.Println("BODY")
  return fmt.Println("RETURN")
}

/*
>>> OUTPUT <<<
BODY
RETURN
DEFER 3
DEFER 2
DEFER 1
*/
```



*“defer”* statement is a special statement in Go. You can call any functions after the *defer* statement. The functions will be kept in a stack and they will be called after the caller function returns. As you can see in the example, there is a reversed order of function calls.

# Functions

## **Function components**

![Image for post](https://miro.medium.com/max/60/1*L25gUVmwpFId-2hcUK1QuQ.png?q=20)

![Image for post](https://miro.medium.com/max/2027/1*L25gUVmwpFId-2hcUK1QuQ.png)

Go function has 4 parts.

1. **Name**: Should be named in camelCase / CamelCase.
2. **Arguments**: A function can take zero or more arguments. For two or more consecutive arguments with the same type, you can define the type on the back of the last argument (like “*string”* in the example).
3. **Return Types**: A function can return zero or more value. If returns more than one values, you need to cover them with parentheses.
4. **Body**: It is a logic of a function.

## Name Return Values

```go
package main

import "fmt"

func main() {
  fmt.Println(threeTimes("Thank You"))
}

func threeTimes(msg string) (tMsg string) {
  tMsg = msg + ", " + msg + ", " + msg
  return
}

/*
>>> OUTPUT <<<
Thank You, Thank You, Thank You
*/
```



You also can name result values of a function. So, you don’t need to declare returned variables and define what the function returns in the return statement. **In this case, you need to put parentheses into the return types although there is only one argument.**

## Exported / Unexported Functions

```go
package main

import "fmt"

func main() {
  s := Sum(10)
  f := factorial(10)
  fmt.Println(s, f)
}

func Sum(n int) int { // exported function
  sum := 0
  for i := 1; i <= n; i++ {
     sum += i
  }
  return sum
}

func factorial(n int) int { // unexported function
  fac := 1
  for i := 1; i <= n; i++ {
    fac *= 1
  }
  return fac
}

/*
>>> OUTPUT <<<
55 3628800
*/
```



Like variable and other identifiers, Functions can be exported and unexported by capitalizing the first letter of their name.

## Anonymous Functions

```go
package main

import "fmt"

func main() {
  a := 1
  b := 1
  c := func(x int) int {
    b *= 2
    return x * 2
  }(a)
  fmt.Println(a, b, c)
}

/*
>>> OUTPUT <<<
1 2 2
*/
```



You can declare a function inside another function and execute immediately after declaring it. It is called *Anonymous* Function that can access the scope of its parent. In this case, the anonymous function can access variable *b* which in the main function’s scope

```go
package main

import "fmt"

func main() {
  myFunc := func(x int) int {
    return x * x
  }
  fmt.Println(myFunc(2), myFunc(3))
}

/*
>>> OUTPUT <<<
4 9
*/
```



As you can see in the example above, the function can be assigned into a variable to be reusable.

## Blank Identifiers

```go
package main

import "fmt"

func main() {
  x, _ := evenOnly(10)
  fmt.Println(x)
}

func evenOnly(n int) (int, error) {
  if n%2 == 0 {
    return n / 2, nil
  }
  return 0, fmt.Errorf("not even")
}

/*
>>> OUTPUT <<<
5
*/
```



Go is very strict for unused variables, you can not compile the code with any unused variables. Some functions return multiple values, and some values are not used. So, Go provides a *“blank identifier”* for replacing unused variables then the code can be complied.

# Next Topics

After you read this article, you will find the way to write a basic Go program. However, there isn’t enough, if you want to create high-performance service or system. There are more topics about Go that you should know which are shown on the list below, and I will explain about them in the next articles.