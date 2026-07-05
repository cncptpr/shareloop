import os
import re
from typing import Any

import yaml

_REF_RE = re.compile(r"^ref\(([^)]+)\)$")


def is_ref(value: Any) -> bool:
    return isinstance(value, str) and bool(_REF_RE.match(value))


def get_ref_id(value: str) -> str:
    m = _REF_RE.match(value)
    if not m:
        raise ValueError(f"Ungültiger Ref: {value}")
    return m.group(1)


def load_and_validate(seeding_dir: str) -> dict[str, Any] | None:
    yaml_path = os.path.join(seeding_dir, "data.yaml")
    if not os.path.isfile(yaml_path):
        return None

    try:
        with open(yaml_path) as f:
            data = yaml.safe_load(f)
    except Exception:
        return None

    if not isinstance(data, dict):
        return None

    users = data.get("users", [])
    if not isinstance(users, list) or not users:
        return None

    user_ids: set[str] = set()
    for u in users:
        if not isinstance(u, dict) or "id" not in u or "email" not in u:
            return None
        if u["id"] in user_ids:
            return None
        user_ids.add(u["id"])

    items = data.get("items", [])
    if not isinstance(items, list) or not items:
        return None

    item_ids: set[str] = set()
    for item in items:
        if not isinstance(item, dict) or "id" not in item:
            return None
        if item["id"] in item_ids:
            return None
        item_ids.add(item["id"])

        author = item.get("author", "")
        if not is_ref(author) or get_ref_id(author) not in user_ids:
            return None

        for img in item.get("images", []):
            if not isinstance(img, dict) or "path" not in img:
                return None
            img_path = os.path.join(seeding_dir, img["path"])
            if not os.path.isfile(img_path):
                return None

    requests = data.get("rent_requests", [])
    for req in requests:
        if not isinstance(req, dict) or "id" not in req:
            return None

        item_ref = req.get("item", "")
        requester_ref = req.get("requester", "")
        if not is_ref(item_ref) or get_ref_id(item_ref) not in item_ids:
            return None
        if not is_ref(requester_ref) or get_ref_id(requester_ref) not in user_ids:
            return None

        for msg in req.get("messages", []):
            if not isinstance(msg, dict) or "author" not in msg:
                return None
            if not is_ref(msg["author"]) or get_ref_id(msg["author"]) not in user_ids:
                return None

        for offer in req.get("offers", []):
            if not isinstance(offer, dict) or "sender" not in offer:
                return None
            if not is_ref(offer["sender"]) or get_ref_id(offer["sender"]) not in user_ids:
                return None

        for read_ref in req.get("mark_read", []):
            if not is_ref(read_ref) or get_ref_id(read_ref) not in user_ids:
                return None

        for ur in req.get("user_ratings", []):
            if not isinstance(ur, dict):
                return None
            if not is_ref(ur.get("reviewer", "")) or get_ref_id(ur["reviewer"]) not in user_ids:
                return None
            for field in ("friendliness", "punctuality", "reliability"):
                if not isinstance(ur.get(field), int) or not 1 <= ur[field] <= 5:
                    return None
            for field in ("communication", "carefulHandling"):
                val = ur.get(field)
                if val is not None and (not isinstance(val, int) or not 1 <= val <= 5):
                    return None

        for ir in req.get("item_ratings", []):
            if not isinstance(ir, dict):
                return None
            if not is_ref(ir.get("reviewer", "")) or get_ref_id(ir["reviewer"]) not in user_ids:
                return None
            for field in ("condition", "cleanliness"):
                if not isinstance(ir.get(field), int) or not 1 <= ir[field] <= 5:
                    return None

    return data
