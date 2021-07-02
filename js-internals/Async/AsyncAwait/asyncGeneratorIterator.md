# Generator and Iterator
As we already know, JavaScript also supports generators, and they are iterable.

Let’s recall a sequence generator from the chapter Generators. It generates a sequence of values from start to end:
```javascript
function* generateSequence(start, end) {
  for (let i = start; i <= end; i++) {
    yield i;
  }
}

for(let value of generateSequence(1, 5)) {
  alert(value); // 1, then 2, then 3, then 4, then 5
}
```

# Async Generator and Iterator
In regular generators we can’t use await. All values must come synchronously: there’s no place for delay in for..of, it’s a synchronous construct.

But what if we need to use await in the generator body? To perform network requests, for instance.

No problem, just prepend it with async, like this:
   
```javascript

async function* generateSequence(start, end) {

  for (let i = start; i <= end; i++) {

    // yay, can use await!
    await new Promise(resolve => setTimeout(resolve, 1000));

    yield i;
  }

}

(async () => {

  let generator = generateSequence(1, 5);
  for await (let value of generator) {
    alert(value); // 1, then 2, then 3, then 4, then 5
  }

})();
```

Now we have the async generator, iterable with for await...of.

It’s indeed very simple. We add the async keyword, and the generator now can use await inside of it, rely on promises and other async functions.

Technically, another difference of an async generator is that its generator.next() method is now asynchronous also, it returns promises.

In a regular generator we’d use result = generator.next() to get values. In an async generator, we should add await, like this:

result = await generator.next(); // result = {value: ..., done: true/false}