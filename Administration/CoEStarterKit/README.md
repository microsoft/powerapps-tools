# Center of Excellence Starter Kit
The Center of Excellence (CoE) Starter Kit is a set of templates that are designed to help develop a strategy for adopting, maintaining and supporting the Power Platform, with a focus on Power Apps and Power Automate. The kit includes multiple Power Apps and Power BI analytics reports to view and interact with the data collected.  The kit also provides several assets that provide templates and suggested patterns and practices for implementing CoE efforts. The assets part of the CoE Starter Kit should be seen as a template from which you inherit your individual solution or can serve as inspiration for implementing your own apps and flows.

## Setup Instructions and Documentation
Please find all information on how to install and use the kit on https://docs.microsoft.com/power-platform/guidance/coe/starter-kit

### Latest Update
Date | Notes
---|---
2021.04.08 | **Core Components**: We are now capturing Capacity and Add-On information for Environments. Information is captured in the Admin \| Sync Template v3 flow, and written to new Environment Capacity and Environment Add-On tables that have a 1:n relationship with Environment. We also added an Environment Business Area table that allows a customer to add a cost code, business area, and environment owner to an Environment - an admin would have to manually add this information in the model driven app. Admins can also set approved capacity and receive alerts when environments are over or close to their approved capacity. No enforcement takes place here, of course, it's just a number to compare to. We have added the Admin \| Welcome Email and App Catalog, previously in Nurture, to Core in an effort to uncouple Nurture from Core and allow it to be installed stand-alone. With the current release, there's still a dependency on the CoE settings table in Core but with the next release we will move those settings to Environment Variables. The Power BI Report has been changed from Import to DirectQuery mode and is using the new Dataverse connector to get the data now. This means you will have to have access to the underlying data to view the report and you will no longer need to set a schedule refresh on the dataset.<br>**Core Components for Teams**: The CoE Starter Kit can now be installed in Dataverse for Teams environments, docs will be updated with setup instructions - for Core, a forked solution called Core for Teams will have to be used. **Governance Components**: This solution can be installed in both Production and Dataverse for Teams environment (the same solution). The Developer Compliance Center has been updated with a new responsive layout and teams look. We have added a new Environment variable to allow customers to exclude the Default environment from the Admin \| Compliance detail request flow, based on customer feedback. **Nurture Components**: This solution can be installed in both Production and Dataverse for Teams environment (the same solution). All apps have been updated with a new responsive layout and teams look. We have developed a new tool called Maker Assessment which has been added to the Nurture solution. This app will take a maker through a set of questions, and they will receive governance and license considerations to keep in mind prior to building the solution. The goal is for a maker to make the best decision possible based on what their internal policies and support is (e.g. they won't start using AI Builder with a trial if their company is not ready to support this yet). We provide a starter set of questions that customers can update and change with an admin app.
2021.03.03 | **Core Components**: Sync Flow (Apps) has been optimized into seperate loops. PowerApps App and Flow tables have new Environment ID fields, and Sync Flow (Apps) and Sync Flow (Flow) flows store the ID to avoid delegation issues in the DLP Editor. DLP Editor v2 has been updated to avoid delegation. **Governance and Nurture components**: canvas apps have been updated with responsive layouts. **Audit Log components** JSON schema has been updated based on customer issues.
2021.02.03 | ALM Accelerator for Makers (GitHub): Fixed an issue with provisioning environments that was caused by an update to the Power Platform Admin connector #739. Also, included is an update to the default for the environment variable that dictates the GitHub template to use when provisioning a new GitHub repo #708
2021.02.01 | Core Components: New Exclude from Archive flag on PowerApps App and Flow tables. DLP Editor added. Governance Components: Archive flows have been updated to ignore apps and flows that have the Exclude from Archive flag set, and flows have been updated to use the Common Data Service (Current Environment) connector. Nurture Components: Welcome email updated to remove broken links. Audit Log: Updated to avoid duplicate write issue.
2021.01.06 | Core Components: Sync flows updated to use Common Data Service (Current Environment) connector, as well as bug fixes per GitHub issues. Innovation Backlog: updated to be Dataverse for Teams environment compatible. Power BI dashboard: updated to use new naming conventions (Desktop Flow and Cloud Flow).
2020.11.24 | Core Components: Bug fixes to PVA sync flow and Power Apps User Shared With sync flow, added missing filters in Power BI dasbhoard. Audit Logs: updated to now work with connection references.
2020.11.16 | Core Components: Bug fixes to sync flows, new columns in Environment table for Microsoft Teams environment management. Governance components: New flows to manage Microsoft Teams environments. Power BI Dashboard: complete refresh of style.
2020.10.16 | Find our release notes on docs: https://docs.microsoft.com/en-us/power-platform/guidance/coe/release-notes
2020.08.14 | Core and Governance Components: Bug fixes, and adding the Audit process for Flows, Chatbots and Custom Connectors - both in Developer Compliance Center, as well as through BPFs in the Power Platform Admin View.
2020.07.24 | Core Components: Fix to a bug in Admin | Sync Template v2 (Power Apps User Shared With), which caused fetching user permissions in Default environment to fail. Fix to a bug in Admin | Sync Template v2 (Model Driven Apps), which caused environments with crm urls not ending in .crm to fail to sync. Example impact are environments like those with .crm4 in the url. Fix to a bug in Admin | Sync Template v2 (PVA), which caused a failure when syncing a PVA Component’s flow, when that flow has not yet been added to the Flow entity.
2020.07.16 | Theming Components: Launched new theming components to create, manage and share canvas app themes.
2020.07.14 | Core Components: Bug fixed on Sync Template v2 (Power Apps User Shared With) flow, and increased exponential retry policy on Sync Template v2 (PVA) flow.
2020.07.07 | Core Components: now include Power Virtual Agents, Canvas App Shared With Users/Groups inventory, new Set App and Flow Permissions apps. Governance components: new Flow archival components. Audit Log solution update to improve performance reliability. If you are using a previous version of the Audit Log solution we highly recommend you upgrade as soon as possible.
2020.05.13 | Core Components: Performance Improvements and improved handling of Legacy environments in Sync Flows. Audit Logs: Bug fixes and now record Deleted App and Deleted Flow audit log events.
2020.05.04 | Core Components: Improvements on handling orphaned resources, Skipping Developer Environments for Model Driven Apps, storing App Plan Classification information in Power Apps App entity, Governance Components: Fixed scope of Archive Approval (was Business Unit, is Organization), new Power BI Dashboard that shows App Plan Classification
2020.04.17 | New advanced Power BI Dashboard (Dashboard-PowerPlatformAdminDashboard_2020-04-17_advanced) is available. Included flows that will create SharePoint lists and document libraries. Updated solutions with bug fixes.
2020.04.09 | Documentation and Setup instructions have moved to https://docs.microsoft.com/power-platform/guidance/coe/starter-kit. 
2020.03.18 | Added Solution (Custom Connector and Power Automate flows) to configure the sync of Audit Logs if MFA is enabled or basic authentication is not desired.
2020.02.12 | New Power BI Dashboard
2020.02.11 | Bug fixes to Sync Template (Model Driven App), Training in a day Flows (updated to use CDS Current Environment), introducing new Setup Instructions documentation 
2020.02.06 | Added temporary solution file for environments that experience the Invalid Argument error on solution import.
2020.01.13 | 1. **NEW** Solution has been split into Core Components, Compliance Components and Nurture Components to make it easier to get started with the installation and deployment<br> 2. **UPDATE** Improved error handling in the Sync Flows, providing a few and daily report of failed Syncs <br>3. **UPDATE** Improved reliability of Archive and Clean Up App Flows <br>4. **UPDATE** PowerApps App entity through Sync Flow (Apps) now stores SharePoint Form URL for SharePoint embedded list forms & App Type reflects SharePoint Form App <br>5. **UPDATE** PowerApps Connector entity through Sync Flow (Connectors) now stores Connector Tier (Standard/Premium) and Publisher (Microsoft etc) <br>6. **UPDATE** Canvas Apps have been updated to use the Common Data SErvice (Current Environment) connector to improve performance <br>7. **NEW** Solutions now use Environment Variables, to avoid you having to go into individual Flows and update variables 

The CoE Starter Kit consists of three solutions;

### Center of Excellence – Core Components 
These components provide the core to get started with setting up a CoE – they sync all your resources into entities and build admin apps on top of that to help you get more visibility of what apps, flows and makers are in your environment. Additionally, apps like the DLP Editor and Set New App Owner help with daily admin tasks.
The Core Components solution only contains assets relevant to admins. No assets need to be shared with other makers or end users.
**Requirements:**  Users(s) will require a Per User license, as well as Global or Power Platform Service Admin permissions

### Center of Excellence – Governance Components
Once you are familiar with your environments and resources, you will start thinking about audit and compliance processes for your apps. You will also want to gather additional information about your apps from your makers, and to audit specific connectors or app usage - apps like the Developer Compliance Center and flows to identify connector usage part of this solution will help with that.
The Audit Components solution contains assets relevant to admins and existing makers. 
The Audit Components provides a layer on top of the Core Components, it is required to install the Core Components prior to using the Audit Components. 
**License Requirements:**  Makers participating in the audit and compliance workflows will need a Per App or Per User License.

### Center of Excellence – Nurture Components
An essential part of establishing a CoE is nurturing your makers and internal community. You will want to share best practices and templates and onboard new makers – the assets part of this solution, like the Welcome Email and Template Catalog can help develop a strategy for this motion.
The Nurture Components solution contains assets relevant to everyone in the organisation. 
The Nurture Components provides a layer on top of the Core Components, it is required to install the Core Components prior to using the Nurture Components.
**License Requirements:**  Anyone in CoE community will need a Per App or Per User License.

### Center of Excellence – Theming Components

A frequent ask when creating canvas apps apps is theming and specifically the ability to create apps that match the organization brand.  The assets in this solution will help you create, manage and share themes.
The Theming Components solution contains assets that are relevant to makers and designers. 

We recommend getting started and familiar with the **Center of Excellence – Core Components** before adding the Audit and Nurture components or building your own assets on top of the Core Components entities.

## Known Issues and Limitations
Notes on some limitations: https://docs.microsoft.com/en-us/power-platform/guidance/coe/limitations

## Download Pack
Directly download the entire solution and all additional components from [aka.ms/CoEStarterKitDownload](https://aka.ms/CoEStarterKitDownload)

## Disclaimer
Although the underlying features and components used to build the Center of Excellence (CoE) Starter Kit (such as Common Data Service, admin APIs, and connectors) are fully supported, the kit itself represents sample implementations of these features. Our customers and community can use and customize these features to implement admin and governance capabilities in their organizations.

If you face issues with:

- **Using the kit**: Report your issue here: [aka.ms/coe-starter-kit-issues](https://aka.ms/coe-starter-kit-issues). (Microsoft Support won't help you with issues related to this kit, but they will help with related, underlying platform and feature issues.)
- The **core features in Power Platform**: Use your standard channel to contact Support.

## Credits

The CoE Starter Kit wouldn't exist and continue to evolve without the wonderful contributions from our Power Platform community. Many customers and champions are influencing the continued journey, and we would like to especially give a shout out to [Rebekka Aalbers](https://twitter.com/RebekkaAalbers), [Paul Culmsee](https://twitter.com/paulculmsee), [Alan Chai](https://twitter.com/alanchai), [Daniel Laskewitz](https://twitter.com/laskewitz).

The theming components are inspired by or are using elements from:
- Sancho Harker https://github.com/iAmManCat
- Richard Wilson https://pcf.gallery/pcf-color-picker/
- Eickhel Mendoza https://pcf.gallery/powerfont/ 

