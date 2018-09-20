using Microsoft.Practices.ServiceLocation;
using PowerApps_Theme_Editor.ViewModel;
using System.Windows;

namespace PowerApps_Theme_Editor
{
    /// <summary>
    /// Interaction logic for Help.xaml
    /// </summary>
    public partial class AddPalette : Window
    {
        private MainViewModel model;

        public AddPalette()
        {
            InitializeComponent();
            this.Left = SystemParameters.PrimaryScreenWidth - this.Width;
            Closing += (s, e) => ViewModelLocator.Cleanup();
        }

        private void AddPalette_Click(object sender, RoutedEventArgs e)
        {
            if (model.addNewPalette())
                this.Close();
        }

        private void PaletteTypeGallery_Selected(object sender, RoutedEventArgs e)
        {
            model = ServiceLocator.Current.GetInstance<MainViewModel>();
            switch ((sender as System.Windows.Controls.ComboBox).SelectedValue.ToString().Replace("System.Windows.Controls.ComboBoxItem: ", ""))
            {
                case "Color":
                    model.toBeAdded.value = "RGBA(1,1,1,1)";
                    break;

                case "Number":
                    model.toBeAdded.value = "0";
                    break;

                case "Font":
                    model.toBeAdded.value = "%Font.RESERVED%.Arial";
                    break;

                case "Font Weight":
                    model.toBeAdded.value = "%FontWeight.RESERVED%.Bold";
                    break;

                case "Border Style":
                    model.toBeAdded.value = "%BorderStyle.RESERVED%.None";
                    break;

                case "Boolean":
                    model.toBeAdded.value = "true";
                    break;

                case "Align":
                    model.toBeAdded.value = "%Align.RESERVED%.Center";
                    break;

                case "Vertical Align":
                    model.toBeAdded.value = "%VerticalAlign.RESERVED%.Bottom";
                    break;

                default:
                    model.toBeAdded.value = "RGBA(1,1,1,1)";
                    break;
            }
        }

        public void ShowDialog(Window owner)
        {
            this.Owner = owner;
            this.ShowDialog();
        }
    }
}