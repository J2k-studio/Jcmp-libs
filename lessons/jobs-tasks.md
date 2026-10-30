# Lesson: `<jobs>` and `<tasks>` - using all the cores

**Install:** `jc lib install jobs`, `jc lib install tasks`   **Use:** `#import <cpu>` then `#import <jobs>` and/or `#import <tasks>`

The phone has eight cores. `Jobs` splits many small jobs between threads; `Task` runs one function on its own thread and gives you its value; `Channel` is a queue between threads.

## Syntax
| call | gives |
|---|---|
| `Jobs::cores()` | the number of cores this program may use |
| `Jobs::run(count, threads, f)` | runs `f(i)` for i in 0..count on that many threads; returns when all are done |
| `Jobs::run_all(count, f)` | the same with one thread a core |
| `Task::run(f, arg)` | starts `int f(void^ arg)` on a new thread |
| `t.wait()` | the value of the function (waits if it is not ready); call it once |
| `t.ready()` | `true` when it is done, without waiting |
| `Channel<T>::make()` | a queue; `c.send(v)`, `c.receive()` (waits), `c.try_receive(@got)`, `c.close()`, `c.is_closed()` |

A job or a task must not throw out of its function. Jobs share memory: each job here writes only to its own place in an array.

## Step 1: many jobs, one result each
```jk
#import <stdlib>
#import <cpu>
#import <jobs>

int^ out;

void work(void^ arg) {
    int i = (int)arg;
    int s = 0;
    for k in 0..100000 { s += (k * i) % 13; }
    out[i] = s;
}

int main() {
    int n = 16;
    out = (int^)Mem::alloc(n * 8);
    Jobs::run(n, 4, work);
    int total = 0;
    for i in 0..n { total += out[i]; }
    cout << "cores " << (Jobs::cores() >= 1) << ", total " << total << "\n";
    return 0;
}
```
The jobs are taken one by one from a shared counter, so slow and fast jobs balance by themselves.

## Step 2: a task that gives a value
```jk
#import <stdlib>
#import <cpu>
#import <tasks>

int square(void^ arg) {
    int n = (int)arg;
    return n * n;
}

int main() {
    Task t = Task::run(square, (void^)12);
    int other = 5 + 5;                       // the main thread works meanwhile
    cout << other << " " << t.wait() << "\n";   // 10 144
    return 0;
}
```

## Step 3: a channel between two threads
```jk
#import <stdlib>
#import <cpu>
#import <tasks>

Channel<int> box;

int producer(void^ arg) {
    for i in 1..6 { box.send(i * 10); }
    box.close();
    return 0;
}

int main() {
    box = Channel<int>::make();
    Task t = Task::run(producer, (void^)0);
    int sum = 0;
    while true {
        int v = box.receive();
        if box.is_closed() && v == 0 { break; }
        sum += v;
    }
    t.wait();
    cout << sum << "\n";                     // 150
    return 0;
}
```
`receive()` waits until a value comes, and gives the zero value when the channel is closed and empty, so a real value of 0 would need another way to tell.

## Exercises
1. Count the primes below 2 million with `Jobs::run`: each job takes one slice and writes its count into `out[i]`.
2. Start four tasks that each sum a quarter of an array and add the four results.
3. Make two producers that send into one channel, and read until both are done.
