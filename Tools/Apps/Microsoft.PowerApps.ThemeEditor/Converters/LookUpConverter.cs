using PowerApps_Theme_Editor.ViewModel;
using System;
using System.Collections.ObjectModel;
using System.Globalization;
using System.Linq;
using System.Windows.Data;

namespace PowerApps_Theme_Editor.Converters
{
    public class LookUpConverter : IValueConverter
    {
        public object Convert(object value, Type targetType, object parameter, CultureInfo culture)
        {
            var palettes = value as ObservableCollection<PaletteViewModel>;
            string key = parameter.ToString();

            if (palettes != null)
                return palettes.SingleOrDefault(s => s.name == key);

            return null;
        }

        public object ConvertBack(object value, Type targetType, object parameter, CultureInfo culture)
        {
            throw new NotImplementedException();
        }
    }
}