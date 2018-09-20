using PowerApps_Theme_Editor.ViewModel;
using System;
using System.ComponentModel;
using System.Globalization;
using System.Linq;
using System.Windows.Data;

namespace PowerApps_Theme_Editor.Converters
{
    public class KeyToFontWeightConverter : IValueConverter
    {
        public static string fontWeightReservedPrefix = "%FontWeight.RESERVED%.";

        public object Convert(object value, Type targetType,
            object parameter, CultureInfo culture)
        {
            if (parameter != null)
            {
                string key = parameter.ToString();

                BindingList<PaletteViewModel> palettes = value as BindingList<PaletteViewModel>;

                if (palettes != null)
                {
                    PaletteViewModel palette = palettes.FirstOrDefault(s => s.name == key);

                    if (palette != null)
                    {
                        string paFontWeightName = palette.value.ToString();
                        paFontWeightName = paFontWeightName.Replace(fontWeightReservedPrefix, "");
                        paFontWeightName = paFontWeightName.Replace("'", "");

                        return paFontWeightName;
                    }
                }
            }
            return "Normal";
        }

        public object ConvertBack(object value, Type targetType,
            object parameter, CultureInfo culture)
        {
            return value;
        }
    }
}