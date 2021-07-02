## Errors
There is no exception handling. Functions that might produce an error just declare an additional return value of type Error. 

#### This is the Error interface:
```go
type error interface {
    Error() string
}
```

#### How to use function, which return an error
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

#### Throw or Return a new Error instance from a function. 
By convention, error variable should be last return. variable.
- errors.New
```go
func Sqrt(f float64) (float64, error) {
    if f < 0 {
        return 0, errors.New("math: square root of negative number")
    }
    return math.Sqrt(f), nil
}
```
- fmt.Errorf
```go
func Sqrt(f float64) (float64, error) {
    if f < 0 {
        return 0, fmt.Errorf("math: square root of negative number %g", f)
    }
    return math.Sqrt(f), nil
}
```

#### Declare a custom error
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

#### Print error stacktrace
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