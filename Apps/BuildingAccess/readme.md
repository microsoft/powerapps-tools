# Building Access Application (A 'Back to Office' scenario)

The **Building Access** app can be used by organizations to bring employees
back into the office facilities safely, as economies and businesses
reopen and organizations plan gradual reopening of their office
facilities. Facilities teams globally are working to restructure
building layouts, and seating arrangements to maintain social distancing
norms and control building occupancy thresholds. They need a way to
manage, track and report employee onsite presence.

>*Built using Power Apps, Power Automate, Power BI, and SharePoint Online
with deep integrations with Microsoft Teams*, the **app allows
facilities managers to manage facility readiness**, **define occupancy
thresholds** per floor or open space in a building, **set eligibility
criteria** for onsite access **and allows employees to reserve an office
workspace after providing self-attestation on key health questions**.
Executives and facility managers can use the **included Power BI
dashboard to gather insights** needed for planning purposes.

![A screenshot of the Building Access Home Screen](.//media/image1.png)

>The solution is suite of **three** **apps** - **Building Access** app
for employees and managers, **Building Admin** app for facilities teams
and **Building Security** app for security teams, thereby servicing the
needs of multiple personas.

 

![A screenshot of the various personas supported by the App](.//media/image2.jpeg)

 

While the app comes with several innovative features, we hope it is easy
for you to extend, enhance and adapt it for your needs since this is
built using our low-code Power Platform. The app has several
configuration settings that can be leveraged to customize the solution
without any code changes.

Here are a few key features:

-   As facilities teams get buildings ready for onsite access, they can configure buildings in the system once they are ready and control capacity on a building and floor (or open space) level. The capacity can be updated as you ramp up onsite work.

-   We understand approving onsite access requests for thousands or even hundreds of workers is going to be a huge overhead for your already stretched workforce. The app offers an easy to use dial to control auto approvals vs manager approvals so facilities teams can establish the optimal setting for their organization. For example, the Auto-Approval Threshold setting of 0% would turn off auto approvals and send every request to the manager for approval, while a setting of 75% would auto approve the initial 75% requests if the key eligibility criteria are met and only require managers to approve the last 25%.

-   Managers are notified via an adaptive card in Teams when a new request in submitted and they can approve or reject the request directly from Teams ensuring minimum disruption for them. They can also do bulk approvals from the app.

-   We know that a one-size solution doesn't work for everyone and organizations would need to define a key eligibility questionnaire based on their requirements. You can define key eligibility questions or turn off the feature completely using the Building Admin companion app.

-   For emergency approvals, the security team can initiate a 1x1 chat with the direct manager from the approval screen in the Building Security app allowing them to collaborate with the managers directly and expedite process.

-   Security teams can leverage the companion Building Security app to get a quick snapshot of the people approved, already onsite and pending check-ins for any building

-   Facilities teams can use the Power BI dashboard to check current and projected occupancy levels and use the contact tracing report to identify people that were present at the same time and in the same building as another individual

>Please check the [detailed deployment instructions](./instructions.md) that walk through the steps for deploying the app in your environment. The instructions cover:

-   Creating a location for your data
-   Running a Power Automate to create the SharePoint lists
-   Importing and configuring the Building Access App
-   Importing and configuring the Building Admin App
-   Importing and configuring the Building Security App
-   Configuring the App settings and creating initial content
-   Deploying the App to Teams
-   Configuring the PowerBI Dashboard


## Support
Please do not open a support ticket if you encounter any bugs with the solution itself, unless it is related to an underlying platform issue unrelated to the template's implementation. 

### Disclaimer
*This app is a sample and may be used with Microsoft Power Apps and Teams for dissemination of reference information only. This app is not intended or made available for use as a medical device, clinical support, diagnostic tool, or other technology intended to be used in the diagnosis, cure, mitigation, treatment, or prevention of disease or other conditions, and no license or right is granted by Microsoft to use this app for such purposes. This app is not designed or intended to be a substitute for professional medical advice, diagnosis, treatment, or judgement and should not be used as such. Customer bears the sole risk and responsibility for any use of this app. Microsoft does not warrant that the app or any materials provided in connection therewith will be sufficient for any medical purposes or meet the health or medical requirements of any person.*