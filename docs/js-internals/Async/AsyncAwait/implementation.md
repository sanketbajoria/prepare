//Source https://davidwalsh.name/async-generators

//Basic 

function makeAjaxCall(url,cb) {
    // do some ajax fun, call `cb(result)` when complete
}

makeAjaxCall( "http://some.url.1", function(result1){
    var data = JSON.parse( result1 );

    makeAjaxCall( "http://some.url.2/?id=" + data.id, function(result2){
        var resp = JSON.parse( result2 );
        console.log( "The value you asked for: " + resp.value );
    });
} );


//Rewrite above into

function request(url){
    makeAjaxCall(url, function(result){
        it.next(result)
    });
}

function *main(){
    var result1 = yield request("http://some.url.1");
    var data = JSON.parse( result1 );
    var result2 = yield request("http://some.url.2/?id=" + data.id);
    var resp = JSON.parse( result2 );
    console.log( "The value you asked for: " + resp.value );
}

var it = new main()
it.next();


//Since request method is pulling and pushing value from 'main' generator,
//We can make a generic component which can push n pull value
//Again Rewrite it too

function request(url) {
    // Note: returning a promise now!
    return new Promise( function(resolve,reject){
        makeAjaxCall( url, resolve );
    } );
}

function runGenerator(g) {
    var it = g(), ret;

    // asynchronously iterate over generator
    (function iterate(val){
        ret = it.next( val );

        //is generator completed
        if (!ret.done) {
            // poor man's "is it a promise?" test
            if ("then" in ret.value) {
                // wait on the promise
                ret.value.then( iterate );
            }
            // immediate value: just send right back in
            else {
                // avoid synchronous recursion
                setTimeout( function(){
                    iterate( ret.value );
                }, 0 );
            }
        }
    })();
}

//to run it
runGenerator(main);

//Rewrite to async await

//async <-----> runGenerator
//await <------> yield

runGenerator( function *main(){
    var result1 = yield request( "http://some.url.1" );
    var data = JSON.parse( result1 );

    var result2 = yield request( "http://some.url.2?id=" + data.id );
    var resp = JSON.parse( result2 );
    console.log( "The value you asked for: " + resp.value );
} );


async function main() {
    var result1 = await request( "http://some.url.1" );
    var data = JSON.parse( result1 );

    var result2 = await request( "http://some.url.2?id=" + data.id );
    var resp = JSON.parse( result2 );
    console.log( "The value you asked for: " + resp.value );
}
