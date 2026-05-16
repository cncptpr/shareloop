import gleam/list
import gleam/order
import gleam/time/duration
import gleam/time/timestamp.{type Timestamp}
import pog
import server/auth/password
import server/auth/session
import server/sql

pub type User {
  User(
    id: Int,
    email: String,
    password_hash: String,
    last_online_at: Timestamp,
  )
}

pub type UserPublic {
  UserPublic(
    id: Int,
    email: String,
    last_online_at: Timestamp,
    created_at: Timestamp,
  )
}

pub type SessionInfo {
  SessionInfo(
    id: Int,
    token_hash: String,
    user_id: Int,
    expires_at: Timestamp,
    created_at: Timestamp,
    email: String,
  )
}

pub type AuthError {
  InvalidCredentials
  EmailAlreadyExists
  SessionExpired
  DatabaseError(String)
}

fn db_error(msg: String) -> AuthError {
  DatabaseError(msg)
}

pub fn create_user(
  conn: pog.Connection,
  email: String,
  plaintext: String,
) -> Result(User, AuthError) {
  case sql.get_user_by_email(conn, email) {
    Ok(ret) if ret.rows != [] -> Error(EmailAlreadyExists)
    _ -> do_create_user(conn, email, plaintext)
  }
}

fn do_create_user(
  conn: pog.Connection,
  email: String,
  plaintext: String,
) -> Result(User, AuthError) {
  let password_hash = password.hash(plaintext)
  case sql.create_user(conn, email, password_hash) {
    Error(_) -> Error(db_error("Failed to create user"))
    Ok(created) -> {
      let first_row = created.rows
      case first_row {
        [] -> Error(db_error("No row returned from create_user"))
        [first, ..] -> {
          case sql.get_user_by_id(conn, first.id) {
            Error(_) -> Error(db_error("Failed to get created user"))
            Ok(user_result) -> {
              case user_result.rows {
                [] -> Error(db_error("User not found after creation"))
                [user_row, ..] ->
                  Ok(User(
                    id: user_row.id,
                    email: user_row.email,
                    password_hash: user_row.password_hash,
                    last_online_at: user_row.last_online_at,
                  ))
              }
            }
          }
        }
      }
    }
  }
}

pub fn login(
  conn: pog.Connection,
  email: String,
  plaintext: String,
) -> Result(#(User, String), AuthError) {
  case get_user_by_email(conn, email) {
    Error(e) -> Error(e)
    Ok(user_row) -> {
      case password.verify(plaintext, user_row.password_hash) {
        False -> Error(InvalidCredentials)
        True -> do_login(conn, user_row)
      }
    }
  }
}

fn do_login(
  conn: pog.Connection,
  user_row: User,
) -> Result(#(User, String), AuthError) {
  let #(token, token_hash) = session.generate_token_and_hash()
  let now = timestamp.system_time()
  let expiry = timestamp.add(now, duration.hours(30 * 24))

  case sql.create_session(conn, token_hash, user_row.id, expiry) {
    Error(_) -> Error(db_error("Failed to create session"))
    Ok(_) -> {
      case sql.update_last_online(conn, user_row.id) {
        Error(_) -> Error(db_error("Failed to update last_online"))
        Ok(_) -> Ok(#(user_row, token))
      }
    }
  }
}

pub fn verify_token(
  conn: pog.Connection,
  token: String,
) -> Result(User, AuthError) {
  let token_hash = session.hash_token(token)
  case sql.get_session_by_token(conn, token_hash) {
    Error(_) -> Error(InvalidCredentials)
    Ok(session_result) -> {
      case session_result.rows {
        [] -> Error(InvalidCredentials)
        [session_row, ..] -> {
          let now = timestamp.system_time()
          case timestamp.compare(session_row.expires_at, now) {
            order.Lt -> Error(SessionExpired)
            _ ->
              Ok(User(
                id: session_row.user_id,
                email: session_row.email,
                password_hash: "",
                last_online_at: session_row.last_online_at,
              ))
          }
        }
      }
    }
  }
}

pub fn list_users(
  conn: pog.Connection,
) -> Result(List(UserPublic), AuthError) {
  case sql.list_users(conn) {
    Error(_) -> Error(db_error("Failed to list users"))
    Ok(rows) ->
      Ok(list.map(rows.rows, fn(row) {
        UserPublic(
          id: row.id,
          email: row.email,
          last_online_at: row.last_online_at,
          created_at: row.created_at,
        )
      }))
  }
}

pub fn list_sessions(
  conn: pog.Connection,
) -> Result(List(SessionInfo), AuthError) {
  case sql.list_sessions(conn) {
    Error(_) -> Error(db_error("Failed to list sessions"))
    Ok(rows) ->
      Ok(list.map(rows.rows, fn(row) {
        SessionInfo(
          id: row.id,
          token_hash: row.token_hash,
          user_id: row.user_id,
          expires_at: row.expires_at,
          created_at: row.created_at,
          email: row.email,
        )
      }))
  }
}

fn get_user_by_email(
  conn: pog.Connection,
  email: String,
) -> Result(User, AuthError) {
  case sql.get_user_by_email(conn, email) {
    Error(_) -> Error(InvalidCredentials)
    Ok(result) -> {
      case result.rows {
        [] -> Error(InvalidCredentials)
        [row, ..] ->
          Ok(User(
            id: row.id,
            email: row.email,
            password_hash: row.password_hash,
            last_online_at: row.last_online_at,
          ))
      }
    }
  }
}
