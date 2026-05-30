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
) -> Result(pog.Returned(GetFeaturedItemsRow), pog.QueryError) {
  let decoder = {
    use id <- decode.field(0, decode.int)
    use title <- decode.field(1, decode.string)
    use description <- decode.field(2, decode.string)
    use author_name <- decode.field(3, decode.string)
    use score <- decode.field(4, decode.float)
    decode.success(GetFeaturedItemsRow(
      id:,
      title:,
      description:,
      author_name:,
      score:,
    ))
  }

  "select
  id,
  title,
  description,
  author_name,
  score
from
  items
order by
  score desc
"
  |> pog.query
  |> pog.returning(decoder)
  |> pog.execute(db)
}
