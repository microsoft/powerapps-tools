using System;
using System.Globalization;
using System.Windows.Data;

namespace PowerApps_Theme_Editor.Converters
{
    public class BorderStyleFormatConverter : IValueConverter
    {
        public static string borderStyleReservedPrefix = "%BorderStyle.RESERVED%.";

        public object Convert(object value, Type targetType, object parameter, CultureInfo culture)
        {
            if (value != null)
            {
                string paBorderStyleName = value.ToString();
                paBorderStyleName = paBorderStyleName.Replace(borderStyleReservedPrefix, "");
                paBorderStyleName = paBorderStyleName.Replace("'", "");
                return paBorderStyleName;
            }

            return null;
        }

        public object ConvertBack(object value, Type targetType, object parameter, CultureInfo culture)
        {
            string paFontWeightName = value.ToString();

            string paFontName = string.Format("{0}{1}", borderStyleReservedPrefix, paFontWeightName);

            return paFontName;
        }
    }
}