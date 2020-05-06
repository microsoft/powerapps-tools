# Release Planner Solution
Earlier, we published a [blog](https://powerapps.microsoft.com/en-us/blog/how-power-platform-helps-us-manage-and-publish-product-release-plans/) that is explaining how Microsoft business applications team is publishing the release plans using a Power Platform. Based on various customers request, we have templatized the release planner app  so that, you can use this app to publish a release notes/plan for your internal application release.

## Package contents
|Component|	Filename |	Description
|-|-|-|
Solutions/Managed|	ReleasePlanner_1_0_0_0_managed.zip|	 A managed solution file that contains all release plan components such as client extensions, custom control, entity, help page, option set, process, security role, and  web resource (JS files, entity icons).
Solutions/Un Managed |	ReleasePlanner_1_0_0_0.zip|	 An Unmanaged solution file that contains all release plan components such as client extensions, custom control, entity, help page, option set, process, security role, and  web resource (JS files, entity icons).
Plugin Project|	ReleasePlannerPlugins.zip |	Visual Studio Project files to create Release plan History records.
Template |	HTML.htm|	Template file used for creating release plan Word document.
CSS | UploadImageTool.css | CSS file for the Upload Image Tool.

## Prerequisites
 
The following apps must be available :

- Dynamics 365 apps such as Dynamics 365 Sales, Dynamics 365 Customer Service, Dynamics 365 Marketing, Dynamics 365 Field Service, and Dynamics 365 Project Service Automation.

- A service account is recommended that will have admin access in Dynamics 365 and SharePoint.

- The same service account can be used in Power Automate files to connect to SharePoint or send an email using Outlook connector ( should have an outlook for office license) for the notification feature to work.

## Audience


This article is intended for the users with System administrator privileges to
the following apps

-   Dynamics 365 apps such as Dynamics 365 Sales, Dynamics 365 Customer Service, Dynamics 365 Marketing, Dynamics 365 Field Service, and Dynamics 365 Project Service Automation.

-   Power Apps

-   Power Automate

-   SharePoint Contributor privilege to create create/read documents.

## Deployment


### Pre-deployment steps


1.  Download the Release Planner solution from \<LINK\>.

2.  On the environment where you intend to import the solution go to
    “Solutions”.  
    #### Classic UI
    

    ![Classic UI - Advanced Settings](media/classicui-advancedsetting.png)

    ![Classic UI - Solutions](media/classicui-solutions.png)

    #### Modern UI
    

    ![Modern UI - Solutions](media/modernui-solutions.png)

3.  Select “Import” on the toolbar.  
    #### Classic UI
    

    ![Classic UI - Import solution](media/classicui-import.png)

      
   #### Modern UI  
    

    ![Modern UI - Import solution](media/modernui-import.png)

4.  Select the solution package ZIP file you have downloaded on step 1 and click
    “Next”:  
    

    ![Import - Choose the solution file](media/import-choosefile.png)

6.  Click “Next”:  
    

    ![Import solution - Click next button](media/import-next.png)

7.  After the import has completed, click “Publish All Customizations”:  
    

    ![Import soltuion - Public all customization](media/import-publishall.png)

### Post-deployment steps

#### Configure “Generate Release Plans Word Document” flow

This flow should be configured if you are looking to generate the Word Document
from the release planner app that contains all the features for a particular
release wave and particular application.

1.  On the environment where you have imported the solution go to “Solutions”
    using the Modern UI:  
    

    ![Modern UI - Solution](media/modernui-solutions.png)

2.  Select “Release Planner” solution:  
    

    ![Release Planner Solution](media/releaseplanner.png)

3.  Select “Flow” filter on the upper right:  
    

    ![Search Flow](media/search-flow.png)

4.  Select “Get Filter Criteria to fetch specific Release Plan records”:  
    

    ![Flow - Get filter criteria to fetch specific release plan records](media/getfiltercriteria.png)

5.  Select “Edit”:  
    

    ![Flow Edit](media/flow-edit.png)

6.  Expand “When an HTTP request is received” step and copy its URL to the
    clipboard:  
    

    ![Copy HTTP URL Request](media/getflowhttp.png)

7.  Go back to the list of flows and select “Generate Release Plans Word
    document”:  
    

    ![Search Generate Release Plans Word document flow](media/searchgeneratereleaseplan.png)

8.  Scroll down to “For each application” step:  
    

    ![A screenshot of a cell phone Description automatically generated](media/scroll-for-each-app.png)

9.  Expand “For each application”, expand “Hierarchy Product value is not null”,
    scroll down to “Get Filter Criteria” step and expand it:  
    

    ![Expand HTTP Request step](media/expand.jpg)

10. Paste the URL copied on step 1.6 into “URI” field.

11. Scroll up to “Init FilePath” step and expand it. In the “Value” field enter
    the path to the SharePoint folder, where the resulting .doc files will be
    saved:  
    

    ![Update the File Path](media/initfilepath.jpg)

12. Copy “HTML.htm” template file (supplied with the Release Planner solution)
    to the SharePoint folder you specified on step 1.11.

13. Scroll down to “Initialize SharePoint SiteAddress” step and expand it. Enter
    your SharePoint site address into “Value” field:  
    

    ![Update SharePoint File Address](media/initsharepointfileaddress.jpg)

14. Scroll to the very beginning of the flow. Expand the first “When a HTTP
    request is received” step and copy its URL to the clipboard:  
    

    ![Copy HTTP Request](media/copyhttprequest.png)

15. Go back to “Solutions” list using Modern UI. Open “Release Planner”
    solution. Select “Other” filter on the upper-right:  
    

    ![Select Other](media/select-other.png)

16. Select “Generate Word Doc Ribbon script” web resource:  
    

    ![Select Generate Word Doc Ribbon script](media/select-generate-word-script.png)

17. Select “Text Editor”:  
    

    ![texteditor](media/texteditor.png)

18. Find “flowUrl” variable and replace its value with the URL copied on step
    1.14:  Click OK.
    

    ![Find Flow URL](media/find-flow-url.jpg)

#### Configure “Daily Email Alerts” flow

1.  On the environment where you have imported the solution go to “Solutions”
    using the Modern UI:  
    

    ![Modern UI - Solution](media/modernui-solutions.png)

2.  Select “Release Planner” solution:  
    

    ![Release Planner](media/releaseplanner.png)

3.  Select “Flow” filter on the upper right:  
    

    ![Search Flow](media/search-flow.png)

4.  Select “Daily Email Alerts”  
    

    ![Daily Email Alerts Flow](media/dailyemailalert.png)

5.  Select “Edit”:  
    

    ![Edit Flow](media/edit-flow.png)

6.  Expand “Initialize Environment URL” step and enter your environment URL into
    the “Value” field:  
    

    ![A screenshot of a cell phone Description automatically generated](media/environmenturl.jpg)

    Click save and close the Flow.

## Entities


The following are the list of entities available in the solution. The detail
documentation for each entity attributes is available as a [Guided
help](https://docs.microsoft.com/en-us/powerapps/maker/common-data-service/create-custom-help-pages)
within the solution. Follow the instructions in the link to enable guided help
in your environment to see the detail documentation

![List of Entities](media/entitylist.png)

### Entity Relationship diagram


![Entity Relationship Diagram](media/entityrelationship.png)

## Flows


The solution contains 5 flows.

### Daily Email Alerts


This flow sends email alerts to the Reviewer to review the release plans that
are created/updated by the author. The release plans that are set as “Reviewed?”
to No will be included for review. This includes the following:

![Recurrence Flow](media/flow-recurrence.png)

1.  Pending Application Overview reviews (Reviewed ? is No)

    ![Pending Application Overview](media/pendingapplicationoverview.png)

2.  Pending Application Area reviews (Reviewed? is No)

    ![Pending Application Area Review](media/pendingappareareview.png)

3.  Pending Release plan reviews (Reviewed? is No)

    ![Pending Release Plan Review](media/pendingreleaseplanreview.png)

4.  Images that are added in the last 24 hours

    ![Images added in the last 24 hours](media/imagesadded.png)

5.  Release Plans that are in shipped status with no documentation link

    ![Release Plans with no document link](media/nodoclink.png)

### Generate Release Plans Word Document

This flow is useful to generate a Word document that includes all the release
plans for a specific wave and for a specific product. This will help someone to
review all the plans offline.

This flow is triggered from “Generate Document” menu on the Release Wave entity
form. The flow produces a .doc file with information about the selected
applications and saves the file to a SharePoint Folder. Once the file has been
saved, the flow sends an email with a link to the file.

![Trigger Doc Generation Flow](media/triggerdocgenerate.jpg)

#### Steps to generate a .doc file

1.  Open the update form for the Release Wave you are interested in.

2.  Select “Generate Document” tab.

3.  In “Release Plan Applications” sub grid select the applications, details of
    which must be included into the .doc file.

4.  Select “Generate Document”, and then select one of the two options:

    - “All Features”: the generated .doc file will include details about all
        features associated with the selected applications. If no application is
        selected, the document will include all the active applications in the
        system.

    - “Features Ready to Disclose”: the generated .doc file will include
        details only about features which have “Include in Release Plan” field
        set to “Yes”.

Once the .doc file has been generated and saved to a SharePoint folder you will
receive an email with a link to the file.

### Get filter criteria to fetch specific Release Plan records

This flow is called by “Generate Release Plans Word document” flow to retrieve
criteria, with which Release Plans will be filtered.

“Get filter criteria to fetch specific Release Plan records” flow allows to
apply custom filter criteria when needed.

### Set App Overview name when released app updated

Updates Application Overview name if Application name gets changed. Sets the
overview name in the format "Overview of \<app name\>". Triggers when
Application field of Application Overview entity is created, updated, or
deleted.

![Call the Flow the change the Overview Name](media/triggeroverview.png)

### Set overview name when app name changed

Updates Application Overview name if another Application is selected for the
overview. Triggers when Application record is created, updated, or deleted.

![Set overview name](media/setoverviewname.png)

## Business Rules
 
### Lock/Unlock the Public Preview Date

If Public Preview Release Status is N/A, the Public Preview Date field must be
locked.

![Lock Public Preview Date](media/lockpublicpreview.png)

### Lock/Unlock the GA Date

If GA Release Status is N/A, the GA Date field must be locked.

![Lock GA Date](media/lockgadate.png)

## Form Validators

Additional field validations are performed for status/date fields on Release
Plan form to match the expected behavior:

-   Dates must be not less than today with Planned status

-   Dates must be not greater than today with Shipped status

-   N/A status locks GA – Release date field

-   At least one of specified dates must be within the related Release Wave
    timeline (otherwise Include in Release Plan also gets locked)

-   Public preview date must be less than GA date

These rules are processed by msft_releaseplan.js script. The script is available
under Web Resources tab in Solution window. All triggered functions are
associated with corresponding events which can be changed in form editor
(Solution \> Entities \> Release Plan \> Forms \> Reviewer/Contributor form \>
Form Properties):

![Form Validation script](media/formvalidation.png)

## Custom Control (Upload Image Tool)

A custom control created to get the image data from local devices.

Apart from default PCF files it contains “index.ts” for processing the data and
UploadImageTool.css for component styling. ControlManifest.Input.xml contains
PCF name, version and other info plus all parameters visible after selecting it
in the form editor. These can be used to adjust the size of control components.

![Set Custom Control](media/setcustomcontrol.png)

The form containing custom control:

![Image Upload Custom Control](media/imagecustomcontrol.png)

Each Release Plan may contain multiple attachments which contain the data about
the image uploaded via Image Upload tool (filename, description etc.). In turn
each Release Plan Attachment is related to one of Annotations (Notes) entities
provided out of the box, where the image in base64 format is stored. All
uploaded files can be also found by navigating to Related \> Release Plan
Attachments on Release Plan form.

## Security Roles


The following security roles are available in the solution:

| **Role Name**                  |   **Role Description**          |
|-------------------------------------|-------------------------------|
| Release Plan – Admin       | This is the administrative role. Users with this role have access to all forms and can make any changes.                                                                                                                                                                  |
| Release Plan – Contributor | This role is designed for content authors. Users with this role have access to **Contributor** forms of Release Plan, Application Area and Application Overview entities. On Contributor forms of these entities **“Reviewed?” field is always read-only**.               |
| Release Plan – Reviewer    | This role is designed for content reviewers. Users with this role have access to **Reviewer** forms of Release Plan, Application Area and Application Overview entities. On Reviewer forms of these entities the **“Include in Release Plan” field is always read-only**. |

## Release Plan Audit Plug-in
  

### Release Plan Audit Plug-in purpose and logic

Release Plan Audit Plug-in is used to automatically create a Release Plan
History record whenever an operation, which meets certain conditions, is
performed on a Release Plan. The following table lists those operations with
their corresponding conditions:

| **Operation type**                  | **Conditions**                                                                                                                                                                                                                                                                                                                                                        | **Release Plan History “Action” field value** |
|-------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-----------------------------------------------|
| A new Release Plan is created       | The creation date is equal to or later than the “Release Plan Cut-off Date” of the Release Wave, to which the new Release Plan belongs.                                                                                                                                                                                                                               | “Created”                                     |
| An existing Release Plan is updated | \- “Include in Release Plan” value has been changed - The date of change is equal to or later than “Release Plan Cut-off Date” of the Release Wave, to which the Release Plan belongs.                                                                                                                                                                                | “Added” or “Removed”                          |
|   An existing Release Plan is updated                                  | \- “Public Preview – Release Date” **and/or** “GA – Release Date” value has been changed **-** The new date(s) is (are) between “Release Start Date” and “Release End Date” of the Release Wave, to which the Release Plan belongs - The date of change is equal to or later than “Release Plan Cut-off Date” of the Release Wave, to which the Release Plan belongs. | “Updated”                                     |

### Steps to access Release Plan History records

1.  Open Update form for the Release Plan you are interested in.

2.  Select “Related” tab and then “Release Plan History”.

![Access Release History](media/accessreleasehistory.jpg)
