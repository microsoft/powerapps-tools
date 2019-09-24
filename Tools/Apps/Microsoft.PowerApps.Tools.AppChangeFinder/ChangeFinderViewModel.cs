using Microsoft.PowerApps.Tools.AppChangeFinder.Common;
using Microsoft.PowerApps.Tools.AppChangeManager;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.ComponentModel;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Forms;
using System.Windows.Input;
using System.Windows.Navigation;
using System.Windows.Threading;

namespace Microsoft.PowerApps.Tools.AppChangeFinder
{
    /// <summary>
    /// ViewModel for Mainwindows.xaml 
    /// </summary>
    public class ChangeFinderViewModel : INotifyPropertyChanged
    {
        #region Constructor

        /// <summary>
        /// Constructor of ChangeFinder ViewModel
        /// </summary>
        public ChangeFinderViewModel()
        {
            BrowseBtnClick = new RelayCommand(new Action<object>(BrowseBtnClicked));
            SearchBtnClick = new RelayCommand(new Action<object>(SearchBtnClicked));
            ExportToJSONBtnClick = new RelayCommand(new Action<object>(ExportToJsonBtnClicked));
            DownloadHTMLBtnClick = new RelayCommand(new Action<object>(DownloadHTMLViewerBtnClicked));
        }

        #endregion Constructor

        #region Properties

        /// <summary>
        /// Field to hold search results
        /// </summary>
        private List<ModifiedResult> searchResult = null;

        /// <summary>
        /// Field to hold Actual Screen Lists
        /// </summary>
        public ObservableCollection<DataModel> OrginalScreenList { get; set; }

        /// <summary>
        /// Private variable for ScreenList
        /// </summary>
        private ObservableCollection<DataModel> screenList = new ObservableCollection<DataModel>();

        /// <summary>
        /// Gets or Sets the ScreenList, holds the screen list which extracted from msapp file
        /// </summary>
        public ObservableCollection<DataModel> ScreenList
        {
            get { return screenList; }
            set
            {
                screenList = value;
                OnPropertyChanged("ScreenList");
            }
        }

        /// <summary>
        /// Private variable of PathTxtBox
        /// </summary>
        private string pathTxtBox = "";

        /// <summary>
        /// Gets or Sets PathTxtBox, holds the browse path of msapp file
        /// </summary>
        public string PathTxtBox
        {
            get { return pathTxtBox; }
            set
            {
                pathTxtBox = value;
                OnPropertyChanged("PathTxtBox");
            }
        }

        /// <summary>
        /// Private varible of IsLoading
        /// </summary>
        private bool _isLoading = false;

        /// <summary>
        /// Gets or Sets IsLoading, holds the value to show waitcursor or not
        /// </summary>
        public bool IsLoading
        {
            get { return _isLoading; }
            set { _isLoading = value; OnPropertyChanged("IsLoading"); }
        }

        /// <summary>
        /// Private variable of SearchTextBox
        /// </summary>
        private string searchTextBox = "";

        /// <summary>
        /// Gets or Sets PathTxtBox, holds the search text
        /// </summary>
        public string SearchTextBox
        {
            get { return searchTextBox; }
            set
            {
                searchTextBox = value;
                OnPropertyChanged("SearchTextBox");
            }
        }
        #endregion Properties

        #region Icommands

        /// <summary>
        /// Private variable of BrowseBtnClick
        /// </summary>
        private ICommand browseBtnClick;

        /// <summary>
        /// ICommand that is attached to the Browse button of the View Page
        /// </summary>
        public ICommand BrowseBtnClick
        {
            get { return browseBtnClick; }
            set { browseBtnClick = value; }
        }

        /// <summary>
        /// Private variable of SearchBtnClick
        /// </summary>
        private ICommand searchBtnClick;

        /// <summary>
        /// ICommand that is attached to the Search text button of the View Page
        /// </summary>
        public ICommand SearchBtnClick
        {
            get { return searchBtnClick; }
            set { searchBtnClick = value; }
        }

        /// <summary>
        /// Private variable of DownloadHTMLBtnClick
        /// </summary>
        private ICommand downloadHTMLBtnClick;
        /// <summary>
        /// ICommand that is attached to the Save as HTML button of the View Page
        /// </summary>
        public ICommand DownloadHTMLBtnClick
        {
            get { return downloadHTMLBtnClick; }
            set { downloadHTMLBtnClick = value; }
        }

        /// <summary>
        /// Private variable of ExportToJSONBtnClick
        /// </summary>
        private ICommand exportToJSONBtnClick;
        /// <summary>
        /// ICommand that is attached to the Export JSON button of the View Page
        /// </summary>
        public ICommand ExportToJSONBtnClick
        {
            get { return exportToJSONBtnClick; }
            set { exportToJSONBtnClick = value; }
        }
        #endregion

        #region Property Changed

        public event PropertyChangedEventHandler PropertyChanged;

        protected void OnPropertyChanged(string name)
        {
            PropertyChanged?.Invoke(this, new PropertyChangedEventArgs(name));
        }

        #endregion Property Changed

        #region Public Methods
        /// <summary>
        /// To extract the json object from msapp file and bind it to UI
        /// </summary>
        /// <param name="obj"></param>
        public async void BrowseBtnClicked(object obj)
        {
            var uiContext = SynchronizationContext.Current;

            await Task.Run(async () =>
            {
                string message = "";
                var ofd = new Win32.OpenFileDialog() { Filter = "PowerApps Files (*.msapp)|*.msapp" };
                var result = ofd.ShowDialog();
                if (result == false) return;
                PathTxtBox = ofd.FileName;
                try
                {
                    if (string.IsNullOrWhiteSpace(PathTxtBox) ||
                        Path.GetExtension(PathTxtBox) != ".msapp")
                    {
                        message = "Select the PowerApps App!";
                    }
                    else
                    {
                        this.IsLoading = true;
                        ChangeManager changeManager = new ChangeManager();
                        searchResult = changeManager.GetModifiedControleList(PathTxtBox);

                        if (searchResult == null || searchResult.Count == 0
                                                 || (searchResult.Count == 1 && searchResult[0].ControlList.Count == 0))
                        {
                            var screenName = $"No change found in the App!";
                            searchResult = new List<ModifiedResult>
                            {
                                new ModifiedResult
                                {
                                    ScreenName = screenName
                                }
                            };
                        }

                        //Clear the binded object everytime
                        ScreenList = new ObservableCollection<DataModel>();

                        //DataModel local variables
                        DataModel _dataModel = null;
                        Controls _controls = null;
                        Property _property = null;

                        //Fill the object by traversing
                        searchResult.ForEach(r =>
                        {
                            _dataModel = new DataModel();
                            _dataModel.ScreenName = r.ScreenName;

                            r.ControlList?.ForEach(s =>
                            {
                                _controls = new Controls();
                                _controls.ControlName = $"{s.ControlName}";
                                //_property = new Property();
                                //_property.PropertyName = $"Parent: {s.Parent}";
                                //_controls.Properties.Add(_property);
                                s.Script?.ForEach(q =>
                                {
                                    if (!string.Equals(q.DefaultSetting, q.InvariantScript,
                                        StringComparison.OrdinalIgnoreCase))
                                    {
                                        _property = new Property();
                                        _property.PropertyName = q.Property;
                                        _property.Properties.Add(new PropertyDetails()
                                        { IsBaseLine = true, Name = "", Value = q.DefaultSetting });
                                        _property.Properties.Add(new PropertyDetails()
                                        { IsBaseLine = false, Name = "", Value = q.InvariantScript });
                                        _controls.Properties.Add(_property);
                                    }
                                });

                                _dataModel.Controls.Add(_controls);
                            });
                            uiContext.Send(x => ScreenList.Add(_dataModel), null);
                        });

                        //Clone to local list
                        OrginalScreenList = ScreenList;
                        this.IsLoading = false;
                    }
                }
                catch (Exception ex)
                {
                    message = ex.Message;
                }

                if (!string.IsNullOrWhiteSpace(message))
                {
                    MessageBoxButton button = MessageBoxButton.OK;
                    System.Windows.MessageBox.Show(message, "Message", button);
                }
            });
        }

        /// <summary>
        /// To search the text in Screens list 
        /// </summary>
        /// <param name="obj"></param>
        public void SearchBtnClicked(object obj)
        {
            string searchTxt = SearchTextBox;
            if (!string.IsNullOrEmpty(searchTxt))
            {
                Task.Factory.StartNew(() =>
                {
                    this.IsLoading = true;
                    ObservableCollection<DataModel> searchedScreenList = new ObservableCollection<DataModel>();
                    //Traverse through the object
                    foreach (DataModel dm in OrginalScreenList)
                    {
                        var foundScreen = new DataModel
                        {
                            ScreenName = dm.ScreenName,
                            Controls = new List<Controls>()
                        };
                        //Start searching with root node -  screen name
                        if (dm.ScreenName.IndexOf(searchTxt, StringComparison.OrdinalIgnoreCase) >= 0)
                        {
                            searchedScreenList.Add(dm);
                            break;
                        }
                        //Searching in child node
                        foreach (Controls control in dm.Controls)
                        {
                            var foundControl = new Controls
                            {
                                ControlName = control.ControlName
                            };
                            if (control.ControlName.IndexOf(searchTxt, StringComparison.OrdinalIgnoreCase) >= 0)
                            {
                                foundScreen.Controls = new List<Controls> { foundControl };
                                searchedScreenList.Add(foundScreen);
                                break;
                            }
                            foreach (Property prop in control.Properties)
                            {
                                var foundProp = new Property
                                {
                                    Properties = prop.Properties,
                                    PropertyName = prop.PropertyName
                                };

                                if (!string.IsNullOrEmpty(prop.PropertyName) && prop.PropertyName.IndexOf(searchTxt, StringComparison.OrdinalIgnoreCase) >= 0)
                                {
                                    foundControl.Properties = new List<Property> { foundProp };
                                    foundScreen.Controls = new List<Controls> {foundControl};
                                    searchedScreenList.Add(foundScreen);
                                    break;
                                }
                                foreach (PropertyDetails propDetails in prop.Properties)
                                {
                                    var foundPropDetails = new PropertyDetails
                                    {
                                        Name = propDetails.Name,
                                        Value = propDetails.Value
                                    };

                                    if (!string.IsNullOrEmpty(propDetails.Name) && propDetails.Name.IndexOf(searchTxt, StringComparison.OrdinalIgnoreCase) >= 0)
                                    {
                                        foundProp.Properties = new List<PropertyDetails> {foundPropDetails};
                                        foundControl.Properties = new List<Property> { foundProp };
                                        foundScreen.Controls = new List<Controls> { foundControl };
                                        searchedScreenList.Add(foundScreen);
                                        break;
                                    }

                                    if (!string.IsNullOrEmpty(propDetails.Value) && propDetails.Value.IndexOf(searchTxt, StringComparison.OrdinalIgnoreCase) >= 0)
                                    {
                                        foundProp.Properties = new List<PropertyDetails> { foundPropDetails };
                                        foundControl.Properties = new List<Property> { foundProp };
                                        foundScreen.Controls = new List<Controls> { foundControl };
                                        searchedScreenList.Add(foundScreen);
                                        break;
                                    }
                                }
                            }
                        }
                    }

                    System.Windows.Application.Current.Dispatcher.Invoke(() =>
                    {
                        ////Set property or change UI compomponents.
                        this.IsLoading = false;
                        ScreenList = searchedScreenList;
                    });
                });
            }
            else
            {
                ScreenList = OrginalScreenList;
            }

            this.IsLoading = false;
        }

        /// <summary>
        /// Download HTML Viewer Button Click event
        /// </summary>
        /// <param name="obj"></param>
        private void DownloadHTMLViewerBtnClicked(object obj)
        {
            //Validation
            if(ScreenList?.Count == 0)
            {
                MessageBoxButton button = MessageBoxButton.OK;
                System.Windows.MessageBox.Show("No result to save!", "Message", button);
                return;
            }
            string fileName = "AppChangeFinder";
            if (!string.IsNullOrEmpty(PathTxtBox))
            {
                string[] pathboxArray = PathTxtBox.Split('\\');
                fileName = PathTxtBox.Split('\\')[pathboxArray.Length - 1];
                fileName = fileName.Replace(".msapp", "");
            }
            fileName += "_CodeReview_" + DateTime.Now.ToString("MM_dd_yyyy");
            SaveFileDialog sfd = new SaveFileDialog
            {
                DefaultExt = ".htm",
                FileName = fileName,
                Filter = "HTML File (.html)|*.html|HTM Files(.htm)| *.htm"
            };
            if (sfd.ShowDialog() == DialogResult.OK && sfd.FileName.Length > 0)
            {
                File.WriteAllText(sfd.FileName, CovertToHTMLTable().ToString());

                if (!string.IsNullOrEmpty(sfd.FileName))
                {
                    //NavigationWindow window = new NavigationWindow();
                    //window.Source = new Uri(sfd.FileName);
                    //window.Show();
                    System.Diagnostics.Process.Start(sfd.FileName);
                }
            }
        }

        /// <summary>
        /// Convert the ScreenList Object to Html Table
        /// </summary>
        /// <returns>Html string</returns>
        private string CovertToHTMLTable()
        {
            StringBuilder htmlStr = new StringBuilder();
            htmlStr.Append("<table style=\"font-family: arial,sans-serif; border-collapse:collapse; width:100%;\">");
            foreach (var item in ScreenList)
            {
                htmlStr.AppendFormat("<tr style=\"border-bottom-width:1px; border-bottom-color:#dddddd; border-bottom-style:solid\">");
                htmlStr.AppendFormat("<td width=\"10% \">{0}</td>", item.ScreenName);
                htmlStr.AppendFormat("<td width=\"90% \">");
                htmlStr.AppendFormat("<table width=\"100% \">");
                foreach (var controlitem in item.Controls)
                {
                    htmlStr.AppendFormat("<tr style=\"border-bottom-width:1px; border-bottom-color:#dddddd; border-bottom-style:solid\">");
                    htmlStr.AppendFormat(           "<td width=\"15% \">{0}</td>", controlitem.ControlName);
                    htmlStr.AppendFormat(           "<td width=\"85% \">");
                    htmlStr.AppendFormat(               "<table width=\"100% \">");
                    foreach (var propertyitem in controlitem.Properties)
                    {
                        htmlStr.AppendFormat(               "<tr style=\"border-bottom-width:1px; border-bottom-color:#dddddd; border-bottom-style:solid\">");
                        htmlStr.AppendFormat(                   "<td width=\"15% \">{0}</td>", propertyitem.PropertyName);
                        foreach (var property in propertyitem.Properties)
                        {
                            htmlStr.AppendFormat(           "<td style=\"width=25%;background-color : #{1} \">{0}</td>", property.Value, property.IsBaseLine? "CEF37E": "FFA7A7");
                        }
                        htmlStr.AppendFormat(                   "<td width=\"35% \">{0}</td>", propertyitem.Comments);
                        htmlStr.AppendFormat(               "</tr>");
                    }
                    htmlStr.AppendFormat(               "</table>");
                    htmlStr.AppendFormat("          </td>");
                    htmlStr.AppendFormat("      </tr>");
                }
                htmlStr.AppendFormat("  </table>");
                htmlStr.AppendFormat("</td>");
                htmlStr.AppendFormat("</tr>");
            }
            htmlStr.Append("</table>");
            return htmlStr.ToString();
        }

        /// <summary>
        /// To the msapp file into JSON
        /// </summary>
        /// <param name="obj"></param>
        private void ExportToJsonBtnClicked(object obj)
        {
            if (searchResult == null)
            {
                MessageBoxButton button = MessageBoxButton.OK;
                System.Windows.MessageBox.Show("No Search result to save!", "Message", button);
                return;
            }

            SaveFileDialog dialog = new SaveFileDialog()
            {
                Filter = "Text Files(*.json)|*.json|All(*.*)|*"
            };

            if (dialog.ShowDialog() == DialogResult.OK)
            {
                var entitiesJson = JsonConvert.SerializeObject(searchResult);
                File.WriteAllText(dialog.FileName, entitiesJson);
            }
        }

        #endregion Public Methods
    }
}
