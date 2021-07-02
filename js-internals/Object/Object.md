//__proto__ and prototype

//Every function object contain prototype as property, which is used to create a new corresponding prototype object. 
function A(){

}
A.prototype.constructor === A //true

var a = new A();
// a ---> A.prototype --> Object.prototype ---> null

a.__proto__ === A.prototype //true
a.__proto__.constructor === A //true


//Object.create vs new
var a = {a: 1}; 
// a ---> Object.prototype ---> null

var b = Object.create(a);
// b ---> a ---> Object.prototype ---> null
console.log(b.a); // 1 (inherited)

