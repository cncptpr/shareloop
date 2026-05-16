-module(auth_ffi).
-export([pbkdf2_hmac/4]).

pbkdf2_hmac(Password, Salt, Iterations, KeyLength) ->
    crypto:pbkdf2_hmac(sha256, Password, Salt, Iterations, KeyLength).
