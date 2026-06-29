# Renting workflow
Your job is to program the renting workflow for the app.

After the inital scan and plan, you will run autonoumus.
Perform no action that would interrupt the execution.

Don't just hack something in, make an effort to do a good job.
Every tool you need should be avaiable via mise. Use the tasks.

Read the docs and README.md

## Generell Workflow
1. In the screen of item of interest, click the a send request button.
2. A chat will open up, in which you can contact the item owner. You can ask questions and discuss the details there.
3. If (you think) you came to a agreement, you or the item owner can make an offer.
  - This contains a specific time frame in which you want to borrow the item.
  - Is visually shown kind of as a message in chat.
4. The other party can accept, or make different offer.
  - Only the last open offer can be accepted.
  - Only the last accepted offer is valid.
  - This is also how edits work: just a new offer.
5. After the start date happens, the owner is asked if the borrow happend. (Important for avaiablitiy calendar)
6. At any time the owner can say, that the item is back. He will be asked for it, only at the end day or after.

## Data stored
Try to keep fields required, but prefer nullable over modeling in an empty String or similar.
Try to not use boolean fields. For example for accepted, use a nullable date as the type.
Something being nullable should have a real meaning for the modeled data.

Generally store a created_at, and for everything that can update an updated at.

- Rent Requests
  - stores who is interested in which item
  - tracks general progress of the workflow
  - Store the id of the lastest accepted Request (for quick access for avaiablitiy calender)
  - Store if there is one, of the lastest open Request after the lastest accepted one

- Messages
  - The messages written
  - has author as user id
  - Rent Request used as the "Chat"

- Rent Offers
  - The offers send

## API
Use the openapi spec and code gen to help you.

## UI
The button on the item screen should open the request/chat screen.
If no open request exisits, the request is created in the background, on first message send.
If an open request exisits, the request/chat screen is loaded with that request and the chat hintory.
A request ist closed, by the owner after return.

All request/chat should be accessable through the message screen. Closed ones through a toggle.

Multiple open request per item are allowed, but should not be a focus of the ui.

## Notification & Polling
Ignore at first. Just make reciving messages while in the app or in the chat possible.

If everything else is done:
I want Mobile Push-Notifications for new messages/requests.
Choose a common default strategy for this.
It should be fast (for demo purposes).



