[Documentation]
The files in this repository can be used to create a base governance solution which uses SQL Server tables to store Environment artifact metadata which can then be used by Flow, PowerApps and PowerBI for environment management.  The files in the repository include:
  - EnvironmentInventory_20190521090037.zip:  This is a Flow which can be imported into your admin environment. In order to collect information from all environments the Flow should be run with an account that has Global Admin rights or BAP Admin rights for the tenant. It's responsible for collecting all of the artifacts in the environment and saving the artifact metadata into a set of SQL Server Tables.  In order to configure this flow you'll need to create a new sql database and use the .SQL Files below to create the required SQL Server Tables.
  - CreateEnvironmentsTable.sql:  Creates the Environments Table which stores all of the environment metadata
  - CreatePowerAppTable.sql: Creates the PowerApp table which stores all of the PowerApps in all environments
  - CreatePowerAppConnectionTable.sql: Creates a PowerAppConnection table which stores all of the connection metadata in use by each PowerApp in the PowerApp table
  - CreateFlowTable.sql: Creates a Flow table which stores all of the flow metadata for all flows in all environments

Database Notes:
  - All tables have a column called "LastRecorded" which keeps a record of the last time information was recorded about a specific artifact.  If the LastRecorded column value is different than the date/time when the flow ran then this means that the artifact was deleted sometime after it's LastRecorded value.

************* START - Updated 5/28/2019 **************

Four new files have been added which will enable you to collect data from the Office 365 Security and Compliance Audit log related to PowerApps and Flows.  You will need global tenant admin permissions or an account with read access to the O365 Audit logs in order to use the O365 Audit Log custom connector.  You should deploy the files in the following order:
  - CreateFlowAuditLogTable.sql:  Creates the FlowAuditLog table which stores audit log entries for Flow
  - CreatePowerAppAuditLogTable.sql:  Creates the PowerAppAuditLog table which stores audit log entries for PowerApps
  - O365-Audit-Logs.swagger.json:  This is the Swagger definition for a custom connector which reads audit log entries. After you import the custom connector you will be required to log into the audit log service with an account that has read permission.
  - UpdateAuditLog_20190528.zip:  Once the SQL Tables and the O365 Audit Log Custom Connector have been created you can import this flow.  It's currently configured to run hourly and collect Flow Create/Edit log entries and PowerApps Update/Publish/Launch entries.  You can customize the recurrence and log entry types by modifying the flow. 

************* END - Updated 5/28/2019 **************


  
