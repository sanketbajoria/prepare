```javascript
var arr = [];
//size
arr.length;

//Mutable methods below

//add element at last
arr.push();
//add element at start
arr.unshift();
//add element in middle
arr.splice(idx,0,items);

//remove from last
arr.pop()
//remove from first
arr.shift()

//remove from middle
//modify existing array
arr.splice(idx,1)

//sorting array
arr.sort()
//Keep in mind it will sort the original array, lexographically, irrespective if element inside is number
//For eg, if i sort [2,3,10], then after arr.sort() it will be [10,2,3] 
//To make it correct, please pass comparator function
arr.sort(function(a,b){return a-b})
//Then output will be [2,3,10]

//reverse array
arr.reverse()

```

```javascript
//Functional programming
//map,reduce,filter,reduceRight,find,findIndex
[1,2,3].map(function(x){return x*x}); //output [1,4,9]

//Reduce from left to right
[1,2,3].reduce(function(x,y){return x+""+y}, ""); //output "123"

[1,2,3].filter(function(x){return x%2==0}); //output [2]

//Reduce from right to left
[1,2,3].reduceRight(function(x,y){return x+""+y}, ""); //output "321"

[1,2,3,4].find(function(x){return x>2}); //output 3

[1,2,3,4].findIndex(function(x){return x>2}); //output 2
```

```javascript
//Immutable methods below
//sublist or cloning
arr.slice()

//append one arr to another
//doesn't modify arr, but return new array
arr.concat(arr2) 


//join array
["a", "b", "c"].join("-")
//output: "a-b-c"
```




