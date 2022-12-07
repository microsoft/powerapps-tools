# Code Review Tool Reference Document

## Prerequisites

Latest version of Code Review Tool has been redesigned using [Power CAT Creator Kit](https://github.com/microsoft/powercat-creator-kit). As a prerequisite install the [Power CAT Creator Kit](https://github.com/microsoft/powercat-creator-kit) core solution in your target environment by following below instructions.

- Download the 'Power CAT Creator Kit' Core solution from [here](https://github.com/microsoft/powercat-creator-kit/releases/download/CreatorKit-November2022/CreatorKitCore_1.0.20221205.2_managed.zip).  
- Import the solution in your target environment (<https://make.preview.powerapps.com/> -> Solutions -> Import)

## Install Instructions

- Download the ArchitectureReview_1_0_0_xx_manage solution
- Import the solution in your target environment (<https://make.preview.powerapps.com/> -> Solutions -> Import)
- Enable PCF Component in Admin Center ![Admin Center](https://docs.microsoft.com/en-us/powerapps/developer/component-framework/media/enable-pcf-feature.png)

## Power Apps Review Tool

With the Power Apps review tool, you can conduct app reviews more efficiently thanks to a customizable checklist of best practices, a 360 view of your app through app checker results, app settings and a free search code viewer.

![PowerApps Review Tool](https://pahandsonlab.blob.core.windows.net/tools/crtlandingpage.png)

## Creating a Review

To start a new Review click on '+ New' from home screen. You can either attach a [Dataverse solution](https://learn.microsoft.com/en-us/power-platform/alm/solution-concepts-alm) file or the App file (.msapp) and click on 'Submit' to initiate the Review.

![PowerApps Review Tool](https://pahandsonlab.blob.core.windows.net/tools/crtcreatereview.png)

## Open a Review

Post creation of a Review, the tool analyze and render the results in the background. You would get a 'Review' link once the review results are available. Click on 'Review' link to access the review results.

![PowerApps Review Tool](https://pahandsonlab.blob.core.windows.net/tools/crtopenreview.png)

Click the 'Review' link will take you to the landing screen where you can get the list of all Apps along with Score. Click on 'Review' link against each App to view the results.

![PowerApps Review Tool](https://pahandsonlab.blob.core.windows.net/tools/crtreviewlanding.png)

## The Checklist

The checklist represents a series of patterns to check in your application. You can pass or fail each pattern, add comment for the app maker to consider or view additional details related to the pattern.  

![PowerApps Review Tool](https://pahandsonlab.blob.core.windows.net/tools/crtreviewchecklist.png)

## App Checker Results

The app checker screen shows the results from the last app checker result run for the app. These results are available in the Power Apps studio as your build your app. They are included in this tool for convenience.

![PowerApps Review Tool](https://pahandsonlab.blob.core.windows.net/tools/crtappcheckerresults.png)

## App Overview

The app overview section allows us to quickly check if certain important app setting flags are on. The flags have an impact on performance. The screen info section gives us a quick count of the number of controls used for each screen to ensure that it is below the recommended max of 300 control per screen. The media files sections list all medias embedded with the app as well as their size. Finally, the network trace section helps identify slow network requests within the app.

![PowerApps Review Tool](https://pahandsonlab.blob.core.windows.net/tools/crtreviewappoverview.png)

## Code Viewer

The code viewer section lists screens, controls and properties with a search and filter function allowing to quickly find formulas within your app.  

![PowerApps Review Tool](https://pahandsonlab.blob.core.windows.net/tools/crtcodeviewer.png)

If you find code defects, you can link it to corresponding the review pattern.

![PowerApps Review Tool](https://pahandsonlab.blob.core.windows.net/tools/crtlinkitem.png)

## Code Review Results

The code review results section provides graphical representation of 'Failed patterns by category' and 'Failed patterns by severity' along with Score, Grade and Passed Patterns ratio.

![PowerApps Review Tool](https://pahandsonlab.blob.core.windows.net/tools/crtcodereviewresults.png)

Check out the intro video

[![Code Review Tool Video](https://pahandsonlab.blob.core.windows.net/tools/thumbnail.png)](https://youtu.be/ZkXL_IqK4UE?t=232 "Code Review Tool Video")
