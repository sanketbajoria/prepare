// Code goes here

function ajax(cb){
    setTimeout(function(){
      cb(1);
    }, 2)
  }
  
  function promisifyAjax1(){
    var defer = new Defer();
    ajax(defer.resolve);
    return defer.promise;
  }
  
  
  function promisifyAjax2(){
    return new Promise((resolve, reject) => {
      ajax(resolve);
    })
  }
  
  function pollingAjax(cb){
    setInterval(function(){
      cb(Math.random());
    },5);
  }
  
  function observablePollingAjax(){
    return Rx.Observable.create(function(observer){
      pollingAjax(observer.onNext)
    });
  }
  
  