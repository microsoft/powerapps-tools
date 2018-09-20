using Microsoft.Practices.ServiceLocation;
using PowerApps_Theme_Editor.ViewModel;
using System;
using System.Globalization;
using System.Linq;
using System.Windows.Data;

namespace PowerApps_Theme_Editor.Converters
{
    internal class PaletteNameToValue : IValueConverter
    {
        public object Convert(object value, Type targetType, object parameter, CultureInfo culture)
        {
            string paletteName = value as string;
            MainViewModel model = ServiceLocator.Current.GetInstance<MainViewModel>();

            if (model.Palettes != null)
            {
                PaletteViewModel palette = model.Palettes.FirstOrDefault(s => s.name == paletteName);

                if (palette != null)
                {
                    switch (parameter as string)
                    {
                        case "color":
                            ColorConverter colorConverter = new ColorConverter();
                            return colorConverter.Convert(palette.value, targetType, parameter, culture);

                        case "number":
                            StringToIntConverter IntConverter = new StringToIntConverter();
                            return IntConverter.Convert(palette.value, targetType, parameter, culture);

                        case "fontWeight":
                            FontWeightFormatConverter fontWeightConverter = new FontWeightFormatConverter();
                            return fontWeightConverter.Convert(palette.value, targetType, parameter, culture);

                        case "font":
                            FontFormatConverter FontConverter = new FontFormatConverter();
                            return FontConverter.Convert(palette.value, targetType, parameter, culture);

                        case "borderStyle":
                            BorderStyleFormatConverter borderStyleFormatConverter = new BorderStyleFormatConverter();
                            return borderStyleFormatConverter.Convert(palette.value, targetType, parameter, culture);

                        case "align":
                            AlignStyleFormatConverter alignStyleFormatConverter = new AlignStyleFormatConverter();
                            return alignStyleFormatConverter.Convert(palette.value, targetType, parameter, culture);

                        case "verticalAlign":
                            VerticalAlignStyleFormatConverter verticalAlignStyleFormatConverter = new VerticalAlignStyleFormatConverter();
                            return verticalAlignStyleFormatConverter.Convert(palette.value, targetType, parameter, culture);

                        default:
                            return palette.value;
                    }
                }
            }

            return value;
        }

        public object ConvertBack(object value, Type targetType, object parameter, CultureInfo culture)
        {
            return value;
        }
    }
}