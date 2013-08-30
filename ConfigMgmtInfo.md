# Configuration Management Information

## Creating a New Working Directory

Retrieve the modules from the repository:

    git clone git@macmini.local:/Users/git/ResultraGenericLib.git
    git clone git@macmini.local:/Users/git/MailShredder.git
    git clone git@macmini.local:/Users/git/MailCore.git
    git clone git@macmini.local:/Users/git/MarkdownHelpGeneration.git

## Reference a Specific Version of MailCore

MailShredder depends on a specific version of the MailCore library. This version must be populated into the library's directory, then the appropriate versions of submodules need to be populated too:

	cd MailCore
	git checkout a182d01
	git submodule init
	git submodule update
	cd ..
	
Refer to releaseManifest.md to confirm the specific version of MailCore to be referenced.

## Reference a Specific Version of ResultraGenericLib

MailShredder currently references a specific version of ResultraLib. So, similar to what was done for MailCore, this version needs to be populated into the library's directory:

	cd ResultraGenericLib
	git checkout da39ca3
	cd ..
	
Refer to releaseManifest.md to confirm the specific version of ResultraGenericLib to be referenced.