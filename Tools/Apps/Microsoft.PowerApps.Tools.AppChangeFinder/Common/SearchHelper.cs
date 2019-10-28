using System;
using System.Collections.Generic;
using System.Linq;
using System.Collections.ObjectModel;

namespace Microsoft.PowerApps.Tools.AppChangeFinder.Common
{
    public static class SearchHelper
    {
        public static SearchFilters SearchFilter { get; private set; }

        public static List<DataModel> HierarchySearch(ObservableCollection<DataModel> screenList, SearchFilters searchFilter, string searchText)
        {
            SearchFilter = searchFilter;
            var searchedScreenList = new List<DataModel>();

            foreach (DataModel dm in screenList)
            {
                var foundScreen = new DataModel
                {
                    ScreenName = dm.ScreenName,
                    Controls = new List<Controls>()
                };

                foreach (Controls control in dm.Controls)
                {
                    var foundControl = new Controls
                    {
                        ControlName = control.ControlName,
                        ControlIcon = control.ControlIcon
                    };

                    foreach (Property prop in control.Properties)
                    {
                        var foundProp = new Property
                        {
                            Properties = prop.Properties,
                            PropertyName = prop.PropertyName
                        };

                        foreach (PropertyDetails propDetails in prop.Properties)
                        {
                            var foundPropDetails = new PropertyDetails
                            {
                                Name = propDetails.Name,
                                Value = propDetails.Value,
                                IsBaseLine = propDetails.IsBaseLine
                            };

                            if ((!string.IsNullOrEmpty(propDetails.Name) && propDetails.Name.IndexOf(searchText, StringComparison.OrdinalIgnoreCase) >= 0)
                                || !string.IsNullOrEmpty(propDetails.Value) && propDetails.Value.IndexOf(searchText, StringComparison.OrdinalIgnoreCase) >= 0
                                && (AllowSearch("propertydetails") || AllowSearch("events", prop.PropertyName)))
                            {

                                if (searchedScreenList.Contains(foundScreen))
                                {
                                    if (searchedScreenList.Any(scn => scn.Controls.Contains(foundControl)))
                                    {
                                        if (searchedScreenList.Any(scn => scn.Controls.Any(ctrl => ctrl.Properties.Contains(foundProp))))
                                        {
                                            searchedScreenList.Find(scn => scn.ScreenName == foundScreen.ScreenName)
                                                .Controls.Find(ctrl => ctrl.ControlName == foundControl.ControlName)
                                                .Properties.Find(prp => prp.PropertyName == foundProp.PropertyName)
                                                .Properties.Add(foundPropDetails);
                                        }
                                        else
                                        {
                                            foundProp.Properties = new List<PropertyDetails> { foundPropDetails };
                                            searchedScreenList.Find(scn => scn.ScreenName == foundScreen.ScreenName)
                                                .Controls.Find(ctrl => ctrl.ControlName == foundControl.ControlName)
                                                .Properties.Add(foundProp);
                                        }
                                    }
                                    else
                                    {
                                        foundProp.Properties = new List<PropertyDetails> { foundPropDetails };
                                        foundControl.Properties = new List<Property> { foundProp };
                                        searchedScreenList.Find(scn => scn.ScreenName == foundScreen.ScreenName)
                                            .Controls.Add(foundControl);
                                    }
                                }
                                else
                                {
                                    foundProp.Properties = new List<PropertyDetails> { foundPropDetails };
                                    foundControl.Properties = new List<Property> { foundProp };
                                    foundScreen.Controls = new List<Controls> { foundControl };
                                    searchedScreenList.Add(foundScreen);
                                }
                            }
                        }

                        if (!string.IsNullOrEmpty(prop.PropertyName) && prop.PropertyName.IndexOf(searchText, StringComparison.OrdinalIgnoreCase) >= 0 && AllowSearch("property"))
                        {
                            if (searchedScreenList.Contains(foundScreen))
                            {
                                if (searchedScreenList.Any(scn => scn.Controls.Contains(foundControl)))
                                {
                                    searchedScreenList.Find(scn => scn.ScreenName == foundScreen.ScreenName)
                                        .Controls.Find(ctrl => ctrl.ControlName == foundControl.ControlName)
                                        .Properties.Add(foundProp);
                                }
                                else
                                {
                                    foundControl.Properties = new List<Property> { foundProp };
                                    searchedScreenList.Find(scn => scn.ScreenName == foundScreen.ScreenName)
                                        .Controls.Add(foundControl);
                                }
                            }
                            else
                            {
                                foundControl.Properties = new List<Property> { foundProp };
                                foundScreen.Controls = new List<Controls> { foundControl };
                                searchedScreenList.Add(foundScreen);
                            }
                        }
                    }

                    if (control.ControlName.IndexOf(searchText, StringComparison.OrdinalIgnoreCase) >= 0 && AllowSearch("control"))
                    {
                        // foundScreen.Controls = new List<Controls> { foundControl };
                        if (searchedScreenList.Contains(foundScreen))
                        {
                            searchedScreenList.Find(scn => scn.ScreenName == foundScreen.ScreenName).Controls.Add(foundControl);
                        }
                        else
                        {
                            foundScreen.Controls.Add(foundControl);
                            searchedScreenList.Add(foundScreen);
                        }
                    }
                }

                if (dm.ScreenName.IndexOf(searchText, StringComparison.OrdinalIgnoreCase) >= 0 && AllowSearch("screen"))
                {
                    searchedScreenList.Add(foundScreen);
                    break;
                }
            }

            return searchedScreenList;
        }

        private static bool AllowSearch(string type, string propertyName = null)
        {
            var events = new List<string>
            {
                "OnChange",
                "OnSelect"
            };

            switch (type)
            {
                case "screen":
                    return SearchFilter == SearchFilters.All;
                case "control":
                    return SearchFilter == SearchFilters.All || SearchFilter == SearchFilters.Controls;
                case "property":
                    return SearchFilter == SearchFilters.All || SearchFilter == SearchFilters.Properties;
                case "propertydetails":
                    return SearchFilter == SearchFilters.All;
                case "events":
                    return SearchFilter == SearchFilters.All || (SearchFilter == SearchFilters.Events && events.Contains(propertyName));
                default:
                    return false;
            }
        }
    }
}
