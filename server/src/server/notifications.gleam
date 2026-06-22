import gleam/dict
import gleam/erlang/process.{type Subject}
import gleam/list
import gleam/option.{type Option}
import gleam/otp/actor
import gleam/result

pub type RegistryMessage {
  Register(user_id: Int, subject: Subject(WsEvent))
  Unregister(user_id: Int, subject: Subject(WsEvent))
  Notify(user_id: Int, event: WsEvent)
}

pub type WsEvent {
  AuthTimeout
  NotifyEvent(payload: String)
  CloseConnection
}

pub type WsState {
  WsState(
    authenticated: Bool,
    user_id: Option(Int),
    notify_subject: Option(Subject(WsEvent)),
  )
}

pub fn start_registry() -> Subject(RegistryMessage) {
  let assert Ok(started) =
    dict.new()
    |> actor.new
    |> actor.on_message(fn(state, msg) {
      case msg {
        Register(user_id, subject) -> {
          let subs = dict.get(state, user_id) |> result.unwrap([])
          let subs =
            subs |> list.prepend(subject) |> list.unique
          actor.continue(dict.insert(state, user_id, subs))
        }
        Unregister(user_id, subject) -> {
          let subs = dict.get(state, user_id) |> result.unwrap([])
          let subs = subs |> list.filter(fn(s) { s != subject })
          case subs {
            [] -> actor.continue(dict.delete(state, user_id))
            _ -> actor.continue(dict.insert(state, user_id, subs))
          }
        }
        Notify(user_id, event) -> {
          case dict.get(state, user_id) {
            Ok(subjects) ->
              list.each(subjects, fn(s) { process.send(s, event) })
            _ -> Nil
          }
          actor.continue(state)
        }
      }
    })
    |> actor.start
  started.data
}
pub fn notify(
  registry: Subject(RegistryMessage),
  user_id: Int,
  event: WsEvent,
) -> Nil {
  let _ = process.send(registry, Notify(user_id, event))
  Nil
}
