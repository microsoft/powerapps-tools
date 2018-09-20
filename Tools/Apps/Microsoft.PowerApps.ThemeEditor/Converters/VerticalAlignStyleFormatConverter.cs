using System;
using System.Globalization;
using System.Windows.Data;

namespace PowerApps_Theme_Editor.Converters
{
    public class VerticalAlignStyleFormatConverter : IValueConverter
    {
        public static string VerticalAlignStyleReservedPrefix = "%VerticalAlign.RESERVED%.";

        public object Convert(object value, Type targetType, object parameter, CultureInfo culture)
        {
            if (value != null)
            {
                string paBorderStyleName = value.ToString();
                paBorderStyleName = paBorderStyleName.Replace(VerticalAlignStyleReservedPrefix, "");
                paBorderStyleName = paBorderStyleName.Replace("'", "");
                return paBorderStyleName;
            }

            return null;
        }

        public object ConvertBack(object value, Type targetType, object parameter, CultureInfo culture)
        {
            string paFontWeightName = value.ToString();

            string paFontName = string.Format("{0}{1}", VerticalAlignStyleReservedPrefix, paFontWeightName);

            return paFontName;
        }
    }
}