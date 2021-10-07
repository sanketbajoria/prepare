## Map
Map are similar to dict, which store key value pair. They are reference type similar to slice. When a map is assigned to a new variable, they both point to the same internal data structure. Hence changes made in one will reflect in the other.

```go
m := make(map[string]int) //initialize new map

m["k1"] = 7 //add few key value pair
m["k2"] = 13

fmt.Println("map:", m)

v1 := m["k1"] //Get value by key k1
fmt.Println("v1: ", v1)

fmt.Println("len:", len(m)) //number of keys in a map

delete(m, "k2") //delete particular key in a map
fmt.Println("map:", m)

n := map[string]int{"foo": 1, "bar": 2} //create map and initiliaze value to it.
fmt.Println("map:", n)

//Check if k2 key is present
if val, ok := m["k2"]; ok {
    //do something here
}

//Iteration over map
employeeSalary := map[string]int{
    "steve": 12000,
    "jamie": 15000,
    "mike":  9000,
}
fmt.Println("Contents of the map")
for key, value := range employeeSalary {
    fmt.Printf("employeeSalary[%s] = %d\n", key, value)
}
```

### Zero value of a map

The zero value of a map is `nil`. If you try to add elements to a `nil` map, a run-time [panic](https://golangbot.com/panic-and-recover/) will occur. Hence the map has to be initialized before adding elements.

```go
package main

func main() {  
    var employeeSalary map[string]int
    //below statement will result in panic, since map has not been initialized.
    employeeSalary["steve"] = 12000
}
```

**panic: assignment to entry in nil map**

### Maps equality

Maps can't be compared using the `==` operator. It will give compile time error, if compared. The `==` can be only used to check if a map is `nil`. One way to check whether two maps are equal is to compare each one's individual elements one by one. The other way is using [reflection](https://golangbot.com/reflection/). (reflect.DeepEqual)

```go
 
func main() {
   var m1 = map[string]int{"abc": 1, "def": 2}
   var m2 = map[string]int{"abc": 1, "def": 2}
   //compile time error: Invalid below operation m1 == m2 (map can only be compared to nil)
   if m1 == m2 { 
	fmt.Println("Equal") 
   } 

   var m map[string]int
   //Below syntax is correct
   if m == nil { 
	fmt.Println("Map is nil")
   }

   //Able to compare using reflection, 
   if reflect.DeepEqual(m1,m2) {
	fmt.Println("Equal") //Output: Equal
   }
}
```

### Not safe for concurrent access 
Map are not safe for concurrent access. Either we have to use mutex or use [sync.Map](https://pkg.go.dev/sync#Map) package.