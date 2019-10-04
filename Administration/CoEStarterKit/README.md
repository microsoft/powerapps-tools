# Center of Excellence Starter Kit
Get started with developing your Center of Excellence for PowerApps and Flow.

### Updates
Date | Notes
---|---
2019.06.09 | Initial release
2019.06.17 | Updated documentation
2019.06.20 | Fixed issues with connecting to CDS in Power BI dashboard
2019.06.24 | Fixed issue with Flow reading null field value, updated PBI dashboard, removed Audit Log Sync template from solution (provided as package in download)
2019.07.17 | Fixed issues with validation errors in Flow sync template (including modifications to PowerApps App / iconuri field and Flow / displayname field was not long enough). Addded DLP Editor direct download.
2019.08.26 | Added Solution that does not contain canvas (no canvas apps), provided all canvas app import packages individually. Also added a new canvas app to replace PowerApps app owners.
2019.09.30 | Major updates to Sync template: <br> - Split Sync Template Flow into 5 Flows, making it easier to read and modify: <br> 1. Admin &#124; Sync Template v2 - runs on a schedule and updates environments <br> 2. Admin &#124; Sync Template v2 (Apps) - runs when an environment is created/modified and gets App information, also updates record if Apps are deleted <br> 3. Admin &#124; Sync Template v2 (Flows) - runs when an environment is created/modified and gets Flow information, also updates record if Flows are deleted <br> 4. Admin &#124; Sync Template v2 (Connectors) - runs when an environment is created/modified and gets Connector information <br> 5. Admin &#124; Sync Template v2 (Custom Connector) - runs when an environment is created/modified and gets Custom Connector information <br> - Sync template errors: All Flows implement a Try/Catch/Error logic, and if they fail will send an email to the owner with a link to the workflow run instance. For that, when configuring the Flow owners will need to specify a Flow environment URL. We could look at making this a setting in the CoE kit when they're setting it up so they only have to specify it once. <br> Added 'deleted date' to the entity schema <br> - Power BI: Fixed issues with displaying Flow cities <br> - Model driven app (Power Platform Admin View): Removed 'New' button from all grids to prevent creation of data that's not synced with the Power Platform server

## Known Issues
Currently no known issues.

## Documentation
View the [documentation](./Documentation.pdf) ([download](https://github.com/microsoft/powerapps-tools/raw/master/Administration/CoEStarterKit/Documentation.pdf))

## Download Pack
Directly download the entire solution and all additional components from [aka.ms/CoEStarterKitDownload](https://aka.ms/CoEStarterKitDownload)

## Components
Here is a list of all the components in the starter kit:
### Solution-aware components
These items are installed in the CDS solution 'Center Of Excellence'. You must install the solution to access these components.
#### Common Data Service Entities
Entity | Description 
-|-
Environments | Represents the Environment object, which contains PowerApps, Flows and Connectors. 
PowerApps Apps | Represents a PowerApps App.
Flows | Represents a Flow.
Connectors | Represents a standard or custom connector.
Connection References | Represents a connection used in a PowerApp or Flow.
Makers | Represents a user who has created a PowerApp, Flow, Custom Connector or Environment.
Audit Logs | Represents session details for PowerApps. 
CoE Settings | Settings configurations live in a record here. Contains details for configuring the branding and support aspect of the solution.

#### Flows
List of Flows that come with the solution.
- ##### Admin | Sync Template (v1)
    "Uber" sync Flow that syncs resource data from the admin connectors to the CDS resource entities. 
- ##### Admin | Sync Template (v2)
    Runs on a schedule and updates environments
- ##### Admin | Sync Template v2 (Apps)
    Runs when an environment is created/modified and gets App information, also updates record if Apps are deleted
- ##### Admin | Sync Template v2 (Flows)
    Runs when an environment is created/modified and gets Flow information, also updates record if Flows are deleted
- ##### Admin | Sync Template v2 (Connectors)
    Runs when an environment is created/modified and gets Connector information
- ##### Admin | Sync Template v2 (Custom Connector)
    Runs when an environment is created/modified and gets Custom Connector information
- ##### Admin | Sync Audit Logs
    Uses the Office 365 Audit logs custom connector to write audit log data into the CDS Audit Log entity. This will generate a view of usage for PowerApps.
- ##### Admin | Welcome Email
    Sends an email to a user who creates a PowerApp, Flow, Custom Connector or Environment 
- ##### Admin | Compliance detail request
    Sends an email to users who have PowerApps apps in the tenant who are not compliant with specific thresholds:
    - The app is shared with > 20 Users or at least 1 group and the business justification details have not been provided.
    - The app has business justification details provided but has not been published in 60 days or is missing a description.
    - The app has business justification details provided and has indicated high business impact, and has not submitted a mitigation plan to the attachments field.
    
#### Canvas Apps
- ##### Developer Compliance Center
    This app is used in the PowerApps App Auditing Process, defined later in this document, as a tool for users to submit information to the center of excellence admins as business justification to stay in compliance. They can also use the app to update the description and re-publish, which are other ways to stay in compliance. 
- ##### App Catalog
    Canvas app that gives access to the entire organization to make apps more discoverable. Admins audit and validate certain apps which are graduated to the app catalog if the app is meant to be shared broadly.
- ##### DLP Editor
    Canvas app that reads and updates DLP policies while showing a list of apps that are affected by the policy configurations.
- ##### PowerApps Admin - Set Owner
    Standalone app that updates the canvas app owner and can also assign additional permissions to apps.
 
#### Model Driven App
Power Platform Admin View. A model driven app that provides an interface used to navigate the items in the CDS custom entities. It provides access to views and forms for the custom entities in the solution.
Business Process Flows

#### PowerApps App Approval BPF (Business Process Flow)
This process helps the admin audit the PowerApps App audit process by providing a visual placeholder for the stage in the process they are currently on.

#### Security Roles
Role | Description
-|-
Power Platform Admin SR | Gives full access to create, read, write and delete operations on the custom entities.
Power Platform Maker SR | Gives read and write access to the resource custom entities.
Power Platform User SR | Gives read only access to the resources in the custom entities.

### Non-Solution aware components
The following components are seperate files that are located in the download pack, but are not installed when the CDS solution is installed.

#### Power BI Report
Provides a wholistic view with visualizations and insights of data in the CDS entities: Environments, PowerApps Apps, Flows, Connectors, Connection References, Makers and Audit Logs.
 
#### Office 365 Logs Custom Connector
The custom connector swagger definition for getting audit logs programmatically.

#### Flow: Sync Audit Logs
This Flow comes as a package (.zip) and should be imported seperately from the solution.

#### Documentation
The most updated details on the solution will always be published in the documentation file.

## Support
Questions, comments, concerns, or interest in contributing? Please post your feedback in the [Administering PowerApps community forum](https://powerusers.microsoft.com/t5/Administering-PowerApps/bd-p/Admin_PowerApps). 
