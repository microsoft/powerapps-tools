# Building Access App Deployment Instructions

The documentation below walks through the steps for deploying the app in
your environment and covers:

-   Creating a location for your data
-   Running a Power Automate to create the SharePoint lists
-   Importing and configuring the Building Access App
-   Importing and configuring the Building Admin App
-   Importing and configuring the Building Security App
-   Configuring the App settings and creating initial content
-   Deploying the App to Teams
-   Configuring the PowerBI Dashboard

## Download solution
Directly [download all assets](https://github.com/microsoft/powerapps-tools/raw/master/Apps/BuildingAccess/BuildingAccessApp.zip) needed for deploying this solution

## Prerequisites

1.  Sign up for Power Apps.

2.  You must have a valid SharePoint Online license and permission to
    create lists.

3.  You must have a public SharePoint site where you can store the data
    for the app.

4.  Download the Assets from GitHub Repository

## Package contents
| Component | Filename | Description |
|--|--|--|
| SharePoint list creation flow | DeploySPLists.zip | Creates the lists necessary to hold the data in the app. |
| Building Access end-user app and create request flow | BuildingAccess.zip  | Allows users to request space in a building and managers to approve requests. |
| Building Admin application | BuildingAdmin.zip | Allows facility management teams to configure building details, occupancy thresholds and other app settings |
| Building Security application | BuildingSecurity.zip | Allows security offices and lobby managers to validate access for users and check them in |
| Approver notification flow | BARNotifyApprover.zip | Sends an adaptive card to the approving manager in Teams |
| PowerBI Dashboard | Building Access Insights.zip | Dashboard provides insights around building occupancy, trending metrics and contact tracing |
| Label & messages translations | colTranslations.xlsx | Excel file containing machine translations for 44 languages for all the labels and messages used in the app. |


Create a home for your data
===========================

Data for the app is stored in SharePoint lists, so the first step is to
create a new SharePoint site.

Create a SharePoint site.
-------------------------

1.  Sign in to [Office online](https://www.office.com/), and then select
    SharePoint.

2.  Select **Create site.**

![A screenshot of a cell phone Description automatically
generated](.//media/image3.png)

3.  Select **Team site.**

![A screenshot of a cell phone Description automatically
generated](.//media/image4.png)

4.  Enter name and description for your site.

5.  Set Privacy settings to Public so that everyone in the company can
    get the necessary information.\
    ![A screenshot of a cell phone Description automatically
    generated](.//media/image5.png)

6.  Select Next.

7.  Add additional owners for the site (optional).

8.  Select Finish.

Create SharePoint Lists for the app
-----------------------------------

The app uses multiple lists to store its data. You can use the
**DeploySPLists** power automate, available from the downloaded *assets
package*, to automatically create these lists. The power automate
creates the required lists, fields and sets columns as indexed.

### Import the SharePoint list deployment flow

1.  Go to flow.microsoft.com.

2.  Select My flows from the left navigation pane.

3.  Select Import on the command bar.

4.  Upload **DeploySPLists.zip** package from the GitHub Repository\
    ![A screenshot of a cell phone Description automatically
    generated](.//media/image6.png)

5.  Add a SharePoint connection for the new flow by selecting the Select
    during import link and completing the form![A screenshot of a social
    media post Description automatically
    generated](.//media/image7.png)

6.  If you need to create a new SharePoint connection, select **Create
    new** in the **Import setup** pane.

7.  Select **New connection** on the command bar.

![A screenshot of a social media post Description automatically
generated](.//media/image8.png)

8.  Search for the SharePoint connector.

9.  Choose the option to "Connect directly (cloud-services).

10. Return to the tab where the flow is being imported and select the
    connection you just created.

![A screenshot of a cell phone Description automatically
generated](.//media/image9.png)

11. Select Save.

12. Select Import.

### Edit the SharePoint list deployment flow

1.  After the import is done, go to My flows and refresh the list of
    flows.

2.  Select the newly imported flow, DeploySPLists.

3.  Select Edit on the command bar.

4.  Open the Variable - Target Site for Lists card.

5.  For Value, enter the URL of your SharePoint site (e.g.
    https://contoso.sharepoint.com/sites/BAR).

6.  Open the Variable -- App name card.

7.  For Value, enter the name of your app; by default, the name is
    Building Access.

![A screenshot of a cell phone Description automatically
generated](.//media/image10.png)

8.  Select Save.

### Run the SharePoint list deployment flow

1.  Click the back arrow to return to the detail screen for the
    Deploy\_SPLists flow.

2.  Select Run on the command bar.

3.  Select Continue, and then select Run flow

***Note:***

*You might receive an error stating that location services are required.
If this occurs, allow location services to access Power Automate and
refresh the page before trying again.*

4.  Refresh the flow detail screen until the run status changes from
    running to Succeeded.

![](.//media/image11.png)

5.  The flow creates the following SharePoint lists in your SharePoint
    site. Return to the SharePoint site you specified above and verify
    that they are now created by clicking on the gear icon in the top
    right, then Site Contents.

![A screenshot of a cell phone Description automatically
generated](.//media/image12.png)

6.  You should see the following Document Library and Lists created.
    Learn more about their purpose in the table below.

![A screenshot of a cell phone Description automatically
generated](.//media/image13.png)

| Display Title | Purpose | Description |
|--|--|--|
|BAR\_AppSettings | Used for feature configuration by the admin of the app. Note: This list should be read-only for all members who aren't admins. | Admin configuration list for the *\[App Name\]* app. |
|BAR\_Buildings | Collection of all buildings. Includes information about total number of seats in the building, maximum allowed seats. Maximum allowed seats depend on the availability threshold %. | Building list for for the *\[App Name\]* app. |
|BAR\_Spaces| Collection of spaces associated with a building. A space is any bookable area within the building for example, a floor or a room. | List of bookable spaces for *\[App Name\]* app. |
|BAR_SafetyPrecautions  | Collection of information that a company wants to relay to employees. This list could hold safety precautions or company news. | Information list for *\[App Name\]* app. |
|BAR_KeyQuestions | Collection of screening questions that an employee must respond to before making a request to the building. This feature can be turned off from the admin app. | Key Questions for *\[App Name\]* app. |
|BAR_KeyQuestionAnswers | This list stores user responses to the key questions. | Answers for Key Questions List for *\[App Name\]* app. |
|BAR_Requests | This is the core lists which holds all access requests from users. The list holds key request information. | Request list for *\[App Name\]* app.AccessKey, Approver, BuildingID, CheckInTime, Created, DateValue, Modified,Requestor, Status fields are indexed in this list |


***Note***

-   *All these list columns should be considered as dependencies.
    Protect the lists from accidental schema changes (for example,
    adding new columns is allowed, but deleting columns might break the
    app.)*

-   *Use caution when deleting list items; deleting list items deletes
    historical records. You can turn the deprecation value toggle from
    No to Yes to drop records from contacts, news, FAQs, or links.*

### 

### Managing SharePoint 5000 Item Limit

It is essential that certain columns within the BAR\_Request list are
indexed. This is to avoid any delegation issues if the SharePoint lists
crosses the 5000 list items. Column indexing for Building Access App is
automatically set by the DeploySPLists flow.

For more information on SharePoint field indexing refer to this
[article.](https://support.microsoft.com/en-us/office/add-an-index-to-a-sharepoint-column-f3f00554-b7dc-44d1-a2ed-d477eac463b0)

SharePoint Security
-------------------

SharePoint lists should be configured using principal of least
privilege. This is to ensure that the users are only given privileges
that they require for seamlessly using the Apps in an intended way.

Refer to the permission matrix below to ensure users have right level of
access to the SharePoint lists.

| LISTS                  | USERS      | ADMIN      | SECURITY  |
|------------------------|------------|------------|-----------|
| BAR_AppSettings        | Read       | Read,Edit  | Read      |
| BAR_Buildings          | Read       | Read,Edit  | Read      |
| BAR_KeyQuestionAnswers | Read,Edit  | Read,Edit  | Read,Edit |
| BAR_KeyQuestions       | Read       | Read, Edit | Read      |
| BAR_Requests           | Read, Edit | Read, Edit | Read,Edit |
| BAR_SafetyPrecautions  | Read       | Read,Edit  | Read      |
| BAR_Spaces             | Read       | Read,Edit  | Read      |



In the above permissions matrix:

1.  Admins are users who use the Building admin app and are responsible
    for configuring key settings and reference data for the Building
    Access App.

2.  Users use the Building Access App. Users make reservation requests.
    Users are also managers who are responsible for approving the
    reservation requests.

3.  Security are users who use the Building Security App. They are
    responsible for building security and ensuring that users follow
    protocols by managing their entry to the building.

***Note***

-   *Currently SharePoint site has been configured as Public. This means
    all users in your organisation are members of the site.*

-   *Admins should be configured as owners of the site.*

-   *As the site is public, security users are already part of the
    members group of the site.*

Steps below show how to set up permissions for the BAR\_AppSettings
list. Same steps can be followed for other lists to provide access as
per the permission matrix above.

1.  Navigate to the SharePoint site.

2.  Click on the gear icon on top right and then click Site Contents.

![A screenshot of a cell phone Description automatically
generated](.//media/image14.png)

3.  Click Show Actions icon and then select Settings

![A screenshot of a social media post Description automatically
generated](.//media/image15.png)

4.  In the Permissions and Management section, click Permissions for
    this List

![A screenshot of a cell phone Description automatically
generated](.//media/image16.png)

5.  On the top left corner Click Stop Inheriting Permissions.

![A screenshot of a cell phone Description automatically
generated](.//media/image17.png)

6.  This creates unique permissions for the list.

7.  Select the members group.

8.  Select Edit User Permissions

![A screenshot of a cell phone Description automatically
generated](.//media/image18.png)

9.  Uncheck Edit and check Read.

> ![A screenshot of a social media post Description automatically
> generated](.//media/image19.png)

10. Click Ok.

***Note***

-   *The SharePoint site can be configured as a private site.*

-   *If site is configured as private, it is important that list
    permission matrix is followed.*

Import and set up the Building Access app
=========================================

After all SharePoint lists have been created, you can import the app and
connect it to your new data sources.

Import the app
--------------

1.  Sign in to [Power Apps](https://make.powerapps.com/).

2.  Select Apps from the left navigation pane.

3.  Select Import on the command bar.

4.  Upload the BuildingAccess.zip file from ....

> ![A screenshot of a computer Description automatically
> generated](.//media/image20.png)

5.  Complete the import setup for SharePoint Connection and Office 365
    Users Connection by selecting the appropriate connections by using
    the Select during import hyperlink. You might have to create a [new
    connection](https://docs.microsoft.com/en-us/powerapps/maker/canvas-apps/add-data-connection),
    if it doesn\'t already exist.

6.  Select Import.

Update the SharePoint connections
---------------------------------

1.  Go back to the Apps list.

2.  Select More commands (\...) for the Building Access app.

3.  Select Edit from the context menu.

> ![A screenshot of a cell phone Description automatically
> generated](.//media/image21.png)

4.  Sign in or create any necessary connections, and then select Allow.

5.  Go to the data sources in the left pane.

> ![A screenshot of a cell phone Description automatically
> generated](.//media/image22.png)

6.  Click the "..." to remove existing SharePoint lists inside the app,
    because they don\'t point to your current SharePoint site.

> ![A screenshot of a cell phone Description automatically
> generated](.//media/image23.png)

7.  Add the lists from your own SharePoint site. Start by searching for
    SharePoint in the search bar.

8.  Select SharePoint, and then choose a connection.

![A screenshot of a cell phone Description automatically
generated](.//media/image24.png)

9.  Copy and paste the URL to your SharePoint site in the text field,
    and then select Connect.

![A screenshot of a cell phone Description automatically
generated](.//media/image25.png)

10. Select all the SharePoint lists and libraries that start with "BAR",
    and then select Connect.

![A screenshot of a cell phone Description automatically
generated](.//media/image26.png)

11. From the File menu, select Save, and then select Publish.

Update the BARCreateRequests power automate.
--------------------------------------------

This flow is called from within the Building Access app. This creates
the building reservation request in the SharePoint list. The flow passes
the context information back to the Building Access app.

1.  Go to flow.microsoft.com

2.  Select My Flows from the left navigation pane.

3.  Select More commands(...) for BARCreateRequests, and then select
    Edit.

4.  Open the INIVarSiteURL Lists card.

> ![A screenshot of a cell phone Description automatically
> generated](.//media/image27.png)

5.  For Value, enter the URL of your SharePoint site.

6.  For any Actions that have an orange triangle, open the action and
    set up a connection by clicking "Add new connection".

![A screenshot of a cell phone Description automatically
generated](.//media/image28.png)

7.  Select Save.

Import and set up the BARNotifyApprover power automate
------------------------------------------------------

This flow sends an adaptive card to the requestor's manager, requesting
approval for the submitted request. The adaptive card is set to the
manager as defined in active directory. If manager information is
missing from active directory, the adaptive card is sent to the Teams'
channel as defined within the BAR\_AppSettings list.

![A screenshot of a cell phone Description automatically
generated](.//media/image29.png)

### Import Power Automate

1.  Go to flow.microsoft.com.

2.  Select My flows from the left navigation pane.

3.  Select Import on the command bar.

4.  Upload the **BARNotifyApprover.zip** package from ....

![A screenshot of a cell phone Description automatically
generated](.//media/image30.png)

5.  Add a SharePoint connection for the new flow by selecting the Select
    during import link and completing the form.

> ![A screenshot of a cell phone Description automatically
> generated](.//media/image31.png)

6.  If you need to create a new SharePoint connection, select Create new
    in the Import setup pane and follow the instructions as before.

7.  Add a Microsoft Teams Connection by selecting the Select during
    import link and completing the form.

8.  If you need to create a new Microsoft Teams connection, select
    **Create new** in the **Import setup** pane.

9.  Select **New connection** on the command bar.

> ![A screenshot of a cell phone Description automatically
> generated](.//media/image32.png)

10. Search for the name of the connection, for example Teams.

![A screenshot of a cell phone Description automatically
generated](.//media/image33.png)

11. Select the connection you created.

12. Select Save.

Edit the BARNotifyApprover power automate
-----------------------------------------

1.  After the import is done, go to My flows and refresh the list of
    flows.

2.  Select the newly imported flow, BARNotifyApprover

3.  Select Edit on the command bar.

4.  Select the trigger "Request" card.

5.  Change the Site Address to the URL of your SharePoint site.

6.  Update the list name to BAR\_Requests

> ![A screenshot of a social media post Description automatically
> generated](.//media/image34.png)

7.  Open the Initialize Variable -varSiteUrl card.

> ![A screenshot of a cell phone Description automatically
> generated](.//media/image35.png)

8.  For Value, enter the URL of your SharePoint site.

9.  Select Save.

10. If you receive a message that "Some of the connections are not
    authorized yet", open the flow conditions
    (![](.//media/image36.png)) and switch statement
    (![](.//media/image37.png)) and assign a connection to the
    actions with an orange triangle
    (![](.//media/image38.png)) by clicking Add new connection.

> ![A screenshot of a cell phone Description automatically
> generated](.//media/image39.png)

11. Once these connections are fixed, Save the flow.

Import and set up the admin app
===============================

To manage the app you imported, repeat the same steps for the admin app.

1.  Sign in to [Power Apps](https://make.powerapps.com/).

2.  Select Apps from the left navigation pane.

3.  Select Import on the command bar.

4.  Upload the **BuildingAdmin.zip** from ....

> ![A screenshot of a social media post Description automatically
> generated](.//media/image40.png)

5.  Select Import.

Update connections for the admin app
------------------------------------

1.  Go back to the Apps list.

2.  Select More Commands (\...) for Building Access admin app.

3.  Select Edit from the context menu.

4.  Sign in or create any necessary connections, and then
    select **Allow**.

5.  Go to the data sources in the left pane.

> ![A screenshot of a cell phone Description automatically
> generated](.//media/image22.png)

6.  Remove existing SharePoint lists inside the app, because they don\'t
    point to your current SharePoint site.

> ![A screenshot of a cell phone Description automatically
> generated](.//media/image23.png)

7.  Add the lists from your own SharePoint site. Start by searching for
    SharePoint in the search bar.

8.  Select SharePoint, and then choose a connection.

![A screenshot of a cell phone Description automatically
generated](.//media/image24.png)

9.  Copy and paste the URL to your SharePoint site in the text field,
    and then select Connect.

![A screenshot of a cell phone Description automatically
generated](.//media/image25.png)

10. Select all the SharePoint lists and libraries, and then select
    Connect.

![A screenshot of a cell phone Description automatically
generated](.//media/image26.png)

11. From the File menu, select Save, and then select Publish.

Import and set up the Security app
==================================

To manage the app you imported, repeat the same steps for the admin app.

1.  Sign in to [Power Apps](https://make.powerapps.com/).

2.  Select Apps from the left navigation pane.

3.  Select Import on the command bar.

4.  Upload the **BuildingSecurity.zip** from ....

> ![A screenshot of a computer Description automatically
> generated](.//media/image41.png)

5.  Select Import.

Update connections for the security app
---------------------------------------

1.  Go back to the Apps list.

2.  Select More Commands (\...) for Building Access Security app.

3.  Select Edit from the context menu.

> ![A screenshot of a social media post Description automatically
> generated](.//media/image42.png)

4.  Sign in or create any necessary connections, and then
    select **Allow**.

5.  Go to the data sources in the left pane.

> ![A screenshot of a cell phone Description automatically
> generated](.//media/image22.png)

6.  Remove existing SharePoint lists inside the app, because they don\'t
    point to your current SharePoint site.

> ![A screenshot of a cell phone Description automatically
> generated](.//media/image23.png)

7.  Add the lists from your own SharePoint site. Start by searching for
    SharePoint in the search bar.

8.  Select SharePoint, and then choose a connection.

![A screenshot of a cell phone Description automatically
generated](.//media/image24.png)

9.  Copy and paste the URL to your SharePoint site in the text field,
    and then select Connect.

![A screenshot of a cell phone Description automatically
generated](.//media/image25.png)

10. Select all the SharePoint lists and libraries, and then select
    Connect.

![A screenshot of a cell phone Description automatically
generated](.//media/image26.png)

11. Select Save, and then select Publish.

12. Select Save, and then select Publish.

Set up an Admin Team
====================

It is important that you set up an admin team to centrally manage admin
tasks like, configuring key settings and reference data, approving
building access requests.

Building access requests are approved or rejected by requestor's manager
as defined in the Active directory. There might be instances where an
organisation's active directory doesn't hold this information for user.
In this case, Admin team will be responsible for approving or rejecting
building access requests.

Set up an Admin team following instructions in this
[article](https://support.microsoft.com/en-ie/office/create-a-team-from-scratch-174adf5f-846b-4780-b765-de1a0a737e2b?ui=en-us&rs=en-ie&ad=ie).
It is recommended that you create a channel to manage building access
requests. To create a channel with your newly created admin team, follow
instruction in this
[article](https://support.microsoft.com/en-gb/office/create-a-channel-in-teams-fda0b75e-5b90-4fb8-8857-7e102b014525?ui=en-us&rs=en-gb&ad=gb).

***Note***

-   *Ensure that right users are added to the admin team.*

-   *Generally, users using the Building Admin App and owners of the
    SharePoint site should be part of this team.*

Create initial content for the app
==================================

At this point, you\'ve successfully imported both the Building Access
App, Building Admin app and Building Security App. You can now start
creating the initial content. To start, open the Building Admin app.

![A screenshot of a cell phone Description automatically
generated](.//media/image43.png)

You can use the admin app to customise all the key information required
in the Building Access app and to configure key settings for the app and
accompanying flows.

Set up key parameters under Settings
------------------------------------

To initialize your app, you need to provide all the required fields by
navigating to Settings.

Complete all the fields as shown in the following table, and then select
Save.

| Field name                                                   | Logical name in SharePoint | Purpose                                                                                                                                                  | Example                                               |
|--------------------------------------------------------------|----------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------|-------------------------------------------------------|
| Limit requests to X Days in future                           | BookingAdvance             | This setting defines number of days from today in future the request to access the building can be made.                                                 | 14                                                    |
| Admin Team ID                                                | AdminTeamID                | This is the team ID where the approval adaptive card is sent if the requestor does not have a manager assigned in Active Directory                       | 9cd94000-09ce-472d-976f-0a080f3a071c                  |
| Admin Team Channel ID                                        | AdminTeamChannelID         | This is the channel within the Admin team where the approval adaptive card is sent if the requestor does not have a manager assigned in Active Directory | 19%3a175691a3520d4e43a86 81457b687823a%40thread.tacv2 |
| Show inline approval buttons on approvals                    | EnableInlineApprovals      | This setting enables managers to approve individual requests from the Building Access app                                                                | Yes/No                                                |
| Enable Safety Precautions Feature                            | SafetyPrecautions          | This setting enables/disables safety precaution feature on the Building Access App                                                                       | Yes/No                                                |
| Require Key Question completion before creating reservations | KeyQuestions               | This setting makes it mandatory for requestors to answer Key eligibility questions before requesting access to a building                                | Yes/No                                                |
| Key Questions failure message                                | KeyQuestionsFailMessage    | This is the message that appears if a requestor has answered “Yes” to any of the Key Eligibility Questions                                               | Sorry at this time you do not qualify.                |


**[NOTE: Retrieve Team's ID]{.underline}**

1.  Open teams.

2.  Click on (...) next to your admin team name.

3.  Click Get link to the team.

![A screenshot of a social media post Description automatically
generated](.//media/image44.png)

4.  Copy the team's link and paste in a text editor like notepad.

![A screenshot of a cell phone Description automatically
generated](.//media/image45.png)

5.  The link is in the format

**https://teams.microsoft.com/\_?tenantId=\<Tenant ID\>&groupId=\<Team
ID\>**

6.  The value of the groupid parameter is the id of your team.

**[NOTE: Retrieve Team's Channel ID]{.underline}**

1.  Navigate to the admin team's channel.

2.  Click (...) next to the channel name.

3.  Click get link to the channel.

![A screenshot of a social media post Description automatically
generated](.//media/image46.png)

4.  Copy the channel link in a text editor like notepad.

5.  Extract the id between channel/ and /general. This is your channel
    id.

![A screenshot of a cell phone Description automatically generated](.//media/image47.png)

Sharing PowerApps
====================================================================================================================================================================

You need to share your PowerApps with relevant users in order to make
the apps available to use. For guidance on sharing a canvas app, refer
to this
[article.](https://docs.microsoft.com/en-us/powerapps/maker/canvas-apps/share-app)

It is important that you share the apps with right users. As an example,

1.  Building Access app can be shared with all users in your
    organisation who are required to request access to a building.

2.  Building Admin can be shared with Facilities Admin users, who are
    responsible for managing key information like Buildings.

3.  Building Security can be shared with security personnel, who are
    responsible for managing entry to a building.

Deploying Building Access App to Teams
======================================

Deploying the Building Access App to teams is an easy way to promote
adoption, centralize discussions, and amplify information across the
organization. Teams Admins, as well as end-users, can add this app to
Teams, albeit with slightly different steps. Once you have downloaded
the app following the written or video instructions above, the steps
below walk through the process to deploy it to Teams.

Download the Building Access App from Power Apps Homepage
---------------------------------------------------------

1.  Navigate to <https://make.powerapps.com>

2.  The Building Access app should appear under "Your Apps".

3.  Click the "..." to the right of the app name, then select the "Add
    to Teams" option.

![A screenshot of a social media post Description automatically generated](.//media/image48.png)

4.  Click Download app.

![A screenshot of a cell phone Description automatically
generated](.//media/image49.png)

5.  This will download a zip file which can be uploaded to Teams in the
    next step, so save the file to a location you can remember and
    easily access.

Add app to your Teams app store
-------------------------------

1.  Once the app has been downloaded from your Power Apps homepage as a
    zip file, open Teams and navigate to the app store.

2.  Use the "Upload a custom app" function at the bottom-left. If you don't see Upload a custom app option it may mean that this option is disabled for your organisation. Contact you team's administrator and follow instructions in the "Notes" section below.![A screenshot of a computer Description automatically generated](.//media/image50.png)

3.  Click Upload for \[Organisation Name\].

4.  Upload the zip file you downloaded from Power Apps in the prior
    step.

![A screenshot of a computer Description automatically
generated](.//media/image51.png)

5.  Once uploaded, the app appears in the app store.

![A screenshot of a computer Description automatically
generated](.//media/image52.png)

![A screenshot of a computer Description automatically
generated](.//media/image53.png)

***Note***

-   *In case you don't see Upload Custom app option, it may mean this
    functionality is disabled for your organisation.*

-   *This setting could be turned on by navigating to [teams admin
    centre](https://admin.teams.microsoft.com/).*

-   *Under Team's apps, select Setup Policies.*

-   *Switch on Upload custom apps setting.*

![A screenshot of a cell phone Description automatically
generated](.//media/image54.png)

**Pin the app** to your organisation's Teams app bar (Teams Admins)
---------------------------------------------------------------

Teams Admins have a great opportunity to drive awareness and highlight
the apps that their organization should be using. As with any app, Teams
Admins can use the [Teams Admin
Center](https://admin.teams.microsoft.com/) to pin this app to the Teams
App bar for their entire tenant.

1.  Under "Teams apps", select "Setup policies", and choose which policy
    to update (the "Global" policy, for example).

![A screenshot of a computer Description automatically
generated](.//media/image55.png)

2.  Now select "Add apps" under the "Pinned apps" section, and search
    for the app to pin (based on the name you gave the app in Power
    Apps).

3.  Click Add to select the app to pin.

![A screenshot of a cell phone Description automatically
generated](.//media/image56.png)

4.  Shortly, all users in this policy will see this app appear on their
    Teams app bar.

Pin the app to your personal Teams app bar (any Teams user)
-----------------------------------------------------------

Even if your Teams Admin has not taken steps to add this app to the
Teams app bar for your tenant, any user can add this app their personal
app bar.

1.  Click the app from the app store.

![A screenshot of a cell phone Description automatically
generated](.//media/image57.png)

2\. Click Add to add app to your app bar.

![A screenshot of a social media post Description automatically
generated](.//media/image58.png)

3.  Once the app icon appears on your app bar, right click the icon and
    select "pin". The app icon will remain on your app bar to provide
    you easy access, even after you navigate away from the app.

![A screenshot of a computer Description automatically
generated](.//media/image59.png)

Adding Building Admin app as a tab
==================================

The Building Admin app provides an easy way for admins to manage key
settings and reference data for the Building Access app. Adding the
Building Admin App as a tab to an admin team is a great way to ensure
ease of access. To add the Admin app to a tab, follow the following
instructions.

1.  Navigate to your Admin team and select a channel.

![A screenshot of a cell phone Description automatically
generated](.//media/image60.png)

2.  Click the + icon on the tabs bar.

3.  Search for PowerApps in the Add a tab dialog and select PowerApps.

![A screenshot of a cell phone Description automatically
generated](.//media/image61.png)

4.  Next dialog presents all the PowerApps shared with the you.

5.  Select the Building Admin App and click Save

![A screenshot of a cell phone Description automatically
generated](.//media/image62.png)

6.  The app is added as a tab.

![A screenshot of a computer Description automatically
generated](.//media/image63.png)

Configuring PowerBI report
==========================

Once you have configured all the apps, users will start requesting
access to the buildings. Managers or admins will approve them and
security personnel will be able to check in and check out users. PowerBI
report provides an excellent way to report on the data captured and
extract some key information.

Follow the steps below to configure the PowerBI report.

1.  Download Building Access Insights.pbix from the GitHub repository.

2.  Open the pbix file using PowerBI desktop.

3.  Click on Tranform data under Home menu.

![A screenshot of a social media post Description automatically
generated](.//media/image64.png)

4.  In the transform data dialog, under parameters change the values for
    SharePoint URL parameter to the URL of you SharePoint site.

![A screenshot of a social media post Description automatically
generated](.//media/image65.png)

5.  Under parameters change the values for BAR\_Requests SP Key to GUID
    of the BAR\_Requests list.

> Note:

-   To extract GUID of the list, navigate to SharePoint list.

-   Navigate to List Settings under settings icon.

-   Make note of the List GUID from the URL

![](.//media/image66.png)

6.  Under parameters change the values for BAR\_Buildings SP Key to GUID
    of the BAR\_Buildings list.

7.  Under parameters change the values for BAR\_Spaces SP Key to GUID of
    the BAR\_Spaces list.

8.  Click on Data Source Settings.

![A screenshot of a computer Description automatically
generated](.//media/image67.png)

9.  In the Data Source settings dialog, click Edit permissions.

![A screenshot of a cell phone Description automatically
generated](.//media/image68.png)

10. In the Edit Permissions Dialog, Click Edit and leave everything else
    as default.

11. Select Microsoft account and select Sign in as different user.

![A screenshot of a social media post Description automatically
generated](.//media/image69.png)

12. Sign in using credentials for a user account that has at least read
    access to all lists in the SharePoint site.

13. Once you are signed in, a message appears "You are currently signed
    in", Click Save.

![A screenshot of a social media post Description automatically
generated](.//media/image70.png)

14. Click ok on Edit permissions dialog.

![A screenshot of a social media post Description automatically
generated](.//media/image71.png)

15. Click Close in the Data Source settings dialog.

16. Verify by clicking on the Queries, which should now show data.

![A screenshot of a computer Description automatically
generated](.//media/image72.png)

17. Click Close & Apply.

18. The PowerBI report should update with new data.

## Support
Please do not open a support ticket if you encounter any bugs with the solution itself, unless it is related to an underlying platform issue unrelated to the template's implementation. 

### Disclaimer
*This app is a sample and may be used with Microsoft Power Apps and Teams for dissemination of reference information only. This app is not intended or made available for use as a medical device, clinical support, diagnostic tool, or other technology intended to be used in the diagnosis, cure, mitigation, treatment, or prevention of disease or other conditions, and no license or right is granted by Microsoft to use this app for such purposes. This app is not designed or intended to be a substitute for professional medical advice, diagnosis, treatment, or judgement and should not be used as such. Customer bears the sole risk and responsibility for any use of this app. Microsoft does not warrant that the app or any materials provided in connection therewith will be sufficient for any medical purposes or meet the health or medical requirements of any person.*