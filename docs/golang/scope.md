## Scope
```go
package main

// file scope
//They are available only to particular file
import "fmt"

// package scope
// Available within any file having same package, but it never get exported to be used by another package
const ok = true

/*
package scope
Availabe within any file having same package, and also, in any file, which import this package.
*/
const Ok = true

// package scope
func main() { // block scope starts

	//hello is only available within this block
	var hello = "Hello"

	// hello and ok are visible here
	fmt.Println(hello, ok)

} // block scope ends
```