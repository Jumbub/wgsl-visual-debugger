# WGSL (Debug) String Sampler

Extremely simple text (ASCII string) rendering:

```wgsl
@fragment
fn main(@location(0) uv: vec2<f32>) -> @location(0) vec4<f32> {
  let unknownGpuValue: f32 = sin(cos(0.575)+0.13);
  return vec4<f32>(debug_is_f32(uv, unknownGpuValue), 0, 0, 1);
}
```

## Installation

Copy the contents of `wgsl-debug-ascii.wgsl` into your shader.

## Usage

Render an `f32` by using the return type of `debug_is_f32` as the fragment shader color output.

## Use Cases

> Is there a simple way to render text for debugging?

> How do I see the values of my storage buffer?

> How do I see the values of my storage buffer while the buffer is not CPU mappable?

> How do I see the values of my storage buffer without using staging buffers?

Use the utility functions provided by this repository.

## Issues

> I don't see anything

The UV range needs to encompass the character locations.

(characters start at `<0.0, 0.0>`; have a size of `<1.0, 1.0>`; and render in the direction `<+inf, +inf>`)

> I only see the first digit/letter

The most basic UV range - `<0.0, 0.0>` to `<1.0, 1.0>` - will render the first character to fit the entire texture.

To render more characters, apply a uniform scaling factor to the UV.

(a UV range of `<0.0, 0.0>` to `<3.0, 3.0>` will render the first three characters)

> I want to move the text

To render the characters at an offset, subtract an offset from the UV.

(subtract from the UV _before_ applying the above scaling factor)

(a UV range of -3.0 to 3.0 will render the first three characters offset from the UV by three characters)

> I am seeing characters that look like this

The font does not support this character.

(the 2 bottom rows of the character contain the bit representation of the character)
