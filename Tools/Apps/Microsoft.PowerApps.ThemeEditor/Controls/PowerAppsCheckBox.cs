using System.ComponentModel;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Media;

namespace PowerApps_Theme_Editor.Controls
{
    public class PowerAppsCheckBox : CheckBox
    {
        public static DependencyProperty CheckmarkFillProperty =
    DependencyProperty.Register("CheckmarkFill", typeof(SolidColorBrush), typeof(PowerAppsCheckBox), new FrameworkPropertyMetadata(new SolidColorBrush(Colors.Gray)));

        public static DependencyProperty CheckBoxBackgroundFillProperty =
            DependencyProperty.Register("CheckBoxBackgroundFill", typeof(SolidColorBrush), typeof(PowerAppsCheckBox), new FrameworkPropertyMetadata(new SolidColorBrush(Colors.White)));

        [Category("Common Properties")]
        public SolidColorBrush CheckmarkFill
        {
            get { return (SolidColorBrush)GetValue(CheckmarkFillProperty); }
            set { SetValue(CheckmarkFillProperty, value); }
        }

        [Category("Common Properties")]
        public SolidColorBrush CheckBoxBackgroundFill
        {
            get { return (SolidColorBrush)GetValue(CheckBoxBackgroundFillProperty); }
            set { SetValue(CheckBoxBackgroundFillProperty, value); }
        }
    }
}