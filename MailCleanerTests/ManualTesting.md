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

