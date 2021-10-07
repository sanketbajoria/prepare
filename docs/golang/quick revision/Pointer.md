The languages such as Java, C/C++, and Go have pointer concept. It is a concept that allows us to manipulate variables in the **memory address** form. Pointer is not a big topic in Golang but it is used almost everywhere in your code, if you’re working on high performance and high standard Go project. If you want to know what it is, so let’s find out now!

![Image for post](https://miro.medium.com/max/34/1*4Ime9N4IqecqAwqJpVhykg.png?q=20)

![Image for post](https://miro.medium.com/max/2304/1*4Ime9N4IqecqAwqJpVhykg.png)

# What is pointer?

Let’s say there is a variable, and it’s used in multiple functions at the same time. You want it to be updated automatically whenever any function changes its value to let the others can get the new value. **Pointer** is the concept that can solve this situation.

```go
package main

import "fmt"

func main() {
  x := 0
  y := 0
  fmt.Printf("before:\ta=%d\tb=%d\n", x, y)
  update(x, &y)
  fmt.Printf("after:\ta=%d\tb=%d\n", x, y)
}

func update(a int, b *int) {
  a = 10
  *b = 10
  fmt.Printf("inside:\ta=%d\tb=%d\n", a, *b)
}

/*
>>> OUTPUT <<<
before:	a=0  b=0
inside:	a=10 b=10
after:	a=0  b=10
*/
```



As you can see in the example above, the value of *x* isn’t changed after calling the function, different from the value of *y* that’s changed after calling the function. It is because Go is passing variable to a function by value not reference. Means that *x* in *main* function and *a* in *update* function, they are not the same one, and for *y and b* as well*.* But the difference is before passing *y* to the *update* function, it is casted to pointer and sent to the function. So, the function will get the memory address of *y* and uses it to change the value of *y* directly.

# Declaration

```go
package main

import "fmt"

func main() {
  var a *int
  var b *string
  var c *float64
  var d *bool
  fmt.Println(a, b, c, d)
}

/*
>>> OUTPUT <<<
<nil> <nil> <nil> <nil>
*/
```



Similar to other variable type declarations, pointer uses the same format but you need to put **star (\*)** in front of the variable type you need to declare the pointer of it. As you can see, ***nil\*** is the zero value of pointer no matter what kind of variable type the pointer points to.

```go
package main

import "fmt"

func main() {
  var a []int
  var b map[int]bool
  fmt.Println(a, b)
  fmt.Println(a == nil, b == nil)
}

/*
>>> OUTPUT <<<
[] map[]
true true
*/
```



For some variable type, such as **slice** and **map**, the identifier of these variable types are pointer by default. You might see that when you print their value, it won’t display *nil* but they are actually *nil* if you compare the values with *nil*.

```go
package main

import "fmt"

func main() {
  var x []int
  x = append(x, 1)
  x = append(x, 2)
  fmt.Println(x)
  update(x)
  fmt.Println(x)
}

func update(a []int) {
  for i, _ := range a {
  	a[i] *= 10
  }
}

/*
>>> OUTPUT <<<
[1 2]
[10 20]
*/
```



So you can update the value of these kinds of variable inside other functions just like the pointer of other variable types. Anyway, you can use pointer with these kinds of variable, but it’s very rare case that you need to use pointer with them.

```go
package main

import "fmt"

type Point struct {
  X int
  Y int
}

func main() {
  var p Point // non-pointer
  p.X = 1
  p.Y = 2
  var q *Point // pointer
  q.X = 3
  q.Y = 4
  fmt.Println(p, q)
}

/*
>>> ERROR <<<
panic: runtime error: invalid memory address or nil pointer dereference
[signal SIGSEGV: segmentation violation code=0x1 addr=0x0 pc=0x1092f93]
goroutine 1 [running]:
main.main()
	/Users/can/Desktop/test.go:15 +0x23
exit status 2
*/
```

WRONG ❌

```go
package main

import "fmt"

type Point struct {
  X int
  Y int
}

func main() {
  var p Point // non-pointer
  p.X = 1
  p.Y = 2
  var q *Point // pointer
  q = &Point{} // assign before using
  q.X = 3
  q.Y = 4
  fmt.Println(p, q)
}

/*
>>> OUTPUT <<<
{1 2} &{3 4}
*/
```

RIGHT ✅

Your customized variable type and **struct** also can be used with pointer, and it doesn’t change the way to use your struct that much. What you need to do is just to assign the address to your struct pointer before using it which I will explain to you in next topic!

# Get Address

In order to use get an address from a variable, you need to put **ampersand (&)** in front of the variable you need to get its address.

```go
package main

import "fmt"

func main() {
  b := &10
  fmt.Println(b)
}

/*
>>> ERROR <<<
# command-line-arguments
./test.go:6:8: cannot take the address of 10
*/
```



WRONG ❌

```go
package main

import "fmt"

func main() {
  a := 10
  b := &a
  fmt.Println(b)
}

/*
>>> OUTPUT <<<
0xc0000a4000
*/
```



RIGHT ✅

You also can declare a pointer by assigning address from other variable but you can’t get address from basic type data like string, number, and boolean.

Anyway, for some composite type, such as struct, you can get address without declaring other variable to get the address from.

```go
package main

import "fmt"

type Point struct {
  X int
  Y int
}

func main() {
  p := &Point{
    X: 1,
    Y: 2,
  }
  fmt.Println(p)
}

/*
>>> OUTPUT <<<
&{1 2}
*/
```



# Get Value

Similar to address getting, you can get the value from pointer by putting **star (\*)** in front of the pointer

```go
package main

import "fmt"

func main() {
  a := 10
  b := &a
  fmt.Println(b) // display address
  fmt.Println(*b) // display value
}

/*
>>> OUTPUT <<<
0xc00001a0a0
10
*/
```



# Example

For someone who’s new with the languages like Go, and C/C++, you might not see the way to make it useful in any real project. So, I will show you an example of what I think you must use in the future, if you’re going to use Golang with your project.

```go
package main

import (
	"encoding/json"
	"fmt"
)

type Point struct {
	X int `json:"x"`
	Y int `json:"y"`
}

type Tank struct {
	Name     string   `json:"name"`
	Position Point    `json:"position"`
	Drivers  []string `json:"drivers"`
}

func main() {
	myTank := Tank{
		Name: "tank_1234",
		Position: Point{
			X: 12,
			Y: 34,
		},
		Drivers: []string{"man_1", "man_2", "man_3"},
	}
	jsonData, _ := json.Marshal(&myTank)
	fmt.Println(string(jsonData)) // json data

	var newTank Tank
	_ = json.Unmarshal(jsonData, &newTank)
	fmt.Println(newTank) // tank data
}

/*
>>> OUTPUT <<<
{"name":"tank_1234","position":{"x":12,"y":34},"drivers":["man_1","man_2","man_3"]}
{tank_1234 {12 34} [man_1 man_2 man_3]}
*/
```



This is how to encode and decode JSON data. As you can see in the parameters of *json.Unmarshal*, there is no need to return the result, but just change the second parameter’s value by using pointer.

Anyway, there is still be other reasons why so many libraries including this one need to use pointer instead of returning the value, and I will explain to you in the next article which is about **Method and Interface.** Please stay tuned, thanks 😎