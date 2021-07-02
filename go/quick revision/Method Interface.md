If you want to apply some design patterns (read more: https://sourcemaking.com/design_patterns) in Go program, such as Adepter, Proxy, or Decorator, or even in testing you Go program, you might need to use ***methods\*** and ***interfaces\*** in you code. So this article will explain to you about what they are and how to use them. If you’re ready to learn, let’s go through it!

![Image for post](https://miro.medium.com/max/60/1*1Gl8XtTFQvQMaHmJDSibqw.png?q=20)

![Image for post](https://miro.medium.com/max/2304/1*1Gl8XtTFQvQMaHmJDSibqw.png)

# What is a method?

> A method is a function or a piece of code that is associated with an object.

Let’s say, you have a struct called *“Car”* and you create a method of the struct named *“Drive”*, then you declare an object from the struct and name it as *“tesla”*. So you can call the *“Drive”* method of your *“tesla”* to do whatever you programmed the method to do by using the properties or fields of your *“tesla”* to go the calculation.

What I just explained to you is only an example to make you get the concept of method. So now I will show you how to create your own methods and how to use them.

# Usage of Method

Basically, all methods are associated with objects, means that you need to have at least one object in your code to declare any methods.

```go
package main

import "fmt"

type Car struct {
  color string
  distance int
}

func main() {
  tesla := &Car{
    distance: 0,
  }
  fmt.Println(tesla)
}
```



After you got your struct, you will be able to create your method

```go
package main

import "fmt"

type Car struct {
  color string
  distance int
}

func (c *Car) Drive(dist int) {
  c.distance += dist
}

func main() {
  tesla := &Car{
    distance: 0,
  }
  fmt.Println("init distance:", tesla.distance)
  tesla.Drive(10)
  fmt.Println("1st drive distance:", tesla.distance)
}

/*
>>> OUTPUT <<<
init distance: 0
1st drive distance: 10
*/
```



A method is very similar to a function but the difference is that the method is associated with an object and can you the properties inside the object to calculate, just like the *“Drive”* method that uses *“distance”* property of *“Car”* to calculate new *“distance”.*

In case you need to expose some fields of your struct to other packages without directly exporting them, using methods as *“Getter”* is your best choice.

```go
package main

import "fmt"

type Car struct {
  color string
  distance int
}

func (c *Car) Drive(dist int) {
  c.distance += dist
}

func (c *Car) GetDistance() int {
  return c.distance
}

func main() {
  tesla := &Car{
    distance: 0,
  }
  tesla.Drive(10)
  fmt.Println("1st drive distance (without exporting):", tesla.GetDistance())
}

/*
>>> OUTPUT <<<
1st drive distance (without exporting): 10
*/
```



*Setter* is a way to set the value of unexported fields and getter can be used to setup default value of any field you want like the example below.

```go
package main

import "fmt"

type Car struct {
  color string
  distance int
}

func (c *Car) Drive(dist int) {
  c.distance += dist
}

// Getter
func (c *Car) GetDistance() int {
  return c.distance
}

// Setter
func (c *Car) SetColor(color string) {
  c.color = color
}

// Getter with default value
func (c *Car) GetColor() string {
  if c.color == "" {
    c.color = "white"
  }
  return c.color
}

func main() {
  tesla := &Car{
    distance: 0,
  }
  fmt.Println("get default color:", tesla.GetColor())
  tesla.SetColor("silver")
  fmt.Println("get new color:", tesla.GetColor())
}

/*
>>> OUTPUT <<<
get default color: white
get new color: silver
*/
```



Now you have already learnt how methods work and how to work with methods, but there is another feature in Golang that can enhance the power of structs and their methods. The feature is ***“Interface”\***.

# What is an interface?

> An interface is a set of method signature that an object can implement.

To make it more understandable, let’s say you have another struct named *“Plane”* and its methods: *“Fly”* and *“GetDistance”.* And you want to use it with *“Car”* struct by using the same logic to get their distance. An interface will help you for this kind of task.

```go
package main

import "fmt"

// Car struct 
type Car struct {
  distance int
}

func (c *Car) Drive(dist int) {
  c.distance += dist
}

func (c *Car) GetDistance() int {
  return c.distance
}

// Plane struct
type Plane struct {
  distance int
}

func (p *Plane) Fly(dist int) {
  p.distance += dist
}

func (p *Plane) GetDistance() int {
  return p.distance
}

// Use interface as argument
func GetVehicleDistance(i interface{}) int {
  switch i.(type) {
  case *Car:
    c := i.(*Car) // Type assertion
    return c.GetDistance()
  case *Plane:
    p := i.(*Plane) // Type assertion
    return p.GetDistance()
  }
  return 0
}

func main() {
  tesla := &Car{}
  airbus := &Plane{}
  tesla.Drive(10)
  airbus.Fly(10000)
  fmt.Println("tesla distance:", GetVehicleDistance(tesla))
  fmt.Println("airbus distance:", GetVehicleDistance(airbus))
}

/*
>>> OUTPUT <<<
tesla distance: 10
airbus distance: 10000
*/
```



From the example above, you can use the same function with different parameter types by using interface as argument. And before you use the method from the interface, you need to do ***“type assertion”\*** which is very important step for using interfaces.

Anyway the code can be improved and shorten by declaring an interface type with a set of method signature. For our case, it is “GetDistance” method. You will see how short it is.

```go
package main

import "fmt"

// Car struct 
type Car struct {
  distance int
}

func (c *Car) Drive(dist int) {
  c.distance += dist
}

func (c *Car) GetDistance() int {
  return c.distance
}

// Plane struct
type Plane struct {
  distance int
}

func (p *Plane) Fly(dist int) {
  p.distance += dist
}

func (p *Plane) GetDistance() int {
  return p.distance
}

// Declare interface type
type Vehicle interface {
  GetDistance() int
}

// Use interface as argument
func GetVehicleDistance(i interface{}) int {
  v := i.(Vehicle)
  return v.GetDistance()
}

func main() {
  tesla := &Car{}
  airbus := &Plane{}
  tesla.Drive(10)
  airbus.Fly(10000)
  fmt.Println("tesla distance:", GetVehicleDistance(tesla))
  fmt.Println("airbus distance:", GetVehicleDistance(airbus))
}

/*
>>> OUTPUT <<<
tesla distance: 10
airbus distance: 10000
*/
```



However, don’t forget to validate your interface before using it because somehow it can be ***nil\***.

```go
func GetVehicleDistance(i interface{}) int {
  if i == nil { // validate interface before using
    return 0
  }
  v := i.(Vehicle)
  return v.GetDistance()
}
```



I hope you would get some point about implementing interface with multiple types, it will allow you to create only one logic for executing their method and make you life easier 😂.