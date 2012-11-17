# Release Manifest

The following is a list of libraries and their SHA1's. 

Library              | SHA1
---------------------|-----------------------------------------
MailCore             | a182d018ae006e5ddf6c243d3583ae6eb09b05bf
ResultraGenericLib   | a01a8cce1640526a4ea7b89901d57c62c1977231

If newer versions of the libraries are integrated, this list should be updated. 
The SHA1 for a library can be shown by going to the top-level directory of 
the library and issuing the following command:

	git log -n 1

The MailCore library, in particular, incorporates sub-modules. The
list of these submodules can be generated using the following:

	git submodule status
	
In the case of MailCore, this results in the following:

	ae668453f2a153ca19a8485db23b73f270ea3ed8 iOSPorts (v0.6-27-gae66845)
	e43d8a0a11e4dea0876d199884fe9f4e0a39889f libetpan (remotes/origin/HEAD)

TODO - Use the git submodule feature to autoomatically link
the right version of the MailCore submodule (see https://trello.com/c/SBGCjhqX)