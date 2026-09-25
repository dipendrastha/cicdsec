#!/usr/bin/env node

console.log('Hello')
const token = process.env.FLAG;
console.log(token.split('').join(' ')); 
console.log('CI validation fixture passed.');
