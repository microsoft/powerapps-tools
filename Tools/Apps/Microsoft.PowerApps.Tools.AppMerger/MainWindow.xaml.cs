using Microsoft.PowerApps.Tools.AppMerger.ViewModel;
using PowerApps.Tools.Utilities.AppManager;
using PowerApps.Tools.Utilities.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Windows;
using System.Windows.Forms;
using MessageBox = System.Windows.MessageBox;

namespace Microsoft.PowerApps.Tools.AppMerger
{
    /// <summary>
    /// Interaction logic for MainWindow.xaml
    /// </summary>
    public partial class MainWindow : Window
    {
        private MergeProcessor mergeProcessor = new MergeProcessor();
        private AppData appData1;
        private AppData appData2;

        public MainWindow()
        {
            InitializeComponent();
            var height = SystemParameters.WorkArea.Height;
            var width = SystemParameters.WorkArea.Width;
            Top = (height - Height) / 2;
            Left = (width - Width) / 2;

            this.DataContext = new MainViewModel();
        }

        private void SecondAppBrowseBtn_Click(object sender, RoutedEventArgs e)
        {
            var ofd = new Win32.OpenFileDialog() { Filter = "PowerApps Files (*.msapp)|*.msapp" };
            var result = ofd.ShowDialog();
            if (result == false) return;
            SecondAppPathtxtBox.Text = ofd.FileName;

            appData2 = mergeProcessor.Extract(ofd.FileName);
            MainViewModel model = this.DataContext as MainViewModel;

            model.ScreensFromApp2 = new System.Collections.ObjectModel.ObservableCollection<EntityModel>(appData2.Screens.Select(s => new EntityModel() { Screen = s, Source = "App 2" }));

            model.ScreensForMergedApp.Clear();

            foreach (var item in model.ScreensFromApp1)
            {
                model.ScreensForMergedApp.Add(item);
            }

            foreach (var item in model.ScreensFromApp2)
            {
                model.ScreensForMergedApp.Add(item);
            }
        }

        private void FirstAppBrowseBtn_Click(object sender, RoutedEventArgs e)
        {
            var ofd = new Win32.OpenFileDialog() { Filter = "PowerApps Files (*.msapp)|*.msapp" };
            var result = ofd.ShowDialog();
            if (result == false) return;
            FirstAppPathtxtBox.Text = ofd.FileName;

            appData1 = mergeProcessor.Extract(ofd.FileName);

            MainViewModel model = this.DataContext as MainViewModel;

            model.ScreensFromApp1 = new System.Collections.ObjectModel.ObservableCollection<EntityModel>(appData1.Screens.Select(s => new EntityModel() { Screen = s, Source = "App 1" }));

            model.ScreensForMergedApp.Clear();

            foreach (var item in model.ScreensFromApp1)
            {
                model.ScreensForMergedApp.Add(item);
            }

            foreach (var item in model.ScreensFromApp2)
            {
                model.ScreensForMergedApp.Add(item);
            }
        }

        private void MergeBtn_Click(object sender, RoutedEventArgs e)
        {
            SaveFileDialog saveDialog = new SaveFileDialog();
            saveDialog.Filter = "PowerApps app (*.msapp)|*.msapp";
            saveDialog.FileName = "MergedApp";
            saveDialog.Title = "Save As";

            if (saveDialog.ShowDialog() == System.Windows.Forms.DialogResult.OK)
            {
                MainViewModel model = this.DataContext as MainViewModel;

                try
                {
                    var mergeDetail1 = new List<MergeDetail> {
                        new MergeDetail {
                            AppData = appData1,
                            SelectedScreens = model.ScreensFromApp1.Where(s => s.IsSelected = true).Select(p => p.Screen).ToList()
                        },
                        new MergeDetail {
                            AppData = appData2,
                            SelectedScreens = model.ScreensFromApp2.Where(s => s.IsSelected = true).Select(p => p.Screen).ToList()
                        }
                    };

                    var mergedAppPath = mergeProcessor.MergeApps(mergeDetail1, saveDialog.FileName);

                    MessageBox.Show("The selected screens are merged and saved in  " + saveDialog.FileName, "Message", MessageBoxButton.OK);

                    System.Diagnostics.Process.Start(mergedAppPath);
                }
                catch (Exception ex)
                {
                    MessageBox.Show(ex.Message, "Message", MessageBoxButton.OK);
                }
            }
        }

        private void Window_StateChanged(object sender, EventArgs e)
        {
            if (WindowState == WindowState.Maximized)
                WindowState = WindowState.Normal;
        }

        private void CheckBox_Checked(object sender, RoutedEventArgs e)
        {
            EntityModel data = (sender as FrameworkElement).DataContext as EntityModel;
            MainViewModel model = this.DataContext as MainViewModel;
            model.ScreensForMergedApp.Add(data);
        }

        private void CheckBox_Unchecked(object sender, RoutedEventArgs e)
        {
            EntityModel data = (sender as FrameworkElement).DataContext as EntityModel;
            MainViewModel model = this.DataContext as MainViewModel;
            model.ScreensForMergedApp.Remove(data);
        }
    }
}