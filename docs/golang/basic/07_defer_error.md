# Defer
Defer statements delay the execution of the function or method or an anonymous method until the nearby functions returns. It is equivalent to finally in java (but without try catch). It will even get executed in case of **panic** Multiple defer statement get executed in stack order (first statement get executed at last)

```go
package main

import (  
    "fmt"
)

func main() {  
    name := "Naveen"
    fmt.Printf("Original String: %s\n", string(name))
    fmt.Printf("Reversed String: ")
    for _, v := range []rune(name) {
        defer fmt.Printf("%c", v) //one character at a time
    }
}

//This program will output,

//Original String: Naveen  
//Reversed String: neevaN  
```

# Errors
Errors indicate an abnormal condition occurring in the program. Let's say we are trying to open a file and the file does not exist in the file system. This is an abnormal condition and it's represented as an error. There is no exception handling. Functions that might produce an error just declare an additional return value of type Error. 

## This is the Error interface:
```go
type error interface {
    Error() string
}
```

## How to use function, which return an error
```go
func doStuff() (int, error) {
}

func main() {
    result, err := doStuff()
    if err != nil {
        // handle error
    } else {
        // all is good, use result
    }
}
```

## Throw or Return a new Error instance from a function. 
By convention, error variable should be last return. variable.
- **errors.New**
```go
func Sqrt(f float64) (float64, error) {
    if f < 0 {
        return 0, errors.New("math: square root of negative number")
    }
    return math.Sqrt(f), nil
}
```
- **fmt.Errorf**
```go
func Sqrt(f float64) (float64, error) {
    if f < 0 {
        return 0, fmt.Errorf("math: square root of negative number %g", f)
    }
    return math.Sqrt(f), nil
}
```

## Declare a custom error
```go
type NegativeSqrtError float64

func (f NegativeSqrtError) Error() string {
    return fmt.Sprintf("math: square root of negative number %g", float64(f))
}

func Sqrt(f float64) (float64, error) {
    if f < 0 {
        return 0, NegativeSqrtError(f)
    }
    return math.Sqrt(f), nil
}
```

## Print error stacktrace
We can print error stacktrace using **%+v** instead of **%v** in the format pattern
```go
import (
   "github.com/pkg/errors"
   "fmt"
)

func A() error {
   return errors.New("NullPointerException")
}

func B() error {
   return A()
}

func main() {
   fmt.Printf("Error: %+v", B())
}
```

## Providing more information about the error using fields and methods on struct types
```go
package main

import "fmt"

type areaError struct {  
    err    string  //error description
    length float64 //length which caused the error
    width  float64 //width which caused the error
}

func (e *areaError) Error() string {  
    return e.err
}

func (e *areaError) lengthNegative() bool {  
    return e.length < 0
}

func (e *areaError) widthNegative() bool {  
    return e.width < 0
}

func rectArea(length, width float64) (float64, error) {  
    err := ""
    if length < 0 {
        err += "length is less than zero"
    }
    if width < 0 {
        if err == "" {
            err = "width is less than zero"
        } else {
            err += ", width is less than zero"
        }
    }
    if err != "" {
        return 0, &areaError{err, length, width}
    }
    return length * width, nil
}

func main() {  
    length, width := -5.0, -9.0
    area, err := rectArea(length, width)
    if err != nil {
        if err, ok := err.(*areaError); ok {
            //method
            if err.lengthNegative() {
                fmt.Printf("error: length %0.2f is less than zero\n", err.length)

            }
            if err.widthNegative() {
                fmt.Printf("error: width %0.2f is less than zero\n", err.width)
            }
            //field
            if len(err.err) > 0 {
                fmt.Printf("error: %s\n", err.err)
            }
            return
        }
    }
    fmt.Println("area of rect", area)
}
```