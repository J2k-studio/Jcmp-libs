# `<profile>` — profile

Install: `jc lib install profile`   Use: `#import <profile>`



## About (the header of the library)

```
profile 0.1.0 -- timers by name, for a frame or a function.   #import <profile>   (needs jcmp 1.2.1.0; license: MPL-2.0)
Profile p = Profile::make();
int t = p.start();   ...work...   p.stop("physics", t);      // adds the time of this run to the timer "physics"
p.frame();                                                    // call once a frame: counts frames
cout << p.report();                                           // one line a timer: name, calls, total ms, average us, share
p.total_us("physics"), p.calls("physics"), p.average_us("physics"), p.frames, p.reset();
Times are in microseconds (monotonic clock). A timer that does not exist yet is made by its first stop().
```

## Reference

Every function below is used as shown: `Type::name(...)` is a static function, `x.name(...)` a method of a value of the type.

### `Profile`

| call | gives | what it does |
|---|---|---|
| `Profile::make()` | `Profile` |  |
| `x.start()` | `int` | the start mark to give to stop() |
| `x.index(String name)` | `int` |  |
| `x.stop(String name, int t)` | `int` | adds the time since the mark t to the timer `name`; returns that time in ns |
| `x.add_ns(String name, int d)` | `void` |  |
| `x.frame()` | `void` |  |
| `x.calls(String name)` | `int` |  |
| `x.total_us(String name)` | `int` |  |
| `x.average_us(String name)` | `int` |  |
| `x.reset()` | `void` |  |
| `x.report()` | `String` | one line a timer, in the order they were first used |
