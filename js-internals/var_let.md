# Difference between var let & const

- Scope

  - All the scope of 'var' is at function level, not at block level
  - All the scope of 'let' & 'const' is at block level.

- Global Var

  ```javascript
  let me = 'go';  // globally scoped
  const c = 'TEST';
  var i = 'able'; // globally scoped
  //However, global variables defined with let will not be added as properties on the global window object like those defined with var.
  console.log(window.me); // undefined
  console.log(window.c); //undefined
  console.log(window.i); // 'able'
  ```

- Hoisting

  - var declaration get hoisted, at function level block
  - let and const declaration never get hoisted

- Redeclaration:

  - var let you re-declare same variable in the the same scope.
  
    ```javascript
    function test(arg){
        var arg = 5; //Redeclare of arg, give no error
    }
    ```
  
  - let and const always through error on re-declaration of same variable in same scope.
  
    ```javascript
    function test(arg){
    	let arg = 5; //Give Syntax Error
    }
    ```
  
    
  
  