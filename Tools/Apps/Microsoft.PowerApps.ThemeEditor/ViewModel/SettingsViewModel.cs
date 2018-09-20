using GalaSoft.MvvmLight;
using Microsoft.Practices.ServiceLocation;

namespace PowerApps_Theme_Editor.ViewModel
{
    internal class SettingsViewModel : ViewModelBase
    {
        private bool _apply_dimension;
        private bool _apply_theme_styles;
        private MainViewModel model;

        public bool apply_dimension
        {
            get
            {
                return _apply_dimension;
            }
            set
            {
                Set(ref _apply_dimension, value);
            }
        }

        public bool apply_theme_styles
        {
            get
            {
                return _apply_theme_styles;
            }
            set
            {
                Set(ref _apply_theme_styles, value);
            }
        }

        public SettingsViewModel()
        {
            model = ServiceLocator.Current.GetInstance<MainViewModel>();
            _apply_dimension = model.apply_dimension;
            _apply_theme_styles = model.apply_theme_styles;
        }

        public void SaveSettings()
        {
            model.apply_dimension = _apply_dimension;
            model.apply_theme_styles = _apply_theme_styles;
        }
    }
}