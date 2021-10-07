# Variable

Variable is the name given to a memory location to store a value of a specific [type](https://golangbot.com/types/). There are various syntaxes to declare variables in Go.

```go
//single variable
var age int //variable declaration
var age int = 5 //variable declaration with initial value
var age = 5 //type inference
age := 5 //short hand syntax (variable declaration with initial value) (only local variable are allowed, if global variable are declared, with short hand expression then, it will give error)

//multiple variable
var age1,age2 int // multiple variable declaration of same type
var age1,age2 int = 4, 4 //multiple variable declaration with initial values
var (					//multiple variable with different type with initial values
	name   = "naveen"
    age    = 29
    height int
)
name,age := "naveen",29  //short hand syntax (multiple variable with different type with initial values)(only local variable are allowed, if global variable are declared, with short hand expression then, it will give error)


```



# Constants

The term constant in Go is used to denote fixed values such as

```go
95  
"I love Go" 
67.89  
```

constant variable have few properties

- It cannot be reassigned. 
- While declaration, initial value should be assigned to it
- initial value should be able to get calculated during compilation. If initial value dependent of function call, then it will throw error.
- It can be assigned to another variable.

```go
//single constant variable
const age int = 5
const age = 5 //Type inference

//multiple constant variable
const age1,age2 int = 4, 4 //multiple variable declaration with initial values
const (					//multiple variable with different type with initial values
	name   = "naveen"
    age int   = 29
)

//Error condition
const age = 5 
age = 6 // error, const variable cannot be reassigned

const age int // error, initial value should be assigned, while declaration
const age = math.Sqrt(4) //error, initial value dependent on function call, cannot be determine during compile time.

```

