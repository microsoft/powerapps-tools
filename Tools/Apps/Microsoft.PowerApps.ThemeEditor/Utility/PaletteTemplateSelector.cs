using PowerApps_Theme_Editor.ViewModel;
using System.Windows;
using System.Windows.Controls;

namespace PowerApps_Theme_Editor.Utility
{
    public class PaletteTemplateSelector : DataTemplateSelector
    {
        public override DataTemplate
            SelectTemplate(object item, DependencyObject container)
        {
            FrameworkElement element = container as FrameworkElement;

            if (element != null && item != null && item is PaletteViewModel)
            {
                PaletteViewModel palette = item as PaletteViewModel;

                if (palette.type.Equals("c"))
                    return element.FindResource("ColorDataTemplate") as DataTemplate;
                else if (palette.type.Equals("n"))
                    return element.FindResource("NumberDataTemplate") as DataTemplate;
                else if (palette.type.Equals("e") && palette.value.Contains("%Font.RESERVED%"))
                    return element.FindResource("FontDataTemplate") as DataTemplate;
                else if (palette.type.Equals("e") && palette.value.Contains("%FontWeight.RESERVED%"))
                    return element.FindResource("FontWeightDataTemplate") as DataTemplate;
                else if (palette.type.Equals("e") && palette.value.Contains("%BorderStyle.RESERVED%"))
                    return element.FindResource("BorderStyleDataTemplate") as DataTemplate;
                else if (palette.type.Equals("b"))
                    return element.FindResource("BooleanDataTemplate") as DataTemplate;
                else if (palette.type.Equals("e") && palette.value.Contains("%Align.RESERVED%"))
                    return element.FindResource("AlignDataTemplate") as DataTemplate;
                else if (palette.type.Equals("e") && palette.value.Contains("%VerticalAlign.RESERVED%"))
                    return element.FindResource("VerticalAlignDataTemplate") as DataTemplate;
            }

            return element.FindResource("DefaultPaletteDataTemplate") as DataTemplate;
        }
    }
}