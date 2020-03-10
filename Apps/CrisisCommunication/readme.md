# Crisis Communication Solution
The *Crisis Communication* app provides a user-friendly experience to connect
end users with information about a crisis. Quickly get updates on
internal company news, get answers to frequently asked questions, and get access
to important information like links and emergency contacts. This app requires a
small amount of setup to make it your own.

Read the blog announcement [here](https://powerapps.microsoft.com/en-us/blog/crisis-communication-a-power-platform-template/).
 
In the walk through provided in the [documentation](https://aka.ms/crisis-communication-app-docs), you will learn how to:
- Create a location for your data
- Import both the Crisis Communication app and its admin app
- Create content for the app
- Import flows to send notifications to users
- Create a centrally managed Teams team to aggregate data and to effectively respond to issues

Please read the full documentation for installation instructions and more details [https://aka.ms/crisis-communication-app-docs](https://aka.ms/crisis-communication-app-docs).

## Download pack
Directly [download all assets](https://github.com/microsoft/powerapps-tools/raw/master/Apps/CrisisCommunication/CrisisCommunicationPackage.zip).

## Latest Update
Date | Notes
-|-
2020.03.09 | V2 release: <br>Crisis Communication app <br>- Updated design of Crisis Communication app. <br>- Changed calendar component to allow selection of multiple non-consecutive dates. <br>Crisis Communication Admin app <br>- Removed unused fields in the forms
2020.03.06 | Updates: <br>- Added support for GCC (Please see separate files for importing, marked GCC) <br> - Added usability improvements
2020.03.05 | Updates: <br>- Bugfix: Resolved issue in which conditions for updating an existing date and creating new status updates were reversed. Please update your app to the latest version to resolve this issue. <br>- Bugfix: Corrected the conditions enabling and disabling features in the app <br>- Revised accessible labels and tab index <br>- Added support for Japanese <br>- Added feature to Update Status <br>- Removed unused controls
2020.03.04 | Initial solution launch: <br>1. "CrisisCommunication.zip" - Canvas App for end users<br>2. "CrisisCommunicationAdmin.zip" - Canvas App for administrating the content <br>3. "DeploySPLists.zip" - Flow to initialize SharePoint Online Lists for managing content <br>4. "CrisisCommunicationNewsNotification.zip" - Flow to send out notifications when company news updates are published <br>5. "Presence status report.pbix" - Power BI Dashboard to monitor absences and other data

## Support
Please do not open a support ticket if you encounter any bugs with the solution itself, unless it is related to an underlying platform issue unrelated to the template's implementation. If there are issues related to the solution implementation itself, please [report bugs here](https://github.com/microsoft/powerapps-tools/issues/new?assignees=denisem-msft&labels=crisiscommapp&template=-crisis-communication-app--bug-report.md&title=%5BBUG%5D%3A+issue+title).

### Disclaimer
*This app is a sample and may be used with Microsoft Power Apps and Teams for dissemination of reference information only. This app is not intended or made available for use as a medical device, clinical support, diagnostic tool, or other technology intended to be used in the diagnosis, cure, mitigation, treatment, or prevention of disease or other conditions, and no license or right is granted by Microsoft to use this app for such purposes. This app is not designed or intended to be a substitute for professional medical advice, diagnosis, treatment, or judgement and should not be used as such. Customer bears the sole risk and responsibility for any use of this app. Microsoft does not warrant that the app or any materials provided in connection therewith will be sufficient for any medical purposes or meet the health or medical requirements of any person.*
