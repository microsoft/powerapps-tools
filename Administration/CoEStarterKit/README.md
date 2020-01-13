# Center of Excellence Starter Kit
The Center of Excellence (CoE) Starter Kit is a set of templates that are designed to help develop a strategy for adopting, maintaining and supporting the Power Platform, with a focus on Power Apps and Power Automate. The kit provides automation and tooling to help teams build monitoring and automation necessary to support a CoE.  The foundation of the kit is a Common Data Service (CDS) data model and workflows to collect resource information across the environments in the tenant (Sync flows).  The kit includes multiple Power Apps and Power BI analytics reports to view and interact with the data collected.  The kit also provides several assets that provide templates and suggested patterns and practices for implementing CoE efforts. The assets part of the CoE Starter Kit should be seen as a template from which you inherit your individual solution or can serve as inspiration for implementing your own apps and flows.

### Latest Update
(view previous updates in the [PreviousSolutionVersions](https://github.com/microsoft/powerapps-tools/tree/master/Administration/CoEStarterKit/PreviousSolutionVersions) folder

Date | Notes
---|---
2020.01.13 | 1. **NEW** Solution has been split into Core Components, Compliance Components and Nurture Components to make it easier to get started with the installation and deployment
2. **UPDATE** Improved error handling in the Sync Flows, providing a few and daily report of failed Syncs
3. **UPDATE** Improved reliability of Archive and Clean Up App Flows
4. **UPDATE** PowerApps App entity through Sync Flow (Apps) now stores SharePoint Form URL for SharePoint embedded list forms & App Type reflects SharePoint Form App
5. **UPDATE** PowerApps Connector entity through Sync Flow (Connectors) now stores Connector Tier (Standard/Premium) and Publisher (Microsoft etc)
6. **UPDATE** Canvas Apps have been updated to use the Common Data SErvice (Current Environment) connector to improve performance
7. **NEW** Solutions now use Environment Variables, to avoid you having to go into individual Flows and update variables 

## Known Issues and Limitations
1. The CoE Starter Kit is currently not available in GCC environments, as the Flow Management connector is not available in this environment yet
2. Set New App Owner: the management connector action does not support setting new owners for SharePoint apps.
3. DLP Editor: Only returns the first 2000 environments and can not write back environment-type policies.
4. Admin Sync Template v2 Flows: The CDS connector might experience some throttling limits if the tenant has a lot of resources. If you see 429 errors in the Flow run history occurring in the later runs, you can configure a Retry Policy. 

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
