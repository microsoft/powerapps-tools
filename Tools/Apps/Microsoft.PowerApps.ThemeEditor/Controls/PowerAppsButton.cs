using System.Windows;
using System.Windows.Controls;

namespace PowerApps_Theme_Editor.Controls
{
    public class PowerAppsButton : Button
    {
        public static readonly DependencyProperty CornerRadiusProperty =
                    DependencyProperty.Register("CornerRadius", typeof(CornerRadius), typeof(PowerAppsButton), new FrameworkPropertyMetadata(new CornerRadius(0)));

        public CornerRadius CornerRadius
        {
            get { return (CornerRadius)GetValue(CornerRadiusProperty); }
            set { SetValue(CornerRadiusProperty, value); }
        }
    }
}