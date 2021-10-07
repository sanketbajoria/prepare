//use of dictionary in map
var dict = {}
dict[0] = 'zero'
delete dict[0]
Object.keys(dict)
Object.values(dict)
Object.entries(dict)

Object.assign(dict, {a: 1, b: 2})

Object.create(null)

Object.defineProperty(obj, 'key', {
  enumerable: false,
  configurable: false,
  writable: false,
  value: 'static'
});

Object.defineProperty(o, 'b', {
  // Using shorthand method names (ES2015 feature).
  // This is equivalent to:
  // get: function() { return bValue; },
  // set: function(newValue) { bValue = newValue; },
  get() { return bValue; },
  set(newValue) { bValue = newValue; },
  enumerable: true,
  configurable: true
});