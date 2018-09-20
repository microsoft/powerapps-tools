using Microsoft.Practices.ServiceLocation;
using PowerApps_Theme_Editor.ViewModel;
using System;
using System.Globalization;
using System.Linq;
using System.Windows.Data;
using System.Windows.Media;

namespace PowerApps_Theme_Editor.Converters
{
    public class KeyToColorConverter : IValueConverter
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

                    if (model.Palettes != null)
                    {
                        string key = model.Styles.SingleOrDefault(s => s.name == style).propertyValuesMap.SingleOrDefault(s => s.property == property).value.Replace("Palette.", "").Replace("%", "");
                        PaletteViewModel palette = model.Palettes.FirstOrDefault(s => s.name == key);

                        if (palette != null)
                        {
                            string colorString = palette.value;

                            if (colorString.Contains("ColorFade"))
                                return Colors.Black;

                            if (!colorString.Contains("RGBA("))
                                return Colors.Black;

                            int start = colorString.IndexOf("(");
                            int end = colorString.IndexOf(")");
                            var rgba = colorString.Substring(start + 1, end - start - 1);
                            string[] colors = rgba.Split(new char[] { ',' });
                            var alpha = (byte)(float.Parse(colors[3]) * 255);

                            Color x = Color.FromArgb(alpha, byte.Parse(colors[0]), byte.Parse(colors[1]), byte.Parse(colors[2]));

                            return new SolidColorBrush(x);
                        }
                    }
                }
                return new SolidColorBrush(Colors.Black);
            }
            catch (Exception e)
            {
                Console.WriteLine(e.ToString());
                return new SolidColorBrush(Colors.Black);
            }
        }

        public object ConvertBack(object value, Type targetType,
            object parameter, CultureInfo culture)
        {
            return value;
        }
    }
}