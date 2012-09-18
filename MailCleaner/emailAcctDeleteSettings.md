# Message Deletion Settings

The deletion settings for an email account determine what 
happens when a message is deleted from the MailCleaner app. 
The appropriate values for these settings depend on both your
personal preferences and the message deletion behavior for the email account's 
service provider (such as Gmail or iCloud).

The available message deletion settings include the following:

* **Synchronized Folders** - This is the list of IMAP message folders from
  which messages will be retrieved for review and deletion. Depending 
  on the email account, this list will typically  include folders like
  "INBOX" or "All Messages", but exclude folders like "Junk Mail" or "Drafts".
  
* **Trash Folder** - If specified, messages will be moved to this folder for deletion. 
  For many email service providers, there is a specific folder which should be 
  selected as a the **Trash Folder**.  Typically, messages moved into this folder
  will be automatically and permanently erased after a delay; for example,
  this delay is 30 days for Gmail and iCloud.
  
* **Immediately Erase Messages?** - If this setting is turned on, messages
  will be immediately and permanently deleted on the server,  whether
  or not the message is first moved to a selected **Trash Folder**.

## Default Recommended Settings

When an email account is added from a common email service provider, 
the MailCleaner app provides default recommended message deletion
settings, including:

* [Gmail Message Deletion Settings][GmailDeletionSettings]
* [Google Apps  Message Deletion Settings][GoogleAppsDeletionSettings]
* [iCloud Message Deletion Settings][iCloudDeletionSettings]

If your email provider is not listed above, MailCleaner should still
work as long as IMAP is supported. In this case, you will need to 
confirm the IMAP settings with your email provid`er and configure
the email deletion settings accordingly.

[GmailDeletionSettings]:emailAcctDeletionSettingsGmail.html
[GoogleAppsDeletionSettings]:emailAcctDeletionSettingsGoogleApps.html
[iCloudDeletionSettings]:emailAcctDeletionSettingsICloud.html


