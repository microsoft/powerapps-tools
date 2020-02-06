# Center of Excellence Starter Kit
The Center of Excellence (CoE) Starter Kit is a set of templates that are designed to help develop a strategy for adopting, maintaining and supporting the Power Platform, with a focus on Power Apps and Power Automate. The kit includes multiple Power Apps and Power BI analytics reports to view and interact with the data collected.  The kit also provides several assets that provide templates and suggested patterns and practices for implementing CoE efforts. The assets part of the CoE Starter Kit should be seen as a template from which you inherit your individual solution or can serve as inspiration for implementing your own apps and flows.

```diff
- Some users have reported getting an [Invalid argument error](https://github.com/microsoft/powerapps-tools/issues/62) on importing the solution. This is due to a breaking change on the CDS side. A permanent fix is being worked on, in the meantime if you are getting this error please use the solution file in the **TEMP FIX for Invalid Argument Error** file instaed
```

The CoE Starter Kit consists of three solutions;

### Center of Excellence – Core Components 
These components provide the core to get started with setting up a CoE – they sync all your resources into entities and build admin apps on top of that to help you get more visibility of what apps, flows and makers are in your environment. Additionally, apps like the DLP Editor and Set New App Owner help with daily admin tasks.
The Core Components solution only contains assets relevant to admins. No assets need to be shared with other makers or end users.
**Requirements:**  Users(s) will require a Per User license, as well as Global or Power Platform Service Admin permissions

### Center of Excellence – Compliance Components
Once you are familiar with your environments and resources, you will start thinking about audit and compliance processes for your apps. You will also want to gather additional information about your apps from your makers, and to audit specific connectors or app usage - apps like the Developer Compliance Center and flows to identify connector usage part of this solution will help with that.
The Audit Components solution contains assets relevant to admins and existing makers. 
The Audit Components provides a layer on top of the Core Components, it is required to install the Core Components prior to using the Audit Components. 
**License Requirements:**  Makers participating in the audit and compliance workflows will need a Per App or Per User License.

### Center of Excellence – Nurture Components
An essential part of establishing a CoE is nurturing your makers and internal community. You will want to share best practices and templates and onboard new makers – the assets part of this solution, like the Welcome Email and Template Catalog can help develop a strategy for this motion.
The Nurture Components solution contains assets relevant to everyone in the organisation. 
The Nurture Components provides a layer on top of the Core Components, it is required to install the Core Components prior to using the Nurture Components.
**License Requirements:**  Anyone in CoE community will need a Per App or Per User License.

We recommend getting started and familiar with the **Center of Excellence – Core Components** before adding the Audit and Nurture components or building your own assets on top of the Core Components entities.
1.	If you are new to the CoE Starter Kit, start by installing the CoE Starter Kit – Core Components by following the Setup Instructions
2.	If you have previously installed the CoE Starter Kit MANAGED solution and have already started collecting metadata for your apps through the Developer Compliance Center, export the data from the PowerApps App entity, uninstall the CoE Starter Kit solution, install the CoE Starter Kit – Core Components solution and re-import the PowerApps App entity data. Please view the [documentation](https://github.com/microsoft/powerapps-tools/blob/master/Administration/CoEStarterKit/CoE%20Starter%20Kit%20-%20Documentation%20and%20Setup%20Instructions.pdf) for detailed instructions on how to do this.
3.	If you have previously installed the CoE Starter Kit UNMANAGED solution, uninstall the solution before installing the CoE Starter Kit – Core Components solution.


### Latest Update
Date | Notes
---|---
2020.02.06 | Added temporary solution file for environments that experience the Invalid Argument error on solution import.
2020.01.13 | 1. **NEW** Solution has been split into Core Components, Compliance Components and Nurture Components to make it easier to get started with the installation and deployment<br> 2. **UPDATE** Improved error handling in the Sync Flows, providing a few and daily report of failed Syncs <br>3. **UPDATE** Improved reliability of Archive and Clean Up App Flows <br>4. **UPDATE** PowerApps App entity through Sync Flow (Apps) now stores SharePoint Form URL for SharePoint embedded list forms & App Type reflects SharePoint Form App <br>5. **UPDATE** PowerApps Connector entity through Sync Flow (Connectors) now stores Connector Tier (Standard/Premium) and Publisher (Microsoft etc) <br>6. **UPDATE** Canvas Apps have been updated to use the Common Data SErvice (Current Environment) connector to improve performance <br>7. **NEW** Solutions now use Environment Variables, to avoid you having to go into individual Flows and update variables 

(view previous updates in the [PreviousSolutionVersions](https://github.com/microsoft/powerapps-tools/tree/master/Administration/CoEStarterKit/PreviousSolutionVersions) folder

## Known Issues and Limitations
1. The CoE Starter Kit is currently not available in GCC environments, as the Flow Management connector is not available in this environment yet
2. Set New App Owner: the management connector action does not support setting new owners for SharePoint apps.
3. DLP Editor: Only returns the first 2000 environments and can not write back environment-type policies.
4. Admin Sync Template v2 Flows: The CDS connector might experience some throttling limits if the tenant has a lot of resources. If you see 429 errors in the Flow run history occurring in the later runs, you can configure a Retry Policy. 
**5. Users in some environments might get an "Invalid Argument" error on trying to import the solution. This is a known issue, and we are working on providing a fix for this soon.**


## Documentation
View the [documentation](https://github.com/microsoft/powerapps-tools/blob/master/Administration/CoEStarterKit/CoE%20Starter%20Kit%20-%20Documentation%20and%20Setup%20Instructions.pdf)

## Download Pack
Directly download the entire solution and all additional components from [aka.ms/CoEStarterKitDownload](https://aka.ms/CoEStarterKitDownload)

## Components
Find a list of all components in the documentation file and a list in the Individual Components folder.

## Disclaimer
The Center of Excellence (CoE) Starter Kit is not supported by the Power Platform product team (which is true for all tools available in this GitHub repo). We are a small team in Engineering who built this unsupported community sample solution for anyone to use and modify as their own, made available to customers on an as-is basis via an [MIT license](https://github.com/microsoft/powerapps-tools/blob/master/LICENSE). It’s possible you might run into some issues, such as installation problems, authorization issues, or bugs in the apps and flows within the solution. 

## Support
Please, do not raise support tickets for issues related to this toolkit in the Power Platform Admin Center or any official product portal. 
Instead, kindly. 
1. Make sure you have read through the entire documentation 
2. If the issue is not addressed in the documentation, raise a new issue in the [issues tab](https://github.com/microsoft/powerapps-tools/issues) of this repo. Someone from the team will respond to your issue there.  
