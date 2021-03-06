# Message Deletion Behavior

## Deleting Multiple Messages

## Delete Confirmation

Some alternatives include:

* ~~DA1 - Always confirm every message~~
  * This may be too restrictive when people people sometimes need a bulk delete option.
  
* ~~DA2 - Confirm every message, only if immediate delete is configured in the settings.~~
  * A concern with this alternative is this could be complicated
    and confusing behavior.

* **DA3** (DONE) - Provide a passcode screen to increase the security around the app, reducing the probability somebody's messages will be deleted by a family member, etc..

* **DA4** (DONE) - Give the user a "Delete All" Button
  * Before committing to the delete, warn them 
    this cannot be undone.

* **DA5** (DONE) - Don't make immediate deletion the default. This will give users a 30 day window to undo any settings.

* ~~DA6 - Prompt for the passcode if the user want to change the deletion settings.~~
  * A passcode is already enabled by default to just launch the app (or go back to the app). This would be extraneous. 

* **DA7** (DONE) - After the deletion is complete, show a popup window
   to indicate what was done, how many messages were deleted,
   etc. This will keep the user "in control" of what is 
   happening.

* ~~DA8 - Require confirmation of every message if a "select all" option is done.~~
  * This behavior would be confusing and unconventional, since it could change based upon how many messages are deleted.

* DA9 - Provide some settings to tailor how much confirmation is done: e.g.:
  * Maximum number of bulk deletions.

* **DA10** - Allow "incremental bulk deletion", whereby a "page full" of messages can be 
  reviewed and deleted at the same time.
  * For performance reasons, it also makes sense to only show a fixed number of messages
    in the list (e.g., 100).
  * With this option, a "select all" will only select up to the number of messages shown.

* **DA11** (DONE) - While stepping through and confirming each messages's deletion, provide a "page number" for how many confirmation have been done (e.g. "1 of 5"). This will keep the user "in control" to confirm how many messages have been deleted and are remaining (and perhaps not just hit the "Delete All" button).

* **DA12** - If the user deletes a large number of messages, get a second confirmation to proceed.

* **DA13** (DONE) - In the delete confirmation view, provide a description of the deletion behavior, so the 
  user has feedback on what is about to occur.


