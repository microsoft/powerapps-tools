using System.ComponentModel;

namespace Microsoft.PowerApps.Tools.AppMerger
{
    public class EntityModel : INotifyPropertyChanged
    {
        #region private

        private bool _isSelected = true;
        private bool _isNew = false;

        public event PropertyChangedEventHandler PropertyChanged;

        #endregion private

        #region Properties

        public bool IsSelected
        {
            get
            {
                return _isSelected;
            }
            set
            {
                this._isSelected = value;
                this.RaisePropertyChanged("IsSelected");
            }
        }

        public bool IsNew
        {
            get
            {
                return _isNew;
            }
            set
            {
                this._isNew = value;
                this.RaisePropertyChanged("IsNew");
            }
        }

        public string Screen
        {
            get;
            set;
        }

        public string Source
        {
            get;
            set;
        }

        #endregion Properties

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