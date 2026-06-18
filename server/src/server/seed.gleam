import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import gleam/time/timestamp.{type Timestamp}
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

  use dev_user <- result.try(create_user_with_profile(conn, "dev@example.com", "dev", "Dev", "Dev user", 4.9))
  use carl <- result.try(create_user_with_profile(conn, "carl@example.com", "carl", "Carl", "Car seller", 4.3))
  use timon <- result.try(create_user_with_profile(conn, "timon@example.com", "timon", "Timon", "Spezi enthusiast", 5.0))

  use inserat1_id <- result.try(insert_item(conn, "Inserat 1", "Ganz tolles Inserat", dev_user.id, 4.9, 13.4050, 52.5200, "Berlin", "10115"))
  use internat_id <- result.try(insert_item(conn, "Internat", "Ganz tolles Internat", dev_user.id, 4.9, 11.5820, 48.1351, "München", "80331"))
  use inserat2_id <- result.try(insert_item(conn, "Inserat 2", "Papput", dev_user.id, 4.9, 9.9937, 53.5511, "Hamburg", "20095"))
  use auto_id <- result.try(insert_item(conn, "Auto", "Kann fahren", carl.id, 4.3, 6.9603, 50.9375, "Köln", "50667"))
  use spezi_id <- result.try(insert_item(conn, "Spezi", "Bitte voll zurueck", timon.id, 5.0, 8.6821, 50.1109, "Frankfurt am Main", "60311"))
  use fahrrad_id <- result.try(insert_item(conn, "Fahrrad", "Trekkingrad, 28 Zoll, 21 Gänge", carl.id, 4.1, 6.9603, 50.9375, "Köln", "50667"))

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

  io.println("Seeding rent requests...")

  use _ <- result.try(seed_rent_data(conn, dev_user, carl, timon, spezi_id, auto_id, fahrrad_id, internat_id, inserat1_id, inserat2_id))

  Ok(Nil)
}

fn make_ts(s: String) -> Result(Timestamp, String) {
  timestamp.parse_rfc3339(s)
  |> result.map_error(fn(_) { "Invalid timestamp: " <> s })
}

