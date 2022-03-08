# Security Management
As you onboard to start using DataVerse from the complete low code platform (Power platform), you are introduced to multiple security constructs. This security management app is an attempt to simplify the management of security with in a single environment. The app also will also allow to add or remove associations between 
    - Users 
    - Teams 
    - Security Roles
    - Business Units
    - Field Security Roles

The app also has a screen that lets an admin to search and select a specific user and see the user's security role, team and field security profile associations. 

![image](https://user-images.githubusercontent.com/71347619/156307584-d8a42591-6721-432f-b83f-1a02a618b82b.png)

## Install
1. Download the app zip file 
2. In PowerApps studio, select apps and Import Canvas App
3. Select the zip file from the download location 

    - NOTE: It's observed that the app take upto 5 minutes to show in the apps list in some cases. 

## Principles Used
The below principles were applied as part of this app development
- A Canvas app that can be imported as a plug and play, into any environment
- No Power automate flows are used and only connections used as PowerApps for Makers and Office 365

    - ![image](https://user-images.githubusercontent.com/71347619/156307977-6346a33c-5fb0-4454-a9e2-f681a44d09ee.png) button will display option to select a single user/team to the specific role 
    - ![image](https://user-images.githubusercontent.com/71347619/156308274-7069ba94-1733-401f-9c12-7cf56b3ce77e.png) button will get you back to the main users/teams listing 
    - ![image](https://user-images.githubusercontent.com/71347619/156308048-35b347e1-7c5d-42ce-8357-e2e0006674ff.png) button will remove the user from that role (NOTE: this operation is immediate)
    - ![image](https://user-images.githubusercontent.com/71347619/156308156-ec2cfd20-1641-4f3f-aa08-d4b4d9a46b92.png) button will launch the record of the associated object in a new tab
    
    - Clicking on the users name on any screen will take to the user profile screen
    - Clicking the assign button at the bottom would create a new association 
    - All labels and headings are capitalized 

## Security Role Management Screen
This screen shows the roles that are available in this environment. First security role is selected by default and corresponding users and teams associated with this security role are displayed. A picture for users is displayed using the office 365 connector. 

    - A new security role can be created (NOTE: the new window will show the default business unit for the security role)
  ![image](https://user-images.githubusercontent.com/71347619/156307639-23fd7419-3290-4ebb-921d-d4e60aeb7bfa.png)

## Team Management Screen
This screen shows the teams that are available, basic information about the team. Selecting a team will show associated users and teams

    - A new team can be created (NOTE: The window launched will default to Owner team)

## Field security profile management
This screen shows the field security profiles that are available in this environment. Selecting a field security profile, will show associated users and fields along with permissions that are assigned for each.

    - A new field profile can be created (NOTE: The window launched will default to Owner team)

## Business Units
This screen displays business units and associated security roles and teams. (NOTE: unless a security role is created for a specific business unit, you will mostly see the same roles for business units. Teams can differ). 

## User Profile
A users picture is displayed with basic information. The security roles, field security profiles and teams that this user is associated are displayed. The can be removed from any of these or added to an existing object in respective area.
    ![image](https://user-images.githubusercontent.com/71347619/156307660-083ca6ef-135d-445c-a4ea-c6d40c21cd8e.png)

## Search User screen
Type in a name of the user and select their name from the result set to see users association with security roles, field security profiles and teams.

For any feedback and feature requests, please report them as part of this git hub. 

## References 
- Security concepts in Microsoft Dataverse - https://docs.microsoft.com/en-us/power-platform/admin/wp-security-cds
- Security in Microsoft Power Platform - https://docs.microsoft.com/en-us/power-platform/admin/security/overview

## Support
Please do not open a support ticket if you encounter any bugs with the solution itself, unless it is related to an underlying platform issue unrelated to the template's implementation. If there are issues related to the solution implementation itself, please [report bugs here](https://github.com/microsoft/powerapps-tools/issues/new?assignees=ankitchawla23&labels=jitaccess&template=-jit-access--bug-report.md&title=).

### Disclaimer
*This app is a sample and may be used with Microsoft Power Apps and Teams for dissemination of reference information only. This app is not intended or made available for use as a medical device, clinical support, diagnostic tool, or other technology intended to be used in the diagnosis, cure, mitigation, treatment, or prevention of disease or other conditions, and no license or right is granted by Microsoft to use this app for such purposes. This app is not designed or intended to be a substitute for professional medical advice, diagnosis, treatment, or judgement and should not be used as such. Customer bears the sole risk and responsibility for any use of this app. Microsoft does not warrant that the app or any materials provided in connection therewith will be sufficient for any medical purposes or meet the health or medical requirements of any person.*
