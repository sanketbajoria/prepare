//Module Pattern
//Revealing Module Pattern
//
//Implementing Queue

function Queue(){
    var arr = [];
    return {
        enqueue: function(item){
            arr.push(item);
        },
        dequeue: function(item){
            arr.shift();
        },
        count: function(){
            return arr.length;
        }

    }
}

function Stack(){
    var arr = [];
    return {
        enqueue: function(item){
            arr.push(item);
        },
        dequeue: function(item){
            arr.pop();
        },
        count: function(){
            return arr.length;
        }

    }
}