//// Generated routes from Shareloop API v1.0.0

import gleam/http.{type Method, Post}
import generated/types.{type LoginRequest, type LoginResult, type RefreshRequest, type User, type LatLng, type FeaturedItem}

pub type Route {
  Login
  Logout
  Refresh
  Verify
  GetFeaturedItems
  NotFound
}

pub fn match_route(method: Method, segments: List(String)) -> Route {
  case method, segments {
    Post, ["auth", "login"] -> Login
    Post, ["auth", "logout"] -> Logout
    Post, ["auth", "refresh"] -> Refresh
    Post, ["auth", "verify"] -> Verify
    Post, ["featured-items"] -> GetFeaturedItems
    _, _ -> NotFound
  }
}

/// Handler type for login
pub type LoginHandler =
  fn(LoginRequest, ) -> Result(LoginResult, String)

/// Handler type for logout
pub type LogoutHandler =
  fn() -> Result(Nil, String)

/// Handler type for refresh
pub type RefreshHandler =
  fn(RefreshRequest, ) -> Result(LoginResult, String)

/// Handler type for verify
pub type VerifyHandler =
  fn() -> Result(User, String)

/// Handler type for getFeaturedItems
pub type GetFeaturedItemsHandler =
  fn(LatLng, ) -> Result(List(FeaturedItem), String)
