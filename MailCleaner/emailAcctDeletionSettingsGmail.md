### Gmail Email Deletion Settings

When it comes to message deletion and email folders, Gmail 
supports message deletion in a [unique way][GmailDelete]. In particular, 
Gmail supports [message labels][GmailLabels], and these labels are shown 
as folders when IMAP-based email client programs or apps 
(including Email Purger) connect to Gmail.

Only the **[Gmail]/All Mail** folder contains a singular 
list of all email messages. The other folders show the
 same messages, but with the folder name being a message 
 label. Deleting a message from a folder other than **[Gmail]/All Mail** 
 only removes the label, and the message will still appear 
 in the **[Gmail]/All Mail]** folder. 

For purposes of reviewing and deleting messages, it 
only makes sense to synchronize with the **[Gmail]/All Mail** folder; 
otherwise, if a message had labels, Email Purger could
potentially show multiple copies of the same message.

To actually delete a message, it needs to first be moved from the
**[Gmail]/All Mail** to the **[Gmail]/Trash** folder, then 
permanently deleted from the **[Gmail]/Trash** folder. 

As shown in the table below, Email Purger's default and recommended
message deletion settings for Gmail email addresses are tailored 
to integrate with Gmail's message labeling and the need to move 
messages from from the
**[Gmail]/All Mail** to the **[Gmail]/Trash** folder.

Email Purger Message Deletion Setting   | Recommended Value | Comments
------------- | ------------- | ----------
Synchronized Folders    | [Gmail]/All Mail    | This folder is a singular list of all messages in the account. If a message is tagged, it may appear in several folders, where the folder name is the same as the tag. 
Trash Folder    | [Gmail]/Trash    | Moving a message to this folder will cause it to be automatically erased (permanently deleted) after 30 days. The [web interface][GmailWeb] also provides an "Empty Trash" capability to immediately erase messages in the trash folder.
Immediately Erase Messages?    | OFF    | Assuming a 30 day delay to permanently erase the message is acceptable, the recommendation is to not immediately erase messages.


[GmailWeb]:https://mail.google.com
[GmailDelete]:http://support.google.com/mail/bin/answer.py?hl=en&answer=78755
[GmailLabels]:http://support.google.com/mail/bin/answer.py?hl=en&answer=118708

