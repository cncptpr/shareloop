import gleam/bit_array
import gleam/crypto

const token_byte_length = 32

fn encode(bits: BitArray) -> String {
  bit_array.base64_url_encode(bits, False)
}

fn decode(str: String) -> Result(BitArray, Nil) {
  bit_array.base64_url_decode(str)
}

pub fn generate_token_and_hash() -> #(String, String) {
  let token_bytes = crypto.strong_random_bytes(token_byte_length)
  let token = encode(token_bytes)
  let hash = encode(crypto.hash(crypto.Sha256, token_bytes))
  #(token, hash)
}

pub fn generate_token_pair() -> #(#(String, String), #(String, String)) {
  let #(access_token, access_hash) = generate_token_and_hash()
  let #(refresh_token, refresh_hash) = generate_token_and_hash()
  #(#(access_token, access_hash), #(refresh_token, refresh_hash))
}

pub fn hash_token(token: String) -> String {
  let assert Ok(token_bytes) = decode(token)
  encode(crypto.hash(crypto.Sha256, token_bytes))
}
