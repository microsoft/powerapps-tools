using Microsoft.Practices.ServiceLocation;
using Newtonsoft.Json;
using PowerApps_Theme_Editor.ViewModel;
using System;
using System.IO;
using System.Text.RegularExpressions;

namespace PowerApps_Theme_Editor.Model
{
    public class DataService : IDataService
    {
        public void GetData(string path, Action<ThemeModel, Exception> callback)
        {
            // string customThemeFileName = Path.Combine(Directory.GetCurrentDirectory(), "Design/json/", Path.GetFileName("defaultTheme.json"));
            // Regular expression to remove comments from json
            var item = JsonConvert.DeserializeObject<ThemeModel>(Regex.Replace(File.ReadAllText(path), "<!--.*?-->", String.Empty, RegexOptions.Singleline));

            //Temp fix before refactoring @TODO
            if (item.palette == null)
                try
                {
                    item = JsonConvert.DeserializeObject<AppThemeModel>(Regex.Replace(File.ReadAllText(path), "<!--.*?-->", String.Empty, RegexOptions.Singleline)).CustomThemes[0];
                }
                catch (Exception e)
                {
                    System.Windows.MessageBox.Show("Loading default theme\n\n", "Application does not contain theme.", System.Windows.MessageBoxButton.OK, System.Windows.MessageBoxImage.Information);
                    MainViewModel model = ServiceLocator.Current.GetInstance<MainViewModel>();
                    model.LoadTheme(Path.Combine(Path.GetTempPath(), "DefaultApps/Themes.json"));
                    return;
                }
            callback(item, null);
        }
    }
}