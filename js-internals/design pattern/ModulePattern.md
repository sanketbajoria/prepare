//IIFE
(function(){
    //IIFE, close context to avoid global scope cluttering
}());

//Module Pattern
////Private variable/methods are not exposed and can be accessed by public Method and private methods only.
var module = (function(){
    var a = 10;
    var myPrivateMethod = function(){
        console.log("I am private method");
    }
    return {
        publicMethod: function(){
            console.log("I am public method, i can access a - " + a);
        }
    }
})();


//Revealing Module Pattern
////Similar to above, just cleaner approach and clear intent
var module = (function(){
    var a = 10;
    var myPrivateMethod = function(){
        console.log("I am private method");
    }
    var publicMethod = function(){
            console.log("I am public method, i can access a - " + a);
    };
    return {
        publicMethod: publicMethod 
    }
})();