## Coercion

In JavaScript conversion between different two build-in types called `coercion`. Coercion comes in two forms in JavaScript: *explicit* and *implicit*.

 "type casting" (or "type conversion") occur in statically typed languages at compile time, while "type coercion" is a runtime conversion for dynamically typed languages.

Four most used coercion methods

### String conversion

To explicitly convert values to a string apply the `String()` function. Implicit coercion is triggered by the binary `+` operator, when any operand is a string:

```javascript
String(123) // explicit
123 + ''    // implicit
```

All primitive values are converted to strings naturally as you might expect:

```javascript
String(123)                   // '123'
String(-12.3)                 // '-12.3'
String(null)                  // 'null'
String(undefined)             // 'undefined'
String(true)                  // 'true'
String(false)                 // 'false'
String([1,2,3])				  // '1,2,3'
String({})					  // '[object Object]'
```

Symbol conversion is a bit tricky, because it can only be converted explicitly, but not implicitly. [Read more](https://leanpub.com/understandinges6/read/#leanpub-auto-symbol-coercion) on `Symbol` coercion rules.

```javascript
String(Symbol('my symbol'))   // 'Symbol(my symbol)'
'' + Symbol('my symbol')      // TypeError is thrown
```

### Boolean conversion

To explicitly convert a value to a boolean apply the `Boolean()` function.
Implicit conversion happens in logical context, or is triggered by logical operators ( `||` `&&` `!`) .

```javascript
Boolean(2)          // explicit
if (2) { ... }      // implicit due to logical context
!!2                 // implicit due to logical operator
2 || 'hello'        // implicit due to logical operator
```

**Note**: Logical operators such as `||` and `&&` do boolean conversions internally, but [actually return the value of original operands](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Guide/Expressions_and_Operators#Logical_operators), even if they are not boolean.

```javascript
// returns number 123, instead of returning true
// 'hello' and 123 are still coerced to boolean internally to calculate the expression
let x = 'hello' && 123;   // x === 123
```

As soon as there are only 2 possible results of boolean conversion: `true` or `false`, it’s just easier to remember the list of falsy values.

```javascript
Boolean('')           // false
Boolean(0)            // false     
Boolean(-0)           // false
Boolean(NaN)          // false
Boolean(null)         // false
Boolean(undefined)    // false
Boolean(false)        // false
```

Any value that is not in the list is converted to `true`, including object, function, `Array`, `Date`, user-defined type, and so on. Symbols are truthy values. Empty object and arrays are truthy values as well:

```javascript
Boolean({})             // true
Boolean([])             // true
Boolean(Symbol())       // true
!!Symbol()              // true
Boolean(function() {})  // true
```

### Numeric conversion

For an explicit conversion just apply the `Number()` function, same as you did with `Boolean()` and `String()` .

Implicit conversion is tricky, because it’s triggered in more cases:

- comparison operators (`>`, `<`, `<=`,`>=`)
- bitwise operators ( `|` `&` `^` `~`)
- arithmetic operators (`-` `+` `*` `/` `%` ). Note, that binary`+` does not trigger numeric conversion, when any operand is a string.
- unary `+` operator
- loose equality operator `==` (incl. `!=`). 
  Note that `==` does not trigger numeric conversion when both operands are strings.

```javascript
Number('123')   // explicit
+'123'          // implicit
123 != '456'    // implicit
4 > '5'         // implicit
5/null          // implicit
true | 0        // implicit
```

Here is how primitive values are converted to numbers:

```javascript
Number(null)                   // 0
Number(undefined)              // NaN
Number(true)                   // 1
Number(false)                  // 0
Number(" 12 ")                 // 12
Number("-12.34")               // -12.34
Number("\n")                   // 0
Number(" 12s ")                // NaN
Number(123)                    // 123
Number([])					   // 0
Number([1])                    // 1
Number([1,2])				   // NaN
Number({})                     // NaN
```

When converting a string to a number, the engine first trims leading and trailing whitespace, `\n`, `\t` characters, returning `NaN` if the trimmed string does not represent a valid number. If string is empty, it returns `0`.

`null` and `undefined` are handled differently: `null` becomes `0`, whereas `undefined`becomes `NaN`.

Symbols cannot be converted to a number neither explicitly nor implicitly. Moreover, `TypeError` is thrown, instead of silently converting to `NaN`, like it happens for `undefined`. See more on Symbol conversion rules on [MDN](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Symbol#Symbol_type_conversions).

```javascript
Number(Symbol('my symbol'))    // TypeError is thrown
+Symbol('123')                 // TypeError is thrown
```

### Type coercion for objects

So far, we’ve looked at type coercion for primitive values. That’s not very exciting.

When it comes to objects and engine encounters expression like `[1] + [2,3]`, first it needs to convert an object to a primitive value, which is then converted to the final type. And still there are only three types of conversion: numeric, string and boolean.

The simplest case is boolean conversion: any non-primitive value is always 
coerced to `true`, no matter if an object or an array is empty or not.

Objects are converted to primitives via the internal `[[ToPrimitive]]` method, which is responsible for both numeric and string conversion.

Here is a pseudo implementation of `[[ToPrimitive]]` method:

`[[ToPrimitive]]` is passed with an input value and preferred type of conversion: `Number` or `String`. `preferredType` is optional.

Both numeric and string conversion make use of two methods of the input object: `valueOf` and `toString` . Both methods are declared on `Object.prototype` and thus available for any derived types, such as `Date`, `Array`, etc.

In general the algorithm is as follows:

1. If input is already a primitive, do nothing and return it.

\2. Call `input.toString()`, if the result is primitive, return it.

\3. Call `input.valueOf()`, if the result is primitive, return it.

\4. If neither `input.toString()` nor `input.valueOf()` yields primitive, throw `TypeError`.

Numeric conversion first calls `valueOf` (3) with a fallback to `toString` (2). String conversion does the opposite: `toString` (2) followed by `valueOf` (3).

```javascript
true + false             // 1
12 / "6"                 // 2
"number" + 15 + 3        // 'number153'
15 + 3 + "number"        // '18number'
[1] > null               // true
"foo" + + "bar"          // 'fooNaN'
'true' == true           // false
false == 'false'         // false
null == ''               // false
!!"false" == !!"true"    // true
['x'] == 'x'             // true 
[] + null + 1            // 'null1'
[1,2,3] == [1,2,3]       // false
{}+[]+{}+[1]             // '0[object Object]1'
!+[]+[]+![]              // 'truefalse'
new Date(0) - 0          // 0
new Date(0) + 0          // 'Thu Jan 01 1970 02:00:00(EET)0'
```



### Source

https://www.freecodecamp.org/news/js-type-coercion-explained-27ba3d9a2839/