#!/usr/bin/env python3
import os
import sys
import uuid as uuid_mod
from datetime import datetime

import psycopg2

from src.auth.password import hash_password

DATABASE_URL = os.environ.get(
    "DATABASE_URL",
    "postgresql+asyncpg://shareloop:shareloop@localhost:5432/shareloop",
).replace("postgresql+asyncpg://", "postgresql://", 1)
UPLOADS_DIR = os.environ.get("UPLOADS_DIR", "./uploads")
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))


def make_ts(s: str) -> datetime:
    return datetime.fromisoformat(s.replace("Z", "+00:00"))


def extract_filename(path: str) -> str:
    return os.path.basename(path)


def detect_ext_and_mime(filename: str):
    parts = filename.rsplit(".", 1)
    ext = parts[-1].lower() if len(parts) > 1 else ""
    mapping = {"jpg": "jpg", "jpeg": "jpg", "png": "png", "gif": "gif", "webp": "webp"}
    ext = mapping.get(ext, "jpg")
    mime = {"png": "image/png", "gif": "image/gif", "webp": "image/webp"}.get(ext, "image/jpeg")
    return ext, mime


def clear_all(conn):
    with conn.cursor() as cur:
        cur.execute("DELETE FROM items")
        cur.execute("DELETE FROM profiles")
        cur.execute("DELETE FROM users")
    if os.path.isdir(UPLOADS_DIR):
        for name in os.listdir(UPLOADS_DIR):
            path = os.path.join(UPLOADS_DIR, name)
            if os.path.isfile(path):
                os.remove(path)


def create_user_with_profile(conn, email, password, name, bio, rating):
    pw_hash = hash_password(password)
    with conn.cursor() as cur:
        cur.execute(
            "INSERT INTO users (email, password_hash) VALUES (%s, %s) RETURNING id",
            (email, pw_hash),
        )
        user_id = cur.fetchone()[0]
        cur.execute(
            "INSERT INTO profiles (id, name, bio, rating) VALUES (%s, %s, %s, %s)",
            (user_id, name, bio, rating),
        )
    return {"id": user_id, "email": email}


def insert_item(conn, title, description, author_id, score, lng, lat, city, postal_code, category):
    with conn.cursor() as cur:
        cur.execute(
            "INSERT INTO items (title, description, author_id, score, location, city, postal_code, category) "
            "VALUES (%s, %s, %s, %s, st_setsrid(st_makepoint(%s, %s), 4326)::geography, %s, %s, %s) "
            "RETURNING id",
            (title, description, author_id, score, lng, lat, city, postal_code, category),
        )
        return cur.fetchone()[0]


def seed_image(conn, item_id, sort_order, source_path):
    src = os.path.join(SCRIPT_DIR, source_path)
    filename = extract_filename(src)
    with open(src, "rb") as f:
        bytes_data = f.read()
    ext, mime = detect_ext_and_mime(filename)
    image_uuid = uuid_mod.uuid4()
    dest_name = f"{image_uuid}.{ext}"
    dest_path = os.path.join(UPLOADS_DIR, dest_name)
    os.makedirs(UPLOADS_DIR, exist_ok=True)
    with open(dest_path, "wb") as f:
        f.write(bytes_data)
    print(f"  Wrote {dest_path}")
    with conn.cursor() as cur:
        cur.execute(
            "INSERT INTO item_images (id, item_id, original_name, mime_type, sort_order) "
            "VALUES (%s, %s, %s, %s, %s) RETURNING id",
            (str(image_uuid), item_id, filename, mime, sort_order),
        )
        cur.fetchone()
    print(f"  Seeded image {filename} for item {item_id} at sort_order {sort_order}")


def create_rent_request(conn, item_id, requester_id):
    with conn.cursor() as cur:
        cur.execute(
            "INSERT INTO rent_requests (item_id, requester_id) VALUES (%s, %s) RETURNING id",
            (item_id, requester_id),
        )
        return cur.fetchone()[0]


def create_message(conn, rent_request_id, author_id, content):
    with conn.cursor() as cur:
        cur.execute(
            "INSERT INTO messages (rent_request_id, author_id, content) VALUES (%s, %s, %s) RETURNING id",
            (rent_request_id, author_id, content),
        )
        return cur.fetchone()[0]


def create_offer(conn, rent_request_id, sender_id, start_date, end_date):
    with conn.cursor() as cur:
        cur.execute(
            "INSERT INTO rent_offers (rent_request_id, sender_id, start_date, end_date) "
            "VALUES (%s, %s, %s, %s) RETURNING id",
            (rent_request_id, sender_id, start_date, end_date),
        )
        return cur.fetchone()[0]


def accept_offer(conn, offer_id):
    with conn.cursor() as cur:
        cur.execute(
            "UPDATE rent_offers SET accepted_at = now(), updated_at = now() "
            "WHERE id = %s AND accepted_at IS NULL RETURNING id",
            (offer_id,),
        )
        return cur.fetchone()[0]


def update_rent_request_latest_open(conn, offer_id, rent_request_id):
    with conn.cursor() as cur:
        cur.execute(
            "UPDATE rent_requests SET latest_open_offer_id = %s, updated_at = now() WHERE id = %s",
            (offer_id, rent_request_id),
        )


def update_rent_request_latest_accepted(conn, offer_id, rent_request_id):
    with conn.cursor() as cur:
        cur.execute(
            "UPDATE rent_requests SET latest_accepted_offer_id = %s, "
            "latest_open_offer_id = NULL, updated_at = now() WHERE id = %s",
            (offer_id, rent_request_id),
        )


def update_rent_request_borrow(conn, rent_request_id):
    with conn.cursor() as cur:
        cur.execute(
            "UPDATE rent_requests SET borrow_confirmed_at = now(), updated_at = now() "
            "WHERE id = %s AND borrow_confirmed_at IS NULL",
            (rent_request_id,),
        )


def update_rent_request_returned(conn, rent_request_id):
    with conn.cursor() as cur:
        cur.execute(
            "UPDATE rent_requests SET returned_at = now(), updated_at = now() "
            "WHERE id = %s AND returned_at IS NULL",
            (rent_request_id,),
        )


def mark_rent_request_read(conn, rent_request_id, user_id):
    with conn.cursor() as cur:
        cur.execute(
            """UPDATE rent_requests
SET
  requester_read_at = CASE WHEN %s = requester_id THEN NOW() ELSE requester_read_at END,
  owner_read_at = CASE WHEN %s = (SELECT author_id FROM items WHERE id = rent_requests.item_id) THEN NOW() ELSE owner_read_at END
WHERE id = %s AND (
  %s = requester_id OR %s = (SELECT author_id FROM items WHERE id = rent_requests.item_id)
)""",
            (user_id, user_id, rent_request_id, user_id, user_id),
        )


def seed_rent_data(conn, dev_user, lisa, timon, luca, spezi_id, auto_id, fahrrad_id, bohrmaschine_id, internat_id, inserat1_id, inserat2_id):
    # A: Lisa -> Spezi (Timon) -- OPEN, 1 offer
    req_a = create_rent_request(conn, spezi_id, lisa["id"])
    create_message(conn, req_a, lisa["id"], "Hey, kann ich die Spezi fürs Wochenende ausleihen?")
    create_message(conn, req_a, timon["id"], "Klar, wann brauchst du sie?")
    create_message(conn, req_a, lisa["id"], "Von Freitag bis Sonntag, 20.–22. Juni")
    oa_id = create_offer(conn, req_a, timon["id"], make_ts("2026-06-20T00:00:00Z"), make_ts("2026-06-22T00:00:00Z"))
    update_rent_request_latest_open(conn, oa_id, req_a)
    mark_rent_request_read(conn, req_a, lisa["id"])
    mark_rent_request_read(conn, req_a, timon["id"])

    # B: Dev -> Auto (Lisa) -- CLOSED (returned), 1 offer
    req_b = create_rent_request(conn, auto_id, dev_user["id"])
    create_message(conn, req_b, dev_user["id"], "Moin, kann ich das Auto für den Umzug am 1. Juli leihen?")
    create_message(conn, req_b, lisa["id"], "Klar, ein Tag reicht?")
    create_message(conn, req_b, dev_user["id"], "Ja, ein Tag sollte reichen!")
    ob_id = create_offer(conn, req_b, lisa["id"], make_ts("2026-07-01T00:00:00Z"), make_ts("2026-07-01T00:00:00Z"))
    update_rent_request_latest_open(conn, ob_id, req_b)
    accept_offer(conn, ob_id)
    update_rent_request_latest_accepted(conn, ob_id, req_b)
    create_message(conn, req_b, dev_user["id"], "Danke, hat alles geklappt!")
    update_rent_request_borrow(conn, req_b)
    create_message(conn, req_b, lisa["id"], "Gerne, viel Erfolg beim Umzug!")
    update_rent_request_returned(conn, req_b)
    create_message(conn, req_b, dev_user["id"], "Alles gut zurückgegeben, danke!")
    mark_rent_request_read(conn, req_b, dev_user["id"])
    mark_rent_request_read(conn, req_b, lisa["id"])

    # C: Dev -> Spezi (Timon) -- OPEN, ~11 msgs, 2 offers
    req_c = create_rent_request(conn, spezi_id, dev_user["id"])
    create_message(conn, req_c, dev_user["id"], "Hey, kann ich die Spezi auch mal ausleihen?")
    create_message(conn, req_c, timon["id"], "Klar, wann hättest du Zeit?")
    create_message(conn, req_c, dev_user["id"], "Am besten nächstes Wochenende")
    create_message(conn, req_c, timon["id"], "Samstag oder Sonntag?")
    create_message(conn, req_c, dev_user["id"], "Eher Sonntag, 22. Juni")
    oc1_id = create_offer(conn, req_c, timon["id"], make_ts("2026-06-21T00:00:00Z"), make_ts("2026-06-22T00:00:00Z"))
    update_rent_request_latest_open(conn, oc1_id, req_c)
    create_message(conn, req_c, dev_user["id"], "Hmm, Samstag geht auch, aber erst abends. Geht das klar?")
    create_message(conn, req_c, timon["id"], "Klar, kein Problem!")
    create_message(conn, req_c, dev_user["id"], "Und kann ich sie vielleicht schon Freitagabend holen?")
    create_message(conn, req_c, timon["id"], "Ja, das geht klar. Ich schick dir ein neues Angebot.")
    oc2_id = create_offer(conn, req_c, timon["id"], make_ts("2026-06-19T18:00:00Z"), make_ts("2026-06-22T20:00:00Z"))
    update_rent_request_latest_open(conn, oc2_id, req_c)
    create_message(conn, req_c, dev_user["id"], "Perfekt, das passt! Danke dir!")
    create_message(conn, req_c, timon["id"], "Gerne, bis Freitag!")
    mark_rent_request_read(conn, req_c, timon["id"])

    # D: Dev -> Fahrrad (Lisa) -- OPEN, ~6 msgs, no offer
    req_d = create_rent_request(conn, fahrrad_id, dev_user["id"])
    create_message(conn, req_d, dev_user["id"], "Hey, ist das Fahrrad noch frei?")
    create_message(conn, req_d, lisa["id"], "Ja, wann willst du es abholen?")
    create_message(conn, req_d, dev_user["id"], "Am Samstag vielleicht?")
    create_message(conn, req_d, lisa["id"], "Samstag Nachmittag geht klar")
    create_message(conn, req_d, dev_user["id"], "Super, sagen wir 15 Uhr?")
    create_message(conn, req_d, lisa["id"], "Passt, bis Samstag!")
    mark_rent_request_read(conn, req_d, dev_user["id"])
    mark_rent_request_read(conn, req_d, lisa["id"])

    # E: Lisa -> Internat (Dev) -- OPEN, ~11 msgs, 2 offers
    req_e = create_rent_request(conn, internat_id, lisa["id"])
    create_message(conn, req_e, lisa["id"], "Hey, ich würde gern das Internat für ein Projekt nutzen")
    create_message(conn, req_e, dev_user["id"], "Cool, für wie lange?")
    create_message(conn, req_e, lisa["id"], "Zwei Wochen vielleicht?")
    create_message(conn, req_e, dev_user["id"], "Wann genau?")
    create_message(conn, req_e, lisa["id"], "Anfang Juli, 1. bis 14.")
    create_message(conn, req_e, dev_user["id"], "Hmm, zwei Wochen ist schon lang. Würde eine Woche reichen?")
    create_message(conn, req_e, lisa["id"], "Können wir machen, eine Woche ist auch ok")
    oe1_id = create_offer(conn, req_e, dev_user["id"], make_ts("2026-07-01T00:00:00Z"), make_ts("2026-07-07T00:00:00Z"))
    update_rent_request_latest_open(conn, oe1_id, req_e)
    create_message(conn, req_e, lisa["id"], "Eine Woche ist etwas knapp. Schaffst du 10 Tage?")
    create_message(conn, req_e, dev_user["id"], "Okay, 10 Tage gehen klar. Ich erstelle ein neues Angebot.")
    oe2_id = create_offer(conn, req_e, dev_user["id"], make_ts("2026-07-01T00:00:00Z"), make_ts("2026-07-10T00:00:00Z"))
    update_rent_request_latest_open(conn, oe2_id, req_e)
    create_message(conn, req_e, lisa["id"], "Perfekt, 10 Tage sind super! Danke!")
    create_message(conn, req_e, dev_user["id"], "Gerne, viel Erfolg mit dem Projekt!")
    mark_rent_request_read(conn, req_e, lisa["id"])

    # F: Timon -> Inserat 1 (Dev) -- OPEN, ~6 msgs, no offer
    req_f = create_rent_request(conn, inserat1_id, timon["id"])
    create_message(conn, req_f, timon["id"], "Moin, kann ich Inserat 1 ausleihen?")
    create_message(conn, req_f, dev_user["id"], "Ja, für wann?")
    create_message(conn, req_f, timon["id"], "Nächste Woche Di–Do")
    create_message(conn, req_f, dev_user["id"], "Klar, passt!")
    create_message(conn, req_f, timon["id"], "Super, danke!")
    mark_rent_request_read(conn, req_f, dev_user["id"])
    mark_rent_request_read(conn, req_f, timon["id"])

    # G: Lisa -> Inserat 2 (Dev) -- CLOSED (returned), 1 offer
    req_g = create_rent_request(conn, inserat2_id, lisa["id"])
    create_message(conn, req_g, lisa["id"], "Hey, kann ich Inserat 2 leihen?")
    create_message(conn, req_g, dev_user["id"], "Klar, wann?")
    create_message(conn, req_g, lisa["id"], "Diesen Freitag, 13. Juni")
    create_message(conn, req_g, dev_user["id"], "Passt, holst du es ab?")
    create_message(conn, req_g, lisa["id"], "Ja, komme gegen 17 Uhr vorbei")
    og_id = create_offer(conn, req_g, dev_user["id"], make_ts("2026-06-13T00:00:00Z"), make_ts("2026-06-13T23:59:00Z"))
    update_rent_request_latest_open(conn, og_id, req_g)
    accept_offer(conn, og_id)
    update_rent_request_latest_accepted(conn, og_id, req_g)
    create_message(conn, req_g, lisa["id"], "Perfekt, bis Freitag!")
    update_rent_request_borrow(conn, req_g)
    create_message(conn, req_g, dev_user["id"], "Hat alles geklappt?")
    create_message(conn, req_g, lisa["id"], "Ja, danke! Kann es morgen zurückbringen.")
    update_rent_request_returned(conn, req_g)
    create_message(conn, req_g, dev_user["id"], "Alles gut erhalten, danke!")
    mark_rent_request_read(conn, req_g, dev_user["id"])
    mark_rent_request_read(conn, req_g, lisa["id"])

    # H: Dev -> Bohrmaschine (Luca) -- OPEN, ~4 msgs, no offer
    req_h = create_rent_request(conn, bohrmaschine_id, dev_user["id"])
    create_message(conn, req_h, dev_user["id"], "Hey, kann ich die Bohrmaschine fürs Wochenende ausleihen?")
    create_message(conn, req_h, luca["id"], "Klar, für welches Projekt?")
    create_message(conn, req_h, dev_user["id"], "Ich will ein Regal im Keller aufbauen, brauche sie nur Samstag.")
    create_message(conn, req_h, luca["id"], "Klingt gut, hol sie dir einfach ab!")
    mark_rent_request_read(conn, req_h, dev_user["id"])
    mark_rent_request_read(conn, req_h, luca["id"])


def run():
    conn = psycopg2.connect(DATABASE_URL)
    conn.autocommit = True

    print("Clearing existing data...")
    clear_all(conn)

    print("Seeding users...")
    dev_user = create_user_with_profile(conn, "dev@example.com", "dev", "Dev", "Dev user", 4.9)
    lisa = create_user_with_profile(conn, "lisa@example.com", "lisa", "Lisa", "Car seller", 4.3)
    luca = create_user_with_profile(conn, "luca@example.com", "luca", "Luca", "Outdoor enthusiast", 4.5)
    timon = create_user_with_profile(conn, "timon@example.com", "timon", "Timon", "Spezi enthusiast", 5.0)

    print("Seeding items...")
    inserat1_id = insert_item(conn, "Inserat 1", "Ganz tolles Inserat", dev_user["id"], 4.9, 13.405, 52.52, "Berlin", "10115", "Sonstiges")
    internat_id = insert_item(conn, "Internat", "Ganz tolles Internat", dev_user["id"], 4.9, 11.582, 48.1351, "München", "80331", "Sonstiges")
    inserat2_id = insert_item(conn, "Inserat 2", "Papput", dev_user["id"], 4.9, 9.9937, 53.5511, "Hamburg", "20095", "Sonstiges")
    auto_id = insert_item(conn, "Auto", "Kann fahren", lisa["id"], 4.3, 6.9603, 50.9375, "Köln", "50667", "Sport")
    spezi_id = insert_item(conn, "Spezi", "Bitte voll zurueck", timon["id"], 5.0, 8.6821, 50.1109, "Frankfurt am Main", "60311", "Sonstiges")
    fahrrad_id = insert_item(conn, "Fahrrad", "Trekkingrad, 28 Zoll, 21 Gänge", lisa["id"], 4.1, 6.9603, 50.9375, "Köln", "50667", "Sport")
    bohrmaschine_id = insert_item(conn, "Bohrmaschine", "Professionelle Bohrmaschine für Heimwerker", luca["id"], 4.5, 9.18, 48.78, "Stuttgart", "70173", "Werkzeug")
    zelt_id = insert_item(conn, "Zelt", "Geräumiges 4-Personen Zelt für Campingausflüge", luca["id"], 4.2, 9.18, 48.78, "Stuttgart", "70173", "Sport")

    print("Seeding images...")
    seed_image(conn, spezi_id, 0, "seeding/images/paulaner-spezi.jpg")
    seed_image(conn, spezi_id, 1, "seeding/images/wallhaven_4576l3.jpg")
    seed_image(conn, spezi_id, 2, "seeding/images/logo_v1.jpeg")
    seed_image(conn, spezi_id, 3, "seeding/images/wallhaven_weq5jq.jpg")
    seed_image(conn, auto_id, 0, "seeding/images/auto.jpg")
    seed_image(conn, auto_id, 1, "seeding/images/IMG_0642.png")
    seed_image(conn, auto_id, 2, "seeding/images/wallhaven_477mrv.jpg")
    seed_image(conn, auto_id, 3, "seeding/images/wallhaven_nkmxk6.jpg")
    seed_image(conn, inserat1_id, 0, "seeding/images/wallhaven_4gqvxd.jpg")
    seed_image(conn, inserat1_id, 1, "seeding/images/logo_v1.jpeg")
    seed_image(conn, internat_id, 0, "seeding/images/wallhaven_e7651w.jpg")
    seed_image(conn, inserat2_id, 0, "seeding/images/wallhaven_mdgzx9.jpg")
    seed_image(conn, fahrrad_id, 0, "seeding/images/bike.png")
    seed_image(conn, bohrmaschine_id, 0, "seeding/images/wallhaven_477mrv.jpg")
    seed_image(conn, bohrmaschine_id, 1, "seeding/images/wallhaven_nkmxk6.jpg")
    seed_image(conn, zelt_id, 0, "seeding/images/wallhaven_e7651w.jpg")
    seed_image(conn, zelt_id, 1, "seeding/images/wallhaven_4gqvxd.jpg")

    print("Seeding rent requests...")
    seed_rent_data(
        conn, dev_user, lisa, timon, luca,
        spezi_id, auto_id, fahrrad_id, bohrmaschine_id,
        internat_id, inserat1_id, inserat2_id,
    )

    print("Seed completed successfully")


def main():
    try:
        run()
    except Exception as e:
        print(f"Seed failed: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
