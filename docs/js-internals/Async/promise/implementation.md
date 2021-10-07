var ref = function (value) {
    if (value && typeof value.then === "function")
        return value;
    return {
        then: function (callback) {
            return ref(callback(value));
        }
    };
};

function Promise(cb){
    //cb -- (resolve, reject) => {}
    //Keep track of callback handler & end value of this promise
    var successHandler = [], errorHandler = [], value;
    //Keep status of promise -- pending/resolved/rejected
    var status = 'pending';
    //publish the result
    var resolve = function (result) {
        if (status == 'pending') {
            value = ref(result);
            status = 'resolved';
            successHandler.forEach(function (f) {
                setTimeout(function () { value.then(f) }, 0);
            });
        }

    }
    var reject = function () {
        //similar to resolve    
    }
    cb(resolve, reject);
    return {
        then: function(_success, _error){
            //if pending
                //add to successhandler and errorhandler
            //else
                //invoke success or error appropriately
        }
    }
}

function Defer() {
    //Keep track of callback handler & end value of this promise
    var successHandler = [], errorHandler = [], value;
    //Keep status of promise -- pending/resolved/rejected
    var status = 'pending';
    return {
        //publish the result
        resolve: function (result) {
            if (status == 'pending') {
                value = ref(result);
                status = 'resolved';
                successHandler.forEach(function (f) {
                    setTimeout(function () { value.then(f) }, 0);
                });
            }

        },
        reject: function () {
            //similar to resolve    
        },
        promise: {
            //subscribe for the result of asynchronous task
            then: function (_success, _error) {
                var defer = Defer();
                var success = function (value) {
                    defer.resolve(_success(value));
                }
                var error = function (value) {
                    defer.reject(_error(value));
                }
                if (status == 'pending') {
                    successHandler.push(success);
                    if (error)
                        errorHandler.push(error);
                } else {
                    value.then(success, error);
                }
                return defer.promise;
            }
        }

    }
}

