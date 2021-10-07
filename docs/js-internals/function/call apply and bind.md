

### call syntax

```javascript
function.call(thisArg, arg1, arg2, ...)
```



### apply syntax

```javascript
function.apply(thisArg, [argsArray])
```



### bind syntax

```javascript
function.bind(thisArg)
```





### Comparison `call/apply` and `bind` 

|                        | time of function execution | time of this binding |      |
| ---------------------- | :------------------------: | :------------------: | ---- |
| function declaration f |           future           |        future        |      |
| function call f()      |            now             |         now          |      |
| f.apply()              |            now             |         now          |      |
| f.call()               |            now             |         now          |      |
| f.bind()               |           future           |         now          |      |