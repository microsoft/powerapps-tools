# Center of Excellence Starter Kit - Individual Components
The Center of Excellence (CoE) Starter Kit is a set of templates that are designed to help develop a strategy for adopting, maintaining and supporting the Power Platform, with a focus on Power Apps and Power Automate. The kit provides automation and tooling to help teams build monitoring and automation necessary to support a CoE.  The foundation of the kit is a Common Data Service (CDS) data model and workflows to collect resource information across the environments in the tenant (Sync flows).  The kit includes multiple Power Apps and Power BI analytics reports to view and interact with the data collected.  The kit also provides several assets that provide templates and suggested patterns and practices for implementing CoE efforts. The assets part of the CoE Starter Kit should be seen as a template from which you inherit your individual solution or can serve as inspiration for implementing your own apps and flows.

## Components
Here is a list of all the components in the starter kit:
### Solution-aware components
These items are installed in the CDS solution 'Center Of Excellence'. You must install the solution to access these components.
#### Common Data Service Entities
Solution | Entity | Description 
-|-|-
Core Components | Environments | Represents the Environment object, which contains PowerApps, Flows and Connectors. 
Core Components | PowerApps Apps | Represents a PowerApps App.
Core Components | Flows | Represents a Flow.
Core Components | PowerApps Connectors | Represents a standard or custom connector.
Core Components | Connection References | Represents a connection used in a PowerApp or Flow.
Core Components | Makers | Represents a user who has created a PowerApp, Flow, Custom Connector or Environment.
Core Components | Audit Logs | Represents session details for PowerApps. 
Core Components | CoE Settings | Settings configurations live in a record here. Contains details for configuring the branding and support aspect of the solution.
Core Components | Sync Flow Errors | Represents errors that occur during the run of the Sync Flows
Compliance Components | Archive Approval | Represents apps highlighted for archival and their approval status
Nurture Components | In A Day Attendees | Represents users that have registered for training in a day events
Nurture Components | In A Day Events | Represents training in a day events

#### Flows
List of Flows that come within each solution.

##### Core Components
- ###### Admin | Sync Template (v2)
    Runs on a schedule and updates environments
- ###### Admin | Sync Template v2 (Apps)
    Runs when an environment is created/modified and gets App information, also updates record if Apps are deleted
- ###### Admin | Sync Template v2 (Flows)
    Runs when an environment is created/modified and gets Flow information, also updates record if Flows are deleted
- ###### Admin | Sync Template v2 (Connectors)
    Runs when an environment is created/modified and gets Connector information
- ###### Admin | Sync Template v2 (Custom Connector)
    Runs when an environment is created/modified and gets Custom Connector information
- ###### Admin | Sync Template v2 (Sync Flow Errors)
    Runs on a schedule and sends an email of environments that failed to sync with a link to the Flow instance to the admin
- ###### Admin | Sync Audit Logs
    Uses the Office 365 Audit logs custom connector to write audit log data into the CDS Audit Log entity. This will generate a view of usage for PowerApps.

##### Compliance Components
- ###### Admin | Compliance detail request
    Sends an email to users who have PowerApps apps in the tenant who are not compliant with specific thresholds:
    - The app is shared with > 20 Users or at least 1 group and the business justification details have not been provided.
    - The app has business justification details provided but has not been published in 60 days or is missing a description.
    - The app has business justification details provided and has indicated high business impact, and has not submitted a mitigation plan to the attachments field.
- ###### Admin | App Archive and Clean Up - Start Approval
    Checks for apps that have not been modified in the last six months (configurable) and asks the app owner (via Flow Approvals) if the app can be archived.  This Flow starts the approval and writes the Approval Task to the ‘Archive Approval’ CDS Entity. 
- ###### Admin | App Archive and Clean Up - Check Approval
    Monitors Approval Responses of the App Archive and Clean Up – Start Approval Flow and, if approved, archives the app file to SharePoint. 
    Pre-Requisite: Create a SharePoint document library to store the archived apps and configure this in Flow 
    Update: By default, this Flow will archive the application but not remove it or its permission from the environment. Update this Flow based on your requirements, to delete the app from the environment, or remove app permissions.   
- ###### SETUP REQUIRED | Admin | Find and disable flows that leverage certain connectors
    Checks if any Flows are using specific connectors, notifies the Flow maker and disables the Flow. The admin will receive a report.   
- ###### SETUP REQUIRED | Admin | Find and add admins as owners for apps that leverage certain connectors 
    Checks for apps that leverage certain connectors; notifies the app maker and shares the app with the admin security group. 

##### Nurture Components

- ###### Admin | Welcome Email
    Sends an email to a user who creates a PowerApp, Flow, Custom Connector or Environment 
- ###### Admin | Newsletter with Product Updates
    Sends a weekly email with a summary of product updates, consisting of blog posts from the PowerApps / Flow / Power BI Product blogs and PowerApps Community blog 
- ###### Training in a day | Feedback Reminder
    Sends an email to attendees of a training in a day event on the day and requests feedback 
- ###### Training in a day | Registration Confirmation
    Sends an email to an attendee when they register for a training in a day event 
- ###### Training in a day | Reminder
    Sends an email to an attendee of a training in a day event 3 days prior to the event 

#### Canvas Apps

##### Core Components
- ##### DLP Editor
    Canvas app that reads and updates DLP policies while showing a list of apps that are affected by the policy configurations.
    - ##### DLP Customizer
    Canvas app that allows you to add Custom Connectors to the Business Data Group of a DLP Policy.
- ##### Set New App Owner
    Standalone app that updates the canvas app owner and can also assign additional permissions to apps.


##### Compliance Components
- ##### Developer Compliance Center
    This app is used in the PowerApps App Auditing Process, defined later in this document, as a tool for users to submit information to the center of excellence admins as business justification to stay in compliance. They can also use the app to update the description and re-publish, which are other ways to stay in compliance. 

##### Nurture Components
- ##### App Catalog
    Canvas app that gives access to the entire organization to make apps more discoverable. Admins audit and validate certain apps which are graduated to the app catalog if the app is meant to be shared broadly.
- ##### Template Catalog
    Canvas app that allows CoE Admins to share app and component templates as well as best practice documents with their makers. 
- ##### Training in a day Registration
    If you are planning to run internal App / Flow / Custom in a day event, this canvas app will enable your end users to register for upcoming events 
- ##### Training in a day Management
    If you are planning to run internal App / Flow / Custom in a day event, this canvas app will enable you to create and manage events 

#### Model Driven App
**Power Platform Admin View.** (Core Components) A model driven app that provides an interface used to navigate the items in the CDS custom entities. It provides access to views and forms for the custom entities in the solution.
Business Process Flows
**App Archive and Clean Up View.** (Compliance Components) A model driven app that provides an interface to apps that have been highlighted for archiving, and their approval status.

#### PowerApps App Approval BPF (Business Process Flow | Core Components)
This process helps the admin audit the PowerApps App audit process by providing a visual placeholder for the stage in the process they are currently on.

#### Security Roles (Core Components)
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
