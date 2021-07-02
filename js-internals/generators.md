//Concepts involve
//https://davidwalsh.name/es6-generators
// yield
// yield*
// function *
//Generator.prototype.next()
    //Returns a value yielded by the yield expression.
//Generator.prototype.return()
    //Returns the given value and finishes the generator.
//Generator.prototype.throw()
    //Throws an error to a generator.

//Simple generator example
function *foo() {
    yield 1;
    yield 2;
    return 3;
}

console.log( it.next() ); // { value:1, done:false }
console.log( it.next() ); // { value:2, done:false }
console.log( it.next() ); // { value:3, done:true }

for (var v of foo()) {
    console.log( v );
}
//1 2
//No 3 using for of


//Nested generator example
function *parentFoo(){
    yield* foo();
    yield 4;
    return 5;
}

var it = parentFoo();

console.log( it.next() ); // { value:1, done:false }
console.log( it.next() ); // { value:2, done:false }
console.log( it.next() ); // { value:4, done:false }
console.log( it.next() ); // { value:5, done: true}
//No 3 is available.

for (var v of parentFoo()) {
    console.log( v );
}
//1 2 4


//Control passed b/w callee and caller function, example
function *foo(x) {
    var y = 2 * (yield (x + 1));
    var z = yield (y / 3);
    return (x + y + z);
}

var it = foo( 5 );

// note: not sending anything into `next()` here
console.log( it.next() );       // { value:6, done:false }
console.log( it.next( 12 ) );   // { value:8, done:false }
console.log( it.next( 13 ) );   // { value:42, done:true }