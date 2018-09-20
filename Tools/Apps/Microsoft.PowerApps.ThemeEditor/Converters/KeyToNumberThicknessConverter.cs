using Microsoft.Practices.ServiceLocation;
using PowerApps_Theme_Editor.ViewModel;
using System;
using System.Globalization;
using System.Linq;
using System.Windows;
using System.Windows.Data;

namespace PowerApps_Theme_Editor.Converters
{
    public class KeyToNumberThicknessConverter : IValueConverter
    {
        public object Convert(object value, Type targetType,
            object parameter, CultureInfo culture)
        {
            if (parameter != null)
            {
                string[] substrings = parameter.ToString().Split(new char[] { '.' });
                string style = substrings[0];
                string property = substrings[1];
                try
                {
                    MainViewModel model = ServiceLocator.Current.GetInstance<MainViewModel>();
                    string key = model.Styles.SingleOrDefault(s => s.name == style).propertyValuesMap.SingleOrDefault(s => s.property == property).value.Replace("Palette.", "").Replace("%", "");

                    var palettes = model.Palettes;

                    if (palettes != null)
                    {
                        PaletteViewModel palette = palettes.FirstOrDefault(s => s.name == key);

                        if (palette != null)
                        {
                            return new Thickness(int.Parse(palette.value));
                        }
                    }
                }
                catch (Exception e)
                {
                    return new Thickness(1);
                }
            }

            return 0;
        }

        public object ConvertBack(object value, Type targetType,
            object parameter, CultureInfo culture)
        {
            return value;
        }
    }
}