# Manual Testing

## Message Deletion

### DEL-01 Message Delete

Test Procedure:

1. Setup preferences to first move the message to a delete folder, 
   then immediately/permanently delete from there.
2. Set a break-point in the code just before the code which 
   deletes messages which have been moved (in MailDeleteOperation.m,
   on or about line 281).
2. Delete a single message, M0
3. In a separate email client, move a message, M1 to the delete
   folder.
4. Continue execution in the debugger.

Post-condition:

1. M0 should be permanently deleted, but M1 should not.

### DEL-02 Reset Filter While Deleting

Since the Gmail IMAP server takes longer than to move than delete messages, using a test account with Google Apps is advisable. Since the message deletion occurs in a separate thread, both reseting the filter and the message deletion will change the CoreData database; this test will ensure the multi-threaded deletion code and merge logic functions properly.

Test Procedure:

1. In a test account, narrow the filter to a subset of messages. Ideally, there should be >= 100 messages selected.
2. Select all the messages and start the deletion. The "Reset Filter" button should be displayed in the message list view, since no more messages match the filter.
3. Reset the filter while the messages are being deleted.

Post-conditions:

1. All the messages should be displayed after reseting the filter.
2. The message deletion should complete without errors. 

## General

### GEN-T01: Disable then Re-Enable Passcode

Test Procedure:

1. Go to the settings view
2. Disable the passcode (i.e., turn if OFF
3. Stop the application
4. Restart the application
5. Upon re-start, there should be no prompting for the passcode.
5. Go the settings view again
6. Re-Enable the passcode, entering a different one than before
7. Restart the application
8. Upon, re-start, the app should prompt for the new passcode.

### GEN-T02: View Message Details

Test Procedure:

1. Pick a message fromt he message list.
2. Tap on the disclosure button to view the message details

Post-conditions:

1. The message header and body associated with the message is shown.

## Account Creation and Deletion

### ACCT-T01: Account Delete

1. Delete an existing account from the settings view.
2. The account should not longer appear in the account list.

### ACCT-T02 Multiple Accounts

1. After creating an initial account, create a second one.
2. Without changing the current account to the new one, go
   back to the message list view. No errors should occurs.
3. Go back and select the new account. The account should
   initially synchronize without errors.
   
## Filters
  
The automated test suite has good coverage of the filter logic. The tests
below are designed to test the UI functionality related to filters.

### FILTER-T01: Create a Filter from the Popup Menu

1. Load the app with the integration test mail server.
2. Select a message from the message list.
3. From the narrow filter popup menu (RHS), narrow
   the filter to the selcted message.
4. Save the filter from the popup menu.

After completing this test, the new filter should appear
in the load filter menu. If the filter is reset, then reloaded
from the load filter menu, the results should reappear in the message
list.

### FILTER-T01: Create a Filter from the Saved Filter List

Test Procedure:

1. Go to the list of saved filters in the setttings view.
2. Tap on the Edit then '+' buttons to create a new filter
3. Before setting the name, change the sub-criteria for sender
   address.
4. Go back to the main form and enter a name.
5. Tap on the save button.

Post-conditions:

1. The filter should save without creating an error.
2. In the main message list, the filter should be visible in the
   menu.

## iCloud (@me) Integration

### ICLOUD-T01: Account Creation

1. Add an account from the settings view.
2. The first screen should prompt for an account name, email address and password.
3. Hit the next button.
  * Since the domain is "@me", the remaining IMAP account settings should be pre-configured and a connection test should start.
  * Once the connection test is complete, the App should advance to confirm the deletion settings for the account.
4. Confirm the deletion settings
  * The synchronized folders should include: "INBOX", "Sent Messages" and "Archive".
  * The setting to immediately delete messages should be turned off.
  * The "Move to Folder" (deletion folder) should default to "Deleted Messages"

### ICLOUD-T02: Move Messages to Trash

1. Ensure the account settings are setup to not immediately delete messages.
2. Put a message in the "Archive", "Sent Mail", and "Inbox" folder.
3. Delete the messages
4. The messages should appear in the Trash folder. This can be verified using 
   the web interface at www.icloud.com.


### ICLOUD-T03: Immediately Delete (After Moving to Trash)

1. Change the Email Account settings to immediately delete messages.
2. Put a message in the "Archive", "Sent Mail", and "Inbox" folder.
3. Delete the messages
  * The log output within XCode should include a line like 
    "Msg Permanently deleted" for each message.
4. Both messages should no longer appear in any folders, including 
   the trash folders. This can be verified using the web interface at www.icloud.com.
   
## Gmail Integration

### GMAIL-T01: Change the language

1. Go to the gmail settings and change the language to Espanol.
2. Create a new account.
3. Upon creation, the account should be setup like an English account, but the
   equivalent settings for "[Gmail]/All Mail" and "[Gmail]/Trash" folders
	should be in Spanish; i.e.: [Gmail]/Todos and  [Gmail]/Papelera respectively
	
### GMAIL-T02: Verify Language 

If the user changes the language in Gmail, without
updating the App settings, an error should be generated
if the trash folder is no longer valid or the all mail
folder no longer has any messages.

### GMAIL-T03: Real Account

Connect to a real account. The number and variety of messages
will provide a good (albeit not scientific) test case.

Setup:

1. Generate the messages using the integration test server
2. Connect the Apple Mail client to both the integration 
   test account and the Gmail account.
3. Select the messages in the test account, right-click
   and copy them to the "All Mail" folder of the real account.

### GMAIL-T04: Move to Trash

Setup the account to both move the message to [Gmail]/Trash, 
then immediately delete.

### GMAIL-T05: Immediate Delete

Setup the account to both move the message to [Gmail]/Trash, 
then immediately delete.

## Test Server Integration

### TSERV_T01: Large Number of Messages

Setup:

1. Using the test scripts, create a large inbox with 50K messages
   (this is equivalent to someone who receives approximately 50
   messages per day over 5 years).
2. Set up the account to synchronize with test server.

Post-conditions:

1. The synchronizatino should complete successfully (not crash) and 
   the app should still be responsive.
2. The app should only download a number of messages, which is 
   equal to the maximum number of synchronized messages 
   for the account (5000 by default).
   
## General System Testing

### SYSTEST-T01: Release Build

This can sometimes expose problems not seen in a release build, such as
memory management issues.

### SYSTEST-T02: Test on iPad 2

The iPad 2 has dual cores, so it should operate a little more
realistically than the iPhone 3GS with threading.



