fn DBG_debug(uv: vec2<f32>) -> f32 {
  return DBG_is_i32(uv*16, -2147483647);
}

fn DBG_is_u32(uv: vec2<f32>, number: u32) -> f32 {
  if (uv.x < 0 || uv.y < 0) { return 0; }

  var charUv = vec2<u32>(uv);
  let charRange = vec2<u32>(DBG_log_u32(number, 10), 1);

  if (charUv.y > 0 || charUv.x > charRange.x) { return 0; }

  let digit = (number / DBG_pow_u32(10, (charRange.x - charUv.x) - 1)) % 10;
  return DBG_is_ascii(uv - vec2f(f32(charUv.x), 0), DBG_ASCII_DIGITS_START + digit);
}

fn DBG_is_i32(uv: vec2<f32>, number: i32) -> f32 {
  let negative = extractBits(number, 31, 1) != 0;
  if (negative && u32(uv.x) == 0) {
    return DBG_is_ascii(uv, 45);
  }
  return DBG_is_u32(uv - vec2f(select(0f, 1f, negative), 0), u32(abs(number)));
}

fn DBG_is_ascii(uv: vec2<f32>, ascii: u32) -> f32 {
  if (uv.x < 0 || uv.y < 0 || uv.x >= 1 || uv.y >= 1) { return 0f; }
  let uvScaled: vec2<f32> = uv * vec2<f32>(DBG_FONT_SIZE);
  let fontPixel: vec2<u32> = vec2<u32>(uvScaled);
  let fontBitIndex: u32 = ((DBG_FONT_SIZE.x - 1) - fontPixel.x) + fontPixel.y * DBG_FONT_SIZE.x;
  return f32(extractBits(DBG_FONT[ascii], fontBitIndex, 1));
}

fn DBG_pow_u32(number: u32, power: u32) -> u32 {
  if (power > 31) { return 0; }
  var result = number;
  for (var i: u32 = 0; i < power; i += 1) {
    result *= number;
  }
  return result;
}

fn DBG_log_u32(number: u32, base: u32) -> u32 {
  var result: u32 = 0;
  for (var remaining: u32 = number; remaining > 9; remaining /= base) {
    result += 1;
    if (result > 100) { return 0; } // catch runaway gpu
  }
  return result;
}

const DBG_ASCII_DIGITS_START = 48;

const DBG_FONT_SIZE: vec2<u32> = vec2(5, 5);
const DBG_FONT: array<u32, 256> = array(
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0x7c00,
  0,
  0,
  // digits
  0xecd66e, 0x46108e, 0xe8899f, 0xe88a2e, 0x4653e4, 0x1f8783e, 0xe87a2e, 0x1f08888, 0xe8ba2e, 0xe8bc2e,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  // uppercase letters
  0xE8FE31, 0x1E8FA3E, 0xE8C22E, 0x1E8C63E, 0x1F87A1F, 0x1F87A10, 0xE85E2E, 0x118FE31, 0xE2108E, 0xF10A4C, 0x12A6292, 0x108421E, 0x11DD631, 0x11CD671, 0xE8C62E, 0x1E8FA10, 0xE8C66F, 0x1E8FA93, 0xF8383E, 0x1F21084, 0x118C62E, 0x118A944, 0x118C6AA, 0x1151151, 0x1151084, 0x1F1111F,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
);
