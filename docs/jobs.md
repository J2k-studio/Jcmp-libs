# `<jobs>` — jobs

Install: `jc lib install jobs`   Use: `#import <jobs>`



## About (the header of the library)

```
jobs 0.1.0 -- run many small jobs on several threads.   #import <cpu>  #import <jobs>   (needs jcmp 1.2.1.0; license: MPL-2.0)
void work(void^ arg) { int i = (int)arg; ... }          // job number i (0 .. count-1)
Jobs::run(1000, 4, work);                                // 1000 jobs on 4 threads; returns when all are done; the calling thread works too
Jobs::run_all(1000, work);                               // the same with one thread a core (Jobs::cores())
Jobs are taken one by one from a shared counter, so slow and fast jobs balance by themselves.
A job must not throw out of its function (catch inside). The jobs share memory: guard shared data with Mutex or Atomic.
```

## Reference

Every function below is used as shown: `Type::name(...)` is a static function, `x.name(...)` a method of a value of the type.

### `Jobs`

| call | gives | what it does |
|---|---|---|
| `Jobs::cores()` | `int` | the number of cores this program may use |
| `Jobs::run(int count, int threads, void(void^)` | `void` | count jobs on `threads` threads (the caller is one of them) |
| `Jobs::run_all(int count, void(void^)` | `void` |  |
