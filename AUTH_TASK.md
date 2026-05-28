Your job is to implement auth for this app.

No framework avaiable (sadly). Implement youself.
Normal token auth.
Email+Password
Mabybe Later: WebAuthn / TOTP

Read the README to get an understanding of the project

Do only one phase at a time.
Give me a short plan for each phase.

## Rules:
- No communication between app and server outside of openapi spec
- No custom encoders/decoder for api only use generated
- Keep it secure, no sketch stuff

## Phase 0 - What?
Your quick summary of what you understand under token auth. 

## Phase 1 - DB
- Make the db migrations
- Make sql queries
- seeding shoud create user 'dev' with password 'dev'

## Phase 2 - Cli
Create a little cli in test/server/cli.gleam (runnable via gleam -m server/auth) (in test as to use only require dev dependencies)
- no real error handeling, just a quick print and exit
- Use DATABASE_URL with the local as a default
- `help` 
- `users create <email>` should ask for password and create user
- `users list` should list all users
- `users sessions` should show active sessions/tokens with their timeout
- `users login <email>` should run a "login" (same for logout)
- more commands for running actions & debugging, whenever you expand the functionallity

Actions here should use the same functions later used for auth.
Everything related to auth goes in server/auth.gleam or server/auth/*.gleam.

## Phase 3 - OpenAPI & Server
Add the OpenAPI specification.
Implment Server
Make the Mobile APP login with 'dev' 'dev' automaticlly (hardcode).
Mobile APP should display current state + token on profile screen (debug)

## Phase 4 - App
Add a propper login/Logout screen.
Make the APP do refresh and everything.

## Phase 5 - Add User to Items
Make the "author" in the dabase an actual user.

## Phase 6 (Optional) - EMail
Actually send out emails.
Add a dev docker smpt server to the compose, which will be defaulted to.
Allow for setting up smpt via env vars, to allow connecting to e.g. gmail.

Emails are only for Signup / Password reset.
