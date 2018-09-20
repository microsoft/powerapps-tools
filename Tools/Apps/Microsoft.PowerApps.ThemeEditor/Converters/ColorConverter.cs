using System;
using System.Globalization;
using System.Windows.Data;
using System.Windows.Media;

namespace PowerApps_Theme_Editor.Converters
{
    public class ColorConverter : IValueConverter
    {
        public object Convert(object value, Type targetType,
            object parameter, CultureInfo culture)
        {
            if (value != null)
            {
                string colorString = value.ToString();

                if (colorString.Contains("ColorFade"))
                {
                    // ColorFade(RGBA(203, 209, 214, 1), 70 %)
                    colorString = colorString.Replace("ColorFade(", "");
                    colorString = colorString.Remove(colorString.LastIndexOf(")"));

                    string percentString = colorString.Substring(colorString.LastIndexOf(",") + 1).Replace("%", "");
                    float factor = float.Parse(percentString) / 100.0f;

                    Color fadeColor = GetColorFromPowerAppsRGBA(colorString);

                    return ChangeColorBrightness(fadeColor, factor);
                }

                return GetColorFromPowerAppsRGBA(colorString);
            }
            return value;
        }

        public static Color GetColorFromPowerAppsRGBA(string colorString)
        {
            int start = colorString.IndexOf("(");
            int end = colorString.IndexOf(")");
            var rgba = colorString.Substring(start + 1, end - start - 1);
            string[] colors = rgba.Split(new char[] { ',' });
            var alpha = (byte)(float.Parse(colors[3]) * 255);
            return Color.FromArgb(alpha, byte.Parse(colors[0]), byte.Parse(colors[1]), byte.Parse(colors[2])); ;
        }

        public static Color ChangeColorBrightness(Color color, float correctionFactor)
        {
            float red = (float)color.R;
            float green = (float)color.G;
            float blue = (float)color.B;

            if (correctionFactor < 0)
            {
                correctionFactor = 1 + correctionFactor;
                red *= correctionFactor;
                green *= correctionFactor;
                blue *= correctionFactor;
            }
            else
            {
                red = (255 - red) * correctionFactor + red;
                green = (255 - green) * correctionFactor + green;
                blue = (255 - blue) * correctionFactor + blue;
            }

            return Color.FromArgb(color.A, (byte)red, (byte)green, (byte)blue);
        }

        public object ConvertBack(object value, Type targetType,
            object parameter, CultureInfo culture)
        {
            Color color = (Color)value;

            return string.Format("RGBA({0},{1},{2},{3})", color.R, color.G, color.B, ((float)color.A / 255.0f).ToString("0.00"));
        }
    }
}