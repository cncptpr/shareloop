_seeding_available: bool = False


def set_seeding_available(available: bool) -> None:
    global _seeding_available
    _seeding_available = available


def is_seeding_available() -> bool:
    return _seeding_available
