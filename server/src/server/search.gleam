import openapi/types
import gleam/list
import gleam/option.{None, Some}
import gleam/result
import gleam/string
import server/sql
import youid/uuid

fn categories_to_csv(categories: List(String)) -> String {
  string.join(categories, ",")
}

pub fn search_items(
  conn,
  req: types.ItemSearchRequest,
) -> List(types.ItemOverview) {
  let query_str = case req.query {
    None -> ""
    Some(q) -> q
  }
  let lat = case req.lat {
    None -> 0.0
    Some(v) -> v
  }
  let lng = case req.lng {
    None -> 0.0
    Some(v) -> v
  }
  let categories = case req.categories {
    None -> ""
    Some(cats) -> categories_to_csv(cats)
  }
  let min_score = case req.min_score {
    None -> 0.0
    Some(v) -> v
  }
  let max_distance_km = case req.max_distance_km {
    None -> 0.0
    Some(v) -> v
  }
  let sort_by = case req.sort_by {
    None -> ""
    Some(types.ItemSearchRequestSortByRelevance) -> "relevance"
    Some(types.ItemSearchRequestSortByDistance) -> "distance"
    Some(types.ItemSearchRequestSortByScore) -> "score"
    Some(types.ItemSearchRequestSortByNewest) -> "newest"
  }

  sql.search_items(
    conn,
    lat,
    lng,
    query_str,
    categories,
    min_score,
    max_distance_km,
    sort_by,
  )
  |> result.map(fn(returned) { returned.rows })
  |> result.unwrap([])
  |> list.map(fn(row) {
    types.ItemOverview(
      id: row.id,
      title: row.title,
      description: row.description,
      author: types.Person(id: row.author_id, name: row.author_name),
      category: row.category,
      distance: Some(types.Distance(km: row.distance_km)),
      city: row.city,
      postal_code: row.postal_code,
      score: row.score,
      image_uuid: option.map(row.first_image_uuid, uuid.to_string),
    )
  })
}
