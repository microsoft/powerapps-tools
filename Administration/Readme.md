[Documentation]
The files in this repository can be used to create a base governance solution which uses SQL Server tables to store Environment artifact metadata which can then be used by Flow, PowerApps and PowerBI for environment management.  The files in the repository include:
  - EnvironmentInventory_20190521090037.zip:  This is a Flow which can be imported into your admin environment. In order to collect information from all environments the Flow should be run with an account that has Global Admin rights or BAP Admin rights for the tenant. It's responsible for collecting all of the artifacts in the environment and saving the artifact metadata into a set of SQL Server Tables.  In order to configure this flow you'll need to create a new sql database and use the .SQL Files below to create the required SQL Server Tables.
  - CreateEnvironmentsTable.sql:  Creates the Environments Table which stores all of the environment metadata
  - CreatePowerAppTable.sql: Creates the PowerApp table which stores all of the PowerApps in all environments
  - CreatePowerAppConnectionTable.sql: Creates a PowerAppConnection table which stores all of the connection metadata in use by each PowerApp in the PowerApp table
  - CreateFlowTable.sql: Creates a Flow table which stores all of the flow metadata for all flows in all environments
  
Database Notes:
  - All tables have a column called "LastRecorded" which keeps a record of the last time information was recorded about a specific artifact.  If the LastRecorded column value is different than the date/time when the flow ran then this means that the artifact was deleted sometime after it's LastRecorded value.
  
