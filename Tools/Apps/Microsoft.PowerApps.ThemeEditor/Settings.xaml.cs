using PowerApps_Theme_Editor.ViewModel;
using System.Windows;

namespace PowerApps_Theme_Editor
{
    /// <summary>
    /// Interaction logic for Settings.xaml
    /// </summary>
    public partial class Settings : Window
    {
        private SettingsViewModel settingsViewModel;

        public Settings()
        {
            settingsViewModel = new SettingsViewModel();
            InitializeComponent();
            this.DataContext = settingsViewModel;
            this.Left = SystemParameters.PrimaryScreenWidth - this.Width;
        }

        internal void ShowDialog(MainWindow owner)
        {
            this.Owner = owner;
            this.ShowDialog();
        }

        private void Button_Save(object sender, RoutedEventArgs e)
        {
            settingsViewModel.SaveSettings();
            this.Close();
        }
    }
}