import envoy
import gleam/result

pub fn image_upload_dir() {
  envoy.get("UPLOADS_DIR")
  |> result.lazy_unwrap(fn() { "./uploads" })
}

pub const mega_byte = 1_048_576

pub fn max_body_limit() {
  1 * mega_byte
}

pub fn max_upload_limit() {
  10 * mega_byte
}
