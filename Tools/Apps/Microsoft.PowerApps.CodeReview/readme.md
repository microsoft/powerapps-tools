## Install Instructions

- Download the ArchitectureReview_1_0_0_xx_manage solution 
- Import the solution in your target environment (https://make.preview.powerapps.com/ -> Solutions -> Import)
- Enable PCF Component in Admin Center ![Admin Center](https://docs.microsoft.com/en-us/powerapps/developer/component-framework/media/enable-pcf-feature.png)



## Power Apps Review Tool

With the Power Apps review tool, you can conduct app reviews more efficiently thanks to a customizable checklist of best practices, a 360 view of your app through app checker results, app settings and a free search code viewer.

![PowerApps Review Tool](https://pahandsonlab.blob.core.windows.net/tools/home.png)


## Creating a Review

Simply add the app name, msapp file and other optional fields

![PowerApps Review Tool](https://pahandsonlab.blob.core.windows.net/tools/addreview.png)

## The Checklist

The checklist represents a series of patterns to check in your application. You can pass or fail each pattern, add comment for the app maker to consider or view additional details related to the pattern.  

![PowerApps Review Tool](https://pahandsonlab.blob.core.windows.net/tools/checklist.png)


## App Checker Results

The app checker screen shows the results from the last app checker result run for the app. These results are available in the Power Apps studio as your build your app. They are included in this tool for convenience. 

![PowerApps Review Tool](https://pahandsonlab.blob.core.windows.net/tools/appchecker.png)


## App Analysis

The app analysis section allows us to quickly check if certain important app setting flags are on. The flags have an impact on performance. The screen info section gives us a quick count of the number of controls used for each screen to ensure that it is below the recommended max of 300 control per screen. The media files sections list all medias embedded with the app as well as their size. Finally, the network trace section helps identify slow network requests within the app.

![PowerApps Review Tool](https://pahandsonlab.blob.core.windows.net/tools/appanalysis.png)


## Code Viewer

The code viewer section lists screens, controls and properties with a search and filter function allowing to quickly find formulas within your app.  

![PowerApps Review Tool](https://pahandsonlab.blob.core.windows.net/tools/codereview.png)

If you find code defects, you can link it to corresponding the review pattern. 

![PowerApps Review Tool](https://pahandsonlab.blob.core.windows.net/tools/appchecker.png)

 
Check out the intro video 

[![Code Review Tool Video](https://pahandsonlab.blob.core.windows.net/tools/thumbnail.png)](https://youtu.be/ZkXL_IqK4UE?t=232 "Code Review Tool Video")
