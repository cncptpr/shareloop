import generated/types
import gleam/list
import gleam/option.{type Option}
import gleam/order
import gleam/result
import gleam/time/calendar
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
    created_at: Timestamp,
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
    refresh_token_hash: String,
    refresh_expires_at: Timestamp,
    email: String,
  )
}

pub type AuthError {
  InvalidCredentials
  EmailAlreadyExists
  SessionExpired
  TokenExpired
  RefreshTokenExpired
  DatabaseError(String)
}

const access_token_lifetime_hours = 1

const refresh_token_lifetime_days = 30

fn first_row(rows: List(a), on_empty: AuthError) -> Result(a, AuthError) {
  case rows {
    [row, ..] -> Ok(row)
    [] -> Error(on_empty)
  }
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
  use created <- result.try(
    sql.create_user(conn, email, password_hash)
    |> result.map_error(fn(_) { DatabaseError("Failed to create user") }),
  )
  use first <- result.try(first_row(
    created.rows,
    DatabaseError("No row returned"),
  ))
  use user_row <- result.try(
    sql.get_user_by_id(conn, first.id)
    |> result.map_error(fn(_) { DatabaseError("Failed to get created user") })
    |> result.try(fn(r) { first_row(r.rows, DatabaseError("User not found")) }),
  )
  Ok(User(
    id: user_row.id,
    email: user_row.email,
    password_hash: user_row.password_hash,
    last_online_at: user_row.last_online_at,
    created_at: user_row.created_at,
  ))
}

pub fn login(
  conn: pog.Connection,
  email email: String,
  password plaintext: String,
) -> Result(types.LoginResult, AuthError) {
  use user_row <- result.try(get_user_by_email(conn, email))
  case password.verify(plaintext, user_row.password_hash) {
    False -> Error(InvalidCredentials)
    True -> do_login(conn, user_row)
  }
}

fn do_login(
  conn: pog.Connection,
  user: User,
) -> Result(types.LoginResult, AuthError) {
  let #(#(access_token, access_hash), #(refresh_token, refresh_hash)) =
    session.generate_token_pair()
  let now = timestamp.system_time()
  let access_expiry =
    timestamp.add(now, duration.hours(access_token_lifetime_hours))
  let refresh_expiry =
    timestamp.add(now, duration.hours(refresh_token_lifetime_days * 24))

  use _ <- result.try(
    sql.create_session(
      conn,
      access_hash,
      user.id,
      access_expiry,
      refresh_hash,
      refresh_expiry,
    )
    |> result.map_error(fn(_) { DatabaseError("Failed to create session") }),
  )
  use _ <- result.try(
    sql.update_last_online(conn, user.id)
    |> result.map_error(fn(_) { DatabaseError("Failed to update last_online") }),
  )
  Ok(types.LoginResult(
    user: user |> to_api_user,
    access_token:,
    refresh_token:,
    access_expires_at: access_expiry |> encode_timestamp,
    refresh_expires_at: refresh_expiry |> encode_timestamp,
  ))
}

fn to_api_user(user: User) {
  types.User(
    created_at: user.created_at |> encode_timestamp,
    email: user.email,
    id: user.id,
    last_online_at: user.last_online_at |> encode_timestamp,
  )
}

fn encode_timestamp(timestamp) {
  timestamp.to_rfc3339(timestamp, calendar.utc_offset)
}

pub fn verify_token(
  conn: pog.Connection,
  token: String,
) -> Result(types.User, AuthError) {
  let token_hash = session.hash_token(token)
  use session_row <- result.try(
    sql.get_session_by_token(conn, token_hash)
    |> result.map_error(fn(_) { InvalidCredentials })
    |> result.try(fn(r) { first_row(r.rows, InvalidCredentials) }),
  )
  case timestamp.compare(session_row.expires_at, timestamp.system_time()) {
    order.Lt -> Error(TokenExpired)
    _ ->
      Ok(types.User(
        id: session_row.user_id,
        email: session_row.email,
        last_online_at: session_row.last_online_at |> encode_timestamp,
        created_at: session_row.created_at |> encode_timestamp,
      ))
  }
}

pub fn refresh_session(
  conn: pog.Connection,
  refresh_token: String,
) -> Result(types.LoginResult, AuthError) {
  let refresh_hash = session.hash_token(refresh_token)
  use row <- result.try(
    sql.get_session_by_refresh_token(conn, refresh_hash)
    |> result.map_error(fn(_) { InvalidCredentials })
    |> result.try(fn(r) { first_row(r.rows, InvalidCredentials) }),
  )
  case timestamp.compare(row.refresh_expires_at, timestamp.system_time()) {
    order.Lt -> Error(RefreshTokenExpired)
    _ -> do_refresh_session(conn, row)
  }
}

fn do_refresh_session(
  conn: pog.Connection,
  row: sql.GetSessionByRefreshTokenRow,
) -> Result(types.LoginResult, AuthError) {
  let #(
    #(new_access_token, new_access_hash),
    #(new_refresh_token, new_refresh_hash),
  ) = session.generate_token_pair()
  let now = timestamp.system_time()
  let access_expiry =
    timestamp.add(now, duration.hours(access_token_lifetime_hours))
  let refresh_expiry =
    timestamp.add(now, duration.hours(refresh_token_lifetime_days * 24))

  use _ <- result.try(
    sql.update_session_tokens(
      conn,
      new_access_hash,
      access_expiry,
      new_refresh_hash,
      refresh_expiry,
      row.id,
    )
    |> result.map_error(fn(_) {
      DatabaseError("Failed to rotate session tokens")
    }),
  )
  let user =
    User(
      id: row.user_id,
      email: row.email,
      password_hash: "",
      last_online_at: row.last_online_at,
      created_at: row.created_at,
    )
  Ok(types.LoginResult(
    user: user |> to_api_user,
    access_token: new_access_token,
    refresh_token: new_refresh_token,
    access_expires_at: access_expiry |> encode_timestamp,
    refresh_expires_at: refresh_expiry |> encode_timestamp,
  ))
}

pub fn expire_access(
  conn: pog.Connection,
  token: String,
) -> Result(Nil, AuthError) {
  let hash = session.hash_token(token)
  use row <- result.try(
    sql.get_session_by_token(conn, hash)
    |> result.map_error(fn(_) { InvalidCredentials })
    |> result.try(fn(r) { first_row(r.rows, InvalidCredentials) }),
  )
  use _ <- result.try(
    sql.expire_session_access(conn, row.id)
    |> result.map_error(fn(_) { DatabaseError("Failed to expire access token") }),
  )
  Ok(Nil)
}

pub fn expire_access_for_email(
  conn: pog.Connection,
  email: String,
) -> Result(Nil, AuthError) {
  use _ <- result.try(
    sql.expire_session_access_for_email(conn, email)
    |> result.map_error(fn(_) { DatabaseError("Failed to expire access token") }),
  )
  Ok(Nil)
}

pub fn expire_refresh(
  conn: pog.Connection,
  token: String,
) -> Result(Nil, AuthError) {
  let hash = session.hash_token(token)
  use row <- result.try(
    sql.get_session_by_refresh_token(conn, hash)
    |> result.map_error(fn(_) { InvalidCredentials })
    |> result.try(fn(r) { first_row(r.rows, InvalidCredentials) }),
  )
  use _ <- result.try(
    sql.expire_session_refresh(conn, row.id)
    |> result.map_error(fn(_) {
      DatabaseError("Failed to expire refresh token")
    }),
  )
  use _ <- result.try(
    sql.expire_session_access(conn, row.id)
    |> result.map_error(fn(_) { DatabaseError("Failed to expire access token") }),
  )
  Ok(Nil)
}

pub fn expire_refresh_for_email(
  conn: pog.Connection,
  email: String,
) -> Result(Nil, AuthError) {
  use _ <- result.try(
    sql.expire_session_refresh_for_email(conn, email)
    |> result.map_error(fn(_) {
      DatabaseError("Failed to expire refresh token")
    }),
  )
  use _ <- result.try(
    sql.expire_session_access_for_email(conn, email)
    |> result.map_error(fn(_) { DatabaseError("Failed to expire access token") }),
  )
  Ok(Nil)
}

pub fn logout(conn: pog.Connection, token: String) -> Result(Nil, AuthError) {
  let hash = session.hash_token(token)
  use row <- result.try(
    sql.get_session_by_token(conn, hash)
    |> result.map_error(fn(_) { InvalidCredentials })
    |> result.try(fn(r) { first_row(r.rows, InvalidCredentials) }),
  )
  use _ <- result.try(
    sql.delete_session(conn, row.id)
    |> result.map_error(fn(_) { DatabaseError("Failed to delete session") }),
  )
  Ok(Nil)
}

pub fn list_users(conn: pog.Connection) -> Result(List(UserPublic), AuthError) {
  use rows <- result.try(
    sql.list_users(conn)
    |> result.map_error(fn(_) { DatabaseError("Failed to list users") }),
  )
  Ok(
    list.map(rows.rows, fn(row) {
      UserPublic(
        id: row.id,
        email: row.email,
        last_online_at: row.last_online_at,
        created_at: row.created_at,
      )
    }),
  )
}

pub fn list_sessions(
  conn: pog.Connection,
) -> Result(List(SessionInfo), AuthError) {
  use rows <- result.try(
    sql.list_sessions(conn)
    |> result.map_error(fn(_) { DatabaseError("Failed to list sessions") }),
  )
  Ok(
    list.map(rows.rows, fn(row) {
      SessionInfo(
        id: row.id,
        token_hash: row.token_hash,
        user_id: row.user_id,
        expires_at: row.expires_at,
        created_at: row.created_at,
        refresh_token_hash: row.refresh_token_hash,
        refresh_expires_at: row.refresh_expires_at,
        email: row.email,
      )
    }),
  )
}

fn get_user_by_email(
  conn: pog.Connection,
  email: String,
) -> Result(User, AuthError) {
  use row <- result.try(
    sql.get_user_by_email(conn, email)
    |> result.map_error(fn(_) { InvalidCredentials })
    |> result.try(fn(r) { first_row(r.rows, InvalidCredentials) }),
  )
  Ok(User(
    id: row.id,
    email: row.email,
    password_hash: row.password_hash,
    last_online_at: row.last_online_at,
    created_at: row.created_at,
  ))
}
