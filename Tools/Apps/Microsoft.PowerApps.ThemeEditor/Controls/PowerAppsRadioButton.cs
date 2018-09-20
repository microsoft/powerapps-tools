using System.ComponentModel;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Media;

namespace PowerApps_Theme_Editor.Controls
{
    public class PowerAppsRadioButton : RadioButton
    {
        public static DependencyProperty RadioSelectionFillProperty =
    DependencyProperty.Register("RadioSelectionFill", typeof(SolidColorBrush), typeof(PowerAppsRadioButton), new FrameworkPropertyMetadata(new SolidColorBrush(Colors.Gray)));

        public static DependencyProperty RadioSelectionBackgroundFillProperty =
            DependencyProperty.Register("RadioSelectionBackgroundFill", typeof(SolidColorBrush), typeof(PowerAppsRadioButton), new FrameworkPropertyMetadata(new SolidColorBrush(Colors.White)));

        [Category("Common Properties")]
        public SolidColorBrush RadioSelectionFill
        {
            get { return (SolidColorBrush)GetValue(RadioSelectionFillProperty); }
            set { SetValue(RadioSelectionFillProperty, value); }
        }

        [Category("Common Properties")]
        public SolidColorBrush RadioSelectionBackgroundFill
        {
            get { return (SolidColorBrush)GetValue(RadioSelectionBackgroundFillProperty); }
            set { SetValue(RadioSelectionBackgroundFillProperty, value); }
        }
    }
}