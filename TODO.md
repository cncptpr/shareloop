# TODOs for shareloop

> Before merging into master, remove all checked of TODOs!

This is just a dump of things that might be good to do/fix.
Not all of these TODOs need to be done for the finished project.

## Big Features
> Must do-s
- [ ] Registration
- [ ] Propper profile screen
- [ ] View a list of your own items
- [ ] "Delete" items
- [ ] Search & Filters

## Users & Authentification

- [ ] Send out emails for important stuff
- [ ] Registration
- [ ] Clearing of expired User Sessions

## General

- [ ] Introduce Logging Framework
- [ ] When pressing the selected button in the nav bar, return to that tabs default route.
- [ ] Make the UI Text all German
- [ ] Consider adding Timeouts to network requests

## Styling

- [ ] Apply Styling from [Mock](https://stitch.withgoogle.com/projects/15469593552389345105)

## Location

- [ ] Store the reverse lookup (City + optional Postalcode) in the database for each item (Take either lat/lng or city, and make a lookup for the other one on the server)

## Search & Filter

- [ ] Implement Text Search
- [ ] Implement Filters
  - [ ] Distance
  - [ ] Min Rating

## Items

- [ ] Add all missing fields
  - Kategorie
  - Gebüren

## Notifications
Add more Information, like what chat/about what item and a preview of the messages, etc.

## Message
- [ ] Message Previews (of the last message)


## Ideal Handeling of Location when creating an Item
Don't trust the client: To avoid a mismatch the server should should look up the lat/lng from city/postal_code. This should happen async: Add the item to the db, start a task/put it into a queue to get the lat/lng, and when retrieved update db. So it's fast and resiliant against ratelimits. Maybe doing some caching might also prove valueable.
