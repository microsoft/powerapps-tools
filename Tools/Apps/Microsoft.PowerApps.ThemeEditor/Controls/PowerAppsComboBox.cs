using System.ComponentModel;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Media;

namespace PowerApps_Theme_Editor.Controls
{
    public class PowerAppsComboBox : ComboBox
    {
        public static DependencyProperty ChevronBackgroundProperty =
            DependencyProperty.Register("ChevronBackground", typeof(SolidColorBrush), typeof(PowerAppsComboBox), new FrameworkPropertyMetadata(new SolidColorBrush(Colors.Gray)));

        public static DependencyProperty ChevronFillProperty =
            DependencyProperty.Register("ChevronFill", typeof(SolidColorBrush), typeof(PowerAppsComboBox), new FrameworkPropertyMetadata(new SolidColorBrush(Colors.White)));

        [Category("Common Properties")]
        public SolidColorBrush ChevronBackground
        {
            get { return (SolidColorBrush)GetValue(ChevronBackgroundProperty); }
            set { SetValue(ChevronBackgroundProperty, value); }
        }

        [Category("Common Properties")]
        public SolidColorBrush ChevronFill
        {
            get { return (SolidColorBrush)GetValue(ChevronFillProperty); }
            set { SetValue(ChevronFillProperty, value); }
        }
    }
}