
function A(){
    return new String("test");
}

var a = new A();


var obj = {
    
    get p(){

    },
    set p(){

    }
}

function A(){
    var b = 0;
    this.increment = function(){
        console.log(b++);
    }
}


class A{
    constructor(){
        var privateProp = 10;
        Object.defineProperty(this, "publicProp", {
            get:function(){
                return privateProp; 
            },
            set: function(val){
                return privateProp = val;
            }
        })
    }
}

class A{
    prototypeProp = 11;
    constructor(){
        var privateProp = 10;
        Object.defineProperty(this, "publicProp", {
            get:function(){
                return privateProp; 
            },
            set: function(val){
                return privateProp = val;
            }
        })
    }
    get t(){

    }
}