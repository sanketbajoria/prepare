//To create a new Promise, two way

//First Way
var defer = Promise.defer();
defer.reject(); defer.resolve() //Publishing component will utilize resolve and reject hooks
defer.promise //Subscribing component will utilize to register their success or error handler


//Second Way
//Subscribing component will utilize below new promise to register their success or error handler
new Promise((resolve, reject) => {
    //Publishing component will utilize resolve and reject hooks
})

//First Way is already obsolete and deprecated, since, error handling doesn't work well, it get propagated to subscribation part.
//Seconed way is the right way to create it




//Use a promise object
var p = new Promise();
p.then
p.catch
p.finally //Available in bluebird
//More example at chaining.js


//Static method of promise
Promise.resolve //Create a new promise with success value
Promise.reject //Create a new promise with reject value
Promise.all 
Promise.race
