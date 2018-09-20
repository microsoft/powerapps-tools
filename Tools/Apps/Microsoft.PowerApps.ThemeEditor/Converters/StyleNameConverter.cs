using System;
using System.Globalization;
using System.Windows.Data;

namespace PowerApps_Theme_Editor.Converters
{
    internal class StyleNameConverter : IValueConverter
    {
        private static string Default = "  (Default)";

        public object Convert(object value, Type targetType, object parameter, CultureInfo culture)
        {
            String cleanName = (value as string).Replace("default", "").Replace("Style", "");
            if ((value as string).Contains("default"))
                return cleanName + Default;
            else return cleanName;
        }

        public object ConvertBack(object value, Type targetType, object parameter, CultureInfo culture)
        {
            return "default" + (value as string).Replace(Default, "") + "Style";
        }
    }
}