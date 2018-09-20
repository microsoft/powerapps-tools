using Microsoft.Practices.ServiceLocation;
using PowerApps_Theme_Editor.ViewModel;
using System;
using System.Globalization;
using System.Linq;
using System.Windows.Data;

namespace PowerApps_Theme_Editor.Converters
{
    public class FontFormatConverter : IValueConverter
    {
        public static string fontReservedPrefix = "%Font.RESERVED%.";

        public object Convert(object value, Type targetType, object parameter, CultureInfo culture)
        {
            if (value != null)
            {
                //"%Font.RESERVED%.'Open Sans'"
                string paFontName = value.ToString();
                paFontName = paFontName.Replace(fontReservedPrefix, "");
                paFontName = paFontName.Replace("'", "");

                MainViewModel model = ServiceLocator.Current.GetInstance<MainViewModel>();

                return model.Fonts.SingleOrDefault(f => f.Source == paFontName);
            }

            return null;
        }

        public object ConvertBack(object value, Type targetType, object parameter, CultureInfo culture)
        {
            string fontName = value.ToString();

            if (fontName.Contains(" "))
                fontName = string.Format("'{0}'", fontName);

            string paFontName = string.Format("{0}{1}", fontReservedPrefix, fontName);

            return paFontName;
        }
    }
}