# Lesson: `<quat>` - turning things in 3D

**Install:** `jc lib install quat`   **Use:** `#import <vector>` and `#import <quat>`   (`vec3` is in `<vector>`; `Math::pi()` in `<math>`)

Rotation in 3D with three angles (Euler angles) has traps (gimbal lock, order). A **quaternion** stores a rotation as four numbers `x y z w` and has none of them: turns multiply, and you can move smoothly from one turn to another (`slerp`). Games, cameras and robots use them.

## Syntax
| what | form | gives |
|---|---|---|
| make | `quat::identity()` (no turn), `quat::from_axis_angle(vec3 axis, double radians)`, `quat::make(x, y, z, w)` | `quat` |
| combine | `a * b` | the turn `b` first, then `a` (the Hamilton product) |
| use | `q.rotate(vec3 v)` | the vector turned |
| undo | `q.conj()` | the opposite turn (for a unit quaternion) |
| keep it a turn | `q.normalize()`, `q.length()`, `q.dot(o)` | after many products the length drifts: normalise |
| move smoothly | `a.slerp(b, t)` | `t = 0` is `a`, `t = 1` is `b`, by the shortest way |
`vec3::make(x, y, z)` makes a vector (`<vector>`).

## Step 1: a quarter turn about the y axis
```jk
#import <stdlib>
#import <math>
#import <vector>
#import <quat>

int main() {
    quat q = quat::from_axis_angle(vec3::make(0.0, 1.0, 0.0), Math::pi() / 2.0);
    vec3 v = q.rotate(vec3::make(1.0, 0.0, 0.0));            // the x axis turned about y by 90 degrees: (0, 0, -1)
    cout << v.x << " " << v.y << " " << v.z << "\n";
    return 0;
}
```

## Step 2: two turns in a row
```jk
#import <stdlib>
#import <math>
#import <vector>
#import <quat>

int main() {
    quat about_y = quat::from_axis_angle(vec3::make(0.0, 1.0, 0.0), Math::pi() / 2.0);
    quat about_x = quat::from_axis_angle(vec3::make(1.0, 0.0, 0.0), Math::pi() / 2.0);
    quat both = about_x * about_y;                           // first y, then x
    vec3 a = both.rotate(vec3::make(1.0, 0.0, 0.0));
    vec3 b = about_x.rotate(about_y.rotate(vec3::make(1.0, 0.0, 0.0)));   // the same thing, in two steps
    cout << a.x << " " << a.y << " " << a.z << "\n";
    cout << b.x << " " << b.y << " " << b.z << "\n";
    return 0;
}
```

## Step 3: a smooth turn (an animation)
```jk
#import <stdlib>
#import <math>
#import <vector>
#import <quat>

int main() {
    quat start = quat::identity();
    quat end = quat::from_axis_angle(vec3::make(0.0, 0.0, 1.0), Math::pi());      // half a turn about z
    for i in 0..5 {
        double t = (double)i / 4.0;
        quat q = start.slerp(end, t);
        vec3 v = q.rotate(vec3::make(1.0, 0.0, 0.0));
        cout << "t " << t << ": " << v.x << " " << v.y << "\n";                  // the point goes round half a circle
    }
    return 0;
}
```

## Things to know
* The angle is in **radians** (`Math::pi()` is half a turn).
* Normalise after many multiplications (`q = q.normalize()`).
* `q` and `-q` are the same turn.

## Exercises
1. Turn the point (1, 0, 0) about the z axis in ten steps of 36 degrees and print it each time.
2. Turn a whole list of points (a cube) and print their new places.
3. Make a "camera" that turns by the mouse or touch movement: two small turns about y (left-right) and x (up-down) multiplied into the camera turn each frame.

**Next:** `<screen>`, `<gpu>` (draw the turned shape), `<phys2d>`.
