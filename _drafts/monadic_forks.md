# Monadic forks in other languages.

In the esoteric language J, defining a function to calculate the average of a list of number is easy to type (and hard to read):

```
average =: +/ % #
```

In short, this means take the sum (`+/`) of the list and divide it (`%`) by the number of elements in the list (`#`). In J, putting three functions or verbs together in this way is known as a monadic fork.

In a diagram, we pipe our input to the two monadic functions `a` and `b`, and route the output of these to the dyadic function `r`.

[gimmick:yuml (direction: 'LR')]( [input] -> [a], [input] -> [b], [a] -> [r], [b] -> [r], [r] -> [output] )

This structure can be used to define other potentially useful functions (in julia now):

```
*(a ::Function, b ::Function) = x -> a(b(x))
square(x) = x .* x

average = frk(sum, /, length)
range   = frk(maximum, -, minimum)
stddev  = sqrt*frk(square*average, -, average*square)
```

I want to construct the fork idiom in some more well known programming languages. More specifically, I want to:

- make a function `frk` that takes three functions as arguments,
- use ‘frk’ to construct function `avg` that will calculate the average of a list
- save this function `avg` to a variable,
- apply the function to a list of numbers.

## Julia

```
function frk(a, r, b)
  x -> r(a(x),b(x))
end

avg = frk(sum, /, length)
ans = avg([1.0, 2.0, 3.0, 4.0])
```

In julia, everything is easy. Constructing an anonymous function from the primitives `sum`, `/` and `length` is made having real first class functions.

## Python

```python
import operator

def frk(a, r, b):
  return lambda x: r(a(x), b(x))

  avg = frk(sum, operator.div, len)
  ans = avg([1.0, 2.0, 3.0, 4.0])
```

It’s almost as easy in python. The only slight disapointment is having to import a module to get the function ‘operator.div’.

## Javascript

```javascript
function frk(a, r, b) {
  return function(x) {
    return r(a(x), b(x))
  }
}

function sum(a) {
  return a.reduce(function(acc, val) {
    return acc + val
  }, 0)
}

function cnt(a) {
  return a.length
}

function div(a, b) {
  return a/b
}

avg = frk(sum, div, cnt)
ans = avg([1.0, 2.0, 3.0, 4.0])
```

Javascript is (again) almost as easy. We have to define our own sum, count and divide functions, but passing them to the fork to create the average function is easy.

## Ruby

This is my first attempt at writing ruby, so I may have missed a few tricks.

```ruby
def frk a, r, b
  lambda do |x|
    r.call(a.call(x), b.call(x))
  end
end

def sum a
  a.reduce(0) do |sum, value|
   sum + value
  end
end
sum = method :sum

def cnt a
  a.length
end
cnt = method :cnt

def div a, b
  a/b
end
div = method :div

avg = frk sum, div, cnt
ans = avg.call [1.0, 2.0, 3.0, 4.0]
```

Things are not so simple in ruby. The bracket-free syntax is kinda cute, but what is going on with the functions? Ruby allows you to define procedures on the fly with lambda, but the resulting procedure is not the same as a ‘real’ function that was defined with def. 

- wtf is with ‘.call’? 
- Why do I have to make proceudres that were defined with ‘def’ into proc obkjects with the janky
  looking ‘method :name’?
- what is with

## C++

Trigger Warning.

```cpp
#include <vector>
#include <functional>
#include <numeric>
using namespace std;

template<typename T> using bFun = function<T(T,T)>;
template<typename T> using vFun = function<T(vector<T>)>;

template<typename T>
vFun<T> frk(vFun<T> a, bFun<T> r, vFun<T> b) {
  return [&](vector<T> x){
    return r(a(x), b(x));
  };
}

template<typename T>
T sum(vector<T> a) {
  return accumulate(a.begin(), a.end(), 0,
    [](T a, T b) {
      return a+b;
    }
  );
}

template<typename T>
T cnt(vector<T> a) {
  return T(a.size());
}

template<typename T>
T div(T a, T b) {
  return a/b;
}

int main() {
  typedef double T;
  vFun<T> avg = frk<T>(sum<T>, div<T>, cnt<T>);
  T ans = avg({1.0, 2.0, 3.0, 4.0});
}
```

This is heavy on the `c++0x` stuff, but it isn’t as bad as I thought it would be. Everything actually works, and really, its the same as the javascript version except with types.

- why is accumulate not called reduce?
- why is accumulate in numeric rather than algorithms?

## Go

I also am a go newbie. 

```go
type vFun func(x []float64) float64
type bFun func(a float64, b float64) float64

func frk(a vFun, r bFun, b vFun) vFun {
  return func(x []float64) float64 {
    return r(a(x), b(x))
  }
}

func sum(a []float64) float64 {
  sum := 0.0
  for _, v := range a {
    sum += v
  }
  return sum;
}

func cnt(a []float64) float64 {
  return float64(len(a))
}

func div(a float64, b float64) float64 {
  return a/b
}

func main() {
  avg := frk(sum, div, cnt)
  ans := avg([]float64{1.0, 2.0, 3.0, 4.0})
}
```

Is it just me or is this c++. 

Rob Pike et. al may think c++ is all up in your base, quite possibly killing your doodz, but I don't see a lot of difference.

Rob Pike et. al may think c++ is the worst thing since that zergling rush but I don't see a lot of difference.
