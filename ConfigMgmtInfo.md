# Configuration Management Information

## Building MailShredder for Development or Release

### Create a Folder for Development
	
Clone the Source and Libraries from GIT, then populate and confirm the submodules. 

    git clone git@macmini.local:/Users/git/MailShredder.git WORKINGDIRNAME
    
**WORKINGDIRNAME** can be left off if the intent is to populate the 'MailShredder' directory.  

###  Switch to Branch (If Not Working on Main Branch)

To start work on an existing branch:

    git checkout BRANCHNAME
    
Or, to first create the branch for new development:

	git checkout -b BRANCHNAME

###  Populate the Submodules

    git submodule update --init --recursive
    git submodule status --recursive