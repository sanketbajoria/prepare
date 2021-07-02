//Variable Hoisting with declaration and not defintion
console.log(a);
var a = 10;
//Output -- undefined

//Variable Function Hoisting same behavior as variable Hoisting
console.log(a);
var a = function(){}
//Output -- undefined

//Function Hoisting with declaration and definition
console.log(a);
function a(){}
//Output -- function definition