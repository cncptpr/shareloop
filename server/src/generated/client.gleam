//// Generated HTTP client from Shareloop API v1.0.0

import gleam/http.{Post}
import gleam/http/request.{type Request}
import gleam/http/response.{type Response}
import gleam/dynamic/decode
import gleam/json
import gleam/list
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

/// Login
pub fn login_request(config: ClientConfig, body: types.LoginRequest) -> Request(String) {
  let path = "/auth/login"
  request.new()
  |> request.set_method(Post)
  |> request.set_host(config.base_url)
  |> request.set_path(path)
  |> fn(req) {
    list.fold(config.headers, req, fn(r, h) {
      request.set_header(r, h.0, h.1)
    })
  }
  |> request.set_header("content-type", "application/json")
  |> request.set_body(json.to_string(types.encode_login_request(body)))
}

pub fn decode_login_response(resp: Response(String)) -> Result(types.LoginResult, ClientError) {
  case resp.status {
    status if status >= 200 && status < 300 -> {
      case json.parse(resp.body, types.login_result_decoder()) {
        Ok(value) -> Ok(value)
        Error(_) -> Error(DecodeError("Failed to decode response"))
      }
    }
    status -> Error(UnexpectedStatus(status: status, body: resp.body))
  }
}

/// Logout
pub fn logout_request(config: ClientConfig) -> Request(String) {
  let path = "/auth/logout"
  request.new()
  |> request.set_method(Post)
  |> request.set_host(config.base_url)
  |> request.set_path(path)
  |> fn(req) {
    list.fold(config.headers, req, fn(r, h) {
      request.set_header(r, h.0, h.1)
    })
  }
  |> request.set_header("content-type", "application/json")
}

pub fn decode_logout_response(resp: Response(String)) -> Result(Nil, ClientError) {
  case resp.status {
    status if status >= 200 && status < 300 -> {
      Ok(Nil)
    }
    status -> Error(UnexpectedStatus(status: status, body: resp.body))
  }
}

/// Refresh tokens
pub fn refresh_request(config: ClientConfig, body: types.RefreshRequest) -> Request(String) {
  let path = "/auth/refresh"
  request.new()
  |> request.set_method(Post)
  |> request.set_host(config.base_url)
  |> request.set_path(path)
  |> fn(req) {
    list.fold(config.headers, req, fn(r, h) {
      request.set_header(r, h.0, h.1)
    })
  }
  |> request.set_header("content-type", "application/json")
  |> request.set_body(json.to_string(types.encode_refresh_request(body)))
}

pub fn decode_refresh_response(resp: Response(String)) -> Result(types.LoginResult, ClientError) {
  case resp.status {
    status if status >= 200 && status < 300 -> {
      case json.parse(resp.body, types.login_result_decoder()) {
        Ok(value) -> Ok(value)
        Error(_) -> Error(DecodeError("Failed to decode response"))
      }
    }
    status -> Error(UnexpectedStatus(status: status, body: resp.body))
  }
}

/// Verify access token
pub fn verify_request(config: ClientConfig) -> Request(String) {
  let path = "/auth/verify"
  request.new()
  |> request.set_method(Post)
  |> request.set_host(config.base_url)
  |> request.set_path(path)
  |> fn(req) {
    list.fold(config.headers, req, fn(r, h) {
      request.set_header(r, h.0, h.1)
    })
  }
  |> request.set_header("content-type", "application/json")
}

pub fn decode_verify_response(resp: Response(String)) -> Result(types.User, ClientError) {
  case resp.status {
    status if status >= 200 && status < 300 -> {
      case json.parse(resp.body, types.user_decoder()) {
        Ok(value) -> Ok(value)
        Error(_) -> Error(DecodeError("Failed to decode response"))
      }
    }
    status -> Error(UnexpectedStatus(status: status, body: resp.body))
  }
}

/// Get featured items
pub fn get_featured_items_request(config: ClientConfig, body: types.LatLng) -> Request(String) {
  let path = "/featured-items"
  request.new()
  |> request.set_method(Post)
  |> request.set_host(config.base_url)
  |> request.set_path(path)
  |> fn(req) {
    list.fold(config.headers, req, fn(r, h) {
      request.set_header(r, h.0, h.1)
    })
  }
  |> request.set_header("content-type", "application/json")
  |> request.set_body(json.to_string(types.encode_lat_lng(body)))
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

/// Create a new item
pub fn create_item_request(config: ClientConfig, body: types.CreateItemRequest) -> Request(String) {
  let path = "/items"
  request.new()
  |> request.set_method(Post)
  |> request.set_host(config.base_url)
  |> request.set_path(path)
  |> fn(req) {
    list.fold(config.headers, req, fn(r, h) {
      request.set_header(r, h.0, h.1)
    })
  }
  |> request.set_header("content-type", "application/json")
  |> request.set_body(json.to_string(types.encode_create_item_request(body)))
}

pub fn decode_create_item_response(resp: Response(String)) -> Result(types.CreateItemResponse, ClientError) {
  case resp.status {
    status if status >= 200 && status < 300 -> {
      case json.parse(resp.body, types.create_item_response_decoder()) {
        Ok(value) -> Ok(value)
        Error(_) -> Error(DecodeError("Failed to decode response"))
      }
    }
    status -> Error(UnexpectedStatus(status: status, body: resp.body))
  }
}
