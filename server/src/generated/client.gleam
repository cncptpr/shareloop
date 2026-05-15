//// Generated HTTP client from Shareloop API v1.0.0

import gleam/http.{Get}
import gleam/http/request.{type Request}
import gleam/http/response.{type Response}
import gleam/dynamic/decode
import gleam/json
import gleam/option.{type Option}
import gleam/float
import gleam/string
import gleam/list
import gleam/uri
import generated/types

/// Client configuration for API requests.
pub type ClientConfig {
  ClientConfig(
    base_url: String,
    headers: List(#(String, String)),
  )
}

/// Errors that can occur when processing API responses.
pub type ClientError {
  /// Unexpected HTTP status code
  UnexpectedStatus(status: Int, body: String)
  /// Failed to decode the response body
  DecodeError(message: String)
}

/// Get featured items
pub fn get_featured_items_request(config: ClientConfig, lat: Option(Float), lng: Option(Float)) -> Request(String) {
  let path = "/featured-items"
  let query = []
  let query = case lat {
    option.Some(v) -> list.append(query, [#("lat", float.to_string(v))])
    option.None -> query
  }
  let query = case lng {
    option.Some(v) -> list.append(query, [#("lng", float.to_string(v))])
    option.None -> query
  }
  let query_string = uri.query_to_string(query)
  let path = path <> "?" <> query_string
  request.new()
  |> request.set_method(Get)
  |> request.set_host(config.base_url)
  |> request.set_path(path)
  |> fn(req) {
    list.fold(config.headers, req, fn(r, h) {
      request.set_header(r, h.0, h.1)
    })
  }
  |> request.set_header("content-type", "application/json")
}

pub fn decode_get_featured_items_response(resp: Response(String)) -> Result(List(types.FeaturedItem), ClientError) {
  case resp.status {
    status if status >= 200 && status < 300 -> {
      case json.parse(resp.body, decode.list(types.featured_item_decoder())) {
        Ok(value) -> Ok(value)
        Error(_) -> Error(DecodeError("Failed to decode response"))
      }
    }
    status -> Error(UnexpectedStatus(status: status, body: resp.body))
  }
}
