using PowerApps_Theme_Editor.ViewModel;
using System.Windows;
using System.Windows.Controls;

namespace PowerApps_Theme_Editor.Utility
{
    public class PropertyTemplateSelector : DataTemplateSelector
    {
        public override DataTemplate
            SelectTemplate(object item, DependencyObject container)
        {
            FrameworkElement element = container as FrameworkElement;

            if (element != null && item != null && item is PaletteViewModel)
            {
                PaletteViewModel palette = item as PaletteViewModel;

                if (palette.type.Equals("c"))
                    return element.FindResource("PropertyColorDataTemplate") as DataTemplate;
                else if (palette.type.Equals("n"))
                    return element.FindResource("PropertyNumberDataTemplate") as DataTemplate;
                else if (palette.type.Equals("e") && palette.value.Contains("%Font.RESERVED%"))
                    return element.FindResource("PropertyFontDataTemplate") as DataTemplate;
                else if (palette.type.Equals("e") && palette.value.Contains("%FontWeight.RESERVED%"))
                    return element.FindResource("PropertyFontWeightDataTemplate") as DataTemplate;
                else if (palette.type.Equals("e") && palette.value.Contains("%BorderStyle.RESERVED%"))
                    return element.FindResource("PropertyBorderStyleDataTemplate") as DataTemplate;
                else if (palette.type.Equals("b"))
                    return element.FindResource("PropertyBooleanStyleDataTemplate") as DataTemplate;
                else if (palette.type.Equals("e") && palette.value.Contains("%Align.RESERVED%"))
                    return element.FindResource("PropertyAlignDataTemplate") as DataTemplate;
                else if (palette.type.Equals("e") && palette.value.Contains("%VerticalAlign.RESERVED%"))
                    return element.FindResource("PropertyVerticalAlignDataTemplate") as DataTemplate;
            }

            return element.FindResource("DefaultPaletteDataTemplate") as DataTemplate;
        }
    }
}