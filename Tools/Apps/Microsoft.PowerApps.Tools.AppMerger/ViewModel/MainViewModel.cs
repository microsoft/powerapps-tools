using System.Collections.ObjectModel;
using System.ComponentModel;

namespace Microsoft.PowerApps.Tools.AppMerger.ViewModel
{
    public class MainViewModel : INotifyPropertyChanged
    {
        private ObservableCollection<EntityModel> _sreensFromApp1;
        private ObservableCollection<EntityModel> _sreensFromApp2;
        private ObservableCollection<EntityModel> _screensForMergedApp;

        public event PropertyChangedEventHandler PropertyChanged;

        #region Properties

        public ObservableCollection<EntityModel> ScreensFromApp1
        {
            get
            {
                return _sreensFromApp1;
            }

            set
            {
                if (_sreensFromApp1 != value)
                {
                    _sreensFromApp1 = value;
                    this.RaisePropertyChanged("ScreensFromApp1");
                }
            }
        }

        public ObservableCollection<EntityModel> ScreensFromApp2
        {
            get
            {
                return _sreensFromApp2;
            }

            set
            {
                if (_sreensFromApp2 != value)
                {
                    _sreensFromApp2 = value;
                    this.RaisePropertyChanged("ScreensFromApp2");
                }
            }
        }

        public ObservableCollection<EntityModel> ScreensForMergedApp
        {
            get
            {
                return _screensForMergedApp;
            }

            set
            {
                if (_screensForMergedApp != value)
                {
                    _screensForMergedApp = value;
                    this.RaisePropertyChanged("ScreensForMergedApp");
                }
            }
        }

        #endregion Properties

        #region Constructor

        public MainViewModel()
        {
            this._sreensFromApp1 = new ObservableCollection<EntityModel>();
            this._sreensFromApp2 = new ObservableCollection<EntityModel>();
            this._screensForMergedApp = new ObservableCollection<EntityModel>();
        }

        #endregion Constructor

        #region Methods

        private void RaisePropertyChanged(string propertyName)
        {
            // take a copy to prevent thread issues
            PropertyChangedEventHandler handler = PropertyChanged;
            if (handler != null)
            {
                handler(this, new PropertyChangedEventArgs(propertyName));
            }
        }

        #endregion Methods
    }
}