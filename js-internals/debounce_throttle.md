//Debounce, if continuous events are firing, we can do something after event has been stopped for some time

function debounce(cb, wait) {
    var cancelTimeout; //to cancel any existing timeout
    //debounce return another function wrapping cb.
    return function () {
        var context = this, args = arguments;
        var later = function () {
            //if timeout expires, then do below
            cancelTimeout = null;
            cb.apply(context, arguments);
        }
        if (cancelTimeout) {
            //if executed this function again with some event, then clear the existing timeout.
            clearTimeout(cancelTimeout);
        }
        cancelTimeout = setTimeout(later, wait);
    }
}

//Usage
var myEfficientFn = debounce(function () {
    // All the taxing stuff you do
}, 250);

window.addEventListener('resize', myEfficientFn);


//Throttle, if continuous events are firing, we can collate all the events within a time, and fire one callback.
//with leading, callback execute immediately
//with trailing means callback execute after the wait.
function throttle(cb, wait, trailing) {
    var check;
    return function () {
        if (!check) {
            var context = this, args = arguments;
            if(!trailing){
                //leading
                cb.apply(context, arguments);
            }
            check = true;
            setTimeout(function () {
                check = false;
                if(trailing){
                    cb.apply(context, arguments);
                }
            }, wait);
        }
    }
}

