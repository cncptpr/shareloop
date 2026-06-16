# Rules for coding agents

1. Do not edit generated code. Edit it's source and re-generate.

2. Fields (DB and API) are either explicitly optional or a real required value. Never abuse empty strings, empty lists, `0`, `-1`, or similar sentinels as defaults to work around a required field.
