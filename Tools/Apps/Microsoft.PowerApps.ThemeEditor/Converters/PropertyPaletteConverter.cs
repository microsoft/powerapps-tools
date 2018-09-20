using Microsoft.Practices.ServiceLocation;
using PowerApps_Theme_Editor.Model;
using PowerApps_Theme_Editor.ViewModel;
using System;
using System.Globalization;
using System.Linq;
using System.Windows;
using System.Windows.Data;

namespace PowerApps_Theme_Editor.Converters
{
    public class PropertyPaletteConverter : DependencyObject, IValueConverter
    {
        public static DependencyProperty SourceValueProperty =
    DependencyProperty.Register("SourceValue",
                                typeof(Propertyvaluesmap),
                                typeof(PropertyPaletteConverter));

        public Propertyvaluesmap SourceValue
        {
            get { return (Propertyvaluesmap)GetValue(SourceValueProperty); }
            set { SetValue(SourceValueProperty, value); }
        }

        public object Convert(object value, Type targetType, object parameter, CultureInfo culture)
        {
            return (value as Propertyvaluesmap).value.Replace("Palette.", "").Replace("%", "");
        }

        public object ConvertBack(object value, Type targetType, object parameter, CultureInfo culture)
        {
            MainViewModel model = ServiceLocator.Current.GetInstance<MainViewModel>();

            model.Styles.SingleOrDefault(s => s.name == model.SelectedStyle.name).propertyValuesMap.SingleOrDefault(s => s.property == SourceValue.property).value = "%Palette." + (value as string) + "%";
            model.RefreshPalettes();
            return (value as string);
        }
    }
}