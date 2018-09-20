using Microsoft.Practices.ServiceLocation;
using PowerApps_Theme_Editor.Model;
using PowerApps_Theme_Editor.ViewModel;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Windows;
using System.Windows.Forms;
using System.Windows.Input;

namespace PowerApps_Theme_Editor
{
    /// <summary>
    /// Interaction logic for MainWindow.xaml
    /// </summary>
    public partial class MainWindow : Window
    {
        private MainViewModel model;
        private bool undo = false;
        private bool redo = false;

        public Visibility Hidden { get; private set; }

        /// <summary>
        /// Initializes a new instance of the MainWindow class.
        /// </summary>
        public MainWindow()
        {
            InitializeComponent();
            Closing += (s, e) => ViewModelLocator.Cleanup();
            model = ServiceLocator.Current.GetInstance<MainViewModel>();
        }

        private void OnNewAppClick(object sender, RoutedEventArgs e)
        {
            if (SavePrompt())
            {
                model.NewApp();
            }
        }

        private void OnNewThemeClick(object sender, RoutedEventArgs e)
        {
            if (SavePrompt())
            {
                model.LoadEmptyTheme();
            }
        }

        private void OnExitClick(object sender, RoutedEventArgs e)
        {
            System.Windows.Application.Current.Shutdown();
        }

        private void OnOpenThemeClick(object sender, RoutedEventArgs e)
        {
            if (SavePrompt())
            {
                var fileDialog = new System.Windows.Forms.OpenFileDialog();
                fileDialog.Filter = "JSON Files | *.json";
                fileDialog.Multiselect = false;

                var result = fileDialog.ShowDialog();

                switch (result)
                {
                    case System.Windows.Forms.DialogResult.OK:
                        model.LoadTheme(fileDialog.FileName);
                        break;

                    case System.Windows.Forms.DialogResult.Cancel:
                        break;

                    default:
                        break;
                }
            }
        }

        private bool SavePrompt()
        {
            string sMessageBoxText = "Would you like to save your current application?";
            string sCaption = "Theme Editor";

            MessageBoxButton btnMessageBox = MessageBoxButton.YesNoCancel;
            MessageBoxImage icnMessageBox = MessageBoxImage.Warning;

            MessageBoxResult rsltMessageBox = System.Windows.MessageBox.Show(sMessageBoxText, sCaption, btnMessageBox, icnMessageBox);

            switch (rsltMessageBox)
            {
                case MessageBoxResult.Yes:
                    SaveFileDialog saveDialog = new SaveFileDialog();
                    saveDialog.Filter = "PowerApps app (*.msapp)|*.msapp";
                    saveDialog.FileName = model.AppName; ;
                    saveDialog.Title = "Save As";
                    if (saveDialog.ShowDialog() == System.Windows.Forms.DialogResult.OK)
                    {
                        model.ExportApp(saveDialog.FileName);
                        return true;
                    }
                    else return false;
                case MessageBoxResult.No:
                    return true;

                case MessageBoxResult.Cancel:

                default:
                    return false;
            }
        }

        private void OnSaveThemeClick(object sender, RoutedEventArgs e)
        {
            SaveFileDialog saveDialog = new SaveFileDialog();
            saveDialog.Filter = "PowerApps app theme (*.json)|*.json";
            saveDialog.FileName = "Themes";
            saveDialog.Title = "Save As";
            if (saveDialog.ShowDialog() == System.Windows.Forms.DialogResult.OK)
            {
                model.ExportTheme(saveDialog.FileName);
            }
        }

        private void OnExportMsappClick(object sender, RoutedEventArgs e)
        {
            SaveFileDialog saveDialog = new SaveFileDialog();
            saveDialog.Filter = "PowerApps app (*.msapp)|*.msapp";
            saveDialog.FileName = model.AppName; ;
            saveDialog.Title = "Save As";
            if (saveDialog.ShowDialog() == System.Windows.Forms.DialogResult.OK)
            {
                model.ExportApp(saveDialog.FileName);
            }
        }

        private void OnImportMsappClick(object sender, RoutedEventArgs e)
        {
            if (SavePrompt())
            {
                var fileDialog = new System.Windows.Forms.OpenFileDialog();
                var result = fileDialog.ShowDialog();
                switch (result)
                {
                    case System.Windows.Forms.DialogResult.OK:
                        model.OpenThemeFromApp(fileDialog.FileName);
                        break;

                    case System.Windows.Forms.DialogResult.Cancel:
                    default:
                        break;
                }
            }
        }

        private void AddPalette_Click(object sender, RoutedEventArgs e)
        {
            model.addNewPalette();
        }

        private void ApplyTheme_click(object sender, RoutedEventArgs e)
        {
            model.ApplyThemeToEntities();
        }

        private void Delete_Palette_Click(object sender, RoutedEventArgs e)
        {
            string paletteToDelete = ((System.Windows.Controls.MenuItem)sender).Tag as string;
            MessageBoxResult result = System.Windows.MessageBox.Show("Are you sure that you would like to delete " + paletteToDelete + " Palette?", "Applying styles to exisiting entities", MessageBoxButton.YesNo, MessageBoxImage.Question, MessageBoxResult.No);
            if (result.ToString() == "Yes")
                model.DeletePalette(paletteToDelete);
        }

        private void Undo_Click(object sender, RoutedEventArgs e)
        {
            undo = true;
            model.undo();
            model.RefreshPalettes();
            undo = false;
        }

        private void Redo_Click(object sender, RoutedEventArgs e)
        {
            redo = true;
            model.redo();
            model.RefreshPalettes();
            redo = false;
        }

        private void Palette_SourceUpdated(object sender, System.Windows.Data.DataTransferEventArgs e)
        {
            model.RefreshPalettes();
            model.log_change();
        }

        private void Undo_CanExecute(object sender, CanExecuteRoutedEventArgs e)
        {
            e.CanExecute = model.UndoAvailable;
        }

        private void Redo_CanExecute(object sender, CanExecuteRoutedEventArgs e)
        {
            e.CanExecute = model.RedoAvailable;
        }

        private void log_stylechanges()
        {
            try
            {
                List<Propertyvaluesmap> current = model.history_theme.peek().Last().styles.FirstOrDefault(s => s.name == model.SelectedStyle.name).propertyValuesMap;
                if (!model.SelectedStylePallete.All(s => s.PropertyValue.value == current.FirstOrDefault(s2 => s.PropertyValue.property == s2.property).value) && (!undo) && (!redo))
                {
                    model.log_change();
                }
            }
            catch (Exception e)
            {
                return;
            }
        }

        private void SelectedStyleGallery_TargetUpdated(object sender, System.Windows.Data.DataTransferEventArgs e)
        {
            log_stylechanges();
        }

        private void AddPalleteMenu_Click(object sender, RoutedEventArgs e)
        {
            AddPalette addPalette = new AddPalette();
            addPalette.ShowDialog(this);
        }

        private void filter_MouseDown(object sender, RoutedEventArgs e)
        {
            if (model.ToggleShowAllStyles())
            {
                filter.Visibility = Visibility.Hidden;
                filterOff.Visibility = Visibility.Visible;
            }
            else
            {
                filter.Visibility = Visibility.Visible;
                filterOff.Visibility = Visibility.Hidden;
            }
        }

        private void MenuItem_Options_Click(object sender, RoutedEventArgs e)
        {
            Settings settings = new Settings();
            settings.ShowDialog(this);
        }
    }
}