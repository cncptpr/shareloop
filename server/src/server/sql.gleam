//// This module contains the code to run the sql queries defined in
//// `./src/server/sql`.
//// > 🐿️ This module was generated automatically using v4.6.0 of
//// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
////

import gleam/dynamic/decode
import pog

/// A row you get from running the `get_featured_items` query
/// defined in `./src/server/sql/get_featured_items.sql`.
///
/// > 🐿️ This type definition was generated automatically using v4.6.0 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type GetFeaturedItemsRow {
  GetFeaturedItemsRow(
    id: Int,
    title: String,
    description: String,
    author_name: String,
    score: Float,
    distance_km: Float,
  )
}

/// Runs the `get_featured_items` query
/// defined in `./src/server/sql/get_featured_items.sql`.
///
/// > 🐿️ This function was generated automatically using v4.6.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn get_featured_items(
  db: pog.Connection,
  arg_1: Float,
  arg_2: Float,
) -> Result(pog.Returned(GetFeaturedItemsRow), pog.QueryError) {
  let decoder = {
    use id <- decode.field(0, decode.int)
    use title <- decode.field(1, decode.string)
    use description <- decode.field(2, decode.string)
    use author_name <- decode.field(3, decode.string)
    use score <- decode.field(4, decode.float)
    use distance_km <- decode.field(5, decode.float)
    decode.success(GetFeaturedItemsRow(
      id:,
      title:,
      description:,
      author_name:,
      score:,
      distance_km:,
    ))
  }

  "select
  id,
  title,
  description,
  author_name,
  score,
  coalesce(
    st_distance(location, st_setsrid(st_makepoint($2, $1), 4326)::geography) / 1000,
    0.0
  ) as distance_km
from
  items
order by
  score desc
"
  |> pog.query
  |> pog.parameter(pog.float(arg_1))
  |> pog.parameter(pog.float(arg_2))
  |> pog.returning(decoder)
  |> pog.execute(db)
}
