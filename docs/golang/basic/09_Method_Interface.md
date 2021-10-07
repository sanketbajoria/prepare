# Methods and Interfaces

If you want to apply some design patterns in Go program, such as Adapter, Proxy, or Decorator, or even in testing you Go program, you might need to use ***methods\*** and ***interfaces\*** in you code. So this article will explain to you about what they are and how to use them. If you’re ready to learn, let’s go through it!

# What is a method?

> A method is a function or a piece of code that is associated with an struct.

### Usage of Method

```go
package main

import "fmt"

type Car struct {
  color string
  distance int
}

//For mutating method, we have to use pointer
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
//Type switch
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


### Empty interface

An interface that has zero methods is called an empty interface. It is represented as interface{}. Since the empty interface has zero methods, all types implement the empty interface.'

```go
func describe(i interface{}) {  
    fmt.Printf("Type = %T, value = %v\n", i, i)
}
```



### Embedding interfaces

Although go does not offer inheritance, it is possible to create a new interfaces by embedding other interfaces.

Lets see how this is done.

```go
package main

import (  
    "fmt"
)

type SalaryCalculator interface {  
    DisplaySalary()
}

type LeaveCalculator interface {  
    CalculateLeavesLeft() int
}

type EmployeeOperations interface {  
    SalaryCalculator
    LeaveCalculator
}

type Employee struct {  
    firstName string
    lastName string
    basicPay int
    pf int
    totalLeaves int
    leavesTaken int
}

func (e Employee) DisplaySalary() {  
    fmt.Printf("%s %s has salary $%d", e.firstName, e.lastName, (e.basicPay + e.pf))
}

func (e Employee) CalculateLeavesLeft() int {  
    return e.totalLeaves - e.leavesTaken
}

func main() {  
    e := Employee {
        firstName: "Naveen",
        lastName: "Ramanathan",
        basicPay: 5000,
        pf: 200,
        totalLeaves: 30,
        leavesTaken: 5,
    }
    var empOp EmployeeOperations = e
    empOp.DisplaySalary()
    fmt.Println("\nLeaves left =", empOp.CalculateLeavesLeft())
}
```



### Zero value of Interface

The zero value of a interface is nil. A nil interface has both its underlying value and as well as concrete type as nil.

```go
package main

import "fmt"

type Describer interface {  
    Describe()
}

func main() {  
    var d1 Describer
    if d1 == nil {
        fmt.Printf("d1 is nil and has type %T value %v\n", d1, d1)
    }
}
```



### Implementing interfaces using pointer receivers vs value receivers

```go
package main

import "fmt"

type Describer interface {  
    Describe()
}
type Person struct {  
    name string
    age  int
}

func (p Person) Describe() { //implemented using value receiver  
    fmt.Printf("%s is %d years old\n", p.name, p.age)
}

type Address struct {  
    state   string
    country string
}

func (a *Address) Describe() { //implemented using pointer receiver  
    fmt.Printf("State %s Country %s", a.state, a.country)
}

func main() {  
    var d1 Describer
    p1 := Person{"Sam", 25}
    d1 = p1
    d1.Describe()
    p2 := Person{"James", 32}
    d1 = &p2
    d1.Describe()

    var d2 Describer
    a := Address{"Washington", "USA"}

    /* compilation error if the following line is
       uncommented
       cannot use a (type Address) as type Describer
       in assignment: Address does not implement
       Describer (Describe method has pointer
       receiver)
    */
    //d2 = a

    d2 = &a //This works since Describer interface
    //is implemented by Address pointer in line 22
    d2.Describe()

}
```

I hope you would get some point about implementing interface with multiple types, it will allow you to create only one logic for executing their method and make you life easier 😂.

