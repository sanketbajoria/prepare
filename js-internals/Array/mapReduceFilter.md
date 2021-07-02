### Implement map function for Array

```javascript
Array.prototype.map = function(cb){
    var arr = Object(this);
    var res = []
    for(var i=0;i<arr.length;i++){
        res[i] = cb.call(arr[i], i);
    }
    return res;
}
```



### Implement reduce function for Array

```javascript
Array.prototype.reduce = function(cb, res){
    var arr = Object(this);
    for(var i=0;i<arr.length;i++){
        res = cb.call(res, arr[i], i);
    }
    return res;
}
```



### Implement filter function for Array

```javascript
Array.prototype.filter = function(cb){
    var arr = Object(this);
    var res = [];
    for(var i=0;i<arr.length;i++){
        if(cb(arr[i])){
            res.push(arr[i]);
        }
    }
    return res;
}
```

