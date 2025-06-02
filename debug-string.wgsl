fn DBG_debug(uv: vec2<f32>) -> f32 {
  return DBG_is_bool(uv*10, true);
}

fn DBG_is_bool(uv: vec2<f32>, value: bool) -> f32 {
  return DBG_is_i32(uv, select(0, 1, value));
}

fn DBG_is_u32(uv: vec2<f32>, number: u32) -> f32 {
  if (uv.x < 0 || uv.y < 0) { return 0; }

  var charUv = vec2<u32>(uv);
  let charRange = vec2<u32>(DBG_string_length(number) - 1, 1);

  if (charUv.y > 0 || charUv.x > charRange.x) { return 0; }

  let digit = (number / DBG_pow_u32(10, (charRange.x - charUv.x) - 1)) % 10;
  return DBG_is_ascii(uv - vec2f(f32(charUv.x), 0), DBG_ASCII_NUMBER_START + digit);
}

fn DBG_is_i32(uv: vec2<f32>, number: i32) -> f32 {
  let negative = extractBits(number, 31, 1) != 0;
  if (negative && u32(uv.x) == 0) {
    return DBG_is_ascii(uv, 45);
  }
  return DBG_is_u32(uv - vec2f(select(0f, 1f, negative), 0), u32(abs(number)));
}

fn DBG_is_f32(uv: vec2<f32>, number: f32) -> f32 {
  // credit: https://blog.benoitblanchon.fr/lightweight-float-to-string/

  let negative = extractBits(bitcast<i32>(number), 31u, 1u) != 0;
  if (negative && u32(uv.x) == 0) {
    return DBG_is_ascii(uv, 45);
  }

  let uvWithoutSign = uv - vec2<f32>(select(0f, 1f, negative), 0);
  if (extractBits(bitcast<u32>(number), 23u, 8u) == 255) {
    if (extractBits(bitcast<u32>(number), 0u, 23u) == 0) {
      return DBG_is_ascii(uvWithoutSign, 236);
    } else {
      if (uvWithoutSign.x < 1) {
        return DBG_is_ascii(uvWithoutSign, 78);
      } else if (uvWithoutSign.x < 2) {
        return DBG_is_ascii(uvWithoutSign - vec2f(1, 0), 65);
      } else {
        return DBG_is_ascii(uvWithoutSign - vec2f(2, 0), 78);
      }
    }
  }


  let positive: f32 = abs(number);

  let parts = DBG_f32_split(positive);

  let integralLength = DBG_string_length(parts.integral);
  if (uvWithoutSign.x < f32(integralLength)) {
    return DBG_is_u32(uvWithoutSign, parts.integral);
  }
  let uvWithoutIntegral = uvWithoutSign - vec2f(f32(integralLength), 0);

  let decimalLength = select(0, f32(1 + DBG_string_length(parts.decimal)), parts.decimal > 0);
  if (uvWithoutIntegral.x < decimalLength) {
    if (uvWithoutIntegral.x < 1) {
      return DBG_is_ascii(uvWithoutIntegral, 46);
    }
    return DBG_is_u32(uvWithoutIntegral - vec2f(1, 0), parts.decimal);
  }
  let uvWithoutDecimal = uvWithoutIntegral - vec2f(decimalLength, 0);

  if (parts.exponent != 0) {
    if (uvWithoutDecimal.x < 1) {
      return DBG_is_ascii(uvWithoutDecimal, DBG_ASCII_UPPERCASE_ALPHABET_START + 4);
    }
    return DBG_is_i32(uvWithoutDecimal - vec2f(1, 0), parts.exponent);
  }

  return 0f;
}

fn DBG_is_ascii(uv: vec2<f32>, ascii: u32) -> f32 {
  if (uv.x < 0 || uv.y < 0 || uv.x >= 1 || uv.y >= 1) { return 0f; }
  let uvScaled: vec2<f32> = uv * vec2<f32>(DBG_FONT_SIZE) * 1.2;
  if (uvScaled.x > f32(DBG_FONT_SIZE.x)) { return 0; }
  let fontPixel: vec2<u32> = vec2<u32>(uvScaled);
  let fontBitIndex: u32 = ((DBG_FONT_SIZE.x - 1) - fontPixel.x) + fontPixel.y * DBG_FONT_SIZE.x;
  return f32(extractBits(DBG_FONT[ascii], fontBitIndex, 1));
}

// beginning of internals

struct DBG_f32_splits {
  integral: u32,
  decimal: u32,
  exponent: i32
};
fn DBG_f32_split(inValue: f32) -> DBG_f32_splits {
  var n = DBG_f32_normalize(inValue);
  var exponent = n.exponent;
  var value = n.value;
  var integral = u32(value);
  var remainder: f32 = value - f32(integral);
  remainder *= 1e9;
  var decimal: u32 = u32(remainder);
  remainder -= f32(decimal);
  if (remainder >= 0.5) {
    decimal++;
    if (decimal >= 1000000000) {
      decimal = 0;
      integral++;
      if (exponent != 0 && integral >= 10) {
        exponent++;
        integral = 1;
      }
    }
  }
  return DBG_f32_splits(integral, decimal, exponent);
}

struct DBG_f32_normalized {
  value: f32,
  exponent: i32,
}
fn DBG_f32_normalize(value: f32) -> DBG_f32_normalized {
  let positiveExpThreshold: f32 = 1e7;
  let negativeExpThreshold: f32 = 1e-5;
  var exponent: i32 = 0;
  var normalized = value;
  if (normalized >= positiveExpThreshold) {
    if (normalized >= 1e32) { normalized /= 1e32; exponent += 32; }
    if (normalized >= 1e16) { normalized /= 1e16; exponent += 16; }
    if (normalized >= 1e8) { normalized /= 1e8; exponent += 8; }
    if (normalized >= 1e4) { normalized /= 1e4; exponent += 4; }
    if (normalized >= 1e2) { normalized /= 1e2; exponent += 2; }
    if (normalized >= 1e1) { normalized /= 1e1; exponent += 1; }
  }
  if (normalized > 0 && normalized <= negativeExpThreshold) {
    if (normalized < 1e-31) { normalized *= 1e32; exponent -= 32; }
    if (normalized < 1e-15) { normalized *= 1e16; exponent -= 16; }
    if (normalized < 1e-7) { normalized *= 1e8; exponent -= 8; }
    if (normalized < 1e-3) { normalized *= 1e4; exponent -= 4; }
    if (normalized < 1e-1) { normalized *= 1e2; exponent -= 2; }
    if (normalized < 1e0) { normalized *= 1e1; exponent -= 1; }
  }
  return DBG_f32_normalized(normalized, exponent);
}

fn DBG_string_length(number: u32) -> u32 {
  return DBG_log_u32(number, 10) + 1;
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

const DBG_ASCII_NUMBER_START = 48;
const DBG_ASCII_UPPERCASE_ALPHABET_START = 65;

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
  0x4,
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
  0x55540,
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


