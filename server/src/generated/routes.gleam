//// Generated routes from Shareloop API v1.0.0

import gleam/http.{type Method, Get}
import generated/types.{type FeaturedItem}

pub type Route {
  GetFeaturedItems
  NotFound
}

pub fn match_route(method: Method, segments: List(String)) -> Route {
  case method, segments {
    Get, ["featured-items"] -> GetFeaturedItems
    _, _ -> NotFound
  }
}

/// Handler type for getFeaturedItems
pub type GetFeaturedItemsHandler =
  fn() -> Result(List(FeaturedItem), String)
