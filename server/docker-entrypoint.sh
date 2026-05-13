#!/bin/sh
set -e
cd /app
exec erl -pa _build/dev/erlang/server/lib/*/ebin -noshell -eval 'server:main()'
