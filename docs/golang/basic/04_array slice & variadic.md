# Array Slice and Variadic (Looping and Sorting)
We will cover basics of Array Slice and Variadic in this post. And, how can we loop and sort this data structure.

## Array
Array are a collection of elements of the same type, with fixed length. It is an aggregate type, follows copy by value semantics.
```go
var a [10]int // declare an int array with length 10. Array length is part of the type!
a[3] = 42     // set elements
i := a[3]     // read elements

// declare and initialize
var a = [2]int{}
var a = [2]int{1, 2}
a := [2]int{1, 2} //shorthand
a := [...]int{1, 2} // elipsis -> Compiler figures out array length

var b = a[lo:hi]    // creates a slice (view of the array) from index lo to hi-1, it points to same array.
var b = a[1:]		// slice from index 1 to end

//Default behaviour copy by value
b := []int{1, 2}
c := b
c[0] = 5
fmt.Println(b) // [1,2]
fmt.Println(c) // [5,2]

//Equality
a := [...]int{1, 2}
b := [...]int{1, 2}
if a == b {
	fmt.Println("Equal") //Output Equal
}

var d [2]int
// d == nil //Compiler error, since array is aggregate type, not reference type.
fmt.Println(d) // [0,0] 

```
## Slice
Slice is a view of an array, it is a contiguous region of an array. It is a reference type, follows copy by reference semantics.
```go
var a []int                              // declare a slice - similar to an array, but length is unspecified
var a = []int {1, 2, 3, 4}               // declare and initialize a slice (backed by the array given implicitly)
a := []int{1, 2, 3, 4}                   // shorthand
chars := []string{0:"a", 2:"c", 1: "b"}  // ["a", "b", "c"]

var b = a[lo:hi]	// creates a slice (view of the array) from index lo to hi-1
var b = a[1:4]		// slice from index 1 to 3
var b = a[:3]		// missing low index implies 0
var b = a[3:]		// missing high index implies len(a)
a =  append(a,17,3)	// append items to slice a
c := append(a,b...)	// concatenate slices a and b

// create a slice with make
a = make([]byte, 5, 5)	// first arg length, second capacity
a = make([]byte, 5)	// capacity is optional

// create a slice from an array
x := [3]string{"Лайка", "Белка", "Стрелка"}
s := x[1:] // a slice referencing the storage of x
s[1] = "abc"
fmt.Println(x) //[Лайка Белка abc]
fmt.Println(s) //[Белка abc]

//Default behaviour copy by ref
b := []int{1, 2}
c := b
c[0] = 5
fmt.Println(b) // [5,2]
fmt.Println(c) // [5,2]

// copy slice into another slice
slc1 := []int{58, 69, 40, 45, 11, 56, 67, 21, 65}
var slc2 []int
slc3 := make([]int, 5) // [0 0 0 0 0]
slc4 := []int{78, 50, 67, 77}

// Copying the slices
copy(slc2, slc1)
copy(slc3, slc1)
copy(slc4, slc1)
copy(slc1, slc4)

fmt.Println(slc2) // []
fmt.Println(slc3) // [58 69 40 45 11]
fmt.Println(slc4) // [58 69 40 45]

//To check length and capacity of slice
len(s) // give length of slice
cap(s) // give capacity of slice


//insert val at particular index
func insert(a []int, index int, value int) []int {
    if len(a) == index { // nil or empty slice or after last element
        return append(a, value)
    }
    a = append(a[:index+1], a[index:]...) // index < len(a)
    a[index] = value
    return a
}

//remove particular element at particular index
a = append(a[:index], a[index+1:]...)

//remove last element
a = a[:len(a)-1]

//Equality
a := []int{1, 2}
b := []int{1, 2}
var d []int

//a == b //compiler error since slice is a reference type
reflect.DeepEqual(a, b) // true 

d == nil // True, reference type can be compared to nil


```

## Variadic Function

Functions in general accept only a fixed number of arguments. *A variadic function is a function that accepts a variable number of arguments. If the last parameter of a function definition is prefixed by ellipsis **...**, then the function can accept any number of arguments for that parameter.*

### Syntax

```go
func hello(a int, b ...int) {  
}
//type of b is []int (which is slice)
```

For eg: **Append is a variadic function**

```go
func append(slice []Type, elems ...Type) []Type  
```

### How to pass slice to variadic function

```go
func find(a int, b ...int) {  
}
func main() {  
    nums := []int{89, 90, 95}
    //find(89, nums) // error we can't pass it directly
    find(89, nums...) //correct way to pass slice to variadic function
}
```

### Gotcha

Just be sure you know what you are doing when you are modifying a slice inside a variadic function.

```go
package main

import (  
    "fmt"
)

func change(s ...string) {  
    s[0] = "Go"
}

func main() {  
    welcome := []string{"hello", "world"}
    change(welcome...)
    fmt.Println(welcome) //[Go World]
}
```

## Loop
```go
// loop over an array/a slice
for i, e := range a {
    // i is the index, e the element
}

// if you only need e:
for _, e := range a {
    // e is the element
}

// ...and if you only need the index
for i := range a {
}

// In Go pre-1.4, you'll get a compiler error if you're not using i and e.
// Go 1.4 introduced a variable-free form, so that you can do this
for range time.Tick(time.Second) {
    // do it once a sec
}
```


## Sort 

```go
package main

import (
	"fmt"
	"sort"
)

type person struct {
 name string 
 age int
}

type sortStr []string

func (s sortStr) Len() int{
	return len(s)
}

func (s sortStr) Swap(i,j int) {
	s[i],s[j] = s[j],s[i]
}

func (s sortStr) Less(i,j int) bool{
	return len(s[i])<len(s[j])
}


func main() {
	//Simple sort supporting Ints, Float64s, Strings
	a := []int{1,3,5,2,7}
	sort.Ints(a)
	fmt.Println(a)
	
	//Sort using custom less function
	p := []person{{"Sam",4},{"Dave",2},{"Honey",2}, {"Joe",3}}
	sort.SliceStable(p, func(i,j int) bool{
		return p[i].age < p[j].age
	})
	fmt.Println(p)
	
	//Sort using custom data structure
	fruits2 := []string{"peach", "banana", "kiwi"}
	sort.Sort(sortStr(fruits2))
	fmt.Println(fruits2)
}

```