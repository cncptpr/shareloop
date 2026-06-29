import base64
import hashlib
import os

TOKEN_BYTE_LENGTH = 32


def _encode(bits: bytes) -> str:
    return base64.urlsafe_b64encode(bits).rstrip(b"=").decode()


def _decode(s: str) -> bytes:
    return base64.urlsafe_b64decode(s + "==")


def generate_token_and_hash() -> tuple[str, str]:
    token_bytes = os.urandom(TOKEN_BYTE_LENGTH)
    token = _encode(token_bytes)
    hash_value = _encode(hashlib.sha256(token_bytes).digest())
    return token, hash_value


def generate_token_pair() -> tuple[tuple[str, str], tuple[str, str]]:
    access = generate_token_and_hash()
    refresh = generate_token_and_hash()
    return access, refresh


def hash_token(token: str) -> str:
    token_bytes = _decode(token)
    return _encode(hashlib.sha256(token_bytes).digest())
