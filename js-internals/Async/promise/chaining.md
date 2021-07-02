// Code goes here
//http://plnkr.co/edit/IHMYr9Zgiq1r8y9YjeJl?p=preview

//Syntax .then([successCb], [errorCb])
//successCb, or errorCb, if 
// 1) throw a error or return new rejected promise, then next in chain error handler will be called
// 2) return nothing, or some value or new resolved promise, then next in chain success handler will be called.
Promise.resolve("value1")

.then(function(res){
  //Will be called
  print("1st Success - " + res);
  //Returning a new promise, which will be outcome for another
  return Promise.resolve("value2");
}, function(error){
  //Won't be called, since above promise is success
})


.then(function(res){
  print("2nd Success - " + res);
  //overriding res with another value
  return "value3";  
})


.then(function(res){
  print("3rd Success - " + res);
  //returning undefined
})

.then(function(res){
  print("4th Success - " + res);
  //throwing a error
  throw "error";
})

.then(function(res){
  //Won't be called since above throw an error
}, function(err){
  //This is getting called since, error is being thrown
  print("5th Error - " + err);
  throw err;
})

.then(function(res){
  //Won't be called
}, function(err){
  //Will be called
  print("6th Error - " + err);
  //Returning undefined, which will invoke success for next handler
})

.then(function(res){
  //Will be called here
  print("7th Success - " + res);
  return Promise.reject("abc");
}, function(err){
  //Won't be called since, error is being handled by above promise handler, and return undefined instead of throwing error.
})

.then(function(res){
  //Won't be called
}, function(err){
  print("8th Error - " + err);
  return "value8";
})

.then(function(res){
  print("9th Success - " + res);
  throw "error9";
})


//Syntax -- .catch(errorCb)
//Similar rule to then, where successCb is null ie .then(null, errorCb)
.catch(function(err){
  print("10th Error - " + err);
})

.catch(function(err){
  //Won't be called, since above handler return undefined as success
  print("11th Error - " + err);
})

.then(function(res){
  //Will be called, since above to above handler return undefined as success
  print("12th Success - " + res);
  return "value9";
})

//Syntax -- .finally(handler)
//handler will be called irrespective of above success or failure
//No value will be passed to handler
// if handler 
//1) return undefined, value, or new resolved promise, then next handler will depend on previous handler return value
//2) throw error, or return a new rejected promise, then next error handler will get called with new value

.finally(function(res){
  print("13th Finally - " + res)
})

.then(function(res){
  print("14th Success - " + res);
  throw "error13";
})

.finally(function(res){
  print("15th Finally");
})

.catch(function(err){
  print("16th Catch - " + err);
  return "value16"
})
//throwing an exception in a finally block, causing the original value or exception to be forgotten. 
.finally(function(){
  //Overriding success value17 with throw error17
  throw "error17"
})

.then(function(){}, function(err){
  print("18th Error - " + err);
  throw "error18";
})
//throwing an exception in a finally block, causing the original value or exception to be forgotten. 
.finally(function(){
  //Overriding error18 with throw error17
  throw "error19";
})

.catch(function(err){
  print("19th Error - " + err);
  return Promise.resolve("value19");
})
.finally(function(){
  return Promise.resolve("value20");
})

.then(function(res){
  print("21th Success - " + res);
  return Promise.reject("value21");
})
.finally(function(){
  return Promise.resolve("value22");
})

.catch(function(err){
  print("23rd Error - " + err);
  return "value23";
})
.finally(function(){
  return Promise.reject("value24");
})
.catch(function(err){
  print("25th Error - " + err);
})








//Output
//1st Success - value1
//2nd Success - value2
//3rd Success - value3
//4th Success - undefined
//5th Error - error
//6th Error - error
//7th Success - undefined
//8th Error - abc
//9th Success - value8
//10th Error - error9
//12th Success - undefined
//13th Finally - undefined
//14th Success - value9
//15th Finally
//16th Catch - error13
//18th Error - error17
//19th Error - error19
//21th Success - value19
//23rd Error - value21
//25th Error - value24