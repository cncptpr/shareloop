//// This module contains the code to run the sql queries defined in
//// `./src/server/sql`.
//// > 🐿️ This module was generated automatically using v4.7.0 of
//// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
////

import gleam/dynamic/decode
import gleam/option.{type Option}
import gleam/time/timestamp.{type Timestamp}
import pog
import youid/uuid.{type Uuid}

/// A row you get from running the `accept_offer` query
/// defined in `./src/server/sql/accept_offer.sql`.
///
/// > 🐿️ This type definition was generated automatically using v4.7.0 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type AcceptOfferRow {
  AcceptOfferRow(id: Int)
}

/// Runs the `accept_offer` query
/// defined in `./src/server/sql/accept_offer.sql`.
///
/// > 🐿️ This function was generated automatically using v4.7.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn accept_offer(
  db: pog.Connection,
  id: Int,
) -> Result(pog.Returned(AcceptOfferRow), pog.QueryError) {
  let decoder = {
    use id <- decode.field(0, decode.int)
    decode.success(AcceptOfferRow(id:))
  }

  "UPDATE rent_offers SET accepted_at = now(), updated_at = now() WHERE id = $1 AND accepted_at IS NULL
returning id
"
  |> pog.query
  |> pog.parameter(pog.int(id))
  |> pog.returning(decoder)
  |> pog.execute(db)
}

/// A row you get from running the `count_unread_messages` query
/// defined in `./src/server/sql/count_unread_messages.sql`.
///
/// > 🐿️ This type definition was generated automatically using v4.7.0 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type CountUnreadMessagesRow {
  CountUnreadMessagesRow(id: Int, cnt: Int)
}

/// Runs the `count_unread_messages` query
/// defined in `./src/server/sql/count_unread_messages.sql`.
///
/// > 🐿️ This function was generated automatically using v4.7.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn count_unread_messages(
  db: pog.Connection,
  rr2_requester_id: Int,
) -> Result(pog.Returned(CountUnreadMessagesRow), pog.QueryError) {
  let decoder = {
    use id <- decode.field(0, decode.int)
    use cnt <- decode.field(1, decode.int)
    decode.success(CountUnreadMessagesRow(id:, cnt:))
  }

  "SELECT
  rr.id,
  COUNT(u.event_at)::int AS cnt
FROM rent_requests rr
LEFT JOIN (
  -- messages from the other participant
  SELECT m.rent_request_id, m.created_at AS event_at FROM messages m WHERE m.author_id != $1
  UNION ALL
  -- offers from the other participant
  SELECT ro.rent_request_id, ro.created_at FROM rent_offers ro WHERE ro.sender_id != $1
  UNION ALL
  -- accepted offers (owner accepts → unread for requester)
  SELECT ro2.rent_request_id, ro2.accepted_at
  FROM rent_offers ro2
  JOIN rent_requests rr2 ON rr2.id = ro2.rent_request_id
  WHERE ro2.accepted_at IS NOT NULL AND $1 = rr2.requester_id
  UNION ALL
  -- borrow confirmed (owner confirms → unread for requester)
  SELECT rr3.id, rr3.borrow_confirmed_at
  FROM rent_requests rr3
  WHERE rr3.borrow_confirmed_at IS NOT NULL AND $1 = rr3.requester_id
  UNION ALL
  -- return confirmed (owner confirms → unread for requester)
  SELECT rr4.id, rr4.returned_at
  FROM rent_requests rr4
  WHERE rr4.returned_at IS NOT NULL AND $1 = rr4.requester_id
) u ON u.rent_request_id = rr.id
  AND u.event_at > COALESCE(
    CASE WHEN $1 = rr.requester_id THEN rr.requester_read_at ELSE rr.owner_read_at END,
    '1970-01-01'::timestamp
  )
WHERE rr.requester_id = $1 OR rr.item_id IN (SELECT id FROM items WHERE author_id = $1)
GROUP BY rr.id
"
  |> pog.query
  |> pog.parameter(pog.int(rr2_requester_id))
  |> pog.returning(decoder)
  |> pog.execute(db)
}

/// A row you get from running the `create_item` query
/// defined in `./src/server/sql/create_item.sql`.
///
/// > 🐿️ This type definition was generated automatically using v4.7.0 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type CreateItemRow {
  CreateItemRow(id: Int)
}

/// Runs the `create_item` query
/// defined in `./src/server/sql/create_item.sql`.
///
/// > 🐿️ This function was generated automatically using v4.7.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn create_item(
  db: pog.Connection,
  arg_1: String,
  arg_2: String,
  arg_3: Int,
  arg_4: Float,
  arg_5: Float,
  arg_6: Float,
  arg_7: String,
  arg_8: String,
) -> Result(pog.Returned(CreateItemRow), pog.QueryError) {
  let decoder = {
    use id <- decode.field(0, decode.int)
    decode.success(CreateItemRow(id:))
  }

  "INSERT INTO items (title, description, author_id, score, location, city, postal_code) VALUES ($1, $2, $3, $4, st_setsrid(st_makepoint($5, $6), 4326)::geography, $7, $8)
returning id
"
  |> pog.query
  |> pog.parameter(pog.text(arg_1))
  |> pog.parameter(pog.text(arg_2))
  |> pog.parameter(pog.int(arg_3))
  |> pog.parameter(pog.float(arg_4))
  |> pog.parameter(pog.float(arg_5))
  |> pog.parameter(pog.float(arg_6))
  |> pog.parameter(pog.text(arg_7))
  |> pog.parameter(pog.text(arg_8))
  |> pog.returning(decoder)
  |> pog.execute(db)
}

/// A row you get from running the `create_message` query
/// defined in `./src/server/sql/create_message.sql`.
///
/// > 🐿️ This type definition was generated automatically using v4.7.0 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type CreateMessageRow {
  CreateMessageRow(id: Int)
}

/// Runs the `create_message` query
/// defined in `./src/server/sql/create_message.sql`.
///
/// > 🐿️ This function was generated automatically using v4.7.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn create_message(
  db: pog.Connection,
  arg_1: Int,
  arg_2: Int,
  arg_3: String,
) -> Result(pog.Returned(CreateMessageRow), pog.QueryError) {
  let decoder = {
    use id <- decode.field(0, decode.int)
    decode.success(CreateMessageRow(id:))
  }

  "INSERT INTO messages (rent_request_id, author_id, content) VALUES ($1, $2, $3)
returning id
"
  |> pog.query
  |> pog.parameter(pog.int(arg_1))
  |> pog.parameter(pog.int(arg_2))
  |> pog.parameter(pog.text(arg_3))
  |> pog.returning(decoder)
  |> pog.execute(db)
}

/// A row you get from running the `create_offer` query
/// defined in `./src/server/sql/create_offer.sql`.
///
/// > 🐿️ This type definition was generated automatically using v4.7.0 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type CreateOfferRow {
  CreateOfferRow(id: Int)
}

/// Runs the `create_offer` query
/// defined in `./src/server/sql/create_offer.sql`.
///
/// > 🐿️ This function was generated automatically using v4.7.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn create_offer(
  db: pog.Connection,
  arg_1: Int,
  arg_2: Int,
  arg_3: Timestamp,
  arg_4: Timestamp,
) -> Result(pog.Returned(CreateOfferRow), pog.QueryError) {
  let decoder = {
    use id <- decode.field(0, decode.int)
    decode.success(CreateOfferRow(id:))
  }

  "INSERT INTO rent_offers (rent_request_id, sender_id, start_date, end_date) VALUES ($1, $2, $3, $4)
returning id
"
  |> pog.query
  |> pog.parameter(pog.int(arg_1))
  |> pog.parameter(pog.int(arg_2))
  |> pog.parameter(pog.timestamp(arg_3))
  |> pog.parameter(pog.timestamp(arg_4))
  |> pog.returning(decoder)
  |> pog.execute(db)
}

/// Runs the `create_profile` query
/// defined in `./src/server/sql/create_profile.sql`.
///
/// > 🐿️ This function was generated automatically using v4.7.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn create_profile(
  db: pog.Connection,
  arg_1: Int,
  arg_2: String,
  arg_3: String,
  arg_4: Float,
) -> Result(pog.Returned(Nil), pog.QueryError) {
  let decoder = decode.map(decode.dynamic, fn(_) { Nil })

  "INSERT INTO profiles (id, name, bio, rating) VALUES ($1, $2, $3, $4)
"
  |> pog.query
  |> pog.parameter(pog.int(arg_1))
  |> pog.parameter(pog.text(arg_2))
  |> pog.parameter(pog.text(arg_3))
  |> pog.parameter(pog.float(arg_4))
  |> pog.returning(decoder)
  |> pog.execute(db)
}

/// A row you get from running the `create_rent_request` query
/// defined in `./src/server/sql/create_rent_request.sql`.
///
/// > 🐿️ This type definition was generated automatically using v4.7.0 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type CreateRentRequestRow {
  CreateRentRequestRow(id: Int)
}

