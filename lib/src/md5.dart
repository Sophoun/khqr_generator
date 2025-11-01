import 'dart:typed_data';

/// Computes the MD5 hash of a given list of 8-bit integers (bytes).
///
/// This function implements the MD5 (Message-Digest Algorithm 5) hashing algorithm.
/// It takes a list of integers representing the input data and returns a 16-byte
/// (128-bit) [Uint8List] containing the MD5 hash.
///
/// The MD5 algorithm processes the input data in 512-bit (64-byte) chunks.
/// It involves several steps:
/// 1. Padding the message to a length that is a multiple of 512 bits.
/// 2. Initializing four 32-bit chaining variables (A, B, C, D).
/// 3. Processing each 512-bit chunk through four rounds of operations,
///    each involving a non-linear function, bitwise rotations, and additions
///    with constants and message words.
/// 4. Updating the chaining variables after each chunk.
/// 5. Producing the final hash value by concatenating the final chaining variables.
///
/// Note: MD5 is considered cryptographically broken and is not suitable for
/// applications requiring strong collision resistance (e.g., digital signatures).
/// It is still acceptable for use cases where collision resistance is not
/// paramount, such as integrity checks against unintentional corruption.
///
/// Parameters:
/// - [data]: The input data as a list of 8-bit integers.
///
/// Returns:
/// A [Uint8List] of 16 bytes representing the MD5 hash.
Uint8List md5(List<int> data) {
  // MD5 constants for the left rotation amounts in each round.
  final s = [
    7,
    12,
    17,
    22,
    7,
    12,
    17,
    22,
    7,
    12,
    17,
    22,
    7,
    12,
    17,
    22, // Round 1
    5,
    9,
    14,
    20,
    5,
    9,
    14,
    20,
    5,
    9,
    14,
    20,
    5,
    9,
    14,
    20, // Round 2
    4,
    11,
    16,
    23,
    4,
    11,
    16,
    23,
    4,
    11,
    16,
    23,
    4,
    11,
    16,
    23, // Round 3
    6,
    10,
    15,
    21,
    6,
    10,
    15,
    21,
    6,
    10,
    15,
    21,
    6,
    10,
    15,
    21, // Round 4
  ];

  // Sine constants (T[i]) used in the MD5 algorithm.
  // These are derived from the sine function and are used to provide
  // a "randomized" element to the hash computation.
  final k = <int>[
    0xd76aa478,
    0xe8c7b756,
    0x242070db,
    0xc1bdceee,
    0xf57c0faf,
    0x4787c62a,
    0xa8304613,
    0xfd469501,
    0x698098d8,
    0x8b44f7af,
    0xffff5bb1,
    0x895cd7be,
    0x6b901122,
    0xfd987193,
    0xa679438e,
    0x49b40821,
    0xf61e2562,
    0xc040b340,
    0x265e5a51,
    0xe9b6c7aa,
    0xd62f105d,
    0x02441453,
    0xd8a1e681,
    0xe7d3fbc8,
    0x21e1cde6,
    0xc33707d6,
    0xf4d50d87,
    0x455a14ed,
    0xa9e3e905,
    0xfcefa3f8,
    0x676f02d9,
    0x8d2a4c8a,
    0xfffa3942,
    0x8771f681,
    0x6d9d6122,
    0xfde5380c,
    0xa4beea44,
    0x4bdecfa9,
    0xf6bb4b60,
    0xbebfbc70,
    0x289b7ec6,
    0xeaa127fa,
    0xd4ef3085,
    0x04881d05,
    0xd9d4d039,
    0xe6db99e5,
    0x1fa27cf8,
    0xc4ac5665,
    0xf4292244,
    0x432aff97,
    0xab9423a7,
    0xfc93a039,
    0x655b59c3,
    0x8f0ccc92,
    0xffeff47d,
    0x85845dd1,
    0x6fa87e4f,
    0xfe2ce6e0,
    0xa3014314,
    0x4e0811a1,
    0xf7537e82,
    0xbd3af235,
    0x2ad7d2bb,
    0xeb86d391,
  ];

  // Initialize hash values (A, B, C, D) as specified in the MD5 algorithm.
  // These are 32-bit words.
  int a0 = 0x67452301; // A
  int b0 = 0xefcdab89; // B
  int c0 = 0x98badcfe; // C
  int d0 = 0x10325476; // D

  // Pre-processing: adding padding bits
  // The message is padded to ensure its length (in bits) is congruent to 448
  // modulo 512. This means the message length + 1 (for the '1' bit) + padding
  // should be 448 mod 512.
  final msgLen = data.length;
  final paddingLen = (56 - (msgLen + 1) % 64) % 64;
  final totalLen = msgLen + 1 + paddingLen + 8; // +8 for the 64-bit length field

  // Create a new Uint8List to hold the padded message.
  final padded = Uint8List(totalLen);
  // Copy the original data to the padded list.
  padded.setRange(0, msgLen, data);
  // Append a single '1' bit (represented as 0x80 in bytes).
  padded[msgLen] = 0x80;

  // Append original length in bits as 64-bit little-endian.
  // The original message length (in bits) is appended as a 64-bit integer.
  // This is crucial for the security of the hash function.
  final bitLen = msgLen * 8;
  for (int i = 0; i < 8; i++) {
    padded[totalLen - 8 + i] = (bitLen >> (i * 8)) & 0xff;
  }

  // Process message in 512-bit (64-byte) chunks.
  // The core of the MD5 algorithm, iterating through each 512-bit block.
  for (int offset = 0; offset < totalLen; offset += 64) {
    // Each 512-bit chunk is divided into 16 32-bit words (chunk[0] to chunk[15]).
    final chunk = Uint32List(16);
    for (int i = 0; i < 16; i++) {
      // Convert 4 bytes from the padded message into a single 32-bit word
      // (little-endian format).
      chunk[i] =
          (padded[offset + i * 4 + 0] << 0) |
          (padded[offset + i * 4 + 1] << 8) |
          (padded[offset + i * 4 + 2] << 16) |
          (padded[offset + i * 4 + 3] << 24);
    }

    // Initialize working variables for this chunk with the current hash values.
    int a = a0, b = b0, c = c0, d = d0;

    // Main MD5 loop: 64 operations, divided into 4 rounds of 16 operations each.
    for (int i = 0; i < 64; i++) {
      int f, g; // f is the non-linear function, g is the index for the message word.

      // Determine the non-linear function (F, G, H, or I) and the message word index 'g'
      // based on the current round (i).
      if (i < 16) {
        // Round 1: F(B, C, D) = (B AND C) OR ((NOT B) AND D)
        f = (b & c) | ((~b) & d);
        g = i;
      } else if (i < 32) {
        // Round 2: G(B, C, D) = (D AND B) OR ((NOT D) AND C)
        f = (d & b) | ((~d) & c);
        g = (5 * i + 1) % 16;
      } else if (i < 48) {
        // Round 3: H(B, C, D) = B XOR C XOR D
        f = b ^ c ^ d;
        g = (3 * i + 5) % 16;
      } else {
        // Round 4: I(B, C, D) = C XOR (B OR (NOT D))
        f = c ^ (b | (~d));
        g = (7 * i) % 16;
      }

      // The core operation for each step:
      // 1. Add F, A, K[i], and the message word chunk[g].
      // 2. Left rotate the result by s[i] bits.
      // 3. Add B to the rotated result.
      // All additions are modulo 2^32 (0xffffffff).
      f = (f + a + k[i] + chunk[g]) & 0xffffffff;
      a = d;
      d = c;
      c = b;
      b = (b + _leftRotate(f, s[i])) & 0xffffffff;
    }

    // Add the results of this chunk's processing to the initial hash values.
    // These additions are also modulo 2^32.
    a0 = (a0 + a) & 0xffffffff;
    b0 = (b0 + b) & 0xffffffff;
    c0 = (c0 + c) & 0xffffffff;
    d0 = (d0 + d) & 0xffffffff;
  }

  // Produce final hash value (little-endian).
  // The final hash is the concatenation of the four 32-bit chaining variables
  // (a0, b0, c0, d0), stored in little-endian byte order.
  final result = Uint8List(16);
  for (int i = 0; i < 4; i++) {
    result[i] = (a0 >> (i * 8)) & 0xff;
    result[i + 4] = (b0 >> (i * 8)) & 0xff;
    result[i + 8] = (c0 >> (i * 8)) & 0xff;
    result[i + 12] = (d0 >> (i * 8)) & 0xff;
  }

  return result;
}

/// Performs a left bitwise rotation on a 32-bit integer.
///
/// Parameters:
/// - [value]: The 32-bit integer to rotate.
/// - [shift]: The number of bits to shift left.
///
/// Returns:
/// The rotated 32-bit integer.
int _leftRotate(int value, int shift) {
  // The rotation is performed by shifting left and ORing with the bits
  // that "wrapped around" from the left. The result is masked with 0xffffffff
  // to ensure it remains a 32-bit integer.
  return ((value << shift) | (value >> (32 - shift))) & 0xffffffff;
}
