# IMAP Synchronization

## Synchronizing from Server to Local Database

### Local Data Model

The local data model for synchronizing from the IMAP server and locally is as follows:

* **EmailInfo** objects objects in a local CoreData database include:
	* A local copy of header fields, including subject, **UID**, 
	  receive date, sender email (and optional name), and message size. 
	  This information is used for message rules and display of the message 
	  locally.
	* Flags describing it's state w.r.t. deletion, including:
	 	* **locked** - Prevented from deletion by automatic rules or by
	      being trashed
		* **trashed** - Placed in trash, but not yet deleted.
		* **deleted** - Marked for deletion, but not yet deleted on server.
	* **hash** - hash value of immutable header fields for purposes of 
	  synchronization. If the user copies a message from one folder to the next,
	  then there is the possibility of 2 messages having the same hash value.

* **FolderInfo** objects are needed to help keep the IMAP messages in sync
  with the local **EmailInfo** objects.
	* The relevant properties to store locally include:
		* **mailboxName** -Fully qualified mailbox name
		* **nextUID** - Next unique identifier value 
		  (per [RFC3501](http://tools.ietf.org/html/rfc3501#section-2.3.1.1))
		* **UID Validity** - This provides an indication that the sequence 
		  numbers in the mailbox have been rewritten and the whole folder needs to be
		  refreshed.

* Trash and exclusion rules are comprised of objects which generate CoreData
  predicates on **EmailInfo** objects.

### Folder Level Synchronization

Synchronization from the server to the local **EmailInfo** and **FolderInfo** 
objects occurs as follows:

1. Iterate through each folder __serverFolder__ on the IMAP server.

	1. Lookup the corresponding __FolderInfo__ by **mailboxName**.
	
	2. If there is no existing __FolderInfo__
		1. Create a new __FolderInfo__, with properties that match **serverFolder**
		2. Iterate through each message in __serverFolder__, synchronizing each message
		    with a local __EmailInfo__.
		
	3. If there is an existing __FolderInfo__, **folderInfo**
		1. Compare the **UID Validity** value **folderInfo** with **serverFolder**.
			* If they're the same, compare the **nextUID** on the 
			  **serverFolder** and **folderInfo**. Synchronize the newer
			  messages with an **EmailInfo** object.
			
### Message Synchronization

There are a number of scenarios to consider w.r.t. message synchronization. 

* New message on server, no local **EmailInfo** object:
    * A new **EmailInfo** object needs to be created.
* Message deleted on the server, but there is still a 
  local **EmailInfo**
    * The local **EmailInfo** object should be deleted
* Message has been moved to a different folder on server, making the 
  local **EmailInfo**'s UID out of sync. 
* Message has been copied on server, so there are 2 (or more) messages 
  on the server with the same header information for a single **EmailInfo**.

Ideally, there should be a unique ID for each and every message on the server.
There is the **UID** property, but this only persists as long as the message
stays in the same folder and the folder's **UID Validity** property stays the 
same. 

The lack of a truly persistent server generated unique ID makes 
it difficult to keep local state information, such as a 
**lock** or **trashed** flag. Some alternatives for dealing with 
this include:

1. At least in the first version(s), don't support local state information.
    * The user would have to create a specific exclusion rule
      for any messages they didn't want deleted.
    * **EmailInfo** would represent then just a disposable 
      cache of a server's message information.
    * In lieu of **lock** and **trash** flags, the user can:
		* Create reasonably granular trash and exclude rules.
		* Only delete selected messages from the trash.
		* Confirm the deletion of messages from the trash.
		* Use a simple UI to create exclusion rules for multiple
		  messages at once.
2. Represent **lock** or **trashed** flag as a (pseudo)rule - the rule 
   would look for messages whose hash signature matches the
   rule.
    * There would be a performance impact for large amounts of rules.
    * If there are a large number of these rules, editing them alongside
 	  other more general rules could be cumbersome.
    * After messages corresponding to the rules are deleted, the
      rules should be deleted too.
3. Support the **lock** or **trashed** flag only on IMAP servers which 
   support extra keywords/flags which can be used to 
   manage the state information (this may be many/all of them)
    * This is dependent on the server implementation, per RFC3501:

		> Section 2.3.2: Servers MAY permit the client to define new keywords
		> in the mailbox (see the description of the 
		> PERMANENTFLAGS response code for more information).

		> Section 7.1: The PERMANENTFLAGS list can also include the special flag \*,
		> which indicates that it is possible to create new keywords by
		> attempting to store those flags in the mailbox.		

	* As an example, this is how the Mail program on Mac OS X manages labels
	  and junk mail flags.
	* An advantage of this approach is that flags would persist with the
	  message on the server, so if the user was using multiple iOS devices,
	  the **lock** or **trashed** flags would persist across those devices.
4. Depend on server extensions for supporting a unique UID - Gmail supports
   this, for example.
5. Only keep the flag as long as the folder-specific UID is valid - this is
   not considered a viable alternative, since it goes against the user's
   intent that that the lock and trash flags are persistent/sticky.

## Synchronizing Local Deletions with Server

When the user chooses to delete either a selected list of messages in the 
trash, or all of them, the sequence to synchronizes the delete 
with the server is as follows:

1. Set the **deleted** flag on a local **EmailInfo** to TRUE.

2. Perform a server to local synchronization (described above).

3. Iterate through all the local **EmailInfo** objects with delete flags set.