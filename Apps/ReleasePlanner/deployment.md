# Deployment

Follow the steps given in this document to install the Release Planner App in your environment.

### Step by step instruction

1.  On the environment where you intend to import the solution go to
    “Solutions”.  
    #### Classic UI
    

    ![Classic UI - Advanced Settings](./media/classicui-advancedsetting.png)

    ![Classic UI - Solutions](./media/classicui-solutions.png)

    #### Modern UI
    

    ![Modern UI - Solutions](./media/modernui-solutions.png)

2.  Select “Import” on the toolbar.  
    #### Classic UI
    

    ![Classic UI - Import solution](./media/classicui-import.png)

  
   #### Modern UI  
   
   ![Modern UI](./media/import.png)



3.  Select the solution package ZIP file you have downloaded on step 1 and click
    “Next”:  
    

    ![Import - Choose the solution file](./media/import-choosefile.png)

4.  Click “Next”:  
    

    ![Import solution - Click next button](./media/import-next.png)

5.  After the import has completed, click “Publish All Customizations”:  
    

    ![Import soltuion - Public all customization](./media/import-publishall.png)

### Post-deployment steps

#### Configure “Generate Release Plans Word Document” flow

This flow should be configured if you are looking to generate the Word Document
from the release planner app that contains all the features for a particular
release wave and particular application.

1.  On the environment where you have imported the solution go to “Solutions”
    using the Modern UI:  
    

    ![Modern UI - Solution](./media/modernui-solutions.png)

2.  Select “Release Planner” solution:  
    

    ![Release Planner Solution](./media/releaseplanner.png)

3.  Select “Flow” filter on the upper right:  
    

    ![Search Flow](./media/search-flow.png)

4.  Select “Get Filter Criteria to fetch specific Release Plan records”:  
    

    ![Flow - Get filter criteria to fetch specific release plan records](./media/getfiltercriteria.png)

5.  Select “Edit”:  
    

    ![Flow Edit](./media/flow-edit.png)

6.  Expand “When an HTTP request is received” step and copy its URL to the
    clipboard:  
    
    ![Copy HTTP URL Request](./media/getflowhttp.png)
    
     > [!NOTE]
     > The Flow should be turned on for the URL to get generated.

7.  Go back to the list of flows and select “Generate Release Plans Word
    document”:  
    

    ![Search Generate Release Plans Word document flow](./media/searchgeneratereleaseplan.png)

8.  Scroll down to “For each application” step:  
    

    ![A screenshot of a cell phone Description automatically generated](./media/scroll-for-each-app.png)

9.  Expand “For each application”, expand “Hierarchy Product value is not null”,
    scroll down to “Get Filter Criteria” step and expand it:  
    

    ![Expand HTTP Request step](./media/expand.jpg)

10. Paste the URL copied on step 1.6 into “URI” field.

11. Scroll up to “Init FilePath” step and expand it. In the “Value” field enter
    the path to the SharePoint folder, where the resulting .doc files will be
    saved:  
    

    ![Update the File Path](./media/initfilepath.jpg)

12. Copy “HTML.htm” template file (supplied with the Release Planner solution)
    to the SharePoint folder you specified on step 1.11.

13. Scroll down to “Initialize SharePoint SiteAddress” step and expand it. Enter
    your SharePoint site address into “Value” field:  
    

    ![Update SharePoint File Address](./media/initsharepointfileaddress.jpg)

14. Scroll to the very beginning of the flow. Expand the first “When a HTTP
    request is received” step and copy its URL to the clipboard:  
    

    ![Copy HTTP Request](./media/copyhttprequest.png)

15. Go back to “Solutions” list using Modern UI. Open “Release Planner”
    solution. Select “Other” filter on the upper-right:  
    

    ![Select Other](./media/select-other.png)

16. Select “Generate Word Doc Ribbon script” web resource:  
    

    ![Select Generate Word Doc Ribbon script](./media/select-generate-word-script.png)

17. Select “Text Editor”:  
    

    ![texteditor](./media/texteditor.png)

18. Find “flowUrl” variable and replace its value with the URL copied on step
    1.14:  Click OK.
    

    ![Find Flow URL](./media/find-flow-url.jpg)

#### Configure “Daily Email Alerts” flow

1.  On the environment where you have imported the solution go to “Solutions”
    using the Modern UI:  
    

    ![Modern UI - Solution](./media/modernui-solutions.png)

2.  Select “Release Planner” solution:  
    

    ![Release Planner](./media/releaseplanner.png)

3.  Select “Flow” filter on the upper right:  
    

    ![Search Flow](./media/search-flow.png)

4.  Select “Daily Email Alerts”  
    

    ![Daily Email Alerts Flow](./media/dailyemailalert.png)

5.  Select “Edit”:  
    

    ![Edit Flow](./media/edit-flow.png)

6.  Expand “Initialize Environment URL” step and enter your environment URL into
    the “Value” field:  
    

    ![A screenshot of a cell phone Description automatically generated](./media/environmenturl.jpg)

    Click save and close the Flow.
