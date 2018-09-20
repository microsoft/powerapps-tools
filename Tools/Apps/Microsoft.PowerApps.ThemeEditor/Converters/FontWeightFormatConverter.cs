using Microsoft.Practices.ServiceLocation;
using PowerApps_Theme_Editor.ViewModel;
using System;
using System.Globalization;
using System.Windows.Data;

namespace PowerApps_Theme_Editor.Converters
{
    public class FontWeightFormatConverter : IValueConverter
    {
        public static string fontWeightReservedPrefix = "%FontWeight.RESERVED%.";

        public object Convert(object value, Type targetType, object parameter, CultureInfo culture)
        {
            if (value != null)
            {
                string paFontWeightName = value.ToString();
                paFontWeightName = paFontWeightName.Replace(fontWeightReservedPrefix, "");
                paFontWeightName = paFontWeightName.Replace("'", "");

                MainViewModel model = ServiceLocator.Current.GetInstance<MainViewModel>();

                //return model.FontWeights.SingleOrDefault(f => f.Source == paFontWeightName);
                return paFontWeightName;
            }

            return null;
        }

        public object ConvertBack(object value, Type targetType, object parameter, CultureInfo culture)
        {
            string paFontWeightName = value.ToString();

            string paFontName = string.Format("{0}{1}", fontWeightReservedPrefix, paFontWeightName);

            return paFontName;
        }
    }
}