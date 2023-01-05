
# Security Risk Assessment and Management
The version 1 of the app - [Security Management](https://github.com/microsoft/powerapps-tools/tree/master/Apps/Security%20Management), provided features for admins to manage security roles assignment, column security role management, team members management and view user profile with all their security aspects. This new version of the app, is a Model Driven app with custom pages, that has all the same screens from the previous app and also includes Security role risk assessment. The new screen displays a list of security roles from the current environment and you can select one to display the privileges that are associated with that security role. You can also visualize the grouping of these privileges by table or individual privilege. 

## Purpose
As you onboard to start using DataVerse from the complete low code platform (Power platform), you are introduced to multiple security constructs. This security risk assessment and management app is an attempt to simplify the management of security with in a single environment and also provide a way for admins to get an assessment of these security roles. This app provides administrators and users a way to know what security privilege are assigned to a security role and how they will impact the end users interaction. The app will have the below screens:
*  Security Roles assignment management
*  Team users assignment management
*  Column security roles assignment management
*  User profile showing all security postures
*  Summary of security role risk assessments 
*  A summary screen showing the security roles with latest assessment and usage 

![image](https://user-images.githubusercontent.com/71347619/209739584-9a3a1a21-659d-4f7f-a0dc-0d72d6eab28f.png)

## Prerequisites
The previous version of the app was purely one zip file. This version packs a lot of features and to bring the best a few existing resources/contributions are used as part of this app. These solutions will need to be installed before the actual import of the app.  
1. Install the [Creator Kit](https://appsource.microsoft.com/en-US/marketplace/apps?product=power-platform&search=creator%20kit&page=1). Its best to install from the solutions page by clicking on the Open App Source  button. 
2. Download the [Colorful Option set](https://github.com/ORBISAG/ORBIS.PCF.ColorfulOptionset/releases) PCF Component. Thanks to Diana for the community contribution. 
2. [Optional] Setup the Dataverse connection if one doesn't exist. This can also be created at the time of import. 

## Known Issues
A few know issues/features are:
- Security role summary screen displaying the cards takes time to load
- Privileges screen pane #3 shows only 2000 rows at max. This particularly effects secuirty roles with a lot of privileges like System Administrator
- Addition or Removal of privileges from the System Administrator or System Customizer is restricted (buttons are disabled)
- Addition of privilege to a security role will only add the privilege at the least level possible
    
## Install
1. Download the solution zip file 
2. In PowerApps studio, navigate to solutions and Import the zip file downloaded 
3. Select the solution zip file from the downloaded location
4. Select the Dataverse connection during import 

## Approach
A new table is created to capture the request. On creation of the record in the table a power automate flow triggers. As prt of the flow base assessment is retrieved and applied for privileges associated with the security role. Once the process is complete the same record is updated with risk assessment and a count of all privileges at various levels. 
- An assessment can be left in draft state before setting to submitted processing. 
- An assessment can be initiated from the Security roles assessment summary page by clicking on the shield icon
- Security roles assessment summary shows the color of the shield based on last assessment
- Screens from the old app have been converted into custom pages 

# How does the app assess the security role?
A base set assessment for each privilege and level is recommended. However, the user can toggle the button to override, provide a reason for toggle and set their own assessments. 
      ![image](https://user-images.githubusercontent.com/71347619/209748800-76f2c20a-91d5-4b5e-ad7b-9d9f5aba5cb5.png)
Power automate logic retrieves the base assessment rules, retrieves the privileges associated with the flow. Based on the level of the privilege the base assessment is applied to calculate the number of privileges under each role.

## Security Risk assessment grid
This screen shows the risk assessments in a model driven app grid. It gives a quick summary of all assessments with numbers and over all assessment.  
 
 ![image](https://user-images.githubusercontent.com/71347619/209739333-67a1b02c-31e2-417e-9ff2-da58711288ce.png)

## Security Role Summary
This screen presents one card for each security role, irrespective of whether they are assessed or not. A colored shield indicates the latest security assessment. A no color shield can be clicked on to start a new assessment  

 ![image](https://user-images.githubusercontent.com/71347619/209746527-4cdfbcca-d418-4ebd-a3fd-6a194296099e.png)
 
The summary shows additional information of how many users, teams are associated with this role. Also, it shows the number of apps that are associated with this app. In this case 26 users are assigned the Basic role and there 0 teams and no apps assigned to this role. 

![2023-01-04_22-55-18](https://user-images.githubusercontent.com/71347619/210720155-9cc53361-2959-4884-93b9-fbfa7b741f23.gif)


## Security Role Management Screen
This screen shows the roles that are available in this environment. First security role is selected by default and corresponding users and teams associated with this security role are displayed. A picture for users is displayed using the office 365 connector. 

![image](https://user-images.githubusercontent.com/71347619/210715339-a3a72702-52dd-4e0c-91b5-412351a152b9.png)

## Security Role Privileges Screen
A new screen added to display privileges for a selected security role. There are 4 panes 

- The first pane lists all the security roles from this environment. 
- The second pane summarizes the privileges by Table name if they belong to a table or as a individual privilege.
- The third pane shows the privileges that are assigned to the role and 
- The fourth pane displays all privileges. A + icon is enabled next to a privilege if its not already assigned to the role. As you scroll down more rows get loaded based on the delegation used with Common Dataverse.
- #5 in screenshot shows a filter text box that will filter in both #3 and #4. If a selection is made from #2 the value gets populated in this filter text field to show the privileges with that text
- #6 is summary of numbers across the various panes. 
    
    Upon selecting one of the values, the text is set for filtering privileges in both assigned and unassigned panes. In the below example even though Connection Reference is a separate table it shows up as unassigned since it matches by the name activity.  

![image](https://user-images.githubusercontent.com/71347619/210715735-a3bc799a-731d-4bab-89aa-0c756c53cc9e.png)


## Team Management Screen
This screen shows the teams that are available, basic information about the team. Selecting a team will show associated users and teams

![image](https://user-images.githubusercontent.com/71347619/210715798-b0b4ded4-935e-4dd8-892e-183670df6f5f.png)

- A new team can be created (NOTE: The window launched will default to Owner team)

## Column security profile management
This screen shows the column security profiles that are available in this environment. Selecting a field security profile, will show associated users and fields along with permissions that are assigned for each.

![image](https://user-images.githubusercontent.com/71347619/210715834-69aeae68-f1e1-440d-b958-5eb7a0e41f71.png)


## User Profile
A users picture is displayed with basic information. The security roles, field security profiles and teams that this user is associated are displayed. The can be removed from any of these or added to an existing object in respective area.
        
![image](https://user-images.githubusercontent.com/71347619/210715891-2764e2ba-7bfc-4be9-bc15-3ce4f39d44dd.png)

For any feedback and feature requests, please report them as part of this git hub. 

## References 
- Security concepts in Microsoft Dataverse - https://docs.microsoft.com/en-us/power-platform/admin/wp-security-cds
- Security in Microsoft Power Platform - https://docs.microsoft.com/en-us/power-platform/admin/security/overview

## Support
Please do not open a support ticket if you encounter any bugs with the solution itself, unless it is related to an underlying platform issue unrelated to the template's implementation. If there are issues related to the solution implementation itself, please [report bugs here](https://github.com/microsoft/powerapps-tools/issues/new?assignees=Ravi-Chada&labels=securitymgmt&template=-security-management-app--bug-report.md&title=%5BBUG%5D+Security+Management%3A+).

### Disclaimer
*This app is a sample and may be used with Microsoft Power Apps and Teams for dissemination of reference information only. This app is not intended or made available for use as a medical device, clinical support, diagnostic tool, or other technology intended to be used in the diagnosis, cure, mitigation, treatment, or prevention of disease or other conditions, and no license or right is granted by Microsoft to use this app for such purposes. This app is not designed or intended to be a substitute for professional medical advice, diagnosis, treatment, or judgement and should not be used as such. Customer bears the sole risk and responsibility for any use of this app. Microsoft does not warrant that the app or any materials provided in connection therewith will be sufficient for any medical purposes or meet the health or medical requirements of any person.*
