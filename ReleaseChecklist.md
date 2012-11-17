# App Release Checklist

1. Update Version Numbers
  1. In AppStoreInfo.md
  2. In the App Store listing.
  3. In the project settings.

2. Double-check the test account provided in the review notes.  
See AppStoreInfo.md for the review notes. The account needs to
be populated with some messages.

3. Add a Release Notes Entry to the bottom of the AppStoreInfo.md file. This will be used to describe "What's Changed" in the App Store submission.

4. Final Testing
  1. Run the "Analyze" Build phase on the project
  2. Run the project's unit tests using the "Test" option.

4. Create a Release Build
  1. In the project settings and in the "Code Signing" section, set the "Code Signing Identity" to "iPhone Distribution: Resultra, LLC".
  2. Validate and distribute/submit the archive for the App Store.
  3. In XCode, select the project, right click and select "Discard Changes". This will have the effect of reverting the Code Signing back to "iPhone Developer" (Note: there's an open issue to add a "Distribution" target so this isn't necessary, see: https://trello.com/c/3hbwuGMq)
  
5. Update releaseManifest.md with SHA1 of any libraries changed since last release.

6. Using git, tag the app's project code with the version number: e.g.:

	git tag -a v1.0.1 -m "Version 1.0.1 submitted for approval"
	
7. Using git, tag any libraries changed alongside the project code: e.g.:

	git tag -a v1.4 -m "Version Released with v.1.0.1 of MailShredder"
	
8. Create an off-site backup of the current source code tree.