# Reflection in Go

Reflection is one of the advanced topics in Go. I will try to make it as simple as possible.

This tutorial has the following sections.

- What is reflection?
- What is the need to inspect a variable and find its type?
- reflect package
  - reflect.Type and reflect.Value
  - reflect.Kind
  - NumField() and Field() methods
  - Int() and String() methods
- Complete program
- Should reflection be used?

Let's discuss these sections one by one now.

### What is reflection?

Reflection is the ability of a program to inspect its variables and values at run time and find their type. You might not understand what this means but that's alright. You will get a clear understanding of reflection by the end of this tutorial, so stay with me.

### What is the need to inspect a variable and find its type?

The first question anyone gets when learning about reflection is why do we even need to inspect a [variable](https://golangbot.com/variables/) and find its type at runtime when each and every variable in our program is defined by us and we know its type at compile time itself. Well, this is true most of the time, but not always.

Let me explain what I mean. Let's write a simple program.

```go
package main

import (  
    "fmt"
)

func main() {  
    i := 10
    fmt.Printf("%d %T", i, i)
}
```

In the program above, the type of `i` is known at compile time and we print it in the next line. Nothing magical here.

Now let's understand the need to know the type of a variable at run time. Let's say we want to write a simple [function](https://golangbot.com/functions/) which will take a [struct](https://golangbot.com/structs/) as an argument and will create a SQL insert query using it.

Consider the following program,

```go
package main

import (  
    "fmt"
)

type order struct {  
    ordId      int
    customerId int
}

func main() {  
    o := order{
        ordId:      1234,
        customerId: 567,
    }
    fmt.Println(o)
}
```

We need to write a function that will take the struct `o` in the program above as an argument and return the following SQL insert query,

```
insert into order values(1234, 567)  
```

This function is simple to write. Let's do that now.

```go
package main

import (  
    "fmt"
)

type order struct {  
    ordId      int
    customerId int
}

func createQuery(o order) string {  
    i := fmt.Sprintf("insert into order values(%d, %d)", o.ordId, o.customerId)
    return i
}

func main() {  
    o := order{
        ordId:      1234,
        customerId: 567,
    }
    fmt.Println(createQuery(o))
}
```

The `createQuery` function in line no. 12 creates the insert query by using the `ordId` and `customerId` fields of `o`. This program will output,

```sql
insert into order values(1234, 567)  
```

Now let's take our query creator to the next level. What if we want to generalize our query creator and make it work on any struct. Let me explain what I mean by using a program.

```go
package main

type order struct {  
    ordId      int
    customerId int
}

type employee struct {  
    name string
    id int
    address string
    salary int
    country string
}

func createQuery(q interface{}) string {  
}

func main() {

}
```

Our objective is to finish the `createQuery` function in line no. 16 of the above program so that it takes any `struct` as argument and creates an insert query based on the struct fields.

For example, if we pass the struct below,

```go
o := order {  
    ordId: 1234,
    customerId: 567
}
```

Our `createQuery` function should return,

```
insert into order values (1234, 567)  
```

Similarly if we pass

```go
 e := employee {
        name: "Naveen",
        id: 565,
        address: "Science Park Road, Singapore",
        salary: 90000,
        country: "Singapore",
    }
```

it should return,

```
insert into employee values("Naveen", 565, "Science Park Road, Singapore", 90000, "Singapore")  
```

Since the `createQuery` function should work with any struct, it takes a [*interface{}*](https://golangbot.com/interfaces-part-1/#emptyinterface) as argument. For simplicity, we will only deal with structs that contain fields of type `string` and `int` but this can be extended for any type.

The `createQuery` function should work on any struct. The only way to write this function is to examine the type of the struct argument passed to it at run time, find its fields and then create the query. This is where reflection is useful. In the next steps of the tutorial, we will learn how we can achieve this using the `reflect` package.

### reflect package

The [reflect](https://golang.org/pkg/reflect/) package implements run-time reflection in Go. The reflect package helps to identify the underlying concrete type and the value of a [*interface{}*](https://golangbot.com/interfaces-part-1/#emptyinterface) variable. This is exactly what we need. The `createQuery` function takes a `interface{}` argument and the query needs to be created based on the concrete type and value of the `interface{}` argument. This is exactly what the reflect package helps in doing.

There are a few types and methods in the reflect package which we need to know first before writing our generic query generator program. Lets look at them one by one.

#### reflect.Type and reflect.Value

The concrete type of `interface{}` is represented by [reflect.Type](https://golang.org/pkg/reflect/#Type) and the underlying value is represented by [reflect.Value](https://golang.org/pkg/reflect/#Value). There are two functions [reflect.TypeOf()](https://golang.org/pkg/reflect/#TypeOf) and [reflect.ValueOf()](https://golang.org/pkg/reflect/#ValueOf) which return the `reflect.Type` and `reflect.Value` respectively. These two types are the base to create our query generator. Let's write a simple example to understand these two types.

```go
package main

import (  
    "fmt"
    "reflect"
)

type order struct {  
    ordId      int
    customerId int
}

func createQuery(q interface{}) {  
    t := reflect.TypeOf(q)
    v := reflect.ValueOf(q)
    fmt.Println("Type ", t)
    fmt.Println("Value ", v)


}
func main() {  
    o := order{
        ordId:      456,
        customerId: 56,
    }
    createQuery(o)

}
```

In the program above, the createQuery function in line no. 13 takes a interface{} as argument. The function [reflect.TypeOf](https://golang.org/pkg/reflect/#TypeOf) in line no. 14 takes a interface{} as argument and returns the [reflect.Type](https://golang.org/pkg/reflect/#Type) containing the concrete type of the interface{} argument passed. Similarly the [reflect.ValueOf](https://golang.org/pkg/reflect/#ValueOf) function in line no. 15 takes a interface{} as argument and returns the [reflect.Value](https://golang.org/pkg/reflect/#Value) which contains the underlying value of the interface{} argument passed.

The above program prints,

```
Type  main.order  
Value  {456 56}  
```

#### reflect.Kind

There is one more important type in the reflection package called [Kind](https://golang.org/pkg/reflect/#Kind).

The types `Kind` and `Type` in the reflection package might seem similar but they have a difference which will be clear from the program below.

```go
package main

import (  
    "fmt"
    "reflect"
)

type order struct {  
    ordId      int
    customerId int
}

func createQuery(q interface{}) {  
    t := reflect.TypeOf(q)
    k := t.Kind()
    fmt.Println("Type ", t)
    fmt.Println("Kind ", k)


}
func main() {  
    o := order{
        ordId:      456,
        customerId: 56,
    }
    createQuery(o)

}
```

[Run in playground](https://play.golang.org/p/Xw3JIzCm54T)

The program above outputs,

```
Type  main.order  
Kind  struct  
```

I think you will now be clear about the differences between the two. `Type` represents the actual type of the interface{}, in this case **main.Order** and `Kind` represents the specific kind of the type. In this case, it's a **struct**.

#### NumField() and Field() methods

The [NumField()](https://golang.org/pkg/reflect/#Value.NumField) method returns the number of fields in a struct and the [Field(i int)](https://golang.org/pkg/reflect/#Value.Field) method returns the `reflect.Value` of the `i`th field.

```go
package main

import (  
    "fmt"
    "reflect"
)

type order struct {  
    ordId      int
    customerId int
}

func createQuery(q interface{}) {  
    if reflect.ValueOf(q).Kind() == reflect.Struct {
        v := reflect.ValueOf(q)
        fmt.Println("Number of fields", v.NumField())
        for i := 0; i < v.NumField(); i++ {
            fmt.Printf("Field:%d type:%T value:%v\n", i, v.Field(i), v.Field(i))
        }
    }

}
func main() {  
    o := order{
        ordId:      456,
        customerId: 56,
    }
    createQuery(o)
}
```

In the program above, in line no. 14 we first check whether the `Kind` of `q` is a `struct` because the `NumField` method works only on struct. The rest of the program is self explanatory. This program outputs,

```
Number of fields 2  
Field:0 type:reflect.Value value:456  
Field:1 type:reflect.Value value:56  
```

#### Int() and String() methods

The methods [Int](https://golang.org/pkg/reflect/#Value.Int) and [String](https://golang.org/pkg/reflect/#Value.String) help extract the `reflect.Value` as an `int64` and `string` respectively.

```go
package main

import (  
    "fmt"
    "reflect"
)

func main() {  
    a := 56
    x := reflect.ValueOf(a).Int()
    fmt.Printf("type:%T value:%v\n", x, x)
    b := "Naveen"
    y := reflect.ValueOf(b).String()
    fmt.Printf("type:%T value:%v\n", y, y)

}
```

In the program above, in line no. 10, we extract the `reflect.Value` as an `int64` and in line no. 13, we extract it as `string`. This program prints,

```
type:int64 value:56  
type:string value:Naveen  
```

### Complete Program

Now that we have enough knowledge to finish our query generator, let's go ahead and do it.

```go
package main

import (  
    "fmt"
    "reflect"
)

type order struct {  
    ordId      int
    customerId int
}

type employee struct {  
    name    string
    id      int
    address string
    salary  int
    country string
}

func createQuery(q interface{}) {  
    if reflect.ValueOf(q).Kind() == reflect.Struct {
        t := reflect.TypeOf(q).Name()
        query := fmt.Sprintf("insert into %s values(", t)
        v := reflect.ValueOf(q)
        for i := 0; i < v.NumField(); i++ {
            switch v.Field(i).Kind() {
            case reflect.Int:
                if i == 0 {
                    query = fmt.Sprintf("%s%d", query, v.Field(i).Int())
                } else {
                    query = fmt.Sprintf("%s, %d", query, v.Field(i).Int())
                }
            case reflect.String:
                if i == 0 {
                    query = fmt.Sprintf("%s\"%s\"", query, v.Field(i).String())
                } else {
                    query = fmt.Sprintf("%s, \"%s\"", query, v.Field(i).String())
                }
            default:
                fmt.Println("Unsupported type")
                return
            }
        }
        query = fmt.Sprintf("%s)", query)
        fmt.Println(query)
        return

    }
    fmt.Println("unsupported type")
}

func main() {  
    o := order{
        ordId:      456,
        customerId: 56,
    }
    createQuery(o)

    e := employee{
        name:    "Naveen",
        id:      565,
        address: "Coimbatore",
        salary:  90000,
        country: "India",
    }
    createQuery(e)
    i := 90
    createQuery(i)

}
```

In line no. 22, we first check whether the passed argument is a `struct`. In line no. 23 we get the name of the struct from its `reflect.Type` using the `Name()` method. In the next line, we use `t` and start creating the query.

The [case](https://golangbot.com/switch/) statement in line. 28 checks whether the current field is `reflect.Int`, if that's the case we extract the value of that field as `int64` using the `Int()` method. The [if else](https://golangbot.com/if-statement/) statement is used to handle edge cases. Please add logs to understand why it is needed. Similar logic is used to extract the `string` in line no. 34.

We have also added checks to prevent the program from crashing when unsupported types are passed to the `createQuery` function. The rest of the program is self explanatory. I recommend adding logs at appropriate places and checking their output to understand this program better.

This program prints,

```
insert into order values(456, 56)  
insert into employee values("Naveen", 565, "Coimbatore", 90000, "India")  
unsupported type  
```

I would leave it as an exercise for the reader to add the field names to the output query. Please try changing the program to print query of the format,

```
insert into order(ordId, customerId) values(456, 56)  
```

### reflect.DeepEqual
DeepEqual is a recursive relaxation of Go's == operator.

DeepEqual reports whether x and y are “deeply equal,” defined as follows. Two values of identical type are deeply equal if one of the following cases applies. Values of distinct types are never deeply equal.

Array values are deeply equal when their corresponding elements are deeply equal.

Struct values are deeply equal if their corresponding fields, both exported and unexported, are deeply equal.

Func values are deeply equal if both are nil; otherwise they are not deeply equal.

Interface values are deeply equal if they hold deeply equal concrete values.

Map values are deeply equal if they are the same map object or if they have the same length and their corresponding keys (matched using Go equality) map to deeply equal values.

Pointer values are deeply equal if they are equal using Go's == operator or if they point to deeply equal values.

Slice values are deeply equal when all of the following are true: they are both nil or both non-nil, they have the same length, and either they point to the same initial entry of the same underlying array (that is, &x[0] == &y[0]) or their corresponding elements (up to length) are deeply equal. Note that a non-nil empty slice and a nil slice (for example, []byte{} and []byte(nil)) are not deeply equal.

Other values - numbers, bools, strings, and channels - are deeply equal if they are equal using Go's == operator.

### Should reflection be used?

Having shown a practical use of reflection, now comes the real question. Should you be using reflection? I would like to quote [Rob Pike](https://en.wikipedia.org/wiki/Rob_Pike)'s proverb on the use of reflection which answers this question.

*Clear is better than clever. Reflection is never clear.*

Reflection is a very powerful and advanced concept in Go and it should be used with care. It is very difficult to write clear and maintainable code using reflection. It should be avoided wherever possible and should be used only when absolutely necessary.