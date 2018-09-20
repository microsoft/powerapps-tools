using Microsoft.PowerApps.Tools.PhoneToTablet;
using System;
using System.Windows;
using System.Windows.Forms;
using MessageBox = System.Windows.MessageBox;

namespace Microsoft.PowerApps.Tools.PhoneAppConverter
{
    /// <summary>
    /// Interaction logic for MainWindow.xaml
    /// </summary>
    public partial class MainWindow : Window
    {
        public MainWindow()
        {
            InitializeComponent();
            var height = SystemParameters.WorkArea.Height;
            var width = SystemParameters.WorkArea.Width;
            Top = (height - Height) / 2;
            Left = (width - Width) / 2;
        }

        private void BrowseBtn_Click(object sender, RoutedEventArgs e)
        {
            var ofd = new Win32.OpenFileDialog() { Filter = "PowerApps Files (*.msapp)|*.msapp" };
            var result = ofd.ShowDialog();
            if (result == false) return;
            PathtxtBox.Text = ofd.FileName;
        }

        private void ConvertBtn_Click(object sender, RoutedEventArgs e)
        {
            SaveFileDialog saveDialog = new SaveFileDialog();
            saveDialog.Filter = "PowerApps app (*.msapp)|*.msapp";
            saveDialog.FileName = String.Format("{0}_{1}", System.IO.Path.GetFileNameWithoutExtension(PathtxtBox.Text), "MergedApp");
            saveDialog.Title = "Save As";

            if (saveDialog.ShowDialog() == System.Windows.Forms.DialogResult.OK)
            {
                string message = "";
                try
                {
                    if (string.IsNullOrWhiteSpace(PathtxtBox.Text) ||
                        System.IO.Path.GetExtension(PathtxtBox.Text) != ".msapp")
                    {
                        message = "Select the PowerApps App first!";
                    }
                    else if (string.IsNullOrWhiteSpace(saveDialog.FileName))
                    {
                        message = "Select the Destination for Tablet app!";
                    }
                    else
                    {
                        var converter = new Converter();
                        converter.Convert(PathtxtBox.Text, saveDialog.FileName);
                        message = "Tablet version of the app created in  " + saveDialog.FileName;

                        MessageBox.Show(message, "Message", MessageBoxButton.OK);
                        System.Diagnostics.Process.Start(saveDialog.FileName);
                    }
                }
                catch (Exception ex)
                {
                    message = ex.Message;
                    MessageBox.Show(message, "Message", MessageBoxButton.OK);
                }
            }
        }

        private void Window_StateChanged(object sender, EventArgs e)
        {
            if (WindowState == WindowState.Maximized)
                WindowState = WindowState.Normal;
        }
    }
}