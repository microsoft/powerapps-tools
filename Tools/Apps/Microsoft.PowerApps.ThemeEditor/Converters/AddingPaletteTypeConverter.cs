using System;
using System.Globalization;
using System.Windows.Data;

namespace PowerApps_Theme_Editor.Converters
{
    internal class AddingPaletteTypeConverter : IValueConverter
    {
        public object Convert(object value, Type targetType, object parameter, CultureInfo culture)
        {
            //won't be used because it is a Oneway to source binding
            return value;
        }

        public object ConvertBack(object value, Type targetType, object parameter, CultureInfo culture)
        {
            if (value != null)
                switch (value.ToString().Replace("System.Windows.Controls.ComboBoxItem: ", ""))
                {
                    case "Color":
                        return "c";

                    case "Number":
                        return "n";

                    case "Font":
                        return "e";

                    case "Font Weight":
                        return "e";

                    case "Border Style":
                        return "e";

                    case "Boolean":
                        return "b";

                    case "Align":
                        return "e";

                    case "Vertical Align":
                        return "e";

                    default:
                        return "c";
                }
            else return "c";
        }
    }
}