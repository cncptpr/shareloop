import argv
import openapi/types
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import gleam/time/calendar
import gleam/time/timestamp
import server/auth
import server/db
import server/error
import server/migration
import simplifile

const tokens_path = "tokens.txt"

@external(erlang, "auth_ffi", "read_line")
fn read_line(prompt: String) -> String

pub fn main() {
  let args = argv.load().arguments
  let assert Ok(conn) = db.start_pool()
  let assert Ok(_) = migration.run_all() |> result.map_error(error.message)

  case args {
    ["help"] | ["-h"] -> cmd_help()
    ["users", "create", email] -> cmd_create_user(conn, email)
    ["users", "list"] -> cmd_list_users(conn)
    ["users", "sessions"] -> cmd_list_sessions(conn)
    ["users", "login", email] -> cmd_login(conn, email)
    ["users", "validate"] -> cmd_validate(conn)
    ["users", "refresh"] -> cmd_refresh(conn)
    ["users", "expire-access", email] ->
      cmd_expire_access_for_email(conn, email)
    ["users", "expire-refresh", email] ->
      cmd_expire_refresh_for_email(conn, email)
    ["users", "expire-access"] -> cmd_expire_access(conn)
    ["users", "expire-refresh"] -> cmd_expire_refresh(conn)
    ["users", "logout"] -> cmd_logout(conn)
    _ -> cmd_help()
  }
}

fn cmd_help() {
  io.println(
    "
Usage: gleam run -m server/cli <command>

Commands:
  help | -h                           Print this help
  users create <email>                Create a new user (prompts for password)
  users list                          List all users
  users sessions                      Show active sessions (or: users sessions)
  users login <email>                 Login as user (prompts for password) (or: users login)
  users validate                      Validate the stored access token
  users refresh                       Refresh tokens using the stored refresh token
  users expire-access [email]         Force-expire the stored access token or all tokens for email
  users expire-refresh [email]        Force-expire both tokens for the session or all tokens for email
  users logout                        Delete the session for the stored access token",
  )
}

fn prompt_password() -> String {
  io.print("Password: ")
  read_line("") |> string.trim
}

fn save_tokens(access: String, refresh: String) {
  case simplifile.write(to: tokens_path, contents: access <> "\n" <> refresh) {
    Ok(_) -> io.println("Tokens saved to " <> tokens_path)
    Error(e) ->
      io.println(
        "Warning: could not save tokens: " <> simplifile.describe_error(e),
      )
  }
}

fn read_access_token() -> Result(String, Nil) {
  case simplifile.read(from: tokens_path) {
    Ok(contents) -> {
      case string.split(contents, "\n") {
        [line, ..] if line != "" -> Ok(line)
        _ -> Error(Nil)
      }
    }
    Error(_) -> Error(Nil)
  }
}

fn read_refresh_token() -> Result(String, Nil) {
  case simplifile.read(from: tokens_path) {
    Ok(contents) -> {
      case string.split(contents, "\n") {
        [_, line, ..] if line != "" -> Ok(string.trim(line))
        _ -> Error(Nil)
      }
    }
    Error(_) -> Error(Nil)
  }
}

fn println_err(msg: String) {
  io.println_error("Error: " <> msg)
}

fn cmd_create_user(conn, email: String) {
  let password = prompt_password()
  case auth.create_user(conn, email, password) {
    Error(e) -> println_err(error_string(e))
    Ok(user) -> {
      io.println("User created:")
      print_auth_user(user)
    }
  }
}

fn cmd_list_users(conn) {
  case auth.list_users(conn) {
    Error(e) -> println_err(error_string(e))
    Ok(users) -> {
      io.println("ID  | Email               | Last Online   | Created")
      io.println(
        "----+---------------------+---------------+------------------",
      )
      list.each(users, fn(u) {
        io.println(
          pad_end(int.to_string(u.id), 3)
          <> " | "
          <> pad_end(u.email, 19)
          <> " | "
          <> format_ts(u.last_online_at)
          <> " | "
          <> format_ts(u.created_at),
        )
      })
    }
  }
}

fn cmd_list_sessions(conn) {
  case auth.list_sessions(conn) {
    Error(e) -> println_err(error_string(e))
    Ok(sessions) -> {
      io.println(
        "ID  | User ID | Email               | Access Expires     | Refresh Expires    | Created",
      )
      io.println(
        "----+---------+---------------------+--------------------+--------------------+------------------",
      )
      list.each(sessions, fn(s) {
        io.println(
          pad_end(int.to_string(s.id), 3)
          <> " | "
          <> pad_end(int.to_string(s.user_id), 7)
          <> " | "
          <> pad_end(s.email, 19)
          <> " | "
          <> format_ts(s.expires_at)
          <> " | "
          <> format_ts(s.refresh_expires_at)
          <> " | "
          <> format_ts(s.created_at),
        )
      })
    }
  }
}

fn cmd_login(conn, email: String) {
  let password = prompt_password()
  case auth.login(conn, email, password) {
    Error(e) -> println_err(error_string(e))
    Ok(result) -> {
      io.println("Login successful!")
      io.println("  Access token:  " <> result.access_token)
      io.println("  Refresh token: " <> result.refresh_token)
      io.println("  Access expires:  " <> result.access_expires_at)
      io.println("  Refresh expires: " <> result.refresh_expires_at)
      save_tokens(result.access_token, result.refresh_token)
    }
  }
}

fn cmd_validate(conn) {
  case read_access_token() {
    Error(_) -> println_err("No tokens found. Run 'login' first.")
    Ok(token) -> {
      case auth.verify_token(conn, token) {
        Error(e) -> println_err(error_string(e))
        Ok(user) -> {
          io.println("Token is valid for:")
          print_api_user(user)
        }
      }
    }
  }
}

fn cmd_refresh(conn) {
  case read_refresh_token() {
    Error(_) -> println_err("No tokens found. Run 'users login' first.")
    Ok(token) -> {
      case auth.refresh_session(conn, token) {
        Error(e) -> println_err(error_string(e))
        Ok(result) -> {
          io.println("Tokens refreshed!")
          io.println("  Access token:  " <> result.access_token)
          io.println("  Refresh token: " <> result.refresh_token)
          io.println("  Access expires:  " <> result.access_expires_at)
          io.println("  Refresh expires: " <> result.refresh_expires_at)
          save_tokens(result.access_token, result.refresh_token)
        }
      }
    }
  }
}

fn cmd_expire_access(conn) {
  case read_access_token() {
    Error(_) -> println_err("No tokens found. Run 'users login' first.")
    Ok(token) -> {
      case auth.expire_access(conn, token) {
        Error(e) -> println_err(error_string(e))
        Ok(_) -> io.println("Access token expired.")
      }
    }
  }
}

fn cmd_expire_refresh(conn) {
  case read_refresh_token() {
    Error(_) -> println_err("No tokens found. Run 'users login' first.")
    Ok(token) -> {
      case auth.expire_refresh(conn, token) {
        Error(e) -> println_err(error_string(e))
        Ok(_) -> io.println("Refresh token expired (access also expired).")
      }
    }
  }
}

fn cmd_expire_access_for_email(conn, email) {
  case auth.expire_access_for_email(conn, email) {
    Error(e) -> println_err(error_string(e))
    Ok(_) -> io.println("Access token expired.")
  }
}

fn cmd_expire_refresh_for_email(conn, email) {
  case auth.expire_refresh_for_email(conn, email) {
    Error(e) -> println_err(error_string(e))
    Ok(_) -> io.println("Refresh token expired (access also expired).")
  }
}

fn cmd_logout(conn) {
  case read_access_token() {
    Error(_) -> println_err("No tokens found. Run 'users login' first.")
    Ok(token) -> {
      case auth.logout(conn, token) {
        Error(e) -> println_err(error_string(e))
        Ok(_) -> {
          io.println("Logged out.")
          Nil
        }
      }
    }
  }
}

fn error_string(e: auth.AuthError) -> String {
  case e {
    auth.InvalidCredentials -> "Invalid credentials"
    auth.EmailAlreadyExists -> "Email already exists"
    auth.SessionExpired -> "Session expired"
    auth.TokenExpired -> "Token expired"
    auth.RefreshTokenExpired -> "Refresh token expired"
    auth.DatabaseError(s) -> s
  }
}

fn print_api_user(user: types.User) {
  io.println("  ID:    " <> int.to_string(user.id))
  io.println("  Email: " <> user.email)
  io.println("  Last online: " <> user.last_online_at)
}

fn print_auth_user(user: auth.User) {
  io.println("  ID:    " <> int.to_string(user.id))
  io.println("  Email: " <> user.email)
  io.println("  Last online: " <> user.last_online_at |> ts_to_string)
}

fn format_ts(ts: timestamp.Timestamp) -> String {
  let #(seconds, _) = timestamp.to_unix_seconds_and_nanoseconds(ts)
  int.to_string(seconds)
}

fn ts_to_string(ts: timestamp.Timestamp) -> String {
  timestamp.to_rfc3339(ts, calendar.utc_offset)
}

fn pad_end(str: String, width: Int) -> String {
  string.pad_end(str, width, " ")
}
