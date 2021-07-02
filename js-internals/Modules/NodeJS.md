//You can think of each Node.js module as a self-contained function like the following one:

(function (exports, require, module, __filename, __dirname) {
    module.exports = exports = {};
    // Your module code ...
});


//Module.exports vs exports

//module.exports use for class or self contained object
// exports use for function 

class Cat {
    makeSound() {
        return 'Meowww';
    }
}

exports.area = radius => (radius ** 2) * PI;
exports.circumference = radius => 2 * radius * PI;

// exports = Cat; // It will not work with `new Cat();`
// exports.Cat = Cat; // It will require `new Cat.Cat();` to work (yuck!)
module.exports = Cat;



const Cat = require('./cat');
const area = require('./cat').area

const cat = new Cat();
console.log(cat.makeSound());

// Starting with version 8.5.0+, Node.js supports ES modules natively with a feature flag

export function area(radius) {
    return (radius ** 2) * PI;
}

export function circumference(radius) {
    return 2 * radius * PI;
}

import { area, circumference } from './circle.mjs';

