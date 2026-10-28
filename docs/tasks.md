# `<tasks>` — tasks

Install: `jc lib install tasks`   Use: `#import <tasks>`



## About (the header of the library)

```
tasks 0.1.0 -- a function that runs on its own thread and gives a value (Task), and a queue between threads (Channel<T>).   #import <cpu>  #import <tasks>   (needs jcmp 1.2.1.0; license: MPL-2.0)
int square(void^ arg) { int n = (int)arg; return n * n; }
Task t = Task::run(square, (void^)12);       // starts at once on a new thread
...other work...
int r = t.wait();                            // 144; waits if it is not ready; call it once. t.ready() tells without waiting.
Channel<int> c = Channel<int>::make();       // an unbounded queue; many writers and readers are fine
c.send(5);   int v = c.receive();            // receive() waits until a value comes, or returns the zero value when the channel is closed and empty
bool got; int w = c.try_receive(@got);       // never waits
c.close();   c.is_closed();                  // after close(), send() is ignored and receive() drains what is left
A task must not throw out of its function (catch inside). A Channel is a handle: copies of it share the queue.
```

## Reference

Every function below is used as shown: `Type::name(...)` is a static function, `x.name(...)` a method of a value of the type.

### `Task`

| call | gives | what it does |
|---|---|---|
| `Task::run(int(void^)` | `Task` |  |
| `x.ready()` | `bool` |  |
| `x.wait()` | `int` | the value of the function; waits for it |
### `Channel`

| call | gives | what it does |
|---|---|---|
| `Channel::make()` | `Channel<T>` |  |
| `x.send(T v)` | `void` |  |
| `x.try_receive(bool^ got)` | `T` |  |
| `x.receive()` | `T` |  |
| `x.close()` | `void` |  |
| `x.is_closed()` | `bool` |  |
