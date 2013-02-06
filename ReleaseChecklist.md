# App Release Checklist

1. Update Version Numbers
  1. In AppStoreInfo.md
  3. In the project settings.

2. Double-check the test account provided in the review notes.  
See AppStoreInfo.md for the review notes. The account needs to
be populated with some messages.

3. Add a Release Notes Entry to the bottom of the AppStoreInfo.md file. This will be used to describe "What's Changed" in the App Store submission.

4. Update releaseManifest.md with SHA1 of any libraries changed since last release.

5. Update the copyright information in AppStoreInfo.md, if the year has changed
  
6. In iTunes Connect, create the new version
  * Cut and paste the "What's changed" information from AppStoreInfo.md
  * Use the same version number as was changed in step 1.
  * Update the copyright, if the year has changed.

7. Final Testing
  1. Run the "Analyze" Build phase on the project
  2. Run the project's unit tests using the "Test" option.
  3. Install and run on hardware.
  4. There's a test called "StressTestSyncAndDelete" which does a stress
     test against a local IMAP server. This test isn't part of the 
     unit tests which are by default enabled. If any of the 
     client/server related code has been changed (and/or the 
     underlying MailCore library), it is advisable to also setup
     and run this test. 
  
6. Commit changes made to project in steps 1-5 above.

5. Create a Release Build

  1. In the project settings and in the "Code Signing" section, set the "Code Signing Identity" to "iPhone Distribution: Resultra, LLC".

     In the 'Code Signing Identity' section of the Build Settings,
     select "Automatic Profile Selector - iPhone Distribution".
     This should set the iPhone distribution to match:
     
        iPhone Distribution:Resultra LLC' in 'MailShredder App Store Distribution'

  2. From the organizer, open the archive in the finder. Drag the 
     app to a console window to run the following commands:
     
     codesign -dvvv /path/to/MyGreatApp.app
     
     and:
     
     codesign -d --entitlements - /path/to/MyGreatApp.app
     
     The above will confirm the signature and entitlements for the
     app. Run both commands on the previous version of the app
     to confirm the information is the same.

  3. In XCode, select the project, right click and select "Discard Changes". This will have the effect of reverting the Code Signing back to "iPhone Developer" (Note: there's an open issue to add a "Distribution" target so this isn't necessary, see: https://trello.com/c/3hbwuGMq)


6. Validate the Release Build

  1. Using the same archived app folder names as the step above,
     perform a folder difference using DiffMerge on the previous
     and current app folders. The differences should correspond to
     the expected changes.

  2. Refer to the document "ManualTesting.md", which includes tests to
     be performed on a the release build. This notably includes RELTEST-T01,
     which is testing the update to ensure backward compatibility has been preserved.

7. Within the Xcode organizer, validate and distribute/submit the archive for the App Store.
  

8. Using git, tag the app's project code with the version number
   (substituting appropriate version number, instead of "1.0.1"): e.g.:

    cd /Users/sroehling/Development/Workspace/MailCleaner
	git tag -a v1.0.1 -m "Version 1.0.1 submitted for approval"
	
9. Using git, tag any libraries changed alongside the project code 
   (substituting appropriate numbers for MailShredder and library code, instead of 1.4 and 1.0.1): e.g.:

    cd /Users/sroehling/Development/Workspace/ResultraGenericLib
	git tag -a v1.4 -m "Version Released with v1.0.1 of MailShredder"
	
10. Create an off-site backup of the current source code tree, including library code.

11. Create an off-site backup of the archives used to build the project.
