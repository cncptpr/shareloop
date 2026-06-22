import base64
import hashlib
import os

ITERATIONS = 600_000
SALT_SIZE = 16
KEY_LENGTH = 32
ALGORITHM_ID = "pbkdf2-sha256"


def _encode(bits: bytes) -> str:
    return base64.urlsafe_b64encode(bits).rstrip(b"=").decode()


def hash_password(plaintext: str) -> str:
    salt = os.urandom(SALT_SIZE)
    dk = hashlib.pbkdf2_hmac("sha256", plaintext.encode(), salt, ITERATIONS, dklen=KEY_LENGTH)
    salt_b64 = _encode(salt)
    hash_b64 = _encode(dk)
    return f"${ALGORITHM_ID}${ITERATIONS}${salt_b64}${hash_b64}"


def verify_password(plaintext: str, stored: str) -> bool:
    parts = stored.split("$")
    if len(parts) != 5 or parts[1] != ALGORITHM_ID:
        return False
    iter_str = parts[2]
    salt_encoded = parts[3]
    hash_encoded = parts[4]
    try:
        salt = base64.urlsafe_b64decode(salt_encoded + "==")
        expected_hash = base64.urlsafe_b64decode(hash_encoded + "==")
        actual_iterations = int(iter_str)
    except Exception:
        return False
    dk = hashlib.pbkdf2_hmac("sha256", plaintext.encode(), salt, actual_iterations, dklen=KEY_LENGTH)
    return hmac_compare(dk, expected_hash)


def hmac_compare(a: bytes, b: bytes) -> bool:
    if len(a) != len(b):
        return False
    result = 0
    for x, y in zip(a, b, strict=True):
        result |= x ^ y
    return result == 0
