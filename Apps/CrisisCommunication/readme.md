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

## Package contents
| Component | Filename | Description |
|--|--|--|
| SharePoint list creation flow | DeploySPLists.zip <br>GCC: DeploySPLists.zip<br>No Outlook: DeploySPLists.NoOutlook.zip | Creates the lists necessary to hold the data in the app. |
| End-user app and send a request flow | CrisisCommunication.zip <br>GCC:	CrisisCommunicationGCC.zip <br>No Outlook:	CrisisCommunicationNoOutlook.zip & CrisisCommunication.Request.NoOutlook | Displays content to the end-user and submits requests to the central crisis management team. |
| Admin application | CrisisCommunicationAdmin.zip <br>GCC: CrisisCommunicationAdmin.zip <br>No Outlook: CrisisCommunicationAdmin.zip | Allows the crisis management team to update the content in the end-user app |
| News push notification flow | CrisisCommunicationNewsNotification.zip <br>GCC: CrisisCommunicationNewsNotificationGCC.zip <br>No Outlook: CrisisCommunicationNewsNotification.NoOutlook.zip | Sends a push notification to end-users whenever there is a new internal company update |

## Download pack
Directly [download all assets](https://github.com/microsoft/powerapps-tools/raw/master/Apps/CrisisCommunication/CrisisCommunicationPackage.zip).

## How to update
If you have already completed the steps in the [documentation](https://aka.ms/crisis-communication-app-docs) for Crisis Communication, it is not necessary to redo every step again. Follow these steps to import the individual app or flow which you would like to update.

Start by downloading the new CrisisCommunicationPackage.zip file from this github repository. See the Latest Update section for a table of the latest versions.

Important: updating an app will replace any customizations you have made to the template. Please document any revisions to menus and formulas separately before proceeding. You can also save the original app to your computer as an .msapp file and open it in another browser tab to copy content over to the new version. Note that you can always revert to a previous version by accessing the version history of an app.

To update an app:
1. Extract an app you would like to update. For example, if you want to update the Crisis Communication app, extract CrisisCommunication.zip. See the table for Package contents for more details.
2. Go to [make.powerapps.com](https://make.powerapps.com)
3. Sign in.
4. From the left pane, click Apps.
5. From the top menu, click Import. 
6. Browse for the zip file you extracted. The page will change to the import experience. 
7. Instead of creating a new app as done in the original setup instructions, click "Create new" to reveal more options. 
8. A pane appears on the right. Below Setup, change the drop down menu to "Update."
9. A list of apps in the environment appears in the right pane. Select the app which you would like to overwrite. Note that it is possible to revert an app to a previous version as desired.
10. Select a connection for each connection required.
11. Click import and wait for the import to complete.
12. When the import is complete, open the app in the Power Apps studio.
13. From the ribbon, click View > Data sources. In the left pane for Data sources, remove the existing connections to SharePoint. 
14. In the same left pane for Data sources, type 'SharePoint' into the search bar at the top. 
15. Select SharePoint and your connection. A pane will appear on the right to browse for the exact site and lists.
16. In the right pane, select the SharePoint site where your lists for Crisis Communication are located. If the site does not appear in this list, type its URL in the field at the top of the pane.
17. Click Connect.
18. Save and publish the app: File > Save. Publish.

To update a flow:
1. Extract the flow you would like to update. Note that if you have already deployed the SharePoint lists using the DeploySPLists flow, it is not necessary nor possible to create them again in the same site as they already exist.
2. Go to [flow.microsoft.com](https://flow.microsoft.com/)
3. Sign in.
4. From the left pane, click 'My flows.'
5. From the top menu, click Import.
6. Browse for the zip file you extracted. The page will change to the import experience. 
7. Instead of creating a new flow as done in the original setup instructions, click "Create new" to reveal more options. 
8. A pane appears on the right. Below Setup, change the drop down menu to "Update."
9. A list of flows in the environment appears in the right pane. Select the app which you would like to overwrite. 
10. Select a connection for each connection required.
11. Click import and wait for the import to complete.
12. Flows that are imported for the first time may be disabled. It may be necessary to edit the flow and in its details page, click Turn on from the top menu.

## Latest Update
Date | Notes
-|-
2020.05.06 | Updated News Notification Flow to use the Office 365 Groups connector (instead of the Azure AD connector) to avoid admin consent requirement for developers to instantiate the connection.
2020.05.05 | Uploaded No Outlook version, which removes the dependency from the Outlook connector in all apps and flows. Special setup instructions are available in the download package.
2020.03.25 | [V2.20200325](https://github.com/microsoft/powerapps-tools/commit/fb7171ea2ba8bf0a0d029583942f6737b3e77039)<br>News Notification flows (regular & GCC)<br>- Updated default pagination limit of the Azure AD action to 5,000 to accomodate configurations for users with base licenses. This can be reconfigured to 100,000, see the documentation on how to update this.
2020.03.23 | [V2.20200323](https://github.com/microsoft/powerapps-tools/commit/3b3cb2fdee7f8971dfa9d941f3b721d6e0baf4b5) <br>Crisis Communication App <br>- FAQ now sorts by Rank. <br>- Corrected text for Links. <br>- Fixed issue with navigating to the news screen when accessing the app by deep-linking. <br>- Implemented first round of easier styling. <br><br>Crisis Communication Admin App<br>- Fixed issue in which the selected item would not appear in some forms. <br>- Changed navigation behavior to occur OnSuccess of submitting a form. <br><br>Crisis Communication Request flow <br>- Fixed issue with quotation marks in adaptive cards. <br><br>News Notification flow <br>- Improved Azure AD connector to be able to page through members of a security group (up to Power Automate limit of 100,000) <br>- Filtered out non-users in security group. <br><br>DeploySPLists flow <br>- Columns are no longer hidden when flow is run. <br>- Fixed an issue affecting running the flow trigger.
2020.03.16 | Updates: <br>- Bugfix: fixed a bug affecting setting up auto-replies. <br>- Implemented a way to configure more work status options more easily. <br>- Gallery navigation for Tips, News, and RSS have been changed to scroll bars due to a bug. 
2020.03.12 | Updates: <br>- Improved FAQ component: can support categories and order of items if columns are added to the list <br>- Fixed issue with setting up auto replies <br>- Performance improvements, removed unused controls <br>- Included table of translations <br>- Added support for Hebrew and Arabic
2020.03.11 | Updates: <br>- Included fix for Issue #95 in which the home menu was not responding well to wide screen resolutions <br>- Included fix related to Issue #97 in which sending of an email to the selected people would fail if it included those selected in the contacts screen <br>- Improved usability and accessibility
2020.03.10 | Updates: <br>- Updated experiences for galleries in Crisis Communication app. <br>- Made preferred notification a required field in Admin app. <br>- Included email receipts for sharing status and making requests.
2020.03.09 | V2 release: <br>Crisis Communication app <br>- Updated design of Crisis Communication app. <br>- Changed calendar component to allow selection of multiple non-consecutive dates. <br>Crisis Communication Admin app <br>- Removed unused fields in the forms
2020.03.06 | Updates: <br>- Added support for GCC (Please see separate files for importing, marked GCC) <br> - Added usability improvements
2020.03.05 | Updates: <br>- Bugfix: Resolved issue in which conditions for updating an existing date and creating new status updates were reversed. Please update your app to the latest version to resolve this issue. <br>- Bugfix: Corrected the conditions enabling and disabling features in the app <br>- Revised accessible labels and tab index <br>- Added support for Japanese <br>- Added feature to Update Status <br>- Removed unused controls
2020.03.04 | Initial solution launch: <br>1. "CrisisCommunication.zip" - Canvas App for end users<br>2. "CrisisCommunicationAdmin.zip" - Canvas App for administrating the content <br>3. "DeploySPLists.zip" - Flow to initialize SharePoint Online Lists for managing content <br>4. "CrisisCommunicationNewsNotification.zip" - Flow to send out notifications when company news updates are published <br>5. "Presence status report.pbix" - Power BI Dashboard to monitor absences and other data

## Support
Please do not open a support ticket if you encounter any bugs with the solution itself, unless it is related to an underlying platform issue unrelated to the template's implementation. If there are issues related to the solution implementation itself, please [report bugs here](https://github.com/microsoft/powerapps-tools/issues/new?assignees=denisem-msft&labels=crisiscommapp&template=-crisis-communication-app--bug-report.md&title=%5BBUG%5D%3A+issue+title).

### Disclaimer
*This app is a sample and may be used with Microsoft Power Apps and Teams for dissemination of reference information only. This app is not intended or made available for use as a medical device, clinical support, diagnostic tool, or other technology intended to be used in the diagnosis, cure, mitigation, treatment, or prevention of disease or other conditions, and no license or right is granted by Microsoft to use this app for such purposes. This app is not designed or intended to be a substitute for professional medical advice, diagnosis, treatment, or judgement and should not be used as such. Customer bears the sole risk and responsibility for any use of this app. Microsoft does not warrant that the app or any materials provided in connection therewith will be sufficient for any medical purposes or meet the health or medical requirements of any person.*
