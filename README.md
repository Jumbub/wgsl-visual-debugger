# WGSL Hidden Value Debugger

Visualize hidden GPU scalar, vector or matrice values with a pixel sampler function.

```wgsl
let pixel = sample_f32(uv, 1f);
```

## Usage

1) Make the contents of `source.wgsl` available to your shader.

2) Use the required sampler (e.g. `sample_f32`) in your fragment color output.

### Examples

A full example exists in (demo.wgsl)[demo.wgsl].

```wgsl
@fragment
fn main(@location(0) uv: vec2<f32>) -> @location(0) vec4<f32> {
  return vec4<f32>(sample_f32(uv, 1f));
}
```

### API

```wgsl
fn sample_bool(uv: vec2<f32>, value: bool) -> f32;
fn sample_u32(uv: vec2<f32>, number: u32) -> f32;
fn sample_i32(uv: vec2<f32>, number: i32) -> f32;
fn sample_f32(uv: vec2<f32>, number: f32) -> f32;
fn sample_vec4_bool(uv: vec2<f32>, value: vec4<bool>) -> f32;
fn sample_vec3_bool(uv: vec2<f32>, value: vec3<bool>) -> f32;
fn sample_vec2_bool(uv: vec2<f32>, value: vec2<bool>) -> f32;
fn sample_vec4_u32(uv: vec2<f32>, value: vec4<u32>) -> f32;
fn sample_vec3_u32(uv: vec2<f32>, value: vec3<u32>) -> f32;
fn sample_vec2_u32(uv: vec2<f32>, value: vec2<u32>) -> f32;
fn sample_vec4_i32(uv: vec2<f32>, value: vec4<i32>) -> f32;
fn sample_vec3_i32(uv: vec2<f32>, value: vec3<i32>) -> f32;
fn sample_vec2_i32(uv: vec2<f32>, value: vec2<i32>) -> f32;
fn sample_vec4_f32(uv: vec2<f32>, value: vec4<f32>) -> f32;
fn sample_vec3_f32(uv: vec2<f32>, value: vec3<f32>) -> f32;
fn sample_vec2_f32(uv: vec2<f32>, value: vec2<f32>) -> f32;
fn sample_ascii_u32(uv: vec2<f32>, char: u32) -> f32;
fn sample_ascii5_u32(uv: vec2<f32>, string: array<u32, 5>) -> f32;
```

> The ASCII characters use "Code page 437" character encoding

<br/>

## Why?

- Quicker prototyping in WebGPU.
- Enables debugging for buffers which aren't CPU mappable.

#### A potential answer to the questions:

> Is there a way to render text in WebGPU without using textures?

> How do I quickly debug the return values of my WGSL function?

> How do I see the values of my storage buffer while the buffer is not CPU mappable?

> How do I see the values of my storage buffer without using staging buffers?

<br/>

## It's not working?

> I don't see anything

- The UV range needs to encompass the character locations.
- Characters start at `<0.0, 0.0>`; have a size of `<1.0, 1.0>`; and render in the direction `<+inf, +inf>`.

> I only see the first digit/letter

- The most basic UV range - `<0.0, 0.0>` to `<1.0, 1.0>` - will render the first character to fit the entire texture.
- To render more characters, apply a uniform scaling factor to the UV.
- A UV range of `<0.0, 0.0>` to `<3.0, 3.0>` will render the first three characters.

> I want to move the text

- To render the characters at an offset, subtract the offset from the UV.
- Subtract from the UV _before_ applying a scaling factor.
- A UV range of `<-3.0, -3.0>` to `<3.0, 3.0>` will render the first three characters offset from the UV by three characters.

> I am seeing characters that look like this

- The default font does not support this character.
- The 2 bottom rows of the character contain the bit representation of the character).

> The text is stretched

- The aspect ratio of the target texture must match the UV range.
- For a `720x480` texture size you could have a UV range `0x0` to `36x24`).

> The text looks weird when rendered small

- The texture must be a multiple of 6 for pixel perfect sampling.
