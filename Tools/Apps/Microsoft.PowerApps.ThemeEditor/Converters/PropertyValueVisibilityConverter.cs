using System;
using System.Globalization;
using System.Windows;
using System.Windows.Data;

namespace PowerApps_Theme_Editor.Converters
{
    internal class PropertyValueVisibilityConverter : IValueConverter
    {
        public object Convert(object value, Type targetType, object parameter, CultureInfo culture)
        {
            if ((parameter as string).Equals("Default"))
            {
                if ((value as string).Equals("Default"))
                    return Visibility.Visible;
                else
                    return Visibility.Collapsed;
            }
            else
            {
                if ((value as string).Equals("Default"))
                    return Visibility.Collapsed;
                else
                    return Visibility.Visible;
            }
        }

        public object ConvertBack(object value, Type targetType, object parameter, CultureInfo culture)
        {
            throw new NotImplementedException();
        }
    }
}