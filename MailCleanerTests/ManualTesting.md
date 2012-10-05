# Manual Testing

## Message Delete

1. Setup preferences to first move the message to a delete folder, 
   then immediately/permanently delete from there.
2. Set a break-point in the code just before the code which 
   deletes messages which have been moved (in MailDeleteOperation.m,
   on or about line 281).
2. Delete a single message, M0
3. In a separate email client, move a message, M1 to the delete
   folder.
4. Continue execution in the debugger.
5. M0 should be permanently deleted, but M1 should not.

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
4. The messages should appear in the Trash folder. This can be verified using the web interface at www.icloud.com.


### ICLOUD-T03: Immediately Delete (After Moving to Trash)

1. Change the Email Account settings to immediately delete messages.
2. Put a message in the "Archive", "Sent Mail", and "Inbox" folder.
3. Delete the messages
  * The log output within XCode should include a line like 
    "Msg Permanently deleted" for each message.
4. Both messages should no longer appear in any folders, including 
   the trash folders. This can be verified using the web interface at www.icloud.com.

