//After specific time of 1000 millisecond, task will be pushed to event queue
var cancelTimeout = setTimeout(function () {

}, 1000);
clearTimeout(cancelTimeout);

//After every interval of 1000 millisecond, task will be continuously pushed to event queue
var cancelInterval = setInterval(function () {

}, 1000);
clearInterval(cancelInterval);


//After task completion + interval of 1000 millisecond, task will be again pushed to event queue
var scheduleTask = function (task, interval) {
    var cancelSchedule;
    function schedule() {
        //finishing task
        task();
        cancelSchedule = setTimeout(schedule, interval);
    }
    schedule();
    return {
        cancel: function(){
            clearTimeout(cancelSchedule);
        }
    }
}
scheduleTask(function(){console.log("a")}, 2000)
