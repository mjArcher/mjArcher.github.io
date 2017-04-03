# Auto-Currying of functions in Jula

## Problem

writing things like

```
b = map(x -> 1/x, [1.0, 2.0, 3.0, 4.0])
```

is tedious to write. Typing `->`. Choosing a name for the parameter `x`. Using the do notation is also tedious. 

## First idea

```
macro autoCurry(f)
  fname = f.args[1].args[1]
  @eval $f
  @eval function ($fname)(x...)
    (y...) -> $fname( tuple(x..., y...)... )
  end
end

@autoCurry /(a,b) = a/b

map( /(1), [1.0, 2.0, 3.0, 4.0])
```

## Is This A Good Idea?

No.

Totes shut down by `https://github.com/JuliaLang/julia/issues/554`.

## Second Idea

```
macro >(expr)
  sym = gensym()
  expr.args = [(ex -> ex == :_ ? sym : ex)(ex) for ex=expr.args]
  @eval $sym -> $expr
end

map( @>(/(1,_)), [1.0, 2.0, 3.0, 4.0])
```

## Is This A Good Idea?

No.

While neither idea has been good, it is amazeballs that julia lets us do crazy shit like this.

