# Lesson: `<profile>` - where does the time go?

**Install:** `jc lib install profile`   **Use:** `#import <profile>`

A program feels slow, but which part? `Profile` keeps a timer for each name you give it and prints a table.

## Syntax
| call | gives |
|---|---|
| `Profile::make()` | an empty profile |
| `int t = p.start()` | a mark: the time now |
| `p.stop("name", t)` | adds the time since the mark to the timer `name` (made by its first use) |
| `p.frame()` | counts one frame (call it once a frame in a game loop) |
| `p.calls("name")`, `p.total_us("name")`, `p.average_us("name")` | how many runs, the total and the average in microseconds |
| `p.report()` | a `String`: one line a timer |
| `p.reset()` | forget everything |

## Step 1: time two pieces of work
```jk
#import <stdlib>
#import <profile>

int busy(int n) {
    int s = 0;
    for i in 0..n { s += i % 7; }
    return s;
}

int main() {
    Profile p = Profile::make();
    for r in 0..20 {
        int t = p.start();
        busy(20000);
        p.stop("small", t);
        int t2 = p.start();
        busy(200000);
        p.stop("big", t2);
        p.frame();
    }
    cout << "small ran " << p.calls("small") << " times, big ran " << p.calls("big") << " times\n";
    cout << p.report();
    return 0;
}
```
The report shows the share of each timer: the big one should take several times the small one.

## Step 2: compare two ways of doing the same thing
```jk
#import <stdlib>
#import <profile>

int main() {
    Profile p = Profile::make();
    int[] a = arr(100000);
    for i in 0..100000 { a.push(i); }
    int t = p.start();
    int s1 = 0;
    for i in 0..a.len { s1 += a[i]; }
    p.stop("index", t);
    int t2 = p.start();
    int s2 = 0;
    for x in a { s2 += x; }
    p.stop("for each", t2);
    cout << (s1 == s2) << "\n";
    cout << p.report();
    return 0;
}
```

## Exercises
1. Time `Math::sqrt` in a loop of a million calls and print the average time of one call.
2. Put a `Profile` in a small game loop: `start`/`stop` around the update and around the drawing; which one is bigger?
3. Call `p.reset()` after the first second of a program so that the start-up work does not count.
