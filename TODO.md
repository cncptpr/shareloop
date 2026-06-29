# TODOs for shareloop

> Before merging into master, remove all checked of TODOs!

This is just a dump of things that might be good to do/fix.
Not all of these TODOs need to be done for the finished project.

## Big Features
> Must do-s
- [ ] Theming (Lisa)
- [ ] Availability Calendar
- [ ] Feedback & Rating (Lisa)
- [ ] Registration
- [ ] Propper profile screen (Luca)
- [ ] View a list of your own items
- [ ] "Delete" items (Luca)
- [ ] Document Quickstart

## Users & Authentification

- [ ] Send out emails for important stuff
- [ ] Registration
- [ ] Clearing of expired User Sessions

## General

- [ ] Do not offer the distance file if no location is selected (also ignore on server)
- [ ] Introduce Logging Framework
- [ ] When pressing the selected button in the nav bar, return to that tabs default route.
- [ ] Make the UI Text all German
- [ ] Consider adding Timeouts to network requests

## Missing Error Messages

- [ ] Size limit exeded
- [ ] Photo in image picker selected, on a system without that capability

## Styling

- [ ] Apply Styling from [Mock](https://stitch.withgoogle.com/projects/15469593552389345105)

## Location

- [ ] Where did the GPS selector go?
- [ ] Store the reverse lookup (City + optional Postalcode) in the database for each item (Take either lat/lng or city, and make a lookup for the other one on the server)

## Items

- [ ] Add all missing fields
  - Gebüren

## Notifications
- Add more Information, like what chat/about what item and a preview of the messages, etc.
- Have websocket running in a background task -> notifications also work when app not open

## Message
- [ ] Message Previews (of the last message)


## Ideal Handeling of Location when creating an Item
Don't trust the client: To avoid a mismatch the server should should look up the lat/lng from city/postal_code. This should happen async: Add the item to the db, start a task/put it into a queue to get the lat/lng, and when retrieved update db. So it's fast and resiliant against ratelimits. Maybe doing some caching might also prove valueable.
