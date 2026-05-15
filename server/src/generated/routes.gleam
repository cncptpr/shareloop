//// Generated routes from Shareloop API v1.0.0

import gleam/http.{type Method, Post}
import generated/types.{type LatLng, type FeaturedItem}

pub type Route {
  GetFeaturedItems
  NotFound
}

pub fn match_route(method: Method, segments: List(String)) -> Route {
  case method, segments {
    Post, ["featured-items"] -> GetFeaturedItems
    _, _ -> NotFound
  }
}

/// Handler type for getFeaturedItems
pub type GetFeaturedItemsHandler =
  fn(LatLng, ) -> Result(List(FeaturedItem), String)
