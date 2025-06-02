fn DBG_debug(uv: vec2<f32>) -> f32 {
  return DBG_is_ascii(uv, 32);
}

fn DBG_is_bool(uv: vec2<f32>, value: bool) -> f32 {
  if (value) {
    return DBG_is_ascii5(uv, array<u32, 5>(84, 82, 85, 69, 0));
  } else {
    return DBG_is_ascii5(uv, array<u32, 5>(70, 65, 76, 83, 69));
  }
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

  let decimalLength = select(
    0,
    f32(parts.decimalPlace),
    parts.decimal > 0
  );
  if (uvWithoutIntegral.x < decimalLength) {
    if (uvWithoutIntegral.x < 1) {
      return DBG_is_ascii(uvWithoutIntegral, 46);
    }
    let zeros = parts.decimalPlace - DBG_string_length(parts.decimal);
    if (uvWithoutIntegral.x < f32(zeros)) {
      return DBG_is_ascii(vec2f(uvWithoutIntegral.x % 1, uvWithoutIntegral.y), DBG_ASCII_NUMBER_START);
    }
    return DBG_is_u32(uvWithoutIntegral - vec2f(f32(zeros), 0), parts.decimal);
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

fn DBG_is_ascii5(uv: vec2<f32>, string: array<u32, 5>) -> f32 {
  if (uv.x >= 5) { return 0f; }
  return DBG_is_ascii(uv - vec2(floor(uv.x), 0), string[u32(uv.x)]);
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
  decimalPlace: u32,
  exponent: i32,
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
  var decimalPlace: u32 = 10;
  while (decimal % 10 == 0 && decimalPlace > 0) {
    decimal /= 10;
    decimalPlace -= 1;
  }
  return DBG_f32_splits(integral, decimal, decimalPlace, exponent);
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

alias DBG_String = array<u32, 1000>;

const DBG_FONT_SIZE: vec2<u32> = vec2(5, 5);

const DBG_FONT: array<u32, 256> = array(
  0x15f8000 + 0,
  0x15f8000 + 1,
  0x15f8000 + 2,
  0x15f8000 + 3,
  0x15f8000 + 4,
  0x15f8000 + 5,
  0x15f8000 + 6,
  0x15f8000 + 7,
  0x15f8000 + 8,
  0x15f8000 + 9,
  0x15f8000 + 10,
  0x15f8000 + 11,
  0x15f8000 + 12,
  0x15f8000 + 13,
  0x15f8000 + 14,
  0x15f8000 + 15,
  0x15f8000 + 16,
  0x15f8000 + 17,
  0x15f8000 + 18,
  0x15f8000 + 19,
  0x15f8000 + 20,
  0x15f8000 + 21,
  0x15f8000 + 22,
  0x15f8000 + 23,
  0x15f8000 + 24,
  0x15f8000 + 25,
  0x15f8000 + 26,
  0x15f8000 + 27,
  0x15f8000 + 28,
  0x15f8000 + 29,
  0x15f8000 + 30,
  0x15f8000 + 31,
  0x15f8000 + 32,
  0x15f8000 + 33,
  0x15f8000 + 34,
  0x15f8000 + 35,
  0x15f8000 + 36,
  0x15f8000 + 37,
  0x15f8000 + 38,
  0x15f8000 + 39,
  0x15f8000 + 40,
  0x15f8000 + 41,
  0x15f8000 + 42,
  0x15f8000 + 43,
  0x15f8000 + 44,
  0x7c00, // -
  0x4, // .
  0x15f8000 + 47,
  0xecd66e, // digits
  0x46108e,
  0xe8899f,
  0xe88a2e,
  0x4653e4,
  0x1f8783e,
  0xe87a2e,
  0x1f08888,
  0xe8ba2e,
  0xe8bc2e,
  0x15f8000 + 58,
  0x15f8000 + 59,
  0x222082, // <
  0x15f8000 + 61,
  0x820888, // >
  0x15f8000 + 63,
  0x15f8000 + 64,
  0xE8FE31, // uppercase letters
  0x1E8FA3E,
  0xE8C22E,
  0x1E8C63E,
  0x1F87A1F,
  0x1F87A10,
  0xE85E2E,
  0x118FE31,
  0xE2108E,
  0xF10A4C,
  0x12A6292,
  0x108421E,
  0x11DD631,
  0x11CD671,
  0xE8C62E,
  0x1E8FA10,
  0xE8C66F,
  0x1E8FA93,
  0xF8383E,
  0x1F21084,
  0x118C62E,
  0x118A944,
  0x118C6AA,
  0x1151151,
  0x1151084,
  0x1F1111F,
  0x15f8000 + 91,
  0x15f8000 + 92,
  0x15f8000 + 93,
  0x15f8000 + 94,
  0x15f8000 + 95,
  0x15f8000 + 96,
  0x15f8000 + 97,
  0x15f8000 + 98,
  0x15f8000 + 99,
  0x15f8000 + 100,
  0x15f8000 + 101,
  0x15f8000 + 102,
  0x15f8000 + 103,
  0x15f8000 + 104,
  0x15f8000 + 105,
  0x15f8000 + 106,
  0x15f8000 + 107,
  0x15f8000 + 108,
  0x15f8000 + 109,
  0x15f8000 + 110,
  0x15f8000 + 111,
  0x15f8000 + 112,
  0x15f8000 + 113,
  0x15f8000 + 114,
  0x15f8000 + 115,
  0x15f8000 + 116,
  0x15f8000 + 117,
  0x15f8000 + 118,
  0x15f8000 + 119,
  0x15f8000 + 120,
  0x15f8000 + 121,
  0x15f8000 + 122,
  0x15f8000 + 123,
  0x15f8000 + 124,
  0x15f8000 + 125,
  0x15f8000 + 126,
  0x15f8000 + 127,
  0x15f8000 + 128,
  0x15f8000 + 129,
  0x15f8000 + 130,
  0x15f8000 + 131,
  0x15f8000 + 132,
  0x15f8000 + 133,
  0x15f8000 + 134,
  0x15f8000 + 135,
  0x15f8000 + 136,
  0x15f8000 + 137,
  0x15f8000 + 138,
  0x15f8000 + 139,
  0x15f8000 + 140,
  0x15f8000 + 141,
  0x15f8000 + 142,
  0x15f8000 + 143,
  0x15f8000 + 144,
  0x15f8000 + 145,
  0x15f8000 + 146,
  0x15f8000 + 147,
  0x15f8000 + 148,
  0x15f8000 + 149,
  0x15f8000 + 150,
  0x15f8000 + 151,
  0x15f8000 + 152,
  0x15f8000 + 153,
  0x15f8000 + 154,
  0x15f8000 + 155,
  0x15f8000 + 156,
  0x15f8000 + 157,
  0x15f8000 + 158,
  0x15f8000 + 159,
  0x15f8000 + 160,
  0x15f8000 + 161,
  0x15f8000 + 162,
  0x15f8000 + 163,
  0x15f8000 + 164,
  0x15f8000 + 165,
  0x15f8000 + 166,
  0x15f8000 + 167,
  0x15f8000 + 168,
  0x15f8000 + 169,
  0x15f8000 + 170,
  0x15f8000 + 171,
  0x15f8000 + 172,
  0x15f8000 + 173,
  0x15f8000 + 174,
  0x15f8000 + 175,
  0x15f8000 + 176,
  0x15f8000 + 177,
  0x15f8000 + 178,
  0x15f8000 + 179,
  0x15f8000 + 180,
  0x15f8000 + 181,
  0x15f8000 + 182,
  0x15f8000 + 183,
  0x15f8000 + 184,
  0x15f8000 + 185,
  0x15f8000 + 186,
  0x15f8000 + 187,
  0x15f8000 + 188,
  0x15f8000 + 189,
  0x15f8000 + 190,
  0x15f8000 + 191,
  0x15f8000 + 192,
  0x15f8000 + 193,
  0x15f8000 + 194,
  0x15f8000 + 195,
  0x15f8000 + 196,
  0x15f8000 + 197,
  0x15f8000 + 198,
  0x15f8000 + 199,
  0x15f8000 + 200,
  0x15f8000 + 201,
  0x15f8000 + 202,
  0x15f8000 + 203,
  0x15f8000 + 204,
  0x15f8000 + 205,
  0x15f8000 + 206,
  0x15f8000 + 207,
  0x15f8000 + 208,
  0x15f8000 + 209,
  0x15f8000 + 210,
  0x15f8000 + 211,
  0x15f8000 + 212,
  0x15f8000 + 213,
  0x15f8000 + 214,
  0x15f8000 + 215,
  0x15f8000 + 216,
  0x15f8000 + 217,
  0x15f8000 + 218,
  0x15f8000 + 219,
  0x15f8000 + 220,
  0x15f8000 + 221,
  0x15f8000 + 222,
  0x15f8000 + 223,
  0x15f8000 + 224,
  0x15f8000 + 225,
  0x15f8000 + 226,
  0x15f8000 + 227,
  0x15f8000 + 228,
  0x15f8000 + 229,
  0x15f8000 + 230,
  0x15f8000 + 231,
  0x15f8000 + 232,
  0x15f8000 + 233,
  0x15f8000 + 234,
  0x15f8000 + 235,
  0x55540, // ∞
  0x15f8000 + 237,
  0x15f8000 + 238,
  0x15f8000 + 239,
  0x15f8000 + 240,
  0x15f8000 + 241,
  0x15f8000 + 242,
  0x15f8000 + 243,
  0x15f8000 + 244,
  0x15f8000 + 245,
  0x15f8000 + 246,
  0x15f8000 + 247,
  0x15f8000 + 248,
  0x15f8000 + 249,
  0x15f8000 + 250,
  0x15f8000 + 251,
  0x15f8000 + 252,
  0x15f8000 + 253,
  0x15f8000 + 254,
  0x15f8000 + 255,
);
