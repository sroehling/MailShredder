# Cloud Mail Cleaner

This utility app will connect with users' email accounts and give 
them a custom interface with which to clean up old messages 
in their email account. The reasons for this include:

* Regain some privacy: 
    * Mail providers scan email to develop an 
      advertising profile. There's no 
      reason to give them more than they need.
    * If an email account was compromised,
      much personal information can be compromised
      such as online purchase histories or private 
      conversations. After a period of time,
      these emails are not needed. 
    * If someone is ever the subject of a legal
      proceedings, a person's entire email
      database can accessed (TBD - Need 
      to find legal reference for this).
    * Over time an email database can accumulate 1000s
       of emails, most of which are never referenced after
       initially being read or sent. There is simply no reason
       to keep these emails.
    * Governments have been working to lessen citizen's
      online privacy. This is one to assert your
      privacy rights.
* For organized people ("neat freaks") who 
  just want to keep their email database tidy. For most emails,
  there's simply no need to keep them around for years.
* The UI for existing email clients is focused on 
  composition and reading, not deleting. There's
  unique opportunity to develop a customized UI
  just for cleaning up an email database.  
  
An email provider would be unlikely to develop this feature, since 
it is contrary to their goals of having more 
information to search and develop an advertising profile. 

## Use Cases

###  Sent Mail

1. Group the recipients in a way that will allow rapid deletion and/or 
   setting up filters:
    * Group by recipient and show the count. 
    * Show which ones are in address book. 
    * Group by recipients domain (e.g. "@gmail.com","@followupthen.com")
    * Covered by delete rule or not. 
    * By timeframe - e.g. older than 6 months, older than 1 year. 
    * With and without attachments. 
    * Locked vs unlocked. 
    * With a given subject
    * In a given mailbox. 
2. Allow manual deletion of individual emails. 
3. Perhaps allow setting up a rule based upon individual message. 

### Establishing Filters for Groups of Similar Messages

The assumption is there will be a "message list" view for reviewing 
the list of un-deleted messages. 

Rather than displaying a unfiltered list of messaged by default, 
some suggested/common rules for grouping messages to delete can be 
shown in the root view controller. This would serve as a starting point 
for the message filter used to display the list of messages. Alternatively, 
a default message filter could be set, such as "Sent more than 2 years ago"; 
the user could then change the current filter.

1. Select the tab with a list of messages
2. The list of messages is displayed, with a filter limiting 
   the number of message (such as by age, sender's domain, sender).
3. Select an individual message
4. A list of actions are enabled for the currently selected message.
    * Lock the message to prevent from being deleted
    * Move to trash (manually delete)
    * Add message's domain or sender to current filter.

## Key Features

### Message Filter 

* Saved in database
	* Messages view can then be restored to the same state when
		  the app is shut down and restarted.
	* Message Filters can be saved in a list of favorites.
* Filter Parameters
	* Age (Older/Newer Than) - 30 days, 6 months, 1 year, 2 years
	* Time since email
	* In Address Book?
	* From
		* Specific email address
		* Email Domain - e.g: amazon.com, godaddy.com, etc.
			* Could sort by common domains
	* Subject contains <pattern>
	* Has Attachments?
	* Locked from Deletion
* Favorites
    * Save a filter to a favorites list, so it can be 
      loaded at any time: e.g.:
        * Has Attachments 
* Enabled/Disabled - Allow the user to disable certain filters.

### Delete and Exclusion Rules

These rules are automatically applied to the list of undeleted
messages to determine which messages are scheduled for deletion, 
and which ones are excluded.

These rules include:

* A user provided name, so the rule can be shown in lists
* An enabled/disabled flag
* A reference to the message filter used to filter which messages 
  are applicable to the rule.
* An option to require delete confirmation? (delete rules only)
                  
                                    
### Message List View

List of messages which haven't been deleted.
  
* Filter settings in Header
    * This is consistent with other apps which, by convention
        have the search settings in the header.
    * Button on RHS to display and edit the current filter.
    * The current search filter is saved. 
* Message Actions
	* Lock a message from deletion.
        * List of locked messages. 
		* Could use a SHA1 signature to uniquely identify messages,
		  including subject date, etc.
	* Trash a message

### Trash View

This view shows a list of messages scheduled for deletion. 
From this view, the user can:

* View messages matching different rules.
* Exclude individual, or groups of messages from deletion.
* "Empty the trash", which will permanently delete the messages.

TBD - will this a 'trash' confuse the user relative to trash email folder?

### Rules View

The rules view is an ordered list of delete & exclusion rules.
 From this view, the user can:

* Create new rules
* Change existing rules
* Enable and disable individual rules
* Re-order rules
* Delete rules

### App Settings

* Confirm all message deletions
* Passcode protection upon startup

### Archival

* Securely archive messages to Dropbox or iCloud (version 2.0)
