using System;
using System.Windows;
using System.Windows.Controls;

namespace Microsoft.PowerApps.Tools.AppChangeFinder
{
    /// <summary>
    /// Interaction logic for Window1.xaml
    /// </summary>
    public partial class MainWindow : Window
    {
        #region private variable

        //List<ModifiedResult> searchResult = null;

        #endregion private variable

        public MainWindow()
        {
            InitializeComponent();
        }

        private void Window_StateChanged(object sender, EventArgs e)
        {
            if (WindowState == WindowState.Maximized)
                WindowState = WindowState.Normal;
        }

        private void SearchTextBox_TextChanged(object sender, TextChangedEventArgs e)
        {
            if (string.IsNullOrEmpty((this.DataContext as ChangeFinderViewModel).SearchTextBox))
            {
                (this.DataContext as ChangeFinderViewModel).ScreenList = (this.DataContext as ChangeFinderViewModel).OrginalScreenList;
            }
        }
    }
}