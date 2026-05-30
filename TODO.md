# TODOs for shareloop

> Before mergin into master, remove all checked of TODOs

## Users & Authentification

- [ ] Add Users as a concept
- [ ] Implement Auth into the API

## General

- [ ] When pressing the selected button in the nav bar, return to that tabs default route.
- [ ] Allow for 'Pulling down to reload' even if featued Items list is empty
- [ ] Make the UI Text all German

## Styling

- [ ] Apply Styling from [Mock](https://stitch.withgoogle.com/projects/15469593552389345105)

## Location

- [ ] Store selected locations, so users can select their last locations without even needing to send request to the API
  - Make the Search result look less like a dropdown, and use more of space below
  - Instead of showing nothing by default/after pressing "x", show the stored locations
- [ ] Store the reverse lookup (City + optional Postalcode) in the database for each item (Take either lat/lng or city, and make a lookup for the other one on the server)
- [ ] Show the City on the ItemCards next to the Distance or just the City alone, if Distance is N/A
- [ ] Show no decimal digits for the Distance
- [ ] When graying out the "Aktuelle Position verwenden" replace text with "Aktuelle Postition nicht verfügbar"

## Search & Filter

- [ ] Implement Text Search
- [ ] Implement Filters
  - [ ] Distance
  - [ ] Min Rating

## Items

- [ ] Allow for creating Items
- [ ] Items Screen

### Handeling of Location when creating an Item
Don't trust the client: To avoid a mismatch the server should should look up the city/postal_code from lat/lng. This should happen async: Add the item to the db, start a task/put it into a queue to get the city/code, and when retrieved update db. So it's fast and resiliant against ratelimits. Maybe doing some caching might also prove valueable. Also the lat/lng should be generalized, as to not store the exact location of the user.
