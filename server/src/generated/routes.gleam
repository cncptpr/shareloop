//// Generated routes from Shareloop API v1.0.0

import gleam/http.{type Method, Get, Post}
import generated/types.{type LoginRequest, type LoginResult, type RefreshRequest, type User, type LatLng, type FeaturedItem, type CreateItemRequest, type CreateItemResponse, type UploadItemImageRequest, type UploadItemImageResponse}

pub type Route {
  Login
  Logout
  Refresh
  Verify
  GetFeaturedItems
  GetImage(image_id: String)
  CreateItem
  UploadItemImage(item_id: String)
  NotFound
}

pub fn match_route(method: Method, segments: List(String)) -> Route {
  case method, segments {
    Post, ["auth", "login"] -> Login
    Post, ["auth", "logout"] -> Logout
    Post, ["auth", "refresh"] -> Refresh
    Post, ["auth", "verify"] -> Verify
    Post, ["featured-items"] -> GetFeaturedItems
    Get, ["images", image_id] -> GetImage(image_id: image_id)
    Post, ["items"] -> CreateItem
    Post, ["items", item_id, "images"] -> UploadItemImage(item_id: item_id)
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

/// Handler type for getImage
pub type GetImageHandler =
  fn(String, ) -> Result(String, String)

/// Handler type for createItem
pub type CreateItemHandler =
  fn(CreateItemRequest, ) -> Result(CreateItemResponse, String)

/// Handler type for uploadItemImage
pub type UploadItemImageHandler =
  fn(String, UploadItemImageRequest, ) -> Result(UploadItemImageResponse, String)
