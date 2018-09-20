using Microsoft.Practices.ServiceLocation;
using PowerApps_Theme_Editor.ViewModel;
using System;
using System.Globalization;
using System.Linq;
using System.Windows.Data;

namespace PowerApps_Theme_Editor.Converters
{
    public class KeyToFontConverter : IValueConverter
    {
        public static string FontReservedPrefix = "%Font.RESERVED%.";

        public object Convert(object value, Type targetType,
            object parameter, CultureInfo culture)
        {
            MainViewModel model = ServiceLocator.Current.GetInstance<MainViewModel>();

            if (parameter != null)
            {
                string[] substrings = parameter.ToString().Split(new char[] { '.' });
                if (substrings.Length > 1)
                {
                    string style = substrings[0];
                    string property = substrings[1];

                    var palettes = model.Palettes;

                    if (palettes != null)
                    {
                        var currentStyle = model.Styles.SingleOrDefault(s => s.name == style);

                        if (currentStyle != null && currentStyle.propertyValuesMap != null && currentStyle.propertyValuesMap.SingleOrDefault(s => s.property == property) != null)
                        {
                            string key = currentStyle.propertyValuesMap.SingleOrDefault(s => s.property == property).value.Replace("Palette.", "").Replace("%", "");

                            PaletteViewModel palette = palettes.FirstOrDefault(s => s.name == key);
                            if (palette == null) return model.Fonts.First();
                            string paFontName = palette.value.ToString();
                            paFontName = paFontName.Replace(FontReservedPrefix, "");
                            paFontName = paFontName.Replace("'", "");
                            var font = model.Fonts.SingleOrDefault(f => f.Source == paFontName);
                            if (font != null)
                                return model.Fonts.SingleOrDefault(f => f.Source == paFontName);
                            else return model.Fonts.First();
                        }
                    }
                }
            }
            return model.Fonts.First();
        }

        public object ConvertBack(object value, Type targetType,
            object parameter, CultureInfo culture)
        {
            return value;
        }
    }
}