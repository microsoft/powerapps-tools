
# Security Risk Assessment and Management
The version 1 of the app - [Securuty Management](https://github.com/microsoft/powerapps-tools/tree/master/Apps/Security%20Management), provided features for admins to manage security roles assignment, column secruity role management, team members management and view user profile with all their security aspects. This new version of the app, is a Model Driven app with custom pages, that has all the same screens from the previous app and also includes Security role risk assessment. The new screen displays a list of security roles from the current environment and you can select one to display the privileges that are associated with that security role. You can also visualize the grouping of these privileges by table or individual priviege. 

## Purpose
As you onboard to start using DataVerse from the complete low code platform (Power platform), you are introduced to multiple security constructs. This security risk assessment and management app is an attempt to simplify the management of security with in a single environment and also provide a way for admins to get an assessmnent of these security roles. This app provides administrators and users a way to know what security privilegs are assigned to a security role and how they will impact the end users interaction. The app will have the below screens 
    - Security Roles assignemnt management
    - Team users assignment management
    - Column security roles assignment management
    - User profile showing all security postures
    - Secrity risk asessment 
    - Summary of security role risk assessments 
    - A summary screen shwoing the security roles with latest assessment and usage 

![image](https://user-images.githubusercontent.com/71347619/209739584-9a3a1a21-659d-4f7f-a0dc-0d72d6eab28f.png)

## Prerequisites
The previous version of the app was purely one zip file. This version packs a lot of features and to bring the best a few existing resources/contributions are used as part of this app. These solutions will need to be installed before the actual imoprt of the app.  
1. Install the [Creator Kit](https://appsource.microsoft.com/en-US/marketplace/apps?product=power-platform&search=creator%20kit&page=1). Its best to install from the solutions page by clicking on the Open App Source  button. 
2. Download the [ColorfulOptionset](https://github.com/ORBISAG/ORBIS.PCF.ColorfulOptionset/releases) PCF Component. Thanks to Diana for the community contribution. 
2. [Optional] Setup the dataverse connection if one doesn't exist. This can also be created at the time of import. 

## Install
1. Download the solution zip file 
2. In PowerApps studio, navigate to solutions and Import the zip file downlaoded 
3. Select the solution zip file from the downloaded location
4. Select the dataverse connection during import 

## Approach
A new table is created to capture the rquest. On creation of the record in the table a power automate flow triggers. As prt of the flow base assessment is retrieved and applied for privileges associated with the security role. Once the process is complete the same record is updated with risk assessment and a count of all privilegss at various levels. 
    - An assessment can be left in draft state before setting to submitted processing. 
    - An assessment can be initiated from the Security roles asessment summary page by clicking on the shield icon
    - Security roles assessment summary shows the color of the shield based on last assessment
    - Screens from the old app have been converted into custom pages 

# How does the app asess the security role?
A base set assessment for each privilega and level is recommended. Howver, the user can toggle the button to override, provide a reason for toggle and set their own asessments. 
      ![image](https://user-images.githubusercontent.com/71347619/209748800-76f2c20a-91d5-4b5e-ad7b-9d9f5aba5cb5.png)
Power automate logic retreives the base assessment rules, retrieves the privilegs associated with the flow. Based on the level of the privilege the base assessment is applied to calcualte the number of privileges under each role.
    
# Screens and Summary Cards 
A few new screens are added to the previous version that provide an easy way for administrators and stake holders to understand this better.   

## Security Risk asessment grid
This screen shows the risk assessments in a model driven app grid. It gives a quick summary of all assessments with numbers and over all assessment.  
 
 ![image](https://user-images.githubusercontent.com/71347619/209739333-67a1b02c-31e2-417e-9ff2-da58711288ce.png)

## Security Risk asessment summary
A card presentation of the risk asessment sorted in descending order of created on date. The cards can be filtered by either request number, status reason or assessed risk level. 

 ![image](https://user-images.githubusercontent.com/71347619/209747358-beb41ef2-5ae6-4bb8-ad1f-abe82e5dc113.png)

 ![image](https://user-images.githubusercontent.com/71347619/209746086-75a36b30-d27c-4e81-acde-9308aad91b51.png)
 
The above shows summary of risk assessment of Basic User role. It shows that 17 are high riks privileges, 43 are Medium risk, 198 are low risk and 178 are no risk privilges. These privilegs are split to 208 at Org level,  2 at Parent child business unit level, 20 at business unit level and 206 are set at user level. This level of analysis provides a very good understanding of the privileges. The overall assessment is Red, indicating its High risk. 

## Security Role Summary
This screen presents one card for all security roles, irrespecive of whether they are asessed or not. A colored shield indicates the security role is asessed. It picks up the latest assessment details for displaying on the card. A non colored sheild can be clicked on to start a new assessment  


 ![image](https://user-images.githubusercontent.com/71347619/209746527-4cdfbcca-d418-4ebd-a3fd-6a194296099e.png)
 
The same summary presented with alls security roles shows additional information of how many users, teams are assigned this role, and the number of apps that are associated with this app. In this case 26 users are assigned the Basic role and there 0 teams and no apps assigned to this role. 

![2022-12-27_18-37-26](https://user-images.githubusercontent.com/71347619/209748544-b77b3583-9d30-494a-87ff-32f380512457.gif)

## Security Role Management Screen
This screen shows the roles that are available in this environment. First security role is selected by default and corresponding users and teams associated with this security role are displayed. A picture for users is displayed using the office 365 connector. 

    - A new security role can be created (NOTE: the new window will show the default business unit for the security role)
  ![image](https://user-images.githubusercontent.com/71347619/156307639-23fd7419-3290-4ebb-921d-d4e60aeb7bfa.png)

## Team Management Screen
This screen shows the teams that are available, basic information about the team. Selecting a team will show associated users and teams

    - A new team can be created (NOTE: The window launched will default to Owner team)

## Column security profile management
This screen shows the column security profiles that are available in this environment. Selecting a field security profile, will show associated users and fields along with permissions that are assigned for each.

    - A new field profile can be created (NOTE: The window launched will default to Owner team)

## Business Units
This screen displays business units and associated security roles and teams. (NOTE: unless a security role is created for a specific business unit, you will mostly see the same roles for business units. Teams can differ). 

## User Profile
A users picture is displayed with basic information. The security roles, field security profiles and teams that this user is associated are displayed. The can be removed from any of these or added to an existing object in respective area.
    ![image](https://user-images.githubusercontent.com/71347619/156307660-083ca6ef-135d-445c-a4ea-c6d40c21cd8e.png)

For any feedback and feature requests, please report them as part of this git hub. 

## References 
- Security concepts in Microsoft Dataverse - https://docs.microsoft.com/en-us/power-platform/admin/wp-security-cds
- Security in Microsoft Power Platform - https://docs.microsoft.com/en-us/power-platform/admin/security/overview

## Support
Please do not open a support ticket if you encounter any bugs with the solution itself, unless it is related to an underlying platform issue unrelated to the template's implementation. If there are issues related to the solution implementation itself, please [report bugs here](https://github.com/microsoft/powerapps-tools/issues/new?assignees=Ravi-Chada&labels=securitymgmt&template=-security-management-app--bug-report.md&title=%5BBUG%5D+Security+Management%3A+).

### Disclaimer
*This app is a sample and may be used with Microsoft Power Apps and Teams for dissemination of reference information only. This app is not intended or made available for use as a medical device, clinical support, diagnostic tool, or other technology intended to be used in the diagnosis, cure, mitigation, treatment, or prevention of disease or other conditions, and no license or right is granted by Microsoft to use this app for such purposes. This app is not designed or intended to be a substitute for professional medical advice, diagnosis, treatment, or judgement and should not be used as such. Customer bears the sole risk and responsibility for any use of this app. Microsoft does not warrant that the app or any materials provided in connection therewith will be sufficient for any medical purposes or meet the health or medical requirements of any person.*