fn seed_rent_data(
  conn: pog.Connection,
  dev_user: auth.User,
  carl: auth.User,
  timon: auth.User,
  spezi_id: Int,
  auto_id: Int,
  fahrrad_id: Int,
  internat_id: Int,
  inserat1_id: Int,
  inserat2_id: Int,
) -> Result(Nil, String) {
  // ──────────────────────────────────────────────
  // A: Carl → Spezi (Timon) — unrelated to Dev, OPEN, 1 offer
  // ──────────────────────────────────────────────
  use returned <- result.try(
    sql.create_rent_request(conn, spezi_id, carl.id)
    |> result.map_error(fn(_) { "A: create_rent_request" }),
  )
  use req_a <- result.try(
    returned.rows |> list.first |> result.map_error(fn(_) { "A: no id" }),
  )
  use _ <- result.try(
    sql.create_message(conn, req_a.id, carl.id, "Hey, kann ich die Spezi fürs Wochenende ausleihen?")
    |> result.map_error(fn(_) { "A: msg 1" }),
  )
  use _ <- result.try(
    sql.create_message(conn, req_a.id, timon.id, "Klar, wann brauchst du sie?")
    |> result.map_error(fn(_) { "A: msg 2" }),
  )
  use _ <- result.try(
    sql.create_message(conn, req_a.id, carl.id, "Von Freitag bis Sonntag, 20.–22. Juni")
    |> result.map_error(fn(_) { "A: msg 3" }),
  )
  use oa_start <- result.try(make_ts("2026-06-20T00:00:00Z"))
  use oa_end <- result.try(make_ts("2026-06-22T00:00:00Z"))
  use returned <- result.try(
    sql.create_offer(conn, req_a.id, timon.id, oa_start, oa_end)
    |> result.map_error(fn(_) { "A: create_offer" }),
  )
  use oa <- result.try(
    returned.rows |> list.first |> result.map_error(fn(_) { "A: no offer id" }),
  )
  use _ <- result.try(
    sql.update_rent_request_latest_open(conn, oa.id, req_a.id)
    |> result.map_error(fn(_) { "A: update_latest_open" }),
  )

  // ──────────────────────────────────────────────
  // B: Dev → Auto (Carl) — CLOSED (returned), 1 offer
  // ──────────────────────────────────────────────
  use returned <- result.try(
    sql.create_rent_request(conn, auto_id, dev_user.id)
    |> result.map_error(fn(_) { "B: create_rent_request" }),
  )
  use req_b <- result.try(
    returned.rows |> list.first |> result.map_error(fn(_) { "B: no id" }),
  )
  use _ <- result.try(
    sql.create_message(conn, req_b.id, dev_user.id, "Moin, kann ich das Auto für den Umzug am 1. Juli leihen?")
    |> result.map_error(fn(_) { "B: msg 1" }),
  )
  use _ <- result.try(
    sql.create_message(conn, req_b.id, carl.id, "Klar, ein Tag reicht?")
    |> result.map_error(fn(_) { "B: msg 2" }),
  )
  use _ <- result.try(
    sql.create_message(conn, req_b.id, dev_user.id, "Ja, ein Tag sollte reichen!")
    |> result.map_error(fn(_) { "B: msg 3" }),
  )
  use ob_start <- result.try(make_ts("2026-07-01T00:00:00Z"))
  use ob_end <- result.try(make_ts("2026-07-01T00:00:00Z"))
  use returned <- result.try(
    sql.create_offer(conn, req_b.id, carl.id, ob_start, ob_end)
    |> result.map_error(fn(_) { "B: create_offer" }),
  )
  use ob <- result.try(
    returned.rows |> list.first |> result.map_error(fn(_) { "B: no offer id" }),
  )
  use _ <- result.try(
    sql.update_rent_request_latest_open(conn, ob.id, req_b.id)
    |> result.map_error(fn(_) { "B: update_latest_open" }),
  )
  use _ <- result.try(
    sql.accept_offer(conn, ob.id)
    |> result.map_error(fn(_) { "B: accept_offer" }),
  )
  use _ <- result.try(
    sql.update_rent_request_latest_accepted(conn, ob.id, req_b.id)
    |> result.map_error(fn(_) { "B: update_latest_accepted" }),
  )
  use _ <- result.try(
    sql.create_message(conn, req_b.id, dev_user.id, "Danke, hat alles geklappt!")
    |> result.map_error(fn(_) { "B: msg 4" }),
  )
  use _ <- result.try(
    sql.update_rent_request_borrow(conn, req_b.id)
    |> result.map_error(fn(_) { "B: confirm_borrow" }),
  )
  use _ <- result.try(
    sql.create_message(conn, req_b.id, carl.id, "Gerne, viel Erfolg beim Umzug!")
    |> result.map_error(fn(_) { "B: msg 5" }),
  )
  use _ <- result.try(
    sql.update_rent_request_returned(conn, req_b.id)
    |> result.map_error(fn(_) { "B: confirm_return" }),
  )
  use _ <- result.try(
    sql.create_message(conn, req_b.id, dev_user.id, "Alles gut zurückgegeben, danke!")
    |> result.map_error(fn(_) { "B: msg 6" }),
  )

  // ──────────────────────────────────────────────
  // C: Dev → Spezi (Timon) — OPEN, ~11 msgs, 2 offers → long scroll
  // ──────────────────────────────────────────────
  use returned <- result.try(
    sql.create_rent_request(conn, spezi_id, dev_user.id)
    |> result.map_error(fn(_) { "C: create_rent_request" }),
  )
  use req_c <- result.try(
    returned.rows |> list.first |> result.map_error(fn(_) { "C: no id" }),
  )
  use _ <- result.try(
    sql.create_message(conn, req_c.id, dev_user.id, "Hey, kann ich die Spezi auch mal ausleihen?")
    |> result.map_error(fn(_) { "C: msg 1" }),
  )
  use _ <- result.try(
    sql.create_message(conn, req_c.id, timon.id, "Klar, wann hättest du Zeit?")
    |> result.map_error(fn(_) { "C: msg 2" }),
  )
  use _ <- result.try(
    sql.create_message(conn, req_c.id, dev_user.id, "Am besten nächstes Wochenende")
    |> result.map_error(fn(_) { "C: msg 3" }),
  )
  use _ <- result.try(
    sql.create_message(conn, req_c.id, timon.id, "Samstag oder Sonntag?")
    |> result.map_error(fn(_) { "C: msg 4" }),
  )
  use _ <- result.try(
    sql.create_message(conn, req_c.id, dev_user.id, "Eher Sonntag, 22. Juni")
    |> result.map_error(fn(_) { "C: msg 5" }),
  )
  use oc1_start <- result.try(make_ts("2026-06-21T00:00:00Z"))
  use oc1_end <- result.try(make_ts("2026-06-22T00:00:00Z"))
  use returned <- result.try(
    sql.create_offer(conn, req_c.id, timon.id, oc1_start, oc1_end)
    |> result.map_error(fn(_) { "C: create_offer 1" }),
  )
  use oc1 <- result.try(
    returned.rows |> list.first |> result.map_error(fn(_) { "C: no offer 1 id" }),
  )
  use _ <- result.try(
    sql.update_rent_request_latest_open(conn, oc1.id, req_c.id)
    |> result.map_error(fn(_) { "C: update_latest_open 1" }),
  )

  // Dev sees offer, counters
  use _ <- result.try(
    sql.create_message(conn, req_c.id, dev_user.id, "Hmm, Samstag geht auch, aber erst abends. Geht das klar?")
    |> result.map_error(fn(_) { "C: msg 6" }),
  )
  use _ <- result.try(
    sql.create_message(conn, req_c.id, timon.id, "Klar, kein Problem!")
    |> result.map_error(fn(_) { "C: msg 7" }),
  )
  use _ <- result.try(
    sql.create_message(conn, req_c.id, dev_user.id, "Und kann ich sie vielleicht schon Freitagabend holen?")
    |> result.map_error(fn(_) { "C: msg 8" }),
  )
  use _ <- result.try(
    sql.create_message(conn, req_c.id, timon.id, "Ja, das geht klar. Ich schick dir ein neues Angebot.")
    |> result.map_error(fn(_) { "C: msg 9" }),
  )
  use oc2_start <- result.try(make_ts("2026-06-19T18:00:00Z"))
  use oc2_end <- result.try(make_ts("2026-06-22T20:00:00Z"))
  use returned <- result.try(
    sql.create_offer(conn, req_c.id, timon.id, oc2_start, oc2_end)
    |> result.map_error(fn(_) { "C: create_offer 2" }),
  )
  use oc2 <- result.try(
    returned.rows |> list.first |> result.map_error(fn(_) { "C: no offer 2 id" }),
  )
  use _ <- result.try(
    sql.update_rent_request_latest_open(conn, oc2.id, req_c.id)
    |> result.map_error(fn(_) { "C: update_latest_open 2" }),
  )
  use _ <- result.try(
    sql.create_message(conn, req_c.id, dev_user.id, "Perfekt, das passt! Danke dir!")
    |> result.map_error(fn(_) { "C: msg 10" }),
  )
  use _ <- result.try(
    sql.create_message(conn, req_c.id, timon.id, "Gerne, bis Freitag!")
    |> result.map_error(fn(_) { "C: msg 11" }),
  )

  // ──────────────────────────────────────────────
  // D: Dev → Fahrrad (Carl) — OPEN, ~6 msgs, no offer
  // ──────────────────────────────────────────────
  use returned <- result.try(
    sql.create_rent_request(conn, fahrrad_id, dev_user.id)
    |> result.map_error(fn(_) { "D: create_rent_request" }),
  )
  use req_d <- result.try(
    returned.rows |> list.first |> result.map_error(fn(_) { "D: no id" }),
  )
  use _ <- result.try(
    sql.create_message(conn, req_d.id, dev_user.id, "Hey, ist das Fahrrad noch frei?")
    |> result.map_error(fn(_) { "D: msg 1" }),
  )
  use _ <- result.try(
    sql.create_message(conn, req_d.id, carl.id, "Ja, wann willst du es abholen?")
    |> result.map_error(fn(_) { "D: msg 2" }),
  )
  use _ <- result.try(
    sql.create_message(conn, req_d.id, dev_user.id, "Am Samstag vielleicht?")
    |> result.map_error(fn(_) { "D: msg 3" }),
  )
  use _ <- result.try(
    sql.create_message(conn, req_d.id, carl.id, "Samstag Nachmittag geht klar")
    |> result.map_error(fn(_) { "D: msg 4" }),
  )
  use _ <- result.try(
    sql.create_message(conn, req_d.id, dev_user.id, "Super, sagen wir 15 Uhr?")
    |> result.map_error(fn(_) { "D: msg 5" }),
  )
  use _ <- result.try(
    sql.create_message(conn, req_d.id, carl.id, "Passt, bis Samstag!")
    |> result.map_error(fn(_) { "D: msg 6" }),
  )

  // ──────────────────────────────────────────────
  // E: Carl → Internat (Dev) — OPEN, ~11 msgs, 2 offers → long scroll
  // ──────────────────────────────────────────────
  use returned <- result.try(
    sql.create_rent_request(conn, internat_id, carl.id)
    |> result.map_error(fn(_) { "E: create_rent_request" }),
  )
  use req_e <- result.try(
    returned.rows |> list.first |> result.map_error(fn(_) { "E: no id" }),
  )
  use _ <- result.try(
    sql.create_message(conn, req_e.id, carl.id, "Hey, ich würde gern das Internat für ein Projekt nutzen")
    |> result.map_error(fn(_) { "E: msg 1" }),
  )
  use _ <- result.try(
    sql.create_message(conn, req_e.id, dev_user.id, "Cool, für wie lange?")
    |> result.map_error(fn(_) { "E: msg 2" }),
  )
  use _ <- result.try(
    sql.create_message(conn, req_e.id, carl.id, "Zwei Wochen vielleicht?")
    |> result.map_error(fn(_) { "E: msg 3" }),
  )
  use _ <- result.try(
    sql.create_message(conn, req_e.id, dev_user.id, "Wann genau?")
    |> result.map_error(fn(_) { "E: msg 4" }),
  )
  use _ <- result.try(
    sql.create_message(conn, req_e.id, carl.id, "Anfang Juli, 1. bis 14.")
    |> result.map_error(fn(_) { "E: msg 5" }),
  )
  use _ <- result.try(
    sql.create_message(conn, req_e.id, dev_user.id, "Hmm, zwei Wochen ist schon lang. Würde eine Woche reichen?")
    |> result.map_error(fn(_) { "E: msg 6" }),
  )
  use _ <- result.try(
    sql.create_message(conn, req_e.id, carl.id, "Können wir machen, eine Woche ist auch ok")
    |> result.map_error(fn(_) { "E: msg 7" }),
  )
  use oe1_start <- result.try(make_ts("2026-07-01T00:00:00Z"))
  use oe1_end <- result.try(make_ts("2026-07-07T00:00:00Z"))
  use returned <- result.try(
    sql.create_offer(conn, req_e.id, dev_user.id, oe1_start, oe1_end)
    |> result.map_error(fn(_) { "E: create_offer 1" }),
  )
  use oe1 <- result.try(
    returned.rows |> list.first |> result.map_error(fn(_) { "E: no offer 1 id" }),
  )
  use _ <- result.try(
    sql.update_rent_request_latest_open(conn, oe1.id, req_e.id)
    |> result.map_error(fn(_) { "E: update_latest_open 1" }),
  )
  use _ <- result.try(
    sql.create_message(conn, req_e.id, carl.id, "Eine Woche ist etwas knapp. Schaffst du 10 Tage?")
    |> result.map_error(fn(_) { "E: msg 8" }),
  )
  use _ <- result.try(
    sql.create_message(conn, req_e.id, dev_user.id, "Okay, 10 Tage gehen klar. Ich erstelle ein neues Angebot.")
    |> result.map_error(fn(_) { "E: msg 9" }),
  )
  use oe2_start <- result.try(make_ts("2026-07-01T00:00:00Z"))
  use oe2_end <- result.try(make_ts("2026-07-10T00:00:00Z"))
  use returned <- result.try(
    sql.create_offer(conn, req_e.id, dev_user.id, oe2_start, oe2_end)
    |> result.map_error(fn(_) { "E: create_offer 2" }),
  )
  use oe2 <- result.try(
    returned.rows |> list.first |> result.map_error(fn(_) { "E: no offer 2 id" }),
  )
  use _ <- result.try(
    sql.update_rent_request_latest_open(conn, oe2.id, req_e.id)
    |> result.map_error(fn(_) { "E: update_latest_open 2" }),
  )
  use _ <- result.try(
    sql.create_message(conn, req_e.id, carl.id, "Perfekt, 10 Tage sind super! Danke!")
    |> result.map_error(fn(_) { "E: msg 10" }),
  )
  use _ <- result.try(
    sql.create_message(conn, req_e.id, dev_user.id, "Gerne, viel Erfolg mit dem Projekt!")
    |> result.map_error(fn(_) { "E: msg 11" }),
  )

  // ──────────────────────────────────────────────
  // F: Timon → Inserat 1 (Dev) — OPEN, ~6 msgs, no offer yet
  // ──────────────────────────────────────────────
  use returned <- result.try(
    sql.create_rent_request(conn, inserat1_id, timon.id)
    |> result.map_error(fn(_) { "F: create_rent_request" }),
  )
  use req_f <- result.try(
    returned.rows |> list.first |> result.map_error(fn(_) { "F: no id" }),
  )
  use _ <- result.try(
    sql.create_message(conn, req_f.id, timon.id, "Moin, kann ich Inserat 1 ausleihen?")
    |> result.map_error(fn(_) { "F: msg 1" }),
  )
  use _ <- result.try(
    sql.create_message(conn, req_f.id, dev_user.id, "Ja, für wann?")
    |> result.map_error(fn(_) { "F: msg 2" }),
  )
  use _ <- result.try(
    sql.create_message(conn, req_f.id, timon.id, "Nächste Woche Di–Do")
    |> result.map_error(fn(_) { "F: msg 3" }),
  )
  use _ <- result.try(
    sql.create_message(conn, req_f.id, dev_user.id, "Klar, passt!")
    |> result.map_error(fn(_) { "F: msg 4" }),
  )
  use _ <- result.try(
    sql.create_message(conn, req_f.id, timon.id, "Super, danke!")
    |> result.map_error(fn(_) { "F: msg 5" }),
  )

  // ──────────────────────────────────────────────
  // G: Carl → Inserat 2 (Dev) — CLOSED (returned), 1 offer
  // ──────────────────────────────────────────────
  use returned <- result.try(
    sql.create_rent_request(conn, inserat2_id, carl.id)
    |> result.map_error(fn(_) { "G: create_rent_request" }),
  )
  use req_g <- result.try(
    returned.rows |> list.first |> result.map_error(fn(_) { "G: no id" }),
  )
  use _ <- result.try(
    sql.create_message(conn, req_g.id, carl.id, "Hey, kann ich Inserat 2 leihen?")
    |> result.map_error(fn(_) { "G: msg 1" }),
  )
  use _ <- result.try(
    sql.create_message(conn, req_g.id, dev_user.id, "Klar, wann?")
    |> result.map_error(fn(_) { "G: msg 2" }),
  )
  use _ <- result.try(
    sql.create_message(conn, req_g.id, carl.id, "Diesen Freitag, 13. Juni")
    |> result.map_error(fn(_) { "G: msg 3" }),
  )
  use _ <- result.try(
    sql.create_message(conn, req_g.id, dev_user.id, "Passt, holst du es ab?")
    |> result.map_error(fn(_) { "G: msg 4" }),
  )
  use _ <- result.try(
    sql.create_message(conn, req_g.id, carl.id, "Ja, komme gegen 17 Uhr vorbei")
    |> result.map_error(fn(_) { "G: msg 5" }),
  )
  use og_start <- result.try(make_ts("2026-06-13T00:00:00Z"))
  use og_end <- result.try(make_ts("2026-06-13T23:59:00Z"))
  use returned <- result.try(
    sql.create_offer(conn, req_g.id, dev_user.id, og_start, og_end)
    |> result.map_error(fn(_) { "G: create_offer" }),
  )
  use og <- result.try(
    returned.rows |> list.first |> result.map_error(fn(_) { "G: no offer id" }),
  )
  use _ <- result.try(
    sql.update_rent_request_latest_open(conn, og.id, req_g.id)
    |> result.map_error(fn(_) { "G: update_latest_open" }),
  )
  use _ <- result.try(
    sql.accept_offer(conn, og.id)
    |> result.map_error(fn(_) { "G: accept_offer" }),
  )
  use _ <- result.try(
    sql.update_rent_request_latest_accepted(conn, og.id, req_g.id)
    |> result.map_error(fn(_) { "G: update_latest_accepted" }),
  )
  use _ <- result.try(
    sql.create_message(conn, req_g.id, carl.id, "Perfekt, bis Freitag!")
    |> result.map_error(fn(_) { "G: msg 6" }),
  )
  use _ <- result.try(
    sql.update_rent_request_borrow(conn, req_g.id)
    |> result.map_error(fn(_) { "G: confirm_borrow" }),
  )
  use _ <- result.try(
    sql.create_message(conn, req_g.id, dev_user.id, "Hat alles geklappt?")
    |> result.map_error(fn(_) { "G: msg 7" }),
  )
  use _ <- result.try(
    sql.create_message(conn, req_g.id, carl.id, "Ja, danke! Kann es morgen zurückbringen.")
    |> result.map_error(fn(_) { "G: msg 8" }),
  )
  use _ <- result.try(
    sql.update_rent_request_returned(conn, req_g.id)
    |> result.map_error(fn(_) { "G: confirm_return" }),
  )
  use _ <- result.try(
    sql.create_message(conn, req_g.id, dev_user.id, "Alles gut erhalten, danke!")
    |> result.map_error(fn(_) { "G: msg 9" }),
  )

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
