import generated/types
import gleam/list
import gleam/option.{None, Some}
import gleam/result
import server/sql
import youid/uuid

pub fn get_featured_items(conn, location: types.LatLng) -> List(types.FeaturedItem) {
  sql.get_featured_items(conn, location.lat, location.lng)
  |> result.map(fn(returned) { returned.rows })
  |> result.unwrap([])
  |> list.map(fn(row) {
    types.FeaturedItem(
      id: row.id,
      title: row.title,
      description: row.description,
      author: types.Person(id: row.author_id, name: row.author_name),
      distance: Some(types.Distance(km: row.distance_km)),
      city: row.city,
      postal_code: row.postal_code,
      score: row.score,
      image_uuid: option.map(row.first_image_uuid, uuid.to_string),
    )
  })
}

pub fn get_featured_items_without_distance(conn) -> List(types.FeaturedItem) {
  sql.get_featured_items_without_distance(conn)
  |> result.map(fn(returned) { returned.rows })
  |> result.unwrap([])
  |> list.map(fn(row) {
    types.FeaturedItem(
      id: row.id,
      title: row.title,
      description: row.description,
      author: types.Person(id: row.author_id, name: row.author_name),
      distance: None,
      city: row.city,
      postal_code: row.postal_code,
      score: row.score,
      image_uuid: option.map(row.first_image_uuid, uuid.to_string),
    )
  })
}
