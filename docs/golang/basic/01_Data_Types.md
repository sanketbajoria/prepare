# Data types
Data types specify the type of data that a valid Go variable can hold. In Go language, the type is divided into four categories which are as follows:
- **Basic type**: Numbers, strings, and booleans come under this category.
- **Aggregate type**: Array and structs come under this category. (**Derived Type**)
- **Reference type**: Pointers, slices, maps, functions, and channels come under this category. (**Derived Type**)
- **Interface type**:

## Basic Type
The zero value is:

    0 for numeric types,
    false for the boolean type, and
    "" (the empty string) for strings.
### Integer
**int8**	8-bit signed integer **range:** -128 to 127
**int16**	16-bit signed integer **range:** -32768 to 32767
**int32**	32-bit signed integer **range:** -2147483648 to 2147483647
**int64**	64-bit signed integer<br>
**uint8**	8-bit unsigned integer<br>
**uint16**	16-bit unsigned integer<br>
**uint32**	32-bit unsigned integer<br>
**uint64**	64-bit unsigned integer<br>
**int**	    Both int and uint contain same size, either 32 or 64 bit.<br>
**uint**	Both int and uint contain same size, either 32 or 64 bit.<br>
**rune**	It is a synonym of int32 and also represent Unicode code points.<br>
**byte**	It is a synonym of int8.<br>
**uintptr**	It is an unsigned integer type. Its width is not defined, but its can hold all the bits of a pointer value.<br>



### Float
**float32**	32-bit IEEE 754 floating-point number<br>
**float64**	64-bit IEEE 754 floating-point number<br>
<br>

### Complex Number
**complex64**	Complex numbers which contain float32 as a real and imaginary component.
**complex128**	Complex numbers which contain float64 as a real and imaginary component.



### Boolean
**bool**  true/false



### Strings
**string** Immutable



### Type Conversion

Go is very strict about explicit typing. There is no automatic type promotion or conversion. Let's look at what this means with an example.

```go
package main

import (  
    "fmt"
)

func main() {  
    i := 55      //int
    j := 67.8    //float64
    sum := i + j //int + float64 not allowed to fix it use int(j)
    fmt.Println(sum)
}
```

Explicit Type conversion done with 

```go
type A int

int8(a)
int(a)
float64(a)
string(a)
[]byte(a)
[]rune(a)
.
.
.

var a = 15
var b = A(a)
```



### Notes

Type of variable can be printed via **%T**
