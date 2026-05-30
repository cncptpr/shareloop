import gleam/bit_array
import gleam/crypto
import gleam/int
import gleam/string

const iterations = 600_000

const salt_size_in_bytes = 16

const key_length_in_bytes = 32

const id = "pbkdf2-sha256"

@external(erlang, "auth_ffi", "pbkdf2_hmac")
fn pbkdf2_hmac(
  password: BitArray,
  salt: BitArray,
  iterations: Int,
  key_length: Int,
) -> BitArray

fn encode(bits: BitArray) -> String {
  bit_array.base64_url_encode(bits, False)
}

pub fn hash(plaintext: String) -> String {
  let salt = crypto.strong_random_bytes(salt_size_in_bytes)
  let dk = pbkdf2_hmac(<<plaintext:utf8>>, salt, iterations, key_length_in_bytes)
  let salt_encoded = encode(salt)
  let hash_encoded = encode(dk)
  "$" <> id <> "$" <> int.to_string(iterations) <> "$" <> salt_encoded <> "$" <> hash_encoded
}

pub fn verify(plaintext: String, stored: String) -> Bool {
  case string.split(stored, on: "$") {
    ["", _algo, iter_str, salt_encoded, hash_encoded] -> {
      case bit_array.base64_url_decode(salt_encoded), bit_array.base64_url_decode(hash_encoded) {
        Ok(salt), Ok(expected_hash) -> {
          let desired_iterations = int.parse(iter_str)
          let actual_iterations = case desired_iterations {
            Ok(i) -> i
            _ -> iterations
          }
          let dk = pbkdf2_hmac(<<plaintext:utf8>>, salt, actual_iterations, key_length_in_bytes)
          crypto.secure_compare(dk, expected_hash)
        }
        _, _ -> False
      }
    }
    _ -> False
  }
}