/// Runs the `create_rent_request` query
/// defined in `./src/server/sql/create_rent_request.sql`.
///
/// > 🐿️ This function was generated automatically using v4.7.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn create_rent_request(
  db: pog.Connection,
  arg_1: Int,
  arg_2: Int,
) -> Result(pog.Returned(CreateRentRequestRow), pog.QueryError) {
  let decoder = {
    use id <- decode.field(0, decode.int)
    decode.success(CreateRentRequestRow(id:))
  }

  "INSERT INTO rent_requests (item_id, requester_id) VALUES ($1, $2)
returning id
"
  |> pog.query
  |> pog.parameter(pog.int(arg_1))
  |> pog.parameter(pog.int(arg_2))
  |> pog.returning(decoder)
  |> pog.execute(db)
}

/// A row you get from running the `create_session` query
/// defined in `./src/server/sql/create_session.sql`.
///
/// > 🐿️ This type definition was generated automatically using v4.7.0 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type CreateSessionRow {
  CreateSessionRow(id: Int)
}

/// Runs the `create_session` query
/// defined in `./src/server/sql/create_session.sql`.
///
/// > 🐿️ This function was generated automatically using v4.7.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn create_session(
  db: pog.Connection,
  arg_1: String,
  arg_2: Int,
  arg_3: Timestamp,
  arg_4: String,
  arg_5: Timestamp,
) -> Result(pog.Returned(CreateSessionRow), pog.QueryError) {
  let decoder = {
    use id <- decode.field(0, decode.int)
    decode.success(CreateSessionRow(id:))
  }

  "insert into sessions (token_hash, user_id, expires_at, refresh_token_hash, refresh_expires_at) values ($1, $2, $3, $4, $5) returning id
"
  |> pog.query
  |> pog.parameter(pog.text(arg_1))
  |> pog.parameter(pog.int(arg_2))
  |> pog.parameter(pog.timestamp(arg_3))
  |> pog.parameter(pog.text(arg_4))
  |> pog.parameter(pog.timestamp(arg_5))
  |> pog.returning(decoder)
  |> pog.execute(db)
}

/// A row you get from running the `create_user` query
/// defined in `./src/server/sql/create_user.sql`.
///
/// > 🐿️ This type definition was generated automatically using v4.7.0 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type CreateUserRow {
  CreateUserRow(id: Int)
}

/// Runs the `create_user` query
/// defined in `./src/server/sql/create_user.sql`.
///
/// > 🐿️ This function was generated automatically using v4.7.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn create_user(
  db: pog.Connection,
  arg_1: String,
  arg_2: String,
) -> Result(pog.Returned(CreateUserRow), pog.QueryError) {
  let decoder = {
    use id <- decode.field(0, decode.int)
    decode.success(CreateUserRow(id:))
  }

  "insert into users (email, password_hash) values ($1, $2) returning id
"
  |> pog.query
  |> pog.parameter(pog.text(arg_1))
  |> pog.parameter(pog.text(arg_2))
  |> pog.returning(decoder)
  |> pog.execute(db)
}

/// Runs the `delete_all_items` query
/// defined in `./src/server/sql/delete_all_items.sql`.
///
/// > 🐿️ This function was generated automatically using v4.7.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn delete_all_items(
  db: pog.Connection,
) -> Result(pog.Returned(Nil), pog.QueryError) {
  let decoder = decode.map(decode.dynamic, fn(_) { Nil })

  "DELETE FROM items
"
  |> pog.query
  |> pog.returning(decoder)
  |> pog.execute(db)
}

/// Runs the `delete_all_profiles` query
/// defined in `./src/server/sql/delete_all_profiles.sql`.
///
/// > 🐿️ This function was generated automatically using v4.7.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn delete_all_profiles(
  db: pog.Connection,
) -> Result(pog.Returned(Nil), pog.QueryError) {
  let decoder = decode.map(decode.dynamic, fn(_) { Nil })

  "DELETE FROM profiles
"
  |> pog.query
  |> pog.returning(decoder)
  |> pog.execute(db)
}

/// Runs the `delete_all_users` query
/// defined in `./src/server/sql/delete_all_users.sql`.
///
/// > 🐿️ This function was generated automatically using v4.7.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn delete_all_users(
  db: pog.Connection,
) -> Result(pog.Returned(Nil), pog.QueryError) {
  let decoder = decode.map(decode.dynamic, fn(_) { Nil })

  "DELETE FROM users
"
  |> pog.query
  |> pog.returning(decoder)
  |> pog.execute(db)
}

/// A row you get from running the `delete_item_image` query
/// defined in `./src/server/sql/delete_item_image.sql`.
///
/// > 🐿️ This type definition was generated automatically using v4.7.0 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type DeleteItemImageRow {
  DeleteItemImageRow(original_name: String)
}

/// Runs the `delete_item_image` query
/// defined in `./src/server/sql/delete_item_image.sql`.
///
/// > 🐿️ This function was generated automatically using v4.7.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn delete_item_image(
  db: pog.Connection,
  id: Uuid,
  item_id: Int,
) -> Result(pog.Returned(DeleteItemImageRow), pog.QueryError) {
  let decoder = {
    use original_name <- decode.field(0, decode.string)
    decode.success(DeleteItemImageRow(original_name:))
  }

  "DELETE FROM item_images WHERE id=$1 AND item_id=$2
returning original_name
"
  |> pog.query
  |> pog.parameter(pog.text(uuid.to_string(id)))
  |> pog.parameter(pog.int(item_id))
  |> pog.returning(decoder)
  |> pog.execute(db)
}

/// Runs the `delete_session` query
/// defined in `./src/server/sql/delete_session.sql`.
///
/// > 🐿️ This function was generated automatically using v4.7.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn delete_session(
  db: pog.Connection,
  id: Int,
) -> Result(pog.Returned(Nil), pog.QueryError) {
  let decoder = decode.map(decode.dynamic, fn(_) { Nil })

  "delete from sessions where id = $1
"
  |> pog.query
  |> pog.parameter(pog.int(id))
  |> pog.returning(decoder)
  |> pog.execute(db)
}

/// Runs the `delete_user_sessions` query
/// defined in `./src/server/sql/delete_user_sessions.sql`.
///
/// > 🐿️ This function was generated automatically using v4.7.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn delete_user_sessions(
  db: pog.Connection,
  user_id: Int,
) -> Result(pog.Returned(Nil), pog.QueryError) {
  let decoder = decode.map(decode.dynamic, fn(_) { Nil })

  "delete from sessions where user_id = $1
"
  |> pog.query
  |> pog.parameter(pog.int(user_id))
  |> pog.returning(decoder)
  |> pog.execute(db)
}

/// Runs the `expire_session_access` query
/// defined in `./src/server/sql/expire_session_access.sql`.
///
/// > 🐿️ This function was generated automatically using v4.7.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn expire_session_access(
  db: pog.Connection,
  id: Int,
) -> Result(pog.Returned(Nil), pog.QueryError) {
  let decoder = decode.map(decode.dynamic, fn(_) { Nil })

  "update sessions set expires_at = now() where id = $1
"
  |> pog.query
  |> pog.parameter(pog.int(id))
  |> pog.returning(decoder)
  |> pog.execute(db)
}

/// Runs the `expire_session_access_for_email` query
/// defined in `./src/server/sql/expire_session_access_for_email.sql`.
///
/// > 🐿️ This function was generated automatically using v4.7.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn expire_session_access_for_email(
  db: pog.Connection,
  email: String,
) -> Result(pog.Returned(Nil), pog.QueryError) {
  let decoder = decode.map(decode.dynamic, fn(_) { Nil })

  "update sessions
set expires_at = now()
where user_id = (
    select id
    from users
    where email = $1
)
"
  |> pog.query
  |> pog.parameter(pog.text(email))
  |> pog.returning(decoder)
  |> pog.execute(db)
}

/// Runs the `expire_session_refresh` query
/// defined in `./src/server/sql/expire_session_refresh.sql`.
///
/// > 🐿️ This function was generated automatically using v4.7.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn expire_session_refresh(
  db: pog.Connection,
  id: Int,
) -> Result(pog.Returned(Nil), pog.QueryError) {
  let decoder = decode.map(decode.dynamic, fn(_) { Nil })

  "update sessions set refresh_expires_at = now() where id = $1
"
  |> pog.query
  |> pog.parameter(pog.int(id))
  |> pog.returning(decoder)
  |> pog.execute(db)
}

/// Runs the `expire_session_refresh_for_email` query
/// defined in `./src/server/sql/expire_session_refresh_for_email.sql`.
///
/// > 🐿️ This function was generated automatically using v4.7.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn expire_session_refresh_for_email(
  db: pog.Connection,
  email: String,
) -> Result(pog.Returned(Nil), pog.QueryError) {
  let decoder = decode.map(decode.dynamic, fn(_) { Nil })

  "update sessions
set refresh_expires_at = now()
where user_id = (
    select id
    from users
    where email = $1
)
"
  |> pog.query
  |> pog.parameter(pog.text(email))
  |> pog.returning(decoder)
  |> pog.execute(db)
}

/// A row you get from running the `get_featured_items` query
/// defined in `./src/server/sql/get_featured_items.sql`.
///
/// > 🐿️ This type definition was generated automatically using v4.7.0 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type GetFeaturedItemsRow {
  GetFeaturedItemsRow(
    id: Int,
    title: String,
    description: String,
    author_name: String,
    author_id: Int,
    score: Float,
    city: Option(String),
    postal_code: Option(String),
    distance_km: Float,
    first_image_uuid: Option(Uuid),
  )
}

/// Runs the `get_featured_items` query
/// defined in `./src/server/sql/get_featured_items.sql`.
///
/// > 🐿️ This function was generated automatically using v4.7.0 of
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
    use author_id <- decode.field(4, decode.int)
    use score <- decode.field(5, decode.float)
    use city <- decode.field(6, decode.optional(decode.string))
    use postal_code <- decode.field(7, decode.optional(decode.string))
    use distance_km <- decode.field(8, decode.float)
    use first_image_uuid <- decode.field(9, decode.optional(uuid_decoder()))
    decode.success(GetFeaturedItemsRow(
      id:,
      title:,
      description:,
      author_name:,
      author_id:,
      score:,
      city:,
      postal_code:,
      distance_km:,
      first_image_uuid:,
    ))
  }

  "select
  items.id,
  items.title,
  items.description,
  profiles.name as author_name,
  items.author_id,
  items.score,
  items.city,
  items.postal_code,
  coalesce(
    st_distance(location, st_setsrid(st_makepoint($2, $1), 4326)::geography) / 1000,
    0.0
  ) as distance_km,
  first_img.id as first_image_uuid
from items, profiles
left join lateral (
  select id
  from item_images
  where item_images.item_id = items.id
  order by sort_order, created_at
  limit 1
) as first_img on true
where items.author_id = profiles.id
order by score desc"
  |> pog.query
  |> pog.parameter(pog.float(arg_1))
  |> pog.parameter(pog.float(arg_2))
  |> pog.returning(decoder)
  |> pog.execute(db)
}

/// A row you get from running the `get_featured_items_without_distance` query
/// defined in `./src/server/sql/get_featured_items_without_distance.sql`.
///
/// > 🐿️ This type definition was generated automatically using v4.7.0 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type GetFeaturedItemsWithoutDistanceRow {
  GetFeaturedItemsWithoutDistanceRow(
    id: Int,
    title: String,
    description: String,
    author_name: String,
    author_id: Int,
    score: Float,
    city: Option(String),
    postal_code: Option(String),
    first_image_uuid: Option(Uuid),
  )
}

/// Runs the `get_featured_items_without_distance` query
/// defined in `./src/server/sql/get_featured_items_without_distance.sql`.
///
/// > 🐿️ This function was generated automatically using v4.7.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn get_featured_items_without_distance(
  db: pog.Connection,
) -> Result(pog.Returned(GetFeaturedItemsWithoutDistanceRow), pog.QueryError) {
  let decoder = {
    use id <- decode.field(0, decode.int)
    use title <- decode.field(1, decode.string)
    use description <- decode.field(2, decode.string)
    use author_name <- decode.field(3, decode.string)
    use author_id <- decode.field(4, decode.int)
    use score <- decode.field(5, decode.float)
    use city <- decode.field(6, decode.optional(decode.string))
    use postal_code <- decode.field(7, decode.optional(decode.string))
    use first_image_uuid <- decode.field(8, decode.optional(uuid_decoder()))
    decode.success(GetFeaturedItemsWithoutDistanceRow(
      id:,
      title:,
      description:,
      author_name:,
      author_id:,
      score:,
      city:,
      postal_code:,
      first_image_uuid:,
    ))
  }

  "select
  items.id,
  items.title,
  items.description,
  profiles.name as author_name,
  items.author_id,
  items.score,
  items.city,
  items.postal_code,
  first_img.id as first_image_uuid
from items, profiles
left join lateral (
  select id
  from item_images
  where item_images.item_id = items.id
  order by sort_order, created_at
  limit 1
) as first_img on true
where items.author_id = profiles.id
order by score desc"
  |> pog.query
  |> pog.returning(decoder)
  |> pog.execute(db)
}

/// A row you get from running the `get_item_by_id` query
/// defined in `./src/server/sql/get_item_by_id.sql`.
///
/// > 🐿️ This type definition was generated automatically using v4.7.0 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type GetItemByIdRow {
  GetItemByIdRow(
    id: Int,
    title: String,
    description: String,
    author_name: String,
    score: Float,
    city: Option(String),
    postal_code: Option(String),
    created_at: String,
    author_id: Int,
    lng: Float,
    lat: Float,
  )
}

/// Runs the `get_item_by_id` query
/// defined in `./src/server/sql/get_item_by_id.sql`.
///
/// > 🐿️ This function was generated automatically using v4.7.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn get_item_by_id(
  db: pog.Connection,
  items_id: Int,
) -> Result(pog.Returned(GetItemByIdRow), pog.QueryError) {
  let decoder = {
    use id <- decode.field(0, decode.int)
    use title <- decode.field(1, decode.string)
    use description <- decode.field(2, decode.string)
    use author_name <- decode.field(3, decode.string)
    use score <- decode.field(4, decode.float)
    use city <- decode.field(5, decode.optional(decode.string))
    use postal_code <- decode.field(6, decode.optional(decode.string))
    use created_at <- decode.field(7, decode.string)
    use author_id <- decode.field(8, decode.int)
    use lng <- decode.field(9, decode.float)
    use lat <- decode.field(10, decode.float)
    decode.success(GetItemByIdRow(
      id:,
      title:,
      description:,
      author_name:,
      score:,
      city:,
      postal_code:,
      created_at:,
      author_id:,
      lng:,
      lat:,
    ))
  }

  "select
  items.id,
  items.title,
  items.description,
  profiles.name as author_name,
  items.score,
  items.city,
  items.postal_code,
  items.created_at::text as created_at,
  items.author_id,
  st_x(items.location::geometry) as lng,
  st_y(items.location::geometry) as lat
from items, profiles
where items.id = $1 and items.author_id = profiles.id"
  |> pog.query
  |> pog.parameter(pog.int(items_id))
  |> pog.returning(decoder)
  |> pog.execute(db)
}

/// A row you get from running the `get_item_image` query
/// defined in `./src/server/sql/get_item_image.sql`.
///
/// > 🐿️ This type definition was generated automatically using v4.7.0 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type GetItemImageRow {
  GetItemImageRow(
    id: Uuid,
    item_id: Int,
    original_name: String,
    mime_type: String,
  )
}

/// Runs the `get_item_image` query
/// defined in `./src/server/sql/get_item_image.sql`.
///
/// > 🐿️ This function was generated automatically using v4.7.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn get_item_image(
  db: pog.Connection,
  id: Uuid,
) -> Result(pog.Returned(GetItemImageRow), pog.QueryError) {
  let decoder = {
    use id <- decode.field(0, uuid_decoder())
    use item_id <- decode.field(1, decode.int)
    use original_name <- decode.field(2, decode.string)
    use mime_type <- decode.field(3, decode.string)
    decode.success(GetItemImageRow(id:, item_id:, original_name:, mime_type:))
  }

  "SELECT id, item_id, original_name, mime_type
FROM item_images
WHERE id = $1"
  |> pog.query
  |> pog.parameter(pog.text(uuid.to_string(id)))
  |> pog.returning(decoder)
  |> pog.execute(db)
}

/// A row you get from running the `get_item_images_for_item` query
/// defined in `./src/server/sql/get_item_images_for_item.sql`.
///
/// > 🐿️ This type definition was generated automatically using v4.7.0 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type GetItemImagesForItemRow {
  GetItemImagesForItemRow(id: Uuid)
}

/// Runs the `get_item_images_for_item` query
/// defined in `./src/server/sql/get_item_images_for_item.sql`.
///
/// > 🐿️ This function was generated automatically using v4.7.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn get_item_images_for_item(
  db: pog.Connection,
  item_id: Int,
) -> Result(pog.Returned(GetItemImagesForItemRow), pog.QueryError) {
  let decoder = {
    use id <- decode.field(0, uuid_decoder())
    decode.success(GetItemImagesForItemRow(id:))
  }

  "select id from item_images where item_id = $1 order by sort_order, created_at"
  |> pog.query
  |> pog.parameter(pog.int(item_id))
  |> pog.returning(decoder)
  |> pog.execute(db)
}

/// A row you get from running the `get_latest_accepted_offer` query
/// defined in `./src/server/sql/get_latest_accepted_offer.sql`.
///
/// > 🐿️ This type definition was generated automatically using v4.7.0 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type GetLatestAcceptedOfferRow {
  GetLatestAcceptedOfferRow(
    id: Int,
    rent_request_id: Int,
    sender_id: Int,
    start_date: Timestamp,
    end_date: Timestamp,
    accepted_at: Option(Timestamp),
    created_at: Timestamp,
    updated_at: Timestamp,
  )
}

/// Runs the `get_latest_accepted_offer` query
/// defined in `./src/server/sql/get_latest_accepted_offer.sql`.
///
/// > 🐿️ This function was generated automatically using v4.7.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn get_latest_accepted_offer(
  db: pog.Connection,
  rent_request_id: Int,
) -> Result(pog.Returned(GetLatestAcceptedOfferRow), pog.QueryError) {
  let decoder = {
    use id <- decode.field(0, decode.int)
    use rent_request_id <- decode.field(1, decode.int)
    use sender_id <- decode.field(2, decode.int)
    use start_date <- decode.field(3, pog.timestamp_decoder())
    use end_date <- decode.field(4, pog.timestamp_decoder())
    use accepted_at <- decode.field(5, decode.optional(pog.timestamp_decoder()))
    use created_at <- decode.field(6, pog.timestamp_decoder())
    use updated_at <- decode.field(7, pog.timestamp_decoder())
    decode.success(GetLatestAcceptedOfferRow(
      id:,
      rent_request_id:,
      sender_id:,
      start_date:,
      end_date:,
      accepted_at:,
      created_at:,
      updated_at:,
    ))
  }

  "SELECT
  id,
  rent_request_id,
  sender_id,
  start_date as start_date,
  end_date as end_date,
  accepted_at as accepted_at,
  created_at as created_at,
  updated_at as updated_at
FROM rent_offers
WHERE rent_request_id = $1 AND accepted_at IS NOT NULL
ORDER BY accepted_at DESC
LIMIT 1
"
  |> pog.query
  |> pog.parameter(pog.int(rent_request_id))
  |> pog.returning(decoder)
  |> pog.execute(db)
}

/// A row you get from running the `get_latest_open_offer` query
/// defined in `./src/server/sql/get_latest_open_offer.sql`.
///
/// > 🐿️ This type definition was generated automatically using v4.7.0 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type GetLatestOpenOfferRow {
  GetLatestOpenOfferRow(
    id: Int,
    rent_request_id: Int,
    sender_id: Int,
    start_date: Timestamp,
    end_date: Timestamp,
    accepted_at: Option(Timestamp),
    created_at: Timestamp,
    updated_at: Timestamp,
  )
}

/// Runs the `get_latest_open_offer` query
/// defined in `./src/server/sql/get_latest_open_offer.sql`.
///
/// > 🐿️ This function was generated automatically using v4.7.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn get_latest_open_offer(
  db: pog.Connection,
  rent_request_id: Int,
) -> Result(pog.Returned(GetLatestOpenOfferRow), pog.QueryError) {
  let decoder = {
    use id <- decode.field(0, decode.int)
    use rent_request_id <- decode.field(1, decode.int)
    use sender_id <- decode.field(2, decode.int)
    use start_date <- decode.field(3, pog.timestamp_decoder())
    use end_date <- decode.field(4, pog.timestamp_decoder())
    use accepted_at <- decode.field(5, decode.optional(pog.timestamp_decoder()))
    use created_at <- decode.field(6, pog.timestamp_decoder())
    use updated_at <- decode.field(7, pog.timestamp_decoder())
    decode.success(GetLatestOpenOfferRow(
      id:,
      rent_request_id:,
      sender_id:,
      start_date:,
      end_date:,
      accepted_at:,
      created_at:,
      updated_at:,
    ))
  }

  "SELECT
  id,
  rent_request_id,
  sender_id,
  start_date as start_date,
  end_date as end_date,
  accepted_at as accepted_at,
  created_at as created_at,
  updated_at as updated_at
FROM rent_offers
WHERE rent_request_id = $1 AND accepted_at IS NULL
ORDER BY created_at DESC
LIMIT 1
"
  |> pog.query
  |> pog.parameter(pog.int(rent_request_id))
  |> pog.returning(decoder)
  |> pog.execute(db)
}

/// A row you get from running the `get_messages_after_timestamp` query
/// defined in `./src/server/sql/get_messages_after_timestamp.sql`.
///
/// > 🐿️ This type definition was generated automatically using v4.7.0 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type GetMessagesAfterTimestampRow {
  GetMessagesAfterTimestampRow(
    id: Int,
    rent_request_id: Int,
    author_id: Int,
    content: String,
    created_at: Timestamp,
  )
}

/// Runs the `get_messages_after_timestamp` query
/// defined in `./src/server/sql/get_messages_after_timestamp.sql`.
///
/// > 🐿️ This function was generated automatically using v4.7.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn get_messages_after_timestamp(
  db: pog.Connection,
  rent_request_id: Int,
  arg_2: Timestamp,
) -> Result(pog.Returned(GetMessagesAfterTimestampRow), pog.QueryError) {
  let decoder = {
    use id <- decode.field(0, decode.int)
    use rent_request_id <- decode.field(1, decode.int)
    use author_id <- decode.field(2, decode.int)
    use content <- decode.field(3, decode.string)
    use created_at <- decode.field(4, pog.timestamp_decoder())
    decode.success(GetMessagesAfterTimestampRow(
      id:,
      rent_request_id:,
      author_id:,
      content:,
      created_at:,
    ))
  }

  "SELECT
  id,
  rent_request_id,
  author_id,
  content,
  created_at as created_at
FROM messages
WHERE rent_request_id = $1
  AND created_at > $2
ORDER BY created_at ASC
"
  |> pog.query
  |> pog.parameter(pog.int(rent_request_id))
  |> pog.parameter(pog.timestamp(arg_2))
  |> pog.returning(decoder)
  |> pog.execute(db)
}

/// A row you get from running the `get_messages_for_request` query
/// defined in `./src/server/sql/get_messages_for_request.sql`.
///
/// > 🐿️ This type definition was generated automatically using v4.7.0 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type GetMessagesForRequestRow {
  GetMessagesForRequestRow(
    id: Int,
    rent_request_id: Int,
    author_id: Int,
    content: String,
    created_at: Timestamp,
  )
}

/// Runs the `get_messages_for_request` query
/// defined in `./src/server/sql/get_messages_for_request.sql`.
///
/// > 🐿️ This function was generated automatically using v4.7.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn get_messages_for_request(
  db: pog.Connection,
  rent_request_id: Int,
) -> Result(pog.Returned(GetMessagesForRequestRow), pog.QueryError) {
  let decoder = {
    use id <- decode.field(0, decode.int)
    use rent_request_id <- decode.field(1, decode.int)
    use author_id <- decode.field(2, decode.int)
    use content <- decode.field(3, decode.string)
    use created_at <- decode.field(4, pog.timestamp_decoder())
    decode.success(GetMessagesForRequestRow(
      id:,
      rent_request_id:,
      author_id:,
      content:,
      created_at:,
    ))
  }

  "SELECT
  id,
  rent_request_id,
  author_id,
  content,
  created_at as created_at
FROM messages
WHERE rent_request_id = $1
ORDER BY created_at ASC
"
  |> pog.query
  |> pog.parameter(pog.int(rent_request_id))
  |> pog.returning(decoder)
  |> pog.execute(db)
}

/// A row you get from running the `get_offer_by_id` query
/// defined in `./src/server/sql/get_offer_by_id.sql`.
///
/// > 🐿️ This type definition was generated automatically using v4.7.0 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type GetOfferByIdRow {
  GetOfferByIdRow(
    id: Int,
    rent_request_id: Int,
    sender_id: Int,
    start_date: Timestamp,
    end_date: Timestamp,
    accepted_at: Option(Timestamp),
    created_at: Timestamp,
    updated_at: Timestamp,
  )
}

/// Runs the `get_offer_by_id` query
/// defined in `./src/server/sql/get_offer_by_id.sql`.
///
/// > 🐿️ This function was generated automatically using v4.7.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn get_offer_by_id(
  db: pog.Connection,
  id: Int,
) -> Result(pog.Returned(GetOfferByIdRow), pog.QueryError) {
  let decoder = {
    use id <- decode.field(0, decode.int)
    use rent_request_id <- decode.field(1, decode.int)
    use sender_id <- decode.field(2, decode.int)
    use start_date <- decode.field(3, pog.timestamp_decoder())
    use end_date <- decode.field(4, pog.timestamp_decoder())
    use accepted_at <- decode.field(5, decode.optional(pog.timestamp_decoder()))
    use created_at <- decode.field(6, pog.timestamp_decoder())
    use updated_at <- decode.field(7, pog.timestamp_decoder())
    decode.success(GetOfferByIdRow(
      id:,
      rent_request_id:,
      sender_id:,
      start_date:,
      end_date:,
      accepted_at:,
      created_at:,
      updated_at:,
    ))
  }

  "SELECT
  id,
  rent_request_id,
  sender_id,
  start_date as start_date,
  end_date as end_date,
  accepted_at as accepted_at,
  created_at as created_at,
  updated_at as updated_at
FROM rent_offers
WHERE id = $1
"
  |> pog.query
  |> pog.parameter(pog.int(id))
  |> pog.returning(decoder)
  |> pog.execute(db)
}

/// A row you get from running the `get_offers_after_timestamp` query
/// defined in `./src/server/sql/get_offers_after_timestamp.sql`.
///
/// > 🐿️ This type definition was generated automatically using v4.7.0 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type GetOffersAfterTimestampRow {
  GetOffersAfterTimestampRow(
    id: Int,
    rent_request_id: Int,
    sender_id: Int,
    start_date: Timestamp,
    end_date: Timestamp,
    accepted_at: Option(Timestamp),
    created_at: Timestamp,
    updated_at: Timestamp,
  )
}

/// Runs the `get_offers_after_timestamp` query
/// defined in `./src/server/sql/get_offers_after_timestamp.sql`.
///
/// > 🐿️ This function was generated automatically using v4.7.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn get_offers_after_timestamp(
  db: pog.Connection,
  rent_request_id: Int,
  arg_2: Timestamp,
) -> Result(pog.Returned(GetOffersAfterTimestampRow), pog.QueryError) {
  let decoder = {
    use id <- decode.field(0, decode.int)
    use rent_request_id <- decode.field(1, decode.int)
    use sender_id <- decode.field(2, decode.int)
    use start_date <- decode.field(3, pog.timestamp_decoder())
    use end_date <- decode.field(4, pog.timestamp_decoder())
    use accepted_at <- decode.field(5, decode.optional(pog.timestamp_decoder()))
    use created_at <- decode.field(6, pog.timestamp_decoder())
    use updated_at <- decode.field(7, pog.timestamp_decoder())
    decode.success(GetOffersAfterTimestampRow(
      id:,
      rent_request_id:,
      sender_id:,
      start_date:,
      end_date:,
      accepted_at:,
      created_at:,
      updated_at:,
    ))
  }

  "SELECT
  id,
  rent_request_id,
  sender_id,
  start_date as start_date,
  end_date as end_date,
  accepted_at as accepted_at,
  created_at as created_at,
  updated_at as updated_at
FROM rent_offers
WHERE rent_request_id = $1
  AND created_at > $2
ORDER BY created_at ASC
"
  |> pog.query
  |> pog.parameter(pog.int(rent_request_id))
  |> pog.parameter(pog.timestamp(arg_2))
  |> pog.returning(decoder)
  |> pog.execute(db)
}

/// A row you get from running the `get_offers_for_request` query
/// defined in `./src/server/sql/get_offers_for_request.sql`.
///
/// > 🐿️ This type definition was generated automatically using v4.7.0 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type GetOffersForRequestRow {
  GetOffersForRequestRow(
    id: Int,
    rent_request_id: Int,
    sender_id: Int,
    start_date: Timestamp,
    end_date: Timestamp,
    accepted_at: Option(Timestamp),
    created_at: Timestamp,
    updated_at: Timestamp,
  )
}

/// Runs the `get_offers_for_request` query
/// defined in `./src/server/sql/get_offers_for_request.sql`.
///
/// > 🐿️ This function was generated automatically using v4.7.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn get_offers_for_request(
  db: pog.Connection,
  rent_request_id: Int,
) -> Result(pog.Returned(GetOffersForRequestRow), pog.QueryError) {
  let decoder = {
    use id <- decode.field(0, decode.int)
    use rent_request_id <- decode.field(1, decode.int)
    use sender_id <- decode.field(2, decode.int)
    use start_date <- decode.field(3, pog.timestamp_decoder())
    use end_date <- decode.field(4, pog.timestamp_decoder())
    use accepted_at <- decode.field(5, decode.optional(pog.timestamp_decoder()))
    use created_at <- decode.field(6, pog.timestamp_decoder())
    use updated_at <- decode.field(7, pog.timestamp_decoder())
    decode.success(GetOffersForRequestRow(
      id:,
      rent_request_id:,
      sender_id:,
      start_date:,
      end_date:,
      accepted_at:,
      created_at:,
      updated_at:,
    ))
  }

  "SELECT
  id,
  rent_request_id,
  sender_id,
  start_date as start_date,
  end_date as end_date,
  accepted_at as accepted_at,
  created_at as created_at,
  updated_at as updated_at
FROM rent_offers
WHERE rent_request_id = $1
ORDER BY created_at ASC
"
  |> pog.query
  |> pog.parameter(pog.int(rent_request_id))
  |> pog.returning(decoder)
  |> pog.execute(db)
}

/// A row you get from running the `get_open_rent_request_for_item_and_user` query
/// defined in `./src/server/sql/get_open_rent_request_for_item_and_user.sql`.
///
/// > 🐿️ This type definition was generated automatically using v4.7.0 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type GetOpenRentRequestForItemAndUserRow {
  GetOpenRentRequestForItemAndUserRow(
    id: Int,
    item_id: Int,
    requester_id: Int,
    latest_accepted_offer_id: Option(Int),
    latest_open_offer_id: Option(Int),
    borrow_confirmed_at: Option(Timestamp),
    returned_at: Option(Timestamp),
    created_at: Timestamp,
    updated_at: Timestamp,
    requester_read_at: Option(Timestamp),
    owner_read_at: Option(Timestamp),
    item_title: String,
    requester_name: String,
    owner_name: String,
    owner_id: Int,
  )
}

/// Runs the `get_open_rent_request_for_item_and_user` query
/// defined in `./src/server/sql/get_open_rent_request_for_item_and_user.sql`.
///
/// > 🐿️ This function was generated automatically using v4.7.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn get_open_rent_request_for_item_and_user(
  db: pog.Connection,
  rr_item_id: Int,
  rr_requester_id: Int,
) -> Result(pog.Returned(GetOpenRentRequestForItemAndUserRow), pog.QueryError) {
  let decoder = {
    use id <- decode.field(0, decode.int)
    use item_id <- decode.field(1, decode.int)
    use requester_id <- decode.field(2, decode.int)
    use latest_accepted_offer_id <- decode.field(3, decode.optional(decode.int))
    use latest_open_offer_id <- decode.field(4, decode.optional(decode.int))
    use borrow_confirmed_at <- decode.field(
      5,
      decode.optional(pog.timestamp_decoder()),
    )
    use returned_at <- decode.field(6, decode.optional(pog.timestamp_decoder()))
    use created_at <- decode.field(7, pog.timestamp_decoder())
    use updated_at <- decode.field(8, pog.timestamp_decoder())
    use requester_read_at <- decode.field(
      9,
      decode.optional(pog.timestamp_decoder()),
    )
    use owner_read_at <- decode.field(
      10,
      decode.optional(pog.timestamp_decoder()),
    )
    use item_title <- decode.field(11, decode.string)
    use requester_name <- decode.field(12, decode.string)
    use owner_name <- decode.field(13, decode.string)
    use owner_id <- decode.field(14, decode.int)
    decode.success(GetOpenRentRequestForItemAndUserRow(
      id:,
      item_id:,
      requester_id:,
      latest_accepted_offer_id:,
      latest_open_offer_id:,
      borrow_confirmed_at:,
      returned_at:,
      created_at:,
      updated_at:,
      requester_read_at:,
      owner_read_at:,
      item_title:,
      requester_name:,
      owner_name:,
      owner_id:,
    ))
  }

  "SELECT
  rr.id,
  rr.item_id,
  rr.requester_id,
  rr.latest_accepted_offer_id,
  rr.latest_open_offer_id,
  rr.borrow_confirmed_at as borrow_confirmed_at,
  rr.returned_at as returned_at,
  rr.created_at as created_at,
  rr.updated_at as updated_at,
  rr.requester_read_at as requester_read_at,
  rr.owner_read_at as owner_read_at,
  items.title as item_title,
  requester.name as requester_name,
  owner.name as owner_name,
  owner.id as owner_id
FROM rent_requests rr
JOIN items ON items.id = rr.item_id
JOIN profiles requester ON requester.id = rr.requester_id
JOIN profiles owner ON owner.id = items.author_id
WHERE rr.item_id = $1 AND rr.requester_id = $2 AND rr.returned_at IS NULL
ORDER BY rr.created_at DESC
LIMIT 1
"
  |> pog.query
  |> pog.parameter(pog.int(rr_item_id))
  |> pog.parameter(pog.int(rr_requester_id))
  |> pog.returning(decoder)
  |> pog.execute(db)
}

/// A row you get from running the `get_profile` query
/// defined in `./src/server/sql/get_profile.sql`.
///
/// > 🐿️ This type definition was generated automatically using v4.7.0 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type GetProfileRow {
  GetProfileRow(
    id: Int,
    name: String,
    bio: Option(String),
    rating: Option(Float),
  )
}

/// Runs the `get_profile` query
/// defined in `./src/server/sql/get_profile.sql`.
///
/// > 🐿️ This function was generated automatically using v4.7.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn get_profile(
  db: pog.Connection,
  id: Int,
) -> Result(pog.Returned(GetProfileRow), pog.QueryError) {
  let decoder = {
    use id <- decode.field(0, decode.int)
    use name <- decode.field(1, decode.string)
    use bio <- decode.field(2, decode.optional(decode.string))
    use rating <- decode.field(3, decode.optional(pog.numeric_decoder()))
    decode.success(GetProfileRow(id:, name:, bio:, rating:))
  }

  "SELECT id, name, bio, rating
FROM profiles
WHERE id = $1
"
  |> pog.query
  |> pog.parameter(pog.int(id))
  |> pog.returning(decoder)
  |> pog.execute(db)
}

/// A row you get from running the `get_read_at` query
/// defined in `./src/server/sql/get_read_at.sql`.
///
/// > 🐿️ This type definition was generated automatically using v4.7.0 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type GetReadAtRow {
  GetReadAtRow(read_at: String)
}

/// Runs the `get_read_at` query
/// defined in `./src/server/sql/get_read_at.sql`.
///
/// > 🐿️ This function was generated automatically using v4.7.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn get_read_at(
  db: pog.Connection,
  id: Int,
  requester_id: Int,
) -> Result(pog.Returned(GetReadAtRow), pog.QueryError) {
  let decoder = {
    use read_at <- decode.field(0, decode.string)
    decode.success(GetReadAtRow(read_at:))
  }

  "SELECT
  CASE WHEN $2 = requester_id THEN requester_read_at::text ELSE owner_read_at::text END AS read_at
FROM rent_requests
WHERE id = $1 AND (
  $2 = requester_id OR $2 = (SELECT author_id FROM items WHERE id = rent_requests.item_id)
)
"
  |> pog.query
  |> pog.parameter(pog.int(id))
  |> pog.parameter(pog.int(requester_id))
  |> pog.returning(decoder)
  |> pog.execute(db)
}

/// A row you get from running the `get_rent_request_by_id` query
/// defined in `./src/server/sql/get_rent_request_by_id.sql`.
///
/// > 🐿️ This type definition was generated automatically using v4.7.0 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type GetRentRequestByIdRow {
  GetRentRequestByIdRow(
    id: Int,
    item_id: Int,
    requester_id: Int,
    latest_accepted_offer_id: Option(Int),
    latest_open_offer_id: Option(Int),
    borrow_confirmed_at: Option(Timestamp),
    returned_at: Option(Timestamp),
    created_at: Timestamp,
    updated_at: Timestamp,
    requester_read_at: Option(Timestamp),
    owner_read_at: Option(Timestamp),
    item_title: String,
    requester_name: String,
    owner_name: String,
    owner_id: Int,
  )
}

/// Runs the `get_rent_request_by_id` query
/// defined in `./src/server/sql/get_rent_request_by_id.sql`.
///
/// > 🐿️ This function was generated automatically using v4.7.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn get_rent_request_by_id(
  db: pog.Connection,
  rr_id: Int,
) -> Result(pog.Returned(GetRentRequestByIdRow), pog.QueryError) {
  let decoder = {
    use id <- decode.field(0, decode.int)
    use item_id <- decode.field(1, decode.int)
    use requester_id <- decode.field(2, decode.int)
    use latest_accepted_offer_id <- decode.field(3, decode.optional(decode.int))
    use latest_open_offer_id <- decode.field(4, decode.optional(decode.int))
    use borrow_confirmed_at <- decode.field(
      5,
      decode.optional(pog.timestamp_decoder()),
    )
    use returned_at <- decode.field(6, decode.optional(pog.timestamp_decoder()))
    use created_at <- decode.field(7, pog.timestamp_decoder())
    use updated_at <- decode.field(8, pog.timestamp_decoder())
    use requester_read_at <- decode.field(
      9,
      decode.optional(pog.timestamp_decoder()),
    )
    use owner_read_at <- decode.field(
      10,
      decode.optional(pog.timestamp_decoder()),
    )
    use item_title <- decode.field(11, decode.string)
    use requester_name <- decode.field(12, decode.string)
    use owner_name <- decode.field(13, decode.string)
    use owner_id <- decode.field(14, decode.int)
    decode.success(GetRentRequestByIdRow(
      id:,
      item_id:,
      requester_id:,
      latest_accepted_offer_id:,
      latest_open_offer_id:,
      borrow_confirmed_at:,
      returned_at:,
      created_at:,
      updated_at:,
      requester_read_at:,
      owner_read_at:,
      item_title:,
      requester_name:,
      owner_name:,
      owner_id:,
    ))
  }

  "SELECT
  rr.id,
  rr.item_id,
  rr.requester_id,
  rr.latest_accepted_offer_id,
  rr.latest_open_offer_id,
  rr.borrow_confirmed_at as borrow_confirmed_at,
  rr.returned_at as returned_at,
  rr.created_at as created_at,
  rr.updated_at as updated_at,
  rr.requester_read_at as requester_read_at,
  rr.owner_read_at as owner_read_at,
  items.title as item_title,
  requester.name as requester_name,
  owner.name as owner_name,
  owner.id as owner_id
FROM rent_requests rr
JOIN items ON items.id = rr.item_id
JOIN profiles requester ON requester.id = rr.requester_id
JOIN profiles owner ON owner.id = items.author_id
WHERE rr.id = $1
"
  |> pog.query
  |> pog.parameter(pog.int(rr_id))
  |> pog.returning(decoder)
  |> pog.execute(db)
}

/// A row you get from running the `get_rent_requests_for_user` query
/// defined in `./src/server/sql/get_rent_requests_for_user.sql`.
///
/// > 🐿️ This type definition was generated automatically using v4.7.0 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type GetRentRequestsForUserRow {
  GetRentRequestsForUserRow(
    id: Int,
    item_id: Int,
    requester_id: Int,
    latest_accepted_offer_id: Option(Int),
    latest_open_offer_id: Option(Int),
    borrow_confirmed_at: Option(Timestamp),
    returned_at: Option(Timestamp),
    requester_read_at: Option(Timestamp),
    owner_read_at: Option(Timestamp),
    created_at: Timestamp,
    updated_at: Timestamp,
    item_title: String,
    requester_name: String,
    owner_name: String,
    owner_id: Int,
  )
}

/// Runs the `get_rent_requests_for_user` query
/// defined in `./src/server/sql/get_rent_requests_for_user.sql`.
///
/// > 🐿️ This function was generated automatically using v4.7.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn get_rent_requests_for_user(
  db: pog.Connection,
  rr_requester_id: Int,
) -> Result(pog.Returned(GetRentRequestsForUserRow), pog.QueryError) {
  let decoder = {
    use id <- decode.field(0, decode.int)
    use item_id <- decode.field(1, decode.int)
    use requester_id <- decode.field(2, decode.int)
    use latest_accepted_offer_id <- decode.field(3, decode.optional(decode.int))
    use latest_open_offer_id <- decode.field(4, decode.optional(decode.int))
    use borrow_confirmed_at <- decode.field(
      5,
      decode.optional(pog.timestamp_decoder()),
    )
    use returned_at <- decode.field(6, decode.optional(pog.timestamp_decoder()))
    use requester_read_at <- decode.field(
      7,
      decode.optional(pog.timestamp_decoder()),
    )
    use owner_read_at <- decode.field(
      8,
      decode.optional(pog.timestamp_decoder()),
    )
    use created_at <- decode.field(9, pog.timestamp_decoder())
    use updated_at <- decode.field(10, pog.timestamp_decoder())
    use item_title <- decode.field(11, decode.string)
    use requester_name <- decode.field(12, decode.string)
    use owner_name <- decode.field(13, decode.string)
    use owner_id <- decode.field(14, decode.int)
    decode.success(GetRentRequestsForUserRow(
      id:,
      item_id:,
      requester_id:,
      latest_accepted_offer_id:,
      latest_open_offer_id:,
      borrow_confirmed_at:,
      returned_at:,
      requester_read_at:,
      owner_read_at:,
      created_at:,
      updated_at:,
      item_title:,
      requester_name:,
      owner_name:,
      owner_id:,
    ))
  }

  "SELECT
  rr.id,
  rr.item_id,
  rr.requester_id,
  rr.latest_accepted_offer_id,
  rr.latest_open_offer_id,
  rr.borrow_confirmed_at as borrow_confirmed_at,
  rr.returned_at as returned_at,
  rr.requester_read_at as requester_read_at,
  rr.owner_read_at as owner_read_at,
  rr.created_at as created_at,
  rr.updated_at as updated_at,
  items.title as item_title,
  requester.name as requester_name,
  owner.name as owner_name,
  owner.id as owner_id
FROM rent_requests rr
JOIN items ON items.id = rr.item_id
JOIN profiles requester ON requester.id = rr.requester_id
JOIN profiles owner ON owner.id = items.author_id
WHERE rr.requester_id = $1 OR items.author_id = $1
ORDER BY rr.updated_at DESC
"
  |> pog.query
  |> pog.parameter(pog.int(rr_requester_id))
  |> pog.returning(decoder)
  |> pog.execute(db)
}

/// A row you get from running the `get_session_by_refresh_token` query
/// defined in `./src/server/sql/get_session_by_refresh_token.sql`.
///
/// > 🐿️ This type definition was generated automatically using v4.7.0 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type GetSessionByRefreshTokenRow {
  GetSessionByRefreshTokenRow(
    id: Int,
    token_hash: String,
    user_id: Int,
    expires_at: Timestamp,
    created_at: Timestamp,
    refresh_token_hash: String,
    refresh_expires_at: Timestamp,
    email: String,
    last_online_at: Timestamp,
  )
}

/// Runs the `get_session_by_refresh_token` query
/// defined in `./src/server/sql/get_session_by_refresh_token.sql`.
///
/// > 🐿️ This function was generated automatically using v4.7.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn get_session_by_refresh_token(
  db: pog.Connection,
  s_refresh_token_hash: String,
) -> Result(pog.Returned(GetSessionByRefreshTokenRow), pog.QueryError) {
  let decoder = {
    use id <- decode.field(0, decode.int)
    use token_hash <- decode.field(1, decode.string)
    use user_id <- decode.field(2, decode.int)
    use expires_at <- decode.field(3, pog.timestamp_decoder())
    use created_at <- decode.field(4, pog.timestamp_decoder())
    use refresh_token_hash <- decode.field(5, decode.string)
    use refresh_expires_at <- decode.field(6, pog.timestamp_decoder())
    use email <- decode.field(7, decode.string)
    use last_online_at <- decode.field(8, pog.timestamp_decoder())
    decode.success(GetSessionByRefreshTokenRow(
      id:,
      token_hash:,
      user_id:,
      expires_at:,
      created_at:,
      refresh_token_hash:,
      refresh_expires_at:,
      email:,
      last_online_at:,
    ))
  }

  "select
  s.id, s.token_hash, s.user_id, s.expires_at, s.created_at,
  s.refresh_token_hash, s.refresh_expires_at,
  u.email, u.last_online_at
from sessions s
join users u on s.user_id = u.id
where s.refresh_token_hash = $1
"
  |> pog.query
  |> pog.parameter(pog.text(s_refresh_token_hash))
  |> pog.returning(decoder)
  |> pog.execute(db)
}

/// A row you get from running the `get_session_by_token` query
/// defined in `./src/server/sql/get_session_by_token.sql`.
///
/// > 🐿️ This type definition was generated automatically using v4.7.0 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type GetSessionByTokenRow {
  GetSessionByTokenRow(
    id: Int,
    token_hash: String,
    user_id: Int,
    expires_at: Timestamp,
    created_at: Timestamp,
    refresh_token_hash: String,
    refresh_expires_at: Timestamp,
    email: String,
    last_online_at: Timestamp,
  )
}

/// Runs the `get_session_by_token` query
/// defined in `./src/server/sql/get_session_by_token.sql`.
///
/// > 🐿️ This function was generated automatically using v4.7.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn get_session_by_token(
  db: pog.Connection,
  s_token_hash: String,
) -> Result(pog.Returned(GetSessionByTokenRow), pog.QueryError) {
  let decoder = {
    use id <- decode.field(0, decode.int)
    use token_hash <- decode.field(1, decode.string)
    use user_id <- decode.field(2, decode.int)
    use expires_at <- decode.field(3, pog.timestamp_decoder())
    use created_at <- decode.field(4, pog.timestamp_decoder())
    use refresh_token_hash <- decode.field(5, decode.string)
    use refresh_expires_at <- decode.field(6, pog.timestamp_decoder())
    use email <- decode.field(7, decode.string)
    use last_online_at <- decode.field(8, pog.timestamp_decoder())
    decode.success(GetSessionByTokenRow(
      id:,
      token_hash:,
      user_id:,
      expires_at:,
      created_at:,
      refresh_token_hash:,
      refresh_expires_at:,
      email:,
      last_online_at:,
    ))
  }

  "select
  s.id, s.token_hash, s.user_id, s.expires_at, s.created_at,
  s.refresh_token_hash, s.refresh_expires_at,
  u.email, u.last_online_at
from sessions s
join users u on s.user_id = u.id
where s.token_hash = $1
"
  |> pog.query
  |> pog.parameter(pog.text(s_token_hash))
  |> pog.returning(decoder)
  |> pog.execute(db)
}

/// A row you get from running the `get_user_by_email` query
/// defined in `./src/server/sql/get_user_by_email.sql`.
///
/// > 🐿️ This type definition was generated automatically using v4.7.0 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type GetUserByEmailRow {
  GetUserByEmailRow(
    id: Int,
    email: String,
    password_hash: String,
    last_online_at: Timestamp,
    created_at: Timestamp,
  )
}

/// Runs the `get_user_by_email` query
/// defined in `./src/server/sql/get_user_by_email.sql`.
///
/// > 🐿️ This function was generated automatically using v4.7.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn get_user_by_email(
  db: pog.Connection,
  email: String,
) -> Result(pog.Returned(GetUserByEmailRow), pog.QueryError) {
  let decoder = {
    use id <- decode.field(0, decode.int)
    use email <- decode.field(1, decode.string)
    use password_hash <- decode.field(2, decode.string)
    use last_online_at <- decode.field(3, pog.timestamp_decoder())
    use created_at <- decode.field(4, pog.timestamp_decoder())
    decode.success(GetUserByEmailRow(
      id:,
      email:,
      password_hash:,
      last_online_at:,
      created_at:,
    ))
  }

  "select id, email, password_hash, last_online_at, created_at
from users
where email = $1
"
  |> pog.query
  |> pog.parameter(pog.text(email))
  |> pog.returning(decoder)
  |> pog.execute(db)
}

/// A row you get from running the `get_user_by_id` query
/// defined in `./src/server/sql/get_user_by_id.sql`.
///
/// > 🐿️ This type definition was generated automatically using v4.7.0 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type GetUserByIdRow {
  GetUserByIdRow(
    id: Int,
    email: String,
    password_hash: String,
    last_online_at: Timestamp,
    created_at: Timestamp,
  )
}

/// Runs the `get_user_by_id` query
/// defined in `./src/server/sql/get_user_by_id.sql`.
///
/// > 🐿️ This function was generated automatically using v4.7.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn get_user_by_id(
  db: pog.Connection,
  id: Int,
) -> Result(pog.Returned(GetUserByIdRow), pog.QueryError) {
  let decoder = {
    use id <- decode.field(0, decode.int)
    use email <- decode.field(1, decode.string)
    use password_hash <- decode.field(2, decode.string)
    use last_online_at <- decode.field(3, pog.timestamp_decoder())
    use created_at <- decode.field(4, pog.timestamp_decoder())
    decode.success(GetUserByIdRow(
      id:,
      email:,
      password_hash:,
      last_online_at:,
      created_at:,
    ))
  }

  "select id, email, password_hash, last_online_at, created_at
from users
where id = $1
"
  |> pog.query
  |> pog.parameter(pog.int(id))
  |> pog.returning(decoder)
  |> pog.execute(db)
}

/// A row you get from running the `insert_item_image` query
/// defined in `./src/server/sql/insert_item_image.sql`.
///
/// > 🐿️ This type definition was generated automatically using v4.7.0 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type InsertItemImageRow {
  InsertItemImageRow(id: Uuid)
}

/// Runs the `insert_item_image` query
/// defined in `./src/server/sql/insert_item_image.sql`.
///
/// > 🐿️ This function was generated automatically using v4.7.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn insert_item_image(
  db: pog.Connection,
  arg_1: Uuid,
  arg_2: Int,
  arg_3: String,
  arg_4: String,
  arg_5: Int,
) -> Result(pog.Returned(InsertItemImageRow), pog.QueryError) {
  let decoder = {
    use id <- decode.field(0, uuid_decoder())
    decode.success(InsertItemImageRow(id:))
  }

  "INSERT INTO item_images (id, item_id, original_name, mime_type, sort_order)
VALUES ($1, $2, $3, $4, $5)
returning id"
  |> pog.query
  |> pog.parameter(pog.text(uuid.to_string(arg_1)))
  |> pog.parameter(pog.int(arg_2))
  |> pog.parameter(pog.text(arg_3))
  |> pog.parameter(pog.text(arg_4))
  |> pog.parameter(pog.int(arg_5))
  |> pog.returning(decoder)
  |> pog.execute(db)
}

/// A row you get from running the `list_sessions` query
/// defined in `./src/server/sql/list_sessions.sql`.
///
/// > 🐿️ This type definition was generated automatically using v4.7.0 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type ListSessionsRow {
  ListSessionsRow(
    id: Int,
    token_hash: String,
    user_id: Int,
    expires_at: Timestamp,
    created_at: Timestamp,
    refresh_token_hash: String,
    refresh_expires_at: Timestamp,
    email: String,
  )
}

/// Runs the `list_sessions` query
/// defined in `./src/server/sql/list_sessions.sql`.
///
/// > 🐿️ This function was generated automatically using v4.7.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn list_sessions(
  db: pog.Connection,
) -> Result(pog.Returned(ListSessionsRow), pog.QueryError) {
  let decoder = {
    use id <- decode.field(0, decode.int)
    use token_hash <- decode.field(1, decode.string)
    use user_id <- decode.field(2, decode.int)
    use expires_at <- decode.field(3, pog.timestamp_decoder())
    use created_at <- decode.field(4, pog.timestamp_decoder())
    use refresh_token_hash <- decode.field(5, decode.string)
    use refresh_expires_at <- decode.field(6, pog.timestamp_decoder())
    use email <- decode.field(7, decode.string)
    decode.success(ListSessionsRow(
      id:,
      token_hash:,
      user_id:,
      expires_at:,
      created_at:,
      refresh_token_hash:,
      refresh_expires_at:,
      email:,
    ))
  }

  "select s.id, s.token_hash, s.user_id, s.expires_at, s.created_at,
       s.refresh_token_hash, s.refresh_expires_at, u.email
from sessions s
join users u on s.user_id = u.id
order by s.created_at desc
"
  |> pog.query
  |> pog.returning(decoder)
  |> pog.execute(db)
}

/// A row you get from running the `list_users` query
/// defined in `./src/server/sql/list_users.sql`.
///
/// > 🐿️ This type definition was generated automatically using v4.7.0 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type ListUsersRow {
  ListUsersRow(
    id: Int,
    email: String,
    last_online_at: Timestamp,
    created_at: Timestamp,
  )
}

/// Runs the `list_users` query
/// defined in `./src/server/sql/list_users.sql`.
///
/// > 🐿️ This function was generated automatically using v4.7.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn list_users(
  db: pog.Connection,
) -> Result(pog.Returned(ListUsersRow), pog.QueryError) {
  let decoder = {
    use id <- decode.field(0, decode.int)
    use email <- decode.field(1, decode.string)
    use last_online_at <- decode.field(2, pog.timestamp_decoder())
    use created_at <- decode.field(3, pog.timestamp_decoder())
    decode.success(ListUsersRow(id:, email:, last_online_at:, created_at:))
  }

  "select id, email, last_online_at, created_at from users order by id
"
  |> pog.query
  |> pog.returning(decoder)
  |> pog.execute(db)
}

/// Runs the `mark_rent_request_read` query
/// defined in `./src/server/sql/mark_rent_request_read.sql`.
///
/// > 🐿️ This function was generated automatically using v4.7.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn mark_rent_request_read(
  db: pog.Connection,
  id: Int,
  requester_id: Int,
) -> Result(pog.Returned(Nil), pog.QueryError) {
  let decoder = decode.map(decode.dynamic, fn(_) { Nil })

  "UPDATE rent_requests
SET
  requester_read_at = CASE WHEN $2 = requester_id THEN NOW() ELSE requester_read_at END,
  owner_read_at = CASE WHEN $2 = (SELECT author_id FROM items WHERE id = rent_requests.item_id) THEN NOW() ELSE owner_read_at END
WHERE id = $1 AND (
  $2 = requester_id OR $2 = (SELECT author_id FROM items WHERE id = rent_requests.item_id)
)
"
  |> pog.query
  |> pog.parameter(pog.int(id))
  |> pog.parameter(pog.int(requester_id))
  |> pog.returning(decoder)
  |> pog.execute(db)
}

/// A row you get from running the `update_item` query
/// defined in `./src/server/sql/update_item.sql`.
///
/// > 🐿️ This type definition was generated automatically using v4.7.0 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type UpdateItemRow {
  UpdateItemRow(id: Int)
}

/// Runs the `update_item` query
/// defined in `./src/server/sql/update_item.sql`.
///
/// > 🐿️ This function was generated automatically using v4.7.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn update_item(
  db: pog.Connection,
  arg_1: String,
  arg_2: String,
  arg_3: String,
  arg_4: String,
  arg_5: Float,
  arg_6: Float,
  id: Int,
  author_id: Int,
) -> Result(pog.Returned(UpdateItemRow), pog.QueryError) {
  let decoder = {
    use id <- decode.field(0, decode.int)
    decode.success(UpdateItemRow(id:))
  }

  "UPDATE items SET title=$1, description=$2, city=$3, postal_code=$4, location=st_setsrid(st_makepoint($5, $6), 4326)::geography WHERE id=$7 AND author_id=$8
returning id
"
  |> pog.query
  |> pog.parameter(pog.text(arg_1))
  |> pog.parameter(pog.text(arg_2))
  |> pog.parameter(pog.text(arg_3))
  |> pog.parameter(pog.text(arg_4))
  |> pog.parameter(pog.float(arg_5))
  |> pog.parameter(pog.float(arg_6))
  |> pog.parameter(pog.int(id))
  |> pog.parameter(pog.int(author_id))
  |> pog.returning(decoder)
  |> pog.execute(db)
}

/// A row you get from running the `update_item_image_sort_order` query
/// defined in `./src/server/sql/update_item_image_sort_order.sql`.
///
/// > 🐿️ This type definition was generated automatically using v4.7.0 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type UpdateItemImageSortOrderRow {
  UpdateItemImageSortOrderRow(id: Uuid)
}

/// Runs the `update_item_image_sort_order` query
/// defined in `./src/server/sql/update_item_image_sort_order.sql`.
///
/// > 🐿️ This function was generated automatically using v4.7.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn update_item_image_sort_order(
  db: pog.Connection,
  id: Uuid,
  item_id: Int,
  sort_order: Int,
) -> Result(pog.Returned(UpdateItemImageSortOrderRow), pog.QueryError) {
  let decoder = {
    use id <- decode.field(0, uuid_decoder())
    decode.success(UpdateItemImageSortOrderRow(id:))
  }

  "UPDATE item_images SET sort_order=$3 WHERE id=$1 AND item_id=$2
returning id
"
  |> pog.query
  |> pog.parameter(pog.text(uuid.to_string(id)))
  |> pog.parameter(pog.int(item_id))
  |> pog.parameter(pog.int(sort_order))
  |> pog.returning(decoder)
  |> pog.execute(db)
}

/// Runs the `update_last_online` query
/// defined in `./src/server/sql/update_last_online.sql`.
///
/// > 🐿️ This function was generated automatically using v4.7.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn update_last_online(
  db: pog.Connection,
  id: Int,
) -> Result(pog.Returned(Nil), pog.QueryError) {
  let decoder = decode.map(decode.dynamic, fn(_) { Nil })

  "update users set last_online_at = now() where id = $1
"
  |> pog.query
  |> pog.parameter(pog.int(id))
  |> pog.returning(decoder)
  |> pog.execute(db)
}

/// Runs the `update_rent_request_borrow` query
/// defined in `./src/server/sql/update_rent_request_borrow.sql`.
///
/// > 🐿️ This function was generated automatically using v4.7.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn update_rent_request_borrow(
  db: pog.Connection,
  id: Int,
) -> Result(pog.Returned(Nil), pog.QueryError) {
  let decoder = decode.map(decode.dynamic, fn(_) { Nil })

  "UPDATE rent_requests SET borrow_confirmed_at = now(), updated_at = now() WHERE id = $1 AND borrow_confirmed_at IS NULL
"
  |> pog.query
  |> pog.parameter(pog.int(id))
  |> pog.returning(decoder)
  |> pog.execute(db)
}

/// Runs the `update_rent_request_latest_accepted` query
/// defined in `./src/server/sql/update_rent_request_latest_accepted.sql`.
///
/// > 🐿️ This function was generated automatically using v4.7.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn update_rent_request_latest_accepted(
  db: pog.Connection,
  arg_1: Int,
  id: Int,
) -> Result(pog.Returned(Nil), pog.QueryError) {
  let decoder = decode.map(decode.dynamic, fn(_) { Nil })

  "UPDATE rent_requests SET latest_accepted_offer_id = $1, latest_open_offer_id = NULL, updated_at = now() WHERE id = $2
"
  |> pog.query
  |> pog.parameter(pog.int(arg_1))
  |> pog.parameter(pog.int(id))
  |> pog.returning(decoder)
  |> pog.execute(db)
}

/// Runs the `update_rent_request_latest_open` query
/// defined in `./src/server/sql/update_rent_request_latest_open.sql`.
///
/// > 🐿️ This function was generated automatically using v4.7.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn update_rent_request_latest_open(
  db: pog.Connection,
  arg_1: Int,
  id: Int,
) -> Result(pog.Returned(Nil), pog.QueryError) {
  let decoder = decode.map(decode.dynamic, fn(_) { Nil })

  "UPDATE rent_requests SET latest_open_offer_id = $1, updated_at = now() WHERE id = $2
"
  |> pog.query
  |> pog.parameter(pog.int(arg_1))
  |> pog.parameter(pog.int(id))
  |> pog.returning(decoder)
  |> pog.execute(db)
}

/// Runs the `update_rent_request_returned` query
/// defined in `./src/server/sql/update_rent_request_returned.sql`.
///
/// > 🐿️ This function was generated automatically using v4.7.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn update_rent_request_returned(
  db: pog.Connection,
  id: Int,
) -> Result(pog.Returned(Nil), pog.QueryError) {
  let decoder = decode.map(decode.dynamic, fn(_) { Nil })

  "UPDATE rent_requests SET returned_at = now(), updated_at = now() WHERE id = $1 AND returned_at IS NULL
"
  |> pog.query
  |> pog.parameter(pog.int(id))
  |> pog.returning(decoder)
  |> pog.execute(db)
}

/// Runs the `update_session_tokens` query
/// defined in `./src/server/sql/update_session_tokens.sql`.
///
/// > 🐿️ This function was generated automatically using v4.7.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn update_session_tokens(
  db: pog.Connection,
  arg_1: String,
  arg_2: Timestamp,
  arg_3: String,
  refresh_expires_at: Timestamp,
  id: Int,
) -> Result(pog.Returned(Nil), pog.QueryError) {
  let decoder = decode.map(decode.dynamic, fn(_) { Nil })

  "update sessions
set token_hash = $1, expires_at = $2, refresh_token_hash = $3, refresh_expires_at = $4
where id = $5
"
  |> pog.query
  |> pog.parameter(pog.text(arg_1))
  |> pog.parameter(pog.timestamp(arg_2))
  |> pog.parameter(pog.text(arg_3))
  |> pog.parameter(pog.timestamp(refresh_expires_at))
  |> pog.parameter(pog.int(id))
  |> pog.returning(decoder)
  |> pog.execute(db)
}

// --- Encoding/decoding utils -------------------------------------------------

/// A decoder to decode `Uuid`s coming from a Postgres query.
///
fn uuid_decoder() {
  use bit_array <- decode.then(decode.bit_array)
  case uuid.from_bit_array(bit_array) {
    Ok(uuid) -> decode.success(uuid)
    Error(_) -> decode.failure(uuid.v7(), "Uuid")
  }
}
