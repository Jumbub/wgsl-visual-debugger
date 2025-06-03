# WGSL Visual Debugger

Drop-in WGSL functions, rasterizing numerical values into ASCII, for WebGPU fragment shaders.

</br>

Visually debug scalar, vector or matrice values with pixel samplers.

<table>
  <tr>
    <td><img src="https://github.com/user-attachments/assets/7cc6d7ad-d286-4e9a-b8cd-6275a6cd339e"/></td>
    <td><pre>let pixel = sample_f32(uv, 0.445f);</pre></td>
  </tr>
  <tr>
    <td><img src="https://github.com/user-attachments/assets/8a28ed2d-1349-4254-b7f5-0d5df30150dd"/></td>
    <td><pre>let pixel = sample_bool(uv, true);</pre></td>
  </tr>
  <tr>
    <td><img src="https://github.com/user-attachments/assets/76b0f495-43b4-4a6b-9f5e-da2c7c36c952"/></td>
    <td><pre>let pixel = sample_i32(uv, -1337);</pre></td>
  </tr>
</table>

Bringing "printf" debugging to a WebGPU near you.

<br/>

## How?

1) Make the contents of `source.wgsl` available to your shader.

2) Use the required sampler (e.g. `sample_f32`) in your fragment color output.

### Full Example

A full example exists in [demo.html](demo.html).

### Partial Example

```wgsl
${visual_debugger_src}

@fragment
fn main(@location(0) uv: vec2<f32>) -> @location(0) vec4<f32> {
  return vec4<f32>(sample_f32(uv, 1f));
}
```

<br/>

## API

The ASCII uses "Code page 437" character encoding.

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
fn sample_mat2x4_f32(uv: vec2<f32>, value: mat2x4<f32>) -> f32;
fn sample_mat4x2_f32(uv: vec2<f32>, value: mat4x2<f32>) -> f32;
fn sample_mat4x4_f32(uv: vec2<f32>, value: mat4x4<f32>) -> f32;
fn sample_mat3x4_f32(uv: vec2<f32>, value: mat3x4<f32>) -> f32;
fn sample_mat4x3_f32(uv: vec2<f32>, value: mat4x3<f32>) -> f32;
fn sample_mat3x3_f32(uv: vec2<f32>, value: mat3x3<f32>) -> f32;
fn sample_mat2x3_f32(uv: vec2<f32>, value: mat2x3<f32>) -> f32;
fn sample_mat3x2_f32(uv: vec2<f32>, value: mat3x2<f32>) -> f32;
fn sample_mat2x2_f32(uv: vec2<f32>, value: mat2x2<f32>) -> f32;
fn sample_ascii_u32(uv: vec2<f32>, char: u32) -> f32;
fn sample_ascii5_u32(uv: vec2<f32>, string: array<u32, 5>) -> f32;
```

<br/>

## Why?

> Is there a way to render text in WebGPU without using textures?

> How do I quickly debug the return values of my WGSL function?

> How do I see the values of my storage buffer while the buffer is not CPU mappable?

> How do I see the values of my storage buffer without using staging buffers?

> How do I do "print" style debugging in WGSL?

- Use the sampler functions provided by this repository

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
