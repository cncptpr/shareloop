-module(auth_ffi).
-export([pbkdf2_hmac/4, read_line/1]).

pbkdf2_hmac(Password, Salt, Iterations, KeyLength) ->
    crypto:pbkdf2_hmac(sha256, Password, Salt, Iterations, KeyLength).

read_line(Prompt) ->
    case io:get_line(Prompt) of
        eof -> <<>>;
        {error, _} -> <<>>;
        Data -> unicode:characters_to_binary(Data)
    end.
