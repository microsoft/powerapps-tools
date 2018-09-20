using Microsoft.Practices.ServiceLocation;
using PowerApps_Theme_Editor.ViewModel;
using System;
using System.Globalization;
using System.Linq;
using System.Windows.Data;

namespace PowerApps_Theme_Editor.Converters
{
    public class KeyToNumberConverter : IValueConverter
    {
        public object Convert(object value, Type targetType,
            object parameter, CultureInfo culture)
        {
            try
            {
                if (parameter != null)
                {
                    string[] substrings = parameter.ToString().Split(new char[] { '.' });
                    string style = substrings[0];
                    string property = substrings[1];
                    MainViewModel model = ServiceLocator.Current.GetInstance<MainViewModel>();
                    var palettes = model.Palettes;

                    if (palettes != null)
                    {
                        string key = model.Styles.SingleOrDefault(s => s.name == style).propertyValuesMap.SingleOrDefault(s => s.property == property).value.Replace("Palette.", "").Replace("%", "");

                        PaletteViewModel palette = palettes.FirstOrDefault(s => s.name == key);

                        if (palette != null)
                        {
                            return int.Parse(palette.value);
                        }
                    }
                }
                return 0;
            }
            catch (Exception e)
            {
                Console.WriteLine(e.ToString());
                return 0;
            }
        }

        public object ConvertBack(object value, Type targetType,
            object parameter, CultureInfo culture)
        {
            return value;
        }
    }
}