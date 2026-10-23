# `<quat>` — rotations in 3D (quaternions)

Install: `jget -li install quat`   Use: `#import <quat>`

A quaternion turns a vector about an axis without the problems of angles.

## About (the header of the library)

```
quat: a rotation in 3D as four numbers (a quaternion x, y, z, w). #import <math>   using math::quat;
quat q = quat::from_axis_angle(vec3::make(0.0, 1.0, 0.0), Math::pi() / 2.0);   (a quarter turn about the y axis)
vec3 v = q.rotate(vec3::make(1.0, 0.0, 0.0));         q * r  turns by r first, then by q
```

## Example

```jk
#import <stdlib>
#import <math>
using math::quat;
using math::vector;
void main() {
    quat q = quat::from_axis_angle(vec3::make(0.0, 0.0, 1.0), Math::pi() / 2.0);   // a quarter turn about the z axis
    vec3 v = q.rotate(vec3::make(1.0, 0.0, 0.0));
    cout << Math::round(v.x) << " " << Math::round(v.y) << " " << Math::round(v.z) << "\n";
}
```

Output:

```
0.000000 1.000000 0.000000
```

## Reference

Every function below is used as shown: `Type::name(...)` is a static function, `x.name(...)` a method of a value of the type.

### `quat`

| call | gives | what it does |
|---|---|---|
| `quat::make(double x, double y, double z, double w)` | `quat` | a quaternion from x, y, z, w |
| `quat::identity()` | `quat` | no rotation |
| `quat::from_axis_angle(vec3 axis, double angle)` | `quat` | a turn of `angle` radians about an axis (a vec3) |
| `x.conj()` | `quat` | the opposite turn (for a unit quaternion) |
| `x.dot(quat o)` | `double` | the dot product of two quaternions |
| `x.length()` | `double` | the length |
| `x.normalize()` | `quat` | length 1 (a rotation must be normalized) |
| `x.rotate(vec3 v)` | `vec3` | turn a vec3 |
| `x.slerp(quat o, double t)` | `quat` | a smooth mix between two rotations (t from 0 to 1) |
