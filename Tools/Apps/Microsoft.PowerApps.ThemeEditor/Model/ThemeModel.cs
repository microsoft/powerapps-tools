using System.Collections.Generic;

namespace PowerApps_Theme_Editor.Model
{
    public class AppThemeModel
    {
        public string CurrentTheme { get; set; }
        public List<ThemeModel> CustomThemes { get; set; }
    }

    public class ThemeModel
    {
        public string name { get; set; }
        public List<Palette> palette { get; set; }
        public List<Style> styles { get; set; }
    }

    public class Palette
    {
        public string name { get; set; }
        public string value { get; set; }
        public string type { get; set; }
        public string phoneValue { get; set; }
    }

    public class Style
    {
        public string name { get; set; }

        public string controlTemplateName { get; set; }
        public List<Propertyvaluesmap> propertyValuesMap { get; set; }
    }

    public class Propertyvaluesmap
    {
        public string property { get; set; }
        public string value { get; set; }
    }
}