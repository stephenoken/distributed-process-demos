function fib(n, a = 0, b = 1) {
  return (n > 1)? [a].concat(fib(n-1,b,a + b)): [a];
}

console.log(fib(10));
