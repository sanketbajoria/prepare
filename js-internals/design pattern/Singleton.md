
//Simple singleton object
//We can't initialize with any property, since on constructor.
var obj = {

}

//Singleton through module pattern
//Can be initialized with property, since init can act as constructor.
var Singleton = (function(){
    var instance;
    var init = function(){
        return {};
    }

    return {
        getInstance: function(){
            if(!instance){
                instance = init.apply(this, arguments);
            }
            return instance;
        }
    }

})();

