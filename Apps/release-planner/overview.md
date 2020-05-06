# Release Planner Solution
Earlier, we published a [blog](https://powerapps.microsoft.com/en-us/blog/how-power-platform-helps-us-manage-and-publish-product-release-plans/) that is explaining how Microsoft business applications team is publishing the release plans using a Power Platform. We received feedback from customers they want to use similar solution to roll out their internal application releases. So, we have templatized the release planner app.

## Package contents
|Component|	Filename |	Description
|-|-|-|
Solutions --> Managed|	ReleasePlanner_1_0_0_0_managed.zip|	.
End-user app and send a request flow|	CrisisCommunication.zip <br>GCC:	CrisisCommunicationGCC.zip|	Displays content to the end-user and submits requests to the central crisis management team.
Admin application|	CrisisCommunicationAdmin.zip <br>GCC: CrisisCommunicationAdmin.zip|	Allows the crisis management team to update the content in the end-user app
News push notification flow|	CrisisCommunicationNewsNotification.zip <br>GCC: CrisisCommunicationNewsNotificationGCC.zip|	Sends a push notification to end-users whenever there is a new internal company update

## Prerequisites

The following apps must be available :

1.  Dynamics 365 apps built on Common Data Service.

2.  A service account is recommended that will have admin access in Dynamics 365 and SharePoint.

3.  The same service account can be used in Power Automate files to connect to SharePoint or send an email using Outlook connector ( should have an outlook for office license) for the notification feature to work.

## Audience


This article is intended for the users with System administrator privileges to the following apps

-   Dynamics 365 apps build on Common Data Service

-   Power Apps

-   Power Automate

-   SharePoint Contributor privilege to create create/read documents.

## Deployment


### Pre-deployment steps


1.  Download the Release Planner solution from \<LINK\>.

2.  On the environment where you intend to import the solution go to
    “Solutions”.  
    Classic UI:  
    

    ![A screenshot of a cell phone Description automatically generated](media/19d24c93f6ef2cc1b1e75a3ebeef89f7.png)

    ![A screenshot of a cell phone Description automatically generated](media/b3309e74db0850ea0409926150be4f02.png)

3.  Modern UI:  
    

    ![A screenshot of a cell phone Description automatically generated](media/e80f99925454e35a4fbd64b267e265c5.png)

4.  Select “Import” on the toolbar.  
    Classic UI:  
    

    ![A screenshot of a cell phone Description automatically generated](media/3dc2333eef8d59c0f18ac84637d086a1.png)

      
    Modern UI:  
    

    ![A screenshot of a cell phone Description automatically generated](media/ece7c6d291f65a4fbe52ee3c51f5affb.png)

5.  Select the solution package ZIP file you have downloaded on step 1 and click
    “Next”:  
    

    ![A screenshot of a cell phone Description automatically generated](media/9dc41db9e602f7a2508d83b89a4e0ee9.png)

6.  Click “Next”:  
    

    ![A screenshot of a cell phone Description automatically generated](media/c72a32504f583b870f59f03c76920756.png)

7.  After the import has completed, click “Publish All Customizations”:  
    

    ![A screenshot of a social media post Description automatically generated](media/a0278533740b0abe65f9b947ad4c415b.png)

### Post-deployment steps


#### Configure “Generate Release Plans Word Document” flow.

This flow should be configured if you are looking to generate the Word Document
from the release planner app that contains all the features for a particular
release wave and particular application.

1.  On the environment where you have imported the solution go to “Solutions”
    using the Modern UI:  
    

    ![A screenshot of a cell phone Description automatically generated](media/e80f99925454e35a4fbd64b267e265c5.png)

2.  Select “Release Planner” solution:  
    

    ![A screenshot of a cell phone Description automatically generated](media/ad57d9b1e2a3bfe8223f5e224369b0af.png)

3.  Select “Flow” filter on the upper right:  
    

    ![A screenshot of a computer screen Description automatically generated](media/2b0a76f1af9cb9dd951c20c82b3d568d.png)

4.  Select “Get Filter Criteria to fetch specific Release Plan records”:  
    

    ![A screenshot of a cell phone Description automatically generated](media/ba33e06cc35191b9d374c4cab6cb2fa5.png)

5.  Select “Edit”:  
    

    ![A screenshot of a social media post Description automatically generated](media/97dbc216b7b58223dc489c7ca41aeb49.png)

6.  Expand “When an HTTP request is received” step and copy its URL to the
    clipboard:  
    

    ![A screenshot of a social media post Description automatically generated](media/b8e87508b55fa09e5655af7f508eceab.png)

7.  Go back to the list of flows and select “Generate Release Plans Word
    document”:  
    

    ![A screenshot of a cell phone Description automatically generated](media/d7c75e7b7a958d81a2689335f9f406ed.png)

8.  Scroll down to “For each application” step:  
    

    ![A screenshot of a cell phone Description automatically generated](media/35bb09f71076c898af20ca27fb9cce1c.png)

9.  Expand “For each application”, expand “Hierarchy Product value is not null”,
    scroll down to “Get Filter Criteria” step and expand it:  
    

    ![A screenshot of a cell phone Description automatically generated](media/c7c7f43ccce8e80e561cc9f66d22330d.jpg)

10. Paste the URL copied on step 1.6 into “URI” field.

11. Scroll up to “Init FilePath” step and expand it. In the “Value” field enter
    the path to the SharePoint folder, where the resulting .doc files will be
    saved:  
    

    ![A screenshot of a cell phone Description automatically generated](media/8dcfed4dacda1243ff91f45fd188a51f.jpg)

12. Copy “HTML.htm” template file (supplied with the Release Planner solution)
    to the SharePoint folder you specified on step 1.11.

13. Scroll down to “Initialize SharePoint SiteAddress” step and expand it. Enter
    your SharePoint site address into “Value” field:  
    

    ![A screenshot of a cell phone Description automatically generated](media/f2c855b7e00c2fc328e912e5bc69b914.jpg)

14. Scroll to the very beginning of the flow. Expand the first “When a HTTP
    request is received” step and copy its URL to the clipboard:  
    

    ![A screenshot of a social media post Description automatically generated](media/c0bf9da3b5352db7ab2357d884f33d8a.png)

15. Go back to “Solutions” list using Modern UI. Open “Release Planner”
    solution. Select “Other” filter on the upper-right:  
    

    ![A screenshot of a computer Description automatically generated](media/e0838320b95e43f2730b5382331b33d8.png)

16. Select “Generate Word Doc Ribbon script” web resource:  
    

    ![A screenshot of a social media post Description automatically generated](media/66d5feda77117bdcb267a048a29e4202.png)

17. Select “Text Editor”:  
    

    ![A screenshot of a social media post Description automatically generated](media/df53d4e3742870fcf149ec4c8ee42613.png)

18. Find “flowUrl” variable and replace its value with the URL copied on step
    1.14:  
    

    ![A screenshot of a cell phone Description automatically generated](media/bd9daba5a10774dc31eb26439bee37f2.jpg)

### Configure “Daily Email Alerts” flow

1.  On the environment where you have imported the solution go to “Solutions”
    using the Modern UI:  
    

    ![A screenshot of a cell phone Description automatically generated](media/e80f99925454e35a4fbd64b267e265c5.png)

2.  Select “Release Planner” solution:  
    

    ![A screenshot of a cell phone Description automatically generated](media/ad57d9b1e2a3bfe8223f5e224369b0af.png)

3.  Select “Flow” filter on the upper right:  
    

    ![A screenshot of a computer screen Description automatically generated](media/2b0a76f1af9cb9dd951c20c82b3d568d.png)

4.  Select “Daily Email Alerts”  
    

    ![A screenshot of a social media post Description automatically generated](media/84b04d14acd7fb262ccb3831b48bd64d.png)

5.  Select “Edit”:  
    

    ![A screenshot of a cell phone Description automatically generated](media/a132851c48e95ad6195cfc786ebeaaed.png)

6.  Expand “Initialize Environment URL” step and enter your environment URL into
    the “Value” field:  
    

    ![A screenshot of a cell phone Description automatically generated](media/3aa881d2fa6290ca1901b5086695f2c4.jpg)

Entities
========

The following are the list of entities available in the solution. The detail
documentation for each entity attributes is available as a [Guided
help](https://docs.microsoft.com/en-us/powerapps/maker/common-data-service/create-custom-help-pages)
within the solution. Follow the instructions in the link to enable guided help
in your environment to see the detail documentation

![A screenshot of a cell phone Description automatically generated](media/0ee1c54bf6b2bea713884c986f4fd35c.png)

Entity Relationship diagram
---------------------------

![A screenshot of a social media post Description automatically generated](media/04a24f70ab03008ee786f4c266fe3c3c.png)

Flows
=====

The solution contains 5 flows.

Daily Email Alerts
------------------

This flow sends email alerts to the Reviewer to review the release plans that
are created/updated by the author. The release plans that are set as “Reviewed?”
to No will be included for review. This includes the following:

![A screenshot of a cell phone Description automatically generated](media/abf2b83c20fc3b23a33333e38cc3aa54.png)

1.  Pending Application Overview reviews (Reviewed ? is No)

    ![A screenshot of a cell phone Description automatically generated](media/e76492bc9a793e3139915cfbc908a302.png)

2.  Pending Application Area reviews (Reviewed? is No)

    ![A screenshot of a cell phone Description automatically generated](media/39781fa4a68c171149d0f56a3b51b89a.png)

3.  Pending Release plan reviews (Reviewed? is No)

    ![A screenshot of a cell phone Description automatically generated](media/3466c9cad09a978b08c91d2eaaa19656.png)

4.  Images that are added in the last 24 hours

    ![A screenshot of a cell phone Description automatically generated](media/007aeb08e84cdf058b564ff7cc269e8d.png)

5.  Release Plans that are in shipped status with no documentation link

    ![A screenshot of a cell phone Description automatically generated](media/98dccbf25456cead36bbbd8b8cddcc0d.png)

Generate Release Plans Word Document
------------------------------------

This flow is useful to generate a Word document that includes all the release
plans for a specific wave and for a specific product. This will help someone to
review all the plans offline.

This flow is triggered from “Generate Document” menu on the Release Wave entity
form. The flow produces a .doc file with information about the selected
applications and saves the file to a SharePoint Folder. Once the file has been
saved, the flow sends an email with a link to the file.

![A screenshot of a cell phone Description automatically generated](media/19b0e32ce42593a19dbe195b27b6fe6a.jpg)

### Steps to generate a .doc file

1.  Open the update form for the Release Wave you are interested in.

2.  Select “Generate Document” tab.

3.  In “Release Plan Applications” sub grid select the applications, details of
    which must be included into the .doc file.

4.  Select “Generate Document”, and then select one of the two options:

    1.  “All Features”: the generated .doc file will include details about all
        features associated with the selected applications. If no application is
        selected, the document will include all the active applications in the
        system.

    2.  “Features Ready to Disclose”: the generated .doc file will include
        details only about features which have “Include in Release Plan” field
        set to “Yes”.

Once the .doc file has been generated and saved to a SharePoint folder you will
receive an email with a link to the file.

Get filter criteria to fetch specific Release Plan records
----------------------------------------------------------

This flow is called by “Generate Release Plans Word document” flow to retrieve
criteria, with which Release Plans will be filtered.

“Get filter criteria to fetch specific Release Plan records” flow allows to
apply custom filter criteria when needed.

To apply custom filter criteria:

1. Change “IncludeAllPlans” variable from True to False:

![](media/91a577e82fbab95abb7a7c08f71a6f9f.jpg)

2. Specify custom filter criteria for Release Plans in the “No” branch of the
condition step:

![A screenshot of a social media post Description automatically generated](media/77dbc9c04c9623a7d4941c7437e3b2e5.jpg)

Set App Overview name when released app updated
-----------------------------------------------

Updates Application Overview name if Application name gets changed. Sets the
overview name in the format "Overview of \<app name\>". Triggers when
Application field of Application Overview entity is created, updated, or
deleted.

![A screenshot of a social media post Description automatically generated](media/cbb1be6ad3ffc6f587fd1ff8e7d6b648.png)

Set overview name when app name changed
---------------------------------------

Updates Application Overview name if another Application is selected for the
overview. Triggers when Application record is created, updated, or deleted.

![A screenshot of a social media post Description automatically generated](media/65882c2c930842a87cea823613b618d6.png)

Business Rules
==============

Lock/Unlock the Public Preview Date
-----------------------------------

If Public Preview Release Status is N/A, the Public Preview Date field must be
locked.

![A screenshot of a video game Description automatically generated](media/52194c927b5105d5b9a3e64fb69aebab.png)

Lock/Unlock the GA Date
-----------------------

If GA Release Status is N/A, the GA Date field must be locked.

![A screenshot of a video game Description automatically generated](media/623c69c9cdacbdd670e646147bf0651c.png)

Form Validators
===============

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

![A screenshot of a computer Description automatically generated](media/12fcbe6fc9b0dbc36c06a301f84a2f2c.png)

Custom Control (Upload Image Tool)
==================================

A custom control created to get the image data from local devices.

Apart from default PCF files it contains “index.ts” for processing the data and
UploadImageTool.css for component styling. ControlManifest.Input.xml contains
PCF name, version and other info plus all parameters visible after selecting it
in the form editor. These can be used to adjust the size of control components.

![A screenshot of a social media post Description automatically generated](media/6902624135dede3ccb5facac7d85de86.png)

The form containing custom control:

![A screenshot of a computer Description automatically generated](media/64b7f936bbd91deedc4616b3cd903458.png)

Each Release Plan may contain multiple attachments which contain the data about
the image uploaded via Image Upload tool (filename, description etc.). In turn
each Release Plan Attachment is related to one of Annotations (Notes) entities
provided out of the box, where the image in base64 format is stored. All
uploaded files can be also found by navigating to Related \> Release Plan
Attachments on Release Plan form.

Security Roles
==============

The following security roles are available in the solution:

| **Role Name**              | **Role Description**                                                                                                                                                                                                                                                      |
|----------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Release Plan – Admin       | This is the administrative role. Users with this role have access to all forms and can make any changes.                                                                                                                                                                  |
| Release Plan – Contributor | This role is designed for content authors. Users with this role have access to **Contributor** forms of Release Plan, Application Area and Application Overview entities. On Contributor forms of these entities **“Reviewed?” field is always read-only**.               |
| Release Plan – Reviewer    | This role is designed for content reviewers. Users with this role have access to **Reviewer** forms of Release Plan, Application Area and Application Overview entities. On Reviewer forms of these entities the **“Include in Release Plan” field is always read-only**. |

Release Plan Audit Plug-in
==========================

Release Plan Audit Plug-in purpose and logic
--------------------------------------------

Release Plan Audit Plug-in is used to automatically create a Release Plan
History record whenever an operation, which meets certain conditions, is
performed on a Release Plan. The following table lists those operations with
their corresponding conditions:

| **Operation type**                  | **Conditions**                                                                                                                                                                                                                                                                                                                                                        | **Release Plan History “Action” field value** |
|-------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-----------------------------------------------|
| A new Release Plan is created       | The creation date is equal to or later than the “Release Plan Cut-off Date” of the Release Wave, to which the new Release Plan belongs.                                                                                                                                                                                                                               | “Created”                                     |
| An existing Release Plan is updated | \- “Include in Release Plan” value has been changed - The date of change is equal to or later than “Release Plan Cut-off Date” of the Release Wave, to which the Release Plan belongs.                                                                                                                                                                                | “Added” or “Removed”                          |
|                                     | \- “Public Preview – Release Date” **and/or** “GA – Release Date” value has been changed **-** The new date(s) is (are) between “Release Start Date” and “Release End Date” of the Release Wave, to which the Release Plan belongs - The date of change is equal to or later than “Release Plan Cut-off Date” of the Release Wave, to which the Release Plan belongs. | “Updated”                                     |

Steps to access Release Plan History records
--------------------------------------------

1.  Open Update form for the Release Plan you are interested in.

2.  Select “Related” tab and then “Release Plan History”.

![A screenshot of a cell phone Description automatically generated](media/4cc57d6e49faf912f7662d0e0b13b080.jpg)

