import gleam/io
import gleam/result
import pog
import server/auth
import server/db
import server/migration
import server/error
import server/sql

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

  use _ <- result.try(insert_item(conn, "Inserat 1", "Ganz tolles Inserat", dev_user.id, 4.9, 13.4050, 52.5200, "Berlin", "10115"))
  use _ <- result.try(insert_item(conn, "Internat", "Ganz tolles Internat", dev_user.id, 4.9, 11.5820, 48.1351, "München", "80331"))
  use _ <- result.try(insert_item(conn, "Inserat 2", "Papput", dev_user.id, 4.9, 9.9937, 53.5511, "Hamburg", "20095"))
  use _ <- result.try(insert_item(conn, "Auto", "Kann fahren", carl.id, 4.3, 6.9603, 50.9375, "Köln", "50667"))
  use _ <- result.try(insert_item(conn, "Spezi", "Bitte voll zurueck", timon.id, 5.0, 8.6821, 50.1109, "Frankfurt am Main", "60311"))

  Ok(Nil)
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
) -> Result(Nil, String) {
  sql.create_item(conn, title, description, author_id, score, lng, lat, city, postal_code)
  |> result.map_error(fn(_) { "Failed to insert item" })
  |> result.map(fn(_) { Nil })
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
