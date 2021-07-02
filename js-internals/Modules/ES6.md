//http://exploringjs.com/es6/ch_modules.html#sec_overview-modules


//Multiple named exports 
//There can be multiple named exports:

//------ lib.js ------
export const sqrt = Math.sqrt;
export function square(x) {
    return x * x;
}
export function diag(x, y) {
    return sqrt(square(x) + square(y));
}

//------ main.js ------
import { square, diag } from 'lib';
console.log(square(11)); // 121
console.log(diag(4, 3)); // 5
//You can also import the complete module:

//------ main.js ------
import * as lib from 'lib';
console.log(lib.square(11)); // 121
console.log(lib.diag(4, 3)); // 5


//Single default export 
//There can be a single default export. For example, a function:

//------ myFunc.js ------
export default function() {  }; // no semicolon!

//------ main1.js ------
import myFunc from 'myFunc';
myFunc();
//Or a class:

//------ MyClass.js ------
export default class {  } // no semicolon!

//------ main2.js ------
import MyClass from 'MyClass';
const inst = new MyClass();