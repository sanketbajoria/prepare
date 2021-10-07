## Structs
There are no classes, only structs. Structs can have methods.

```go
// A struct is a type. It's also a collection of fields

// Declaration
type Vertex struct {
    X, Y int
}

// Creating
var v = Vertex{1, 2} //order is important
var v = Vertex{X: 1, Y: 2} // Creates a struct by defining values with keys
var v = []Vertex{{1,2},{5,2},{5,5}} // Initialize a slice of structs

// Accessing members
v.X = 4

// You can declare methods on structs. The struct you want to declare the
// method on (the receiving type) comes between the the func keyword and
// the method name. The struct is copied on each method call(!)
func (v Vertex) Abs() float64 {
    return math.Sqrt(v.X*v.X + v.Y*v.Y)
}

// Call method
v.Abs()

// For mutating methods, you need to use a pointer (see below) to the Struct
// as the type. With this, the struct value is not copied for the method call.
func (v *Vertex) add(n float64) {
    v.X += n
    v.Y += n
}
```
**Anonymous structs:** Cheaper and safer than using map[string]interface{}.
```go
point := struct {
	X, Y int
}{1, 2}
```

### Zero value of a struct

```go
type Employee struct {  
    firstName string
    age       int
}
var emp4 Employee 
fmt.Println(emp4) //firstName:"", age: 0
```

### Anonymous struct

```go
type Person struct {  
    string
    int
}

func main() {  
    p1 := Person{
        string: "naveen",
        int:    50,
    }
    fmt.Println(p1.string)
    fmt.Println(p1.int)
}
```

### Nested struct

```go
type Address struct {  
    city  string
    state string
}

type Person struct {  
    name    string
    age     int
    address Address
}

func main() {  
    p := Person{
        name: "Naveen",
        age:  50,
        address: Address{
            city:  "Chicago",
            state: "Illinois",
        },
    }

    fmt.Println("Name:", p.name)
    fmt.Println("Age:", p.age)
    fmt.Println("City:", p.address.city)
    fmt.Println("State:", p.address.state)
}


//In case of anonymous Address field, Address field get promoted to Person
type Address struct {  
    city  string
    state string
}
type Person struct {  
    name string
    age  int
    Address
}

func main() {  
    p := Person{
        name: "Naveen",
        age:  50,
        Address: Address{
            city:  "Chicago",
            state: "Illinois",
        },
    }

    fmt.Println("Name:", p.name)
    fmt.Println("Age:", p.age)
    fmt.Println("City:", p.city)   //city is promoted field
    fmt.Println("State:", p.state) //state is promoted field
}
```

### Exported Unexported Struct and fields

```go
package computer

type Spec struct { //exported struct  
    Maker string //exported field
    Price int //exported field
    model string //unexported field
}
```

### Structs Equality

**Structs are value types and are comparable if each of their fields are comparable. Two struct variables are considered equal if their corresponding fields are equal.**

```go
name1 := name{
    firstName: "Steve",
    lastName:  "Jobs",
}
name2 := name{
    firstName: "Steve",
    lastName:  "Jobs",
}
if name1 == name2 {
    fmt.Println("name1 and name2 are equal") //it will get printed
} else {
    fmt.Println("name1 and name2 are not equal")
}
```

