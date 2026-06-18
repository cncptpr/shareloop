import generated/types
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import gleam/time/calendar
import gleam/time/timestamp.{type Timestamp}
import pog
import server/sql

fn timestamp_to_string(t: Timestamp) -> String {
  timestamp.to_rfc3339(t, calendar.utc_offset)
}

fn parse_timestamp(s: String) -> Result(Timestamp, Nil) {
  timestamp.parse_rfc3339(s)
}

fn rent_request_from_row(
  id: Int,
  item_id: Int,
  requester_id: Int,
  requester_name: String,
  item_title: String,
  owner_name: String,
  owner_id: Int,
  latest_accepted_offer_id: Option(Int),
  latest_open_offer_id: Option(Int),
  borrow_confirmed_at: Option(Timestamp),
  returned_at: Option(Timestamp),
  created_at: String,
  updated_at: String,
) -> types.RentRequest {
  types.RentRequest(
    id:,
    item_id:,
    requester: types.Person(id: requester_id, name: requester_name),
    item_title:,
    owner_name:,
    owner_id:,
    latest_accepted_offer_id:,
    latest_open_offer_id:,
    borrow_confirmed_at: option.map(borrow_confirmed_at, timestamp_to_string),
    returned_at: option.map(returned_at, timestamp_to_string),
    created_at:,
    updated_at:,
  )
}

fn offer_from_row(
  id: Int,
  rent_request_id: Int,
  sender_id: Int,
  start_date: Timestamp,
  end_date: Timestamp,
  accepted_at: Option(Timestamp),
  created_at: Timestamp,
  updated_at: Timestamp,
) -> types.RentOffer {
  types.RentOffer(
    id:,
    rent_request_id:,
    sender_id:,
    start_date: timestamp_to_string(start_date),
    end_date: timestamp_to_string(end_date),
    accepted_at: option.map(accepted_at, timestamp_to_string),
    created_at: timestamp_to_string(created_at),
    updated_at: timestamp_to_string(updated_at),
  )
}

fn single_row(rows: List(a)) -> Result(a, Nil) {
  case rows {
    [row] -> Ok(row)
    _ -> Error(Nil)
  }
}

fn get_request_for_participant(
  conn: pog.Connection,
  request_id: Int,
  user_id: Int,
) -> Result(types.RentRequest, Nil) {
  use returned <- result.try(
    sql.get_rent_request_by_id(conn, request_id)
    |> result.map_error(fn(_) { Nil }),
  )
  use row <- result.try(single_row(returned.rows))

  case row.requester_id == user_id || row.owner_id == user_id {
    True ->
      Ok(rent_request_from_row(
        row.id,
        row.item_id,
        row.requester_id,
        row.requester_name,
        row.item_title,
        row.owner_name,
        row.owner_id,
        row.latest_accepted_offer_id,
        row.latest_open_offer_id,
        row.borrow_confirmed_at,
        row.returned_at,
        row.created_at,
        row.updated_at,
      ))
    False -> Error(Nil)
  }
}

pub fn create_rent_request(
  conn: pog.Connection,
  user_id: Int,
  item_id: Int,
) -> Result(types.RentRequest, Nil) {
  let existing = sql.get_open_rent_request_for_item_and_user(conn, item_id, user_id)
  |> result.map(fn(returned) { returned.rows })
  |> result.unwrap([])

  case existing {
    [row] ->
      Ok(rent_request_from_row(
        row.id,
        row.item_id,
        row.requester_id,
        row.requester_name,
        row.item_title,
        row.owner_name,
        row.owner_id,
        row.latest_accepted_offer_id,
        row.latest_open_offer_id,
        row.borrow_confirmed_at,
        row.returned_at,
        row.created_at,
        row.updated_at,
      ))
    _ -> {
      use created <- result.try(
        sql.create_rent_request(conn, item_id, user_id)
        |> result.map_error(fn(_) { Nil }),
      )
      use id <- result.try(single_row(created.rows) |> result.map(fn(r) { r.id }))

      use returned <- result.try(
        sql.get_rent_request_by_id(conn, id)
        |> result.map_error(fn(_) { Nil }),
      )
      use row <- result.try(single_row(returned.rows))

      Ok(rent_request_from_row(
        row.id,
        row.item_id,
        row.requester_id,
        row.requester_name,
        row.item_title,
        row.owner_name,
        row.owner_id,
        row.latest_accepted_offer_id,
        row.latest_open_offer_id,
        row.borrow_confirmed_at,
        row.returned_at,
        row.created_at,
        row.updated_at,
      ))
    }
  }
}

pub fn get_rent_requests(
  conn: pog.Connection,
  user_id: Int,
) -> Result(List(types.RentRequest), Nil) {
  use returned <- result.try(
    sql.get_rent_requests_for_user(conn, user_id)
    |> result.map_error(fn(_) { Nil }),
  )

  Ok(list.map(returned.rows, fn(row) {
    rent_request_from_row(
      row.id,
      row.item_id,
      row.requester_id,
      row.requester_name,
      row.item_title,
      row.owner_name,
      row.owner_id,
      row.latest_accepted_offer_id,
      row.latest_open_offer_id,
      row.borrow_confirmed_at,
      row.returned_at,
      row.created_at,
      row.updated_at,
    )
  }))
}

pub fn get_rent_request_by_id(
  conn: pog.Connection,
  request_id: Int,
  user_id: Int,
) -> Result(types.RentRequest, Nil) {
  get_request_for_participant(conn, request_id, user_id)
}

pub fn send_message(
  conn: pog.Connection,
  request_id: Int,
  user_id: Int,
  content: String,
) -> Result(types.Message, Nil) {
  use _request <- result.try(get_request_for_participant(conn, request_id, user_id))

  use created <- result.try(
    sql.create_message(conn, request_id, user_id, content)
    |> result.map_error(fn(_) { Nil }),
  )
  use id <- result.try(single_row(created.rows) |> result.map(fn(r) { r.id }))

  use returned <- result.try(
    sql.get_messages_for_request(conn, request_id)
    |> result.map_error(fn(_) { Nil }),
  )
  use msg <- result.try(
    returned.rows
    |> list.filter(fn(r) { r.id == id })
    |> single_row,
  )

  Ok(types.Message(
    id: msg.id,
    rent_request_id: msg.rent_request_id,
    author_id: msg.author_id,
    content: msg.content,
    created_at: timestamp_to_string(msg.created_at),
  ))
}

pub fn get_messages(
  conn: pog.Connection,
  request_id: Int,
  user_id: Int,
) -> Result(List(types.Message), Nil) {
  use _request <- result.try(get_request_for_participant(conn, request_id, user_id))

  use returned <- result.try(
    sql.get_messages_for_request(conn, request_id)
    |> result.map_error(fn(_) { Nil }),
  )

  Ok(list.map(returned.rows, fn(row) {
    types.Message(
      id: row.id,
      rent_request_id: row.rent_request_id,
      author_id: row.author_id,
      content: row.content,
      created_at: timestamp_to_string(row.created_at),
    )
  }))
}

pub fn create_offer(
  conn: pog.Connection,
  request_id: Int,
  user_id: Int,
  start_date: String,
  end_date: String,
) -> Result(types.RentOffer, Nil) {
  use _request <- result.try(get_request_for_participant(conn, request_id, user_id))

  use start <- result.try(parse_timestamp(start_date))
  use end <- result.try(parse_timestamp(end_date))

  use created <- result.try(
    sql.create_offer(conn, request_id, user_id, start, end)
    |> result.map_error(fn(_) { Nil }),
  )
  use id <- result.try(single_row(created.rows) |> result.map(fn(r) { r.id }))

  use _ <- result.try(
    sql.update_rent_request_latest_open(conn, id, request_id)
    |> result.map_error(fn(_) { Nil }),
  )

  use returned <- result.try(
    sql.get_offer_by_id(conn, id)
    |> result.map_error(fn(_) { Nil }),
  )
  use row <- result.try(single_row(returned.rows))

  Ok(offer_from_row(
    row.id,
    row.rent_request_id,
    row.sender_id,
    row.start_date,
    row.end_date,
    row.accepted_at,
    row.created_at,
    row.updated_at,
  ))
}

pub fn get_offers(
  conn: pog.Connection,
  request_id: Int,
  user_id: Int,
) -> Result(List(types.RentOffer), Nil) {
  use _request <- result.try(get_request_for_participant(conn, request_id, user_id))

  use returned <- result.try(
    sql.get_offers_for_request(conn, request_id)
    |> result.map_error(fn(_) { Nil }),
  )

  Ok(list.map(returned.rows, fn(row) {
    offer_from_row(
      row.id,
      row.rent_request_id,
      row.sender_id,
      row.start_date,
      row.end_date,
      row.accepted_at,
      row.created_at,
      row.updated_at,
    )
  }))
}

pub fn accept_offer(
  conn: pog.Connection,
  offer_id: Int,
  user_id: Int,
) -> Result(types.RentOffer, Nil) {
  use returned <- result.try(
    sql.get_offer_by_id(conn, offer_id)
    |> result.map_error(fn(_) { Nil }),
  )
  use offer <- result.try(single_row(returned.rows))

  use request <- result.try(
    get_request_for_participant(conn, offer.rent_request_id, user_id),
  )

  case offer.sender_id == user_id {
    True -> Error(Nil)
    False -> {
      case request.latest_open_offer_id {
        Some(id) if id == offer.id -> {
          use accepted <- result.try(
            sql.accept_offer(conn, offer_id)
            |> result.map_error(fn(_) { Nil }),
          )
          use _ <- result.try(single_row(accepted.rows) |> result.map(fn(_) { Nil }))

          use _ <- result.try(
            sql.update_rent_request_latest_accepted(conn, offer_id, offer.rent_request_id)
            |> result.map_error(fn(_) { Nil }),
          )

          use returned <- result.try(
            sql.get_latest_accepted_offer(conn, offer.rent_request_id)
            |> result.map_error(fn(_) { Nil }),
          )
          use row <- result.try(single_row(returned.rows))

          Ok(offer_from_row(
            row.id,
            row.rent_request_id,
            row.sender_id,
            row.start_date,
            row.end_date,
            row.accepted_at,
            row.created_at,
            row.updated_at,
          ))
        }
        _ -> Error(Nil)
      }
    }
  }
}

pub fn confirm_borrow(
  conn: pog.Connection,
  request_id: Int,
  user_id: Int,
) -> Result(types.RentRequest, Nil) {
  use request <- result.try(get_request_for_participant(conn, request_id, user_id))

  case request.owner_id == user_id {
    True -> {
      use _ <- result.try(
        case request.latest_accepted_offer_id {
          None -> Error(Nil)
          Some(_) -> Ok(Nil)
        }
      )
      use _ <- result.try(
        case request.borrow_confirmed_at {
          None -> Ok(Nil)
          Some(_) -> Error(Nil)
        }
      )
      use _ <- result.try(
        case request.returned_at {
          None -> Ok(Nil)
          Some(_) -> Error(Nil)
        }
      )
      use _ <- result.try(
        sql.update_rent_request_borrow(conn, request_id)
        |> result.map_error(fn(_) { Nil }),
      )

      use returned <- result.try(
        sql.get_rent_request_by_id(conn, request_id)
        |> result.map_error(fn(_) { Nil }),
      )
      use row <- result.try(single_row(returned.rows))

      Ok(rent_request_from_row(
        row.id,
        row.item_id,
        row.requester_id,
        row.requester_name,
        row.item_title,
        row.owner_name,
        row.owner_id,
        row.latest_accepted_offer_id,
        row.latest_open_offer_id,
        row.borrow_confirmed_at,
        row.returned_at,
        row.created_at,
        row.updated_at,
      ))
    }
    False -> Error(Nil)
  }
}

pub fn confirm_return(
  conn: pog.Connection,
  request_id: Int,
  user_id: Int,
) -> Result(types.RentRequest, Nil) {
  use request <- result.try(get_request_for_participant(conn, request_id, user_id))

  case request.owner_id == user_id {
    True -> {
      use _ <- result.try(
        case request.borrow_confirmed_at {
          None -> Error(Nil)
          Some(_) -> Ok(Nil)
        }
      )
      use _ <- result.try(
        case request.returned_at {
          None -> Ok(Nil)
          Some(_) -> Error(Nil)
        }
      )
      use _ <- result.try(
        sql.update_rent_request_returned(conn, request_id)
        |> result.map_error(fn(_) { Nil }),
      )

      use returned <- result.try(
        sql.get_rent_request_by_id(conn, request_id)
        |> result.map_error(fn(_) { Nil }),
      )
      use row <- result.try(single_row(returned.rows))

      Ok(rent_request_from_row(
        row.id,
        row.item_id,
        row.requester_id,
        row.requester_name,
        row.item_title,
        row.owner_name,
        row.owner_id,
        row.latest_accepted_offer_id,
        row.latest_open_offer_id,
        row.borrow_confirmed_at,
        row.returned_at,
        row.created_at,
        row.updated_at,
      ))
    }
    False -> Error(Nil)
  }
}
