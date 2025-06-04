# WGSL Visual Debugging Functions

[<img src="https://img.shields.io/badge/see-demo-%23fff49b"/>](https://jumbub.github.io/wgsl-visual-debugger/demo.html)
[<img src="https://img.shields.io/badge/run-tests-%2334B233"/>](https://jumbub.github.io/wgsl-visual-debugger/test.html)
[<img src="https://img.shields.io/badge/license-MIT-%233355dd"/>](https://github.com/Jumbub/wgsl-visual-debugger?tab=MIT-1-ov-file)

<br/>

Visually debug scalar, vector or matrice values with textureless pixel samplers

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

Bringing "printf" debugging to a WebGPU near you

<br/>

## Usage

1) Make the functions in `visual_debugging_functions.wgsl` available to your shader

2) Use the sampler (e.g. `sample_f32`) in your shader output

3) See visual debug information

<br/>

## Example

A full example exists in [demo.html](demo.html)

```wgsl
${visual_debugger_src}

@fragment
fn main(@location(0) uv: vec2<f32>) -> @location(0) vec4<f32> {
  return vec4<f32>(sample_f32(uv, 1f));
}
```

<br/>

## API

The ASCII uses "Code page 437" character encoding

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

## Motivation

> Is there a way to render text in WebGPU without using textures?

> How do I quickly debug the return values of my WGSL function?

> How do I see the values of my storage buffer while the buffer is not CPU mappable?

> How do I see the values of my storage buffer without using staging buffers?

> How do I do "print" style debugging in WGSL?

- Use the sampler functions provided by this repository

<br/>

## Issues

> I don't see anything

- The UV range needs to encompass the character locations
- Characters start at `<0.0, 0.0>`; have a size of `<1.0, 1.0>`; and render in the direction `<+inf, +inf>`

> I only see the first digit/letter

- The most basic UV range - `<0.0, 0.0>` to `<1.0, 1.0>` - will render the first character to fit the entire texture
- To render more characters, apply a uniform scaling factor to the UV
- A UV range of `<0.0, 0.0>` to `<3.0, 3.0>` will render the first three characters

> I want to move the text

- To render the characters at an offset, subtract the offset from the UV
- Subtract from the UV _before_ applying a scaling factor
- A UV range of `<-3.0, -3.0>` to `<3.0, 3.0>` will render the first three characters offset from the UV by three characters

> I am seeing characters that look like this <img src="https://github.com/user-attachments/assets/4bcbc8d5-2511-46b9-8254-258cab0314b3"/>, <img src="https://github.com/user-attachments/assets/cfa3b24a-168c-4d08-9a27-1d043b8d6adf"/>, <img src="https://github.com/user-attachments/assets/f9fcdfc0-bf54-45ba-9901-ceec55846c2e"/>

- The default font does not support this character
- The bottom two rows contain the bit representation of the character (the examples are 0, 3, 240 respectively)

> The text is stretched <img src="https://github.com/user-attachments/assets/804a55d2-98b6-431d-944d-34f73285bf84"/>

- The aspect ratio of the target texture must match the UV range
- For a `720x480` texture size you could have a UV range `0x0` to `36x24`

> The text has weird artefacts <img src="https://github.com/user-attachments/assets/83dc5e2b-5a5c-4c07-bc95-330865f67db8" />

- The texture must be a multiple of 6 for pixel perfect sampling

<br/>

The project has a full test suit, runnable from the browser: [jumbub.github.io/wgsl-visual-debugger/test](https://jumbub.github.io/wgsl-visual-debugger/test)
