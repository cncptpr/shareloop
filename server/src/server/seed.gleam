import gleam/io
import gleam/result
import pog
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

  use _ <- result.try(clear_items(conn))
  use _ <- result.try(insert_item(conn, "Inserat 1", "Ganz tolles Inserat", "Ich", 4.9))
  use _ <- result.try(insert_item(conn, "Internat", "Ganz tolles Internat", "Ich", 4.9))
  use _ <- result.try(insert_item(conn, "Inserat 2", "Papput", "Ich", 4.9))
  use _ <- result.try(insert_item(conn, "Auto", "Kann fahren", "Carl", 4.3))
  use _ <- result.try(insert_item(conn, "Spezi", "Bitte voll zurueck", "Timon", 5.0))

  Ok(Nil)
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
) -> Result(Nil, String) {
  let query = "insert into items (title, description, author_name, score) values ($1, $2, $3, $4)"

  pog.query(query)
  |> pog.parameter(pog.text(title))
  |> pog.parameter(pog.text(description))
  |> pog.parameter(pog.text(author_name))
  |> pog.parameter(pog.float(score))
  |> pog.execute(conn)
  |> result.map_error(fn(_) { "Failed to insert item" })
  |> result.map(fn(_) { Nil })
}
