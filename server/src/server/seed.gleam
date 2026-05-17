import gleam/io
import gleam/result
import pog
import server/auth
import server/db
import server/migration
import server/error

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

use _ <- result.try(clear_users(conn))
use _ <- result.try(
  auth.create_user(conn, "dev@example.com", "dev")
  |> result.map_error(fn(e) {
    "Failed to create dev user: " <> auth_error_message(e)
  }),
)

use _ <- result.try(clear_items(conn))
use _ <- result.try(insert_item(conn, "Inserat 1", "Ganz tolles Inserat", "Ich", 4.9, 13.4050, 52.5200, "Berlin", "10115"))
  use _ <- result.try(insert_item(conn, "Internat", "Ganz tolles Internat", "Ich", 4.9, 11.5820, 48.1351, "München", "80331"))
  use _ <- result.try(insert_item(conn, "Inserat 2", "Papput", "Ich", 4.9, 9.9937, 53.5511, "Hamburg", "20095"))
  use _ <- result.try(insert_item(conn, "Auto", "Kann fahren", "Carl", 4.3, 6.9603, 50.9375, "Köln", "50667"))
  use _ <- result.try(insert_item(conn, "Spezi", "Bitte voll zurueck", "Timon", 5.0, 8.6821, 50.1109, "Frankfurt am Main", "60311"))

  Ok(Nil)
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

fn clear_users(conn: pog.Connection) -> Result(Nil, String) {
  pog.query("delete from users")
  |> pog.execute(conn)
  |> result.map_error(fn(_) { "Failed to clear users" })
  |> result.map(fn(_) { Nil })
}

fn clear_items(conn: pog.Connection) -> Result(Nil, String) {
  pog.query("delete from items")
  |> pog.execute(conn)
  |> result.map_error(fn(_) { "Failed to clear items" })
  |> result.map(fn(_) { Nil })
}

fn insert_item(
  conn: pog.Connection,
  title: String,
  description: String,
  author_name: String,
  score: Float,
  lng: Float,
  lat: Float,
  city: String,
  postal_code: String,
) -> Result(Nil, String) {
  let query = "insert into items (title, description, author_name, score, location, city, postal_code) values ($1, $2, $3, $4, st_setsrid(st_makepoint($5, $6), 4326)::geography, $7, $8)"

  pog.query(query)
  |> pog.parameter(pog.text(title))
  |> pog.parameter(pog.text(description))
  |> pog.parameter(pog.text(author_name))
  |> pog.parameter(pog.float(score))
  |> pog.parameter(pog.float(lng))
  |> pog.parameter(pog.float(lat))
  |> pog.parameter(pog.text(city))
  |> pog.parameter(pog.text(postal_code))
  |> pog.execute(conn)
  |> result.map_error(fn(_) { "Failed to insert item" })
  |> result.map(fn(_) { Nil })
}
