using GalaSoft.MvvmLight.Threading;
using System.Windows;

namespace PowerApps_Theme_Editor
{
    /// <summary>
    /// Interaction logic for App.xaml
    /// </summary>
    public partial class App : Application
    {
        static App()
        {
            DispatcherHelper.Initialize();
        }
    }
}