# Golang Control Flow
There are three kinds of basic control flow in Golang:

# if else statement

```go
if condition1 {  
...
} else if condition2 {
...
} else {
...
}

// if with assignment
if assignment-statement; condition {  
}
if num := 10; num % 2 == 0 { //checks if number is even
   fmt.Println(num,"is even") 
}
```

# Loop

```go
for [initialisation;] condition[; post] {  //initialisation and post are optional
}

for i := 1; i <= 10; i++ {
  fmt.Printf(" %d",i)
}

//behave like while
for i<=10 {
  fmt.Printf(" %d",i)  
}

//infinite loop
for {
}

//support break and continue

//special support for break with label
func main() {  
outer:  
    for i := 0; i < 3; i++ {
        for j := 1; j < 4; j++ {
            fmt.Printf("i = %d , j = %d\n", i, j)
            if i == j {
                break outer
            }
        }

    }
}

```

# Switch

```go
//as in other language break is not required after each case.
switch finger {
    case 1:
        fmt.Println("Thumb")
    case 2:
        fmt.Println("Index")
    default:
    	fmt.Println("Not a finger")
}

//Multiple expression case and expressionless example
letter := "i"
switch [letter] { //letter is optional here
    case "a", "e", "i", "o", "u": //multiple expressions in case
     	fmt.Println("vowel")
    default:
     	fmt.Println("not a vowel")
}

//Fallthrough happens even when the case evaluates to false
switch num := 25; { 
    case num < 50:
    	fmt.Printf("%d is lesser than 50\n", num)
    	fallthrough
    case num > 100:
    	fmt.Printf("%d is greater than 100\n", num)     
}
//it will print both, because of fallthrough
//25 is lesser than 50  
//25 is greater than 100  

//use break to terminate early in case
switch num := -5; {
    case num < 50:
        if num < 0 {
            break
        }
        fmt.Printf("%d is lesser than 50\n", num)
        fallthrough
    case num < 100:
        fmt.Printf("%d is lesser than 100\n", num)
        fallthrough
    case num < 200:
        fmt.Printf("%d is lesser than 200", num)
}

//type switches
func do(i interface{}) {
	switch v := i.(type) {
	case int:
		fmt.Printf("Twice %v is %v\n", v, v*2)
	case string:
		fmt.Printf("%q is %v bytes long\n", v, len(v))
	default:
		fmt.Printf("I don't know about type %T!\n", v)
	}
}
```



