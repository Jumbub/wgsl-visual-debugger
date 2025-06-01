# Debug String WGSL

Extremely simple text (ASCII string) rendering:

```wgsl
@fragment
fn main(@location(0) uv: vec2<f32>) -> @location(0) vec4<f32> {
  let unknownGpuValue: f32 = sin(cos(0.575)+0.13);
  return vec4<f32>(debug_is_f32(uv, unknownGpuValue), 0, 0, 1);
}
```

## Installation

Copy the contents of `wgsl-debug-ascii.wgsl` to the top of your fragment shader code.

## Usage

Render an `f32` by using the return type of `debug_is_f32` as the fragment shader color output.

## Use Cases

> Is there a simple way to render text for debugging?

> How do I see the values of my storage buffer?

> How do I see the values of my storage buffer while the buffer is not CPU mappable?

> How do I see the values of my storage buffer without using staging buffers?

## Issues

> My text is being cut off at the end

You are exceeding the string length constant.

> I need dynamic string lengths per shader

Use string templating to assign the string length constant.

> The text region is
