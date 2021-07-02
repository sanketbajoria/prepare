# Naming Convention

## Function
- A name must begin with a letter, and can have any number of additional letters and numbers.
- A function name cannot start with a number.
- A function name cannot contain spaces.
- If the functions with names that start with an uppercase letter will be exported to other packages. - If the function name starts with a lowercase letter, it won't be exported to other packages, but you can call this function within the same package.
- If a name consists of multiple words, each word after the first should be capitalized like this: empName, EmpAddress, etc.
- function names are case-sensitive (car, Car and CAR are three different variables).

## Variable
- Use camelCase
- A name must begin with a letter, and can have any number of additional letters and numbers.
- Acronyms should be all capitals, as in ServeHTTP
- Single letter represents index: i, j, k
- Short but descriptive names: cust not customer
- repeat letters to represent collection, slice, or array and use single letter in loop:

## Package 
- short and clear
- lower case, with no under_scores or mixedCaps
- simple noun

For eg
- time (provides functionality for measuring and displaying time)
- list (implements a doubly linked list)
- http (provides HTTP client and server implementations)