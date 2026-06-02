import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import pog
import server/auth
import server/db
import server/migration
import server/error
import server/sql
import simplifile
import youid/uuid

pub fn main() {
  case run() {
    Ok(_) -> io.println("Seed completed successfully")
    Error(msg) -> io.println("Seed failed: " <> msg)
  }
}

fn run() -> Result(Nil, String) {
  use conn <- result.try(db.start_pool())

  use _ <- result.try(
    migration.run_all()
    |> result.map_error(error.message),
  )

  use _ <- result.try(clear_all(conn))

  use dev_user <- result.try(create_user_with_profile(conn, "dev@example.com", "dev", "Ich", "Dev user", 4.9))
  use carl <- result.try(create_user_with_profile(conn, "carl@example.com", "carl", "Carl", "Car seller", 4.3))
  use timon <- result.try(create_user_with_profile(conn, "timon@example.com", "timon", "Timon", "Spezi enthusiast", 5.0))

  use inserat1_id <- result.try(insert_item(conn, "Inserat 1", "Ganz tolles Inserat", dev_user.id, 4.9, 13.4050, 52.5200, "Berlin", "10115"))
  use internat_id <- result.try(insert_item(conn, "Internat", "Ganz tolles Internat", dev_user.id, 4.9, 11.5820, 48.1351, "München", "80331"))
  use inserat2_id <- result.try(insert_item(conn, "Inserat 2", "Papput", dev_user.id, 4.9, 9.9937, 53.5511, "Hamburg", "20095"))
  use auto_id <- result.try(insert_item(conn, "Auto", "Kann fahren", carl.id, 4.3, 6.9603, 50.9375, "Köln", "50667"))
  use spezi_id <- result.try(insert_item(conn, "Spezi", "Bitte voll zurueck", timon.id, 5.0, 8.6821, 50.1109, "Frankfurt am Main", "60311"))

  io.println("Seeding images...")

  use _ <- result.try(seed_image(conn, spezi_id, 0, "seeding/images/paulaner-spezi.jpg"))
  use _ <- result.try(seed_image(conn, spezi_id, 1, "seeding/images/wallhaven_4576l3.jpg"))
  use _ <- result.try(seed_image(conn, spezi_id, 2, "seeding/images/logo_v1.jpeg"))
  use _ <- result.try(seed_image(conn, spezi_id, 3, "seeding/images/wallhaven_weq5jq.jpg"))

  use _ <- result.try(seed_image(conn, auto_id, 0, "seeding/images/auto.jpg"))
  use _ <- result.try(seed_image(conn, auto_id, 1, "seeding/images/IMG_0642.png"))
  use _ <- result.try(seed_image(conn, auto_id, 2, "seeding/images/wallhaven_477mrv.jpg"))
  use _ <- result.try(seed_image(conn, auto_id, 3, "seeding/images/wallhaven_nkmxk6.jpg"))

  use _ <- result.try(seed_image(conn, inserat1_id, 0, "seeding/images/wallhaven_4gqvxd.jpg"))
  use _ <- result.try(seed_image(conn, inserat1_id, 1, "seeding/images/logo_v1.jpeg"))

  use _ <- result.try(seed_image(conn, internat_id, 0, "seeding/images/wallhaven_e7651w.jpg"))

  use _ <- result.try(seed_image(conn, inserat2_id, 0, "seeding/images/wallhaven_mdgzx9.jpg"))

  Ok(Nil)
}

fn seed_image(conn, item_id: Int, sort_order: Int, source_path: String) -> Result(Nil, String) {
  let filename = extract_filename(source_path)

  use bytes <- result.try(
    simplifile.read_bits(source_path)
    |> result.map_error(fn(_) { "Failed to read: " <> source_path }),
  )

  let #(ext, mime) = detect_ext_and_mime(filename)

  let image_uuid = uuid.v4()
  let uuid_string = uuid.to_string(image_uuid)
  let dest_path = "uploads/" <> uuid_string <> "." <> ext

  use _ <- result.try(
    simplifile.write_bits(dest_path, bytes)
    |> result.map_error(fn(_) { "Failed to write: " <> dest_path }),
  )

  io.println("  Wrote " <> dest_path)

  use result <- result.try(
    sql.insert_item_image(conn, image_uuid, item_id, filename, mime, sort_order)
    |> result.map_error(fn(_) { "Failed to insert image DB record for " <> filename }),
  )

  use _ <- result.try(
    result.rows |> list.first |> result.map_error(fn(_) { "No row returned for " <> filename }),
  )

  io.println("  Seeded image " <> filename <> " for item " <> int.to_string(item_id) <> " at sort_order " <> int.to_string(sort_order))
  Ok(Nil)
}

fn extract_filename(path: String) -> String {
  let parts = string.split(path, "/")
  case list.last(parts) {
    Ok(name) -> name
    _ -> path
  }
}

fn detect_ext_and_mime(filename: String) -> #(String, String) {
  let parts = string.split(filename, ".")
  let ext = case list.last(parts) {
    Ok("jpg") -> "jpg"
    Ok("jpeg") -> "jpg"
    Ok("png") -> "png"
    Ok("gif") -> "gif"
    Ok("webp") -> "webp"
    _ -> "jpg"
  }
  let mime = case ext {
    "png" -> "image/png"
    "gif" -> "image/gif"
    "webp" -> "image/webp"
    _ -> "image/jpeg"
  }
  #(ext, mime)
}

fn create_user_with_profile(
  conn: pog.Connection,
  email: String,
  password: String,
  name: String,
  bio: String,
  rating: Float,
) -> Result(auth.User, String) {
  use user <- result.try(
    auth.create_user(conn, email, password)
    |> result.map_error(fn(e) { "Failed to create user: " <> auth_error_message(e) }),
  )

  use _ <- result.try(
    sql.create_profile(conn, user.id, name, bio, rating)
    |> result.map_error(fn(_) { "Failed to create profile" }),
  )

  Ok(user)
}

fn clear_all(conn: pog.Connection) -> Result(Nil, String) {
  use _ <- result.try(
    sql.delete_all_items(conn)
    |> result.map_error(fn(_) { "Failed to clear items" }),
  )
  use _ <- result.try(
    sql.delete_all_profiles(conn)
    |> result.map_error(fn(_) { "Failed to clear profiles" }),
  )
  use _ <- result.try(
    sql.delete_all_users(conn)
    |> result.map_error(fn(_) { "Failed to clear users" }),
  )
  Ok(Nil)
}

fn insert_item(
  conn: pog.Connection,
  title: String,
  description: String,
  author_id: Int,
  score: Float,
  lng: Float,
  lat: Float,
  city: String,
  postal_code: String,
) -> Result(Int, String) {
  use returned <- result.try(
    sql.create_item(conn, title, description, author_id, score, lng, lat, city, postal_code)
    |> result.map_error(fn(_) { "Failed to insert item" }),
  )

  use row <- result.try(
    returned.rows |> list.first |> result.map_error(fn(_) { "No item id returned" }),
  )

  Ok(row.id)
}

fn auth_error_message(e: auth.AuthError) -> String {
  case e {
    auth.InvalidCredentials -> "Invalid credentials"
    auth.EmailAlreadyExists -> "Email already exists"
    auth.SessionExpired -> "Session expired"
    auth.TokenExpired -> "Token expired"
    auth.RefreshTokenExpired -> "Refresh token expired"
    auth.DatabaseError(msg) -> msg
  }
}
