using GalaSoft.MvvmLight;
using Microsoft.PowerApps.Tools.AppEntities;
using Newtonsoft.Json;
using PowerApps_Theme_Editor.Model;
using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.IO;
using System.Linq;
using System.Windows.Media;

namespace PowerApps_Theme_Editor.ViewModel
{
    /// <summary>
    /// This class contains properties that the main View can data bind to.
    /// </summary>
    public class MainViewModel : ViewModelBase
    {
        #region Fields

        private ThemeModel _styleModel;
        private Style _selectedStyle;
        private PaletteViewModel _toBeAdded = new PaletteViewModel(new Palette { name = "New Palette", type = "c", value = "RGBA(1,1,1,1)" });
        private ThemeModel _defaultTheme;

        private readonly IDataService _dataService;
        public History<ThemeModel> history_theme;

        private ObservableCollection<PatchedPropertyValueMap> _selectedStylePallete = new ObservableCollection<PatchedPropertyValueMap>();
        private ObservableCollection<FontFamily> _fonts = new ObservableCollection<FontFamily>();
        private ObservableCollection<PaletteViewModel> _palettes = new ObservableCollection<PaletteViewModel>();

        private static string DefaultPhoneApp = "DefaultApps\\DemoApp.msapp";
        private static string DefaultTabletApp = "DefaultApps\\DemoApp.msapp";
        private static string DefaultThemeFile = "DefaultApps\\DefaultTheme.json";
        private static string ThemeFileSchema = "DefaultApps\\ThemeFileSchema.json";
        private string _appName = "";
        private string _appPath = string.Empty;

        private bool _showAllStyles = true;
        private bool _isDefaultApp = true;
        private bool _isTabletMode = false;
        private bool _setting_apply_dimension = false;
        private bool _setting_apply_theme_styles = true;

        #endregion Fields

        #region Properties

        public bool apply_dimension
        {
            get
            {
                return _setting_apply_dimension;
            }
            set
            {
                Set(ref _setting_apply_dimension, value);
            }
        }

        public bool apply_theme_styles
        {
            get
            {
                return _setting_apply_theme_styles;
            }
            set
            {
                Set(ref _setting_apply_theme_styles, value);
            }
        }

        public string AppPath
        {
            get
            {
                return _appPath;
            }
            set
            {
                Set(ref _appPath, value);
                RaisePropertyChanged("AppPath");
            }
        }

        public bool IsTabletMode
        {
            get
            {
                return _isTabletMode;
            }
            set
            {
                Set(ref _isTabletMode, value);
            }
        }

        public bool isDefaultApp
        {
            get
            {
                return this._appPath == Path.Combine(Directory.GetCurrentDirectory(), MainViewModel.DefaultThemeFile);
            }
            set
            {
                Set(ref _isDefaultApp, value);
                this.RaisePropertyChanged("isDefaultApp");
            }
        }

        public string AppName
        {
            get
            {
                if (this.isDefaultApp)
                    return "Blank PowerApp";
                else return Path.GetFileName(this.AppPath).Replace(".msapp", "");
            }
            set
            {
                Set(ref _appName, value);
                RaisePropertyChanged("AppName");
            }
        }

        public PaletteViewModel toBeAdded
        {
            get
            {
                return this._toBeAdded;
            }
            set
            {
                Set(ref this._toBeAdded, value);
            }
        }

        /// <summary>
        /// Theme Name
        /// </summary>
        public string ThemeName
        {
            get
            {
                return this._styleModel.name;
            }
        }

        /// <summary>
        /// List of color palettes
        /// </summary>
        public ObservableCollection<String> ColorPalettes
        {
            get
            {
                ObservableCollection<string> temp = new ObservableCollection<String>(this._styleModel.palette.Where(s => s.type == "c").OrderBy(s => s.name).Select(s => s.name.ToString()).ToList());
                temp.Add("Default");
                return temp;
            }
        }

        /// <summary>
        /// List of number palettes
        /// </summary>
        public ObservableCollection<String> NumberPalettes
        {
            get
            {
                ObservableCollection<string> temp = new ObservableCollection<String>(this._styleModel.palette.Where(s => s.type == "n").OrderBy(s => s.name).Select(s => s.name.ToString()).ToList());
                temp.Add("Default");
                return temp;
            }
        }

        /// <summary>
        /// List of font palettes
        /// </summary>
        public ObservableCollection<String> FontPalettes
        {
            get
            {
                ObservableCollection<string> temp = new ObservableCollection<String>(this._styleModel.palette.Where(s => (s.type == "e") && (s.value.Contains("%Font.RESERVED%"))).OrderBy(s => s.name).Select(s => s.name.ToString()).ToList());
                temp.Add("Default");
                return temp;
            }
        }

        /// <summary>
        /// List of font weight palettes
        /// </summary>
        public ObservableCollection<String> FontWeightPalettes
        {
            get
            {
                ObservableCollection<string> temp = new ObservableCollection<String>(this._styleModel.palette.Where(s => (s.type == "e") && (s.value.Contains("%FontWeight.RESERVED%"))).OrderBy(s => s.name).Select(s => s.name.ToString()).ToList());
                temp.Add("Default");
                return temp;
            }
        }

        /// <summary>
        /// List of font weight palettes
        /// </summary>
        public ObservableCollection<String> BorderStylePalettes
        {
            get
            {
                ObservableCollection<string> temp = new ObservableCollection<String>(this._styleModel.palette.Where(s => (s.type == "e") && (s.value.Contains("%BorderStyle.RESERVED%"))).OrderBy(s => s.name).Select(s => s.name.ToString()).ToList());
                temp.Add("Default");
                return temp;
            }
        }

        /// <summary>
        /// List of Boolean palettes
        /// </summary>
        public ObservableCollection<String> BooleanStylePalettes
        {
            get
            {
                ObservableCollection<string> temp = new ObservableCollection<String>(this._styleModel.palette.Where(s => (s.type == "b")).OrderBy(s => s.name).Select(s => s.name.ToString()).ToList());
                temp.Add("Default");
                return temp;
            }
        }

        /// <summary>
        /// List of Align palettes
        /// </summary>
        public ObservableCollection<String> AlignStylePalettes
        {
            get
            {
                ObservableCollection<string> temp = new ObservableCollection<String>(this._styleModel.palette.Where(s => (s.type == "e") && (s.value.Contains("%Align.RESERVED%"))).OrderBy(s => s.name).Select(s => s.name.ToString()).ToList());
                temp.Add("Default");
                return temp;
            }
        }

        /// <summary>
        /// List of Vertical Align palettes
        /// </summary>
        public ObservableCollection<String> VerticalAlignStylePalettes
        {
            get
            {
                ObservableCollection<string> temp = new ObservableCollection<String>(this._styleModel.palette.Where(s => (s.type == "e") && (s.value.Contains("%VerticalAlign.RESERVED%"))).OrderBy(s => s.name).Select(s => s.name.ToString()).ToList());
                temp.Add("Default");
                return temp;
            }
        }

        public string[] AllowedFonts
        {
            get
            {
                return new[] {
                    "Arial",
                    "Courier New",
                    "Dancing Script",
                    "Georgia",
                    "Great Vibes",
                    "Lato",
                    "Lato Black",
                    "Lato Hairline",
                    "Lato Light",
                    "Open Sans",
                    "Open Sans Condensed",
                    "Patrick Hand",
                    "Verdana"
                };
            }
        }

        public string[] FontWeights
        {
            get
            {
                return new[] {
                    "Bold",
                    "Semibold",
                    "Normal",
                    "Lighter"
                };
            }
        }

        public string[] BorderStyles
        {
            get
            {
                return new[] {
                    "None",
                    "Solid",
                    "Dashed",
                    "Dotted"
                };
            }
        }

        public string[] AlignStyles
        {
            get
            {
                return new[] {
                    "Center",
                    "Justify",
                    "Left",
                    "Right"
                };
            }
        }

        public string[] VerticalAlignStyles
        {
            get
            {
                return new[] {
                    "Bottom",
                    "Middle",
                    "Top"
                };
            }
        }

        public string[] Boolean
        {
            get
            {
                return new[] {
                    "true",
                    "false"
                };
            }
        }

        /// <summary>
        /// Gets the WelcomeTitle property.
        /// Changes to that property's value raise the PropertyChanged event.
        /// </summary>
        public ThemeModel StyleModel
        {
            get
            {
                _styleModel.styles = new List<Style>(Styles);
                return _styleModel;
            }
            set
            {
                Set(ref _styleModel, value);

                this.RaisePropertyChanged("Palettes");
                this.RaisePropertyChanged("Styles");
                this.RaisePropertyChanged("CustomTitle");

                if (this.Styles != null && this.Styles.Any())
                {
                    this.SelectedStyle = this.Styles.First();
                }
            }
        }

        public ObservableCollection<PaletteViewModel> Palettes
        {
            get
            {
                if (this._styleModel != null && this._styleModel.palette != null)
                {
                    this._palettes = new ObservableCollection<PaletteViewModel>(this._styleModel.palette.Select(s => new PaletteViewModel(s)).OrderBy(s => s.type).ToList());

                    return this._palettes;
                }

                return null;
            }
            set
            {
                Set(ref _palettes, value);
            }
        }

        public ObservableCollection<FontFamily> Fonts
        {
            get
            {
                return this._fonts;
            }
            set
            {
                Set(ref _fonts, value);
            }
        }

        public ObservableCollection<Style> Styles
        {
            get
            {
                if (this._styleModel != null && this._styleModel.styles != null)
                {
                    var styles = new ObservableCollection<Style>(this._styleModel.styles.Where(s => s.name.Contains("default") || _showAllStyles).OrderBy(s => s.controlTemplateName));
                    return styles;
                }
                return null;
            }
        }

        public Style SelectedStyle
        {
            get
            {
                if (_selectedStyle == null)
                {
                    return this.Styles.First();
                }
                else
                    return this._selectedStyle;
            }
            set
            {
                Set(ref _selectedStyle, value);
                RaisePropertyChanged("SelectedStylePallete");
            }
        }

        public ObservableCollection<PatchedPropertyValueMap> SelectedStylePallete
        {
            get
            {
                this._selectedStylePallete.Clear();
                if (this._selectedStyle != null && this._selectedStyle.propertyValuesMap != null)
                {
                    foreach (Propertyvaluesmap property in this._selectedStyle.propertyValuesMap)
                    {
                        //TODO:regex
                        string paletteName = property.value.Replace("%", "").Replace("Palette.", "");
                        PaletteViewModel palette;
                        if (paletteName != "Default")
                            palette = this.Palettes.SingleOrDefault(s => (s.name == paletteName));
                        else
                        {
                            string paletteDefaultName = this._defaultTheme.styles.FirstOrDefault(s => s.name == this._selectedStyle.name).propertyValuesMap.FirstOrDefault(s => s.property == property.property).value;
                            if (paletteDefaultName.Contains("Palette"))
                            {
                                paletteDefaultName = paletteDefaultName.Replace("%", "").Replace("Palette.", "");
                                Palette Defaultpalette = this._defaultTheme.palette.FirstOrDefault(s => s.name == paletteDefaultName);
                                palette = new PaletteViewModel(new Palette { name = "Default", type = Defaultpalette.type, value = Defaultpalette.value });
                            }
                            else palette = null;
                        }
                        if (palette != null)
                        {
                            this._selectedStylePallete.Add(new PatchedPropertyValueMap() { Palette = new PaletteViewModel(new Palette { name = palette.name, type = palette.type, value = palette.value }), PropertyValue = property });
                        }
                    }
                }
                return this._selectedStylePallete;
            }
            set
            {
                Set(ref _selectedStylePallete, value);
            }
        }

        public bool UndoAvailable
        {
            get
            {
                return history_theme.undo_available();
            }
        }

        public bool RedoAvailable
        {
            get
            {
                return history_theme.redo_available();
            }
        }

        #endregion Properties

        #region Constructor

        /// <summary>
        /// Initializes a new instance of the MainViewModel class.
        /// </summary>
        public MainViewModel(IDataService dataService)
        {
            _dataService = dataService;

            //Goes through all the allowed fonts and checks if they are available in the system
            foreach (String font in AllowedFonts)
            {
                var temp = System.Windows.Media.Fonts.SystemFontFamilies.FirstOrDefault(s => s.Source == font);
                if (temp != null)
                    this._fonts.Add(temp);
                else this._fonts.Add(new FontFamily(new Uri("pack://application:,,,/Fonts/" + font), font));
            }

            if (ViewModelBase.IsInDesignModeStatic)
            {
                _dataService.GetData(string.Empty,
              (item, error) =>
              {
                  this.StyleModel = item;
              });
            }
            else
            {
                // extracting mobile & tablet apps
                var defaultPhoneApp = Path.Combine(Directory.GetCurrentDirectory(), MainViewModel.DefaultPhoneApp);
                Microsoft.PowerApps.Tools.Zipper.Utility.ExtactApp(defaultPhoneApp, Path.Combine(Path.GetTempPath(), Path.GetFileName(defaultPhoneApp)));

                var defaultTabletApp = Path.Combine(Directory.GetCurrentDirectory(), MainViewModel.DefaultTabletApp);
                Microsoft.PowerApps.Tools.Zipper.Utility.ExtactApp(defaultTabletApp, Path.Combine(Path.GetTempPath(), Path.GetFileName(defaultTabletApp)));

                this.NewApp();
            }
            history_theme = new History<ThemeModel>(this.StyleModel);
            log_change();
        }

        #endregion Constructor

        #region Methods

        public void NewApp()
        {
            string themeFileName = Path.Combine(Directory.GetCurrentDirectory(), MainViewModel.DefaultThemeFile);
            Console.WriteLine(themeFileName);
            this.LoadTheme(themeFileName);
            this.AppPath = themeFileName;
            this.RaisePropertyChanged("isDefaultApp");
            this.RaisePropertyChanged("AppName");
            this.history_theme = new History<ThemeModel>(this.StyleModel);
            log_change();
        }

        public void LoadEmptyTheme()
        {
            LoadTheme(Path.Combine(Directory.GetCurrentDirectory(), MainViewModel.DefaultThemeFile));
        }

        public void OpenThemeFromApp(string appPath)
        {
            this.AppPath = appPath;
            var destinationFolder = System.IO.Path.Combine(Path.GetTempPath(), System.IO.Path.GetFileName(this.AppPath).Replace(".msapp", ""));
            Microsoft.PowerApps.Tools.Zipper.Utility.ExtactApp(this.AppPath, destinationFolder);

            // Detecting tablet vs phone layout
            string propertiesFileName = System.IO.Path.Combine(destinationFolder, Microsoft.PowerApps.Tools.Zipper.Utility.PropertiesFile);
            PropertyModel propertyModel = JsonConvert.DeserializeObject<PropertyModel>(File.ReadAllText(propertiesFileName));
            if (propertyModel.DocumentAppType.Equals("DesktopOrTablet"))
            {
                this.IsTabletMode = true;
            }

            string themeFileName = System.IO.Path.Combine(destinationFolder, "References", Microsoft.PowerApps.Tools.Zipper.Utility.ThemeFile);
            this.LoadTheme(themeFileName);
            this.RaisePropertyChanged("isDefaultApp");
            this.RaisePropertyChanged("AppName");
            this.history_theme = new History<ThemeModel>(this.StyleModel);
            log_change();
        }

        public void LoadTheme(string themeFileName)
        {
            _dataService.GetData(themeFileName,
                (item, error) =>
                {
                    if (error != null)
                    {
                        //TODO: Report error here
                        return;
                    }

                    this.StyleModel = item;
                });
            this.history_theme = new History<ThemeModel>(this.StyleModel);
            AddMissingProperties();
            log_change();
        }

        public void AddMissingProperties()
        {
            if (this._defaultTheme == null)
            {
                string themeFileName = Path.Combine(Directory.GetCurrentDirectory(), MainViewModel.ThemeFileSchema);
                _dataService.GetData(themeFileName,
                    (item, error) =>
                    {
                        if (error != null)
                        {
                        //TODO: Report error here
                        return;
                        }

                        this._defaultTheme = item;
                    });
            }
            foreach (Style style in this._defaultTheme.styles)
            {
                Style themeStyle = this.StyleModel.styles.FirstOrDefault(s => s.name == style.name);
                if (themeStyle != null)
                {
                    foreach (Propertyvaluesmap property in style.propertyValuesMap)
                    {
                        if (!themeStyle.propertyValuesMap.Any(s => s.property == property.property))
                            themeStyle.propertyValuesMap.Add(new Propertyvaluesmap { property = property.property, value = "Default" });
                    }
                }
            }
        }

        public void ExportApp(string saveTopath)
        {
            if (this.isDefaultApp || _setting_apply_theme_styles) this.ApplyThemeToEntities(true);

            var destinationFolder = Path.Combine(Path.GetTempPath(), System.IO.Path.GetFileName(this.isDefaultApp ? (this.IsTabletMode ? MainViewModel.DefaultTabletApp : MainViewModel.DefaultPhoneApp) : this._appPath.Replace(".msapp", "")));
            string themeFileName = Path.Combine(destinationFolder, Microsoft.PowerApps.Tools.Zipper.Utility.ThemeFile);
            //creates a list of themes and adds current theme
            List<ThemeModel> ThemesInFile = new List<ThemeModel>();
            ThemesInFile.Add(ThemeModel_Without_Default());

            File.WriteAllText(themeFileName, JsonConvert.SerializeObject(new AppThemeModel() { CurrentTheme = this.StyleModel.name, CustomThemes = ThemesInFile }, Newtonsoft.Json.Formatting.None, new JsonSerializerSettings
            {
                NullValueHandling = NullValueHandling.Ignore
            }));

            Microsoft.PowerApps.Tools.Zipper.Utility.ZipApp(destinationFolder, saveTopath);
        }

        public void ExportTheme(string saveTopath)
        {
            File.WriteAllText(saveTopath, JsonConvert.SerializeObject(ThemeModel_Without_Default(), Newtonsoft.Json.Formatting.None, new JsonSerializerSettings
            {
                NullValueHandling = NullValueHandling.Ignore
            }));
        }

        public ThemeModel ThemeModel_Without_Default()
        {
            ThemeModel a = new ThemeModel();
            a.name = this.StyleModel.name;
            a.palette = this.StyleModel.palette;
            a.styles = new List<Style>();
            foreach (Style style in this.StyleModel.styles)
            {
                a.styles.Add(new Style() { name = style.name, controlTemplateName = style.controlTemplateName, propertyValuesMap = style.propertyValuesMap.FindAll(s => (s.value != "Default") && (s.value != "%Palette.Default%")) });
            }
            return a;
        }

        public void ApplyThemeToEntities(bool size)
        {
            var destinationFolder = Path.Combine(Path.GetTempPath(), System.IO.Path.GetFileName(this.isDefaultApp ? (this.IsTabletMode ? MainViewModel.DefaultTabletApp : MainViewModel.DefaultPhoneApp) : this._appPath.Replace(".msapp", "")));
            var controls = Directory.GetFiles(Path.Combine(destinationFolder, "Controls"));

            foreach (var control in controls)
            {
                var controlData = JsonConvert.DeserializeObject<EntityData>(File.ReadAllText(control));
                var entity = controlData.TopParent;

                if (entity != null)
                    ApplyStyleToEntityTree(entity, size);

                controlData.TopParent = entity;
                
                File.WriteAllText(control, JsonConvert.SerializeObject(controlData, Newtonsoft.Json.Formatting.None, new JsonSerializerSettings
                {
                    NullValueHandling = NullValueHandling.Ignore,
                }));
            }
            
            this.rest_history();
        }

        public void ApplyThemeToEntities()
        {
            ApplyThemeToEntities(_setting_apply_dimension);
        }

        public void ApplyStyleToEntityTree(Entity parent, bool size)
        {
            if (parent.StyleName != null)
            {
                string styleName = parent.StyleName;
                Style style = Styles.FirstOrDefault(e => e.name.ToLower() == styleName.ToLower());
                applyStyleRules(style, parent, size);
            }
            else
            {
                string template = parent.Template.Name;
                string styleName = "default" + template + "Style";
                Style style = Styles.FirstOrDefault(e => e.name.ToLower() == styleName.ToLower());
                applyStyleRules(style, parent, size);
            }
            foreach (Entity child in parent.Children.FindAll(e => e.Type == "ControlInfo"))
            {
                ApplyStyleToEntityTree(child, size);
            }
        }

        private void applyStyleRules(Style style, Entity entity, bool size)
        {
            if (style != null)
                foreach (var rule in entity.Rules)
                {
                    var property = style.propertyValuesMap.SingleOrDefault(e => (e.property == rule.Property));
                    if ((!size) && (property != null))
                    {
                        if ((property.property == "Height") || (property.property == "Width"))
                        {
                            property = null;
                        }
                    }
                    if ((property != null) && (property.value != "Default") && (property.value != "%Palette.Default%"))
                    {
                        var palette = Palettes.SingleOrDefault(e => e.name == property.value.Replace("%", "").Replace("Palette.", ""));
                        if (palette != null)
                            rule.InvariantScript = palette.value.Replace(".RESERVED", "").Replace("%", "");
                        if (rule.InvariantScript.Contains(".RESERVED"))
                            rule.InvariantScript = property.value.Replace(".RESERVED", "").Replace("%", "");
                    }
                }
        }

        //Temp fix
        public void RefreshPalettes()
        {
            Style a = SelectedStyle;
            this.SelectedStyle = null;
            this.SelectedStyle = a;
            RaisePropertyChanged("Palettes");
        }

        /// <summary>
        /// Adds new Palette
        /// </summary>
        public bool addNewPalette()
        {
            Palette newPalette = new Palette
            {
                name = _toBeAdded.name.Replace(" ", ""),
                type = _toBeAdded.type,
                value = _toBeAdded.value
            };
            if (newPalette.name == "Default")
            {
                System.Windows.MessageBox.Show("Couldn't add palette, please use a name that is not reserved", "Error occured", System.Windows.MessageBoxButton.OK, System.Windows.MessageBoxImage.Error);
                return false;
            }

            if (!_styleModel.palette.Exists(s => s.name == newPalette.name))
            {
                this._styleModel.palette.Add(newPalette);
                RaisePropertyChanged("Palettes");
                RaisePropertyChanged("ColorPalettes");
                RaisePropertyChanged("NumberPalettes");
                RaisePropertyChanged("FontPalettes");
                RaisePropertyChanged("FontWeightPalettes");
                RaisePropertyChanged("BorderStylePalettes");
                RaisePropertyChanged("BooleanStylePalettes");
                RaisePropertyChanged("AlignStylePalettes");
                RaisePropertyChanged("VerticalAlignStylePalettes");
                this.log_change();
                return true;
            }
            else
            {
                System.Windows.MessageBox.Show("Couldn't add palette, please use a unique name", "Error occured", System.Windows.MessageBoxButton.OK, System.Windows.MessageBoxImage.Error);
                return false;
            }
        }

        public void undo()
        {
            this.StyleModel = history_theme.copy(history_theme.undo());
            RaisePropertyChanged("UndoAvailable");
            RaisePropertyChanged("RedoAvailable");
            RaisePropertyChanged("Palettes");
            RaisePropertyChanged("ColorPalettes");
            RaisePropertyChanged("NumberPalettes");
            RaisePropertyChanged("FontPalettes");
            RaisePropertyChanged("FontWeightPalettes");
            RaisePropertyChanged("BorderStylePalettes");
            RaisePropertyChanged("BooleanStylePalettes");
            RaisePropertyChanged("AlignStylePalettes");
            RaisePropertyChanged("VerticalAlignStylePalettes");
        }

        public void redo()
        {
            this.StyleModel = history_theme.copy(history_theme.redo());
            RaisePropertyChanged("UndoAvailable");
            RaisePropertyChanged("RedoAvailable");
            RaisePropertyChanged("Palettes");
            RaisePropertyChanged("ColorPalettes");
            RaisePropertyChanged("NumberPalettes");
            RaisePropertyChanged("FontPalettes");
            RaisePropertyChanged("FontWeightPalettes");
            RaisePropertyChanged("BorderStylePalettes");
            RaisePropertyChanged("BooleanStylePalettes");
            RaisePropertyChanged("AlignStylePalettes");
            RaisePropertyChanged("VerticalAlignStylePalettes");
        }

        public void log_change()
        {
            history_theme.execute(this._styleModel);
            RaisePropertyChanged("UndoAvailable");
            RaisePropertyChanged("RedoAvailable");
            RaisePropertyChanged("Palettes");
            RaisePropertyChanged("ColorPalettes");
            RaisePropertyChanged("NumberPalettes");
            RaisePropertyChanged("FontPalettes");
            RaisePropertyChanged("FontWeightPalettes");
            RaisePropertyChanged("BorderStylePalettes");
            RaisePropertyChanged("BooleanStylePalettes");
            RaisePropertyChanged("AlignStylePalettes");
            RaisePropertyChanged("VerticalAlignStylePalettes");
        }

        public void rest_history()
        {
            history_theme.rest();
            RaisePropertyChanged("UndoAvailable");
            RaisePropertyChanged("RedoAvailable");
            RaisePropertyChanged("Palettes");
            RaisePropertyChanged("ColorPalettes");
            RaisePropertyChanged("NumberPalettes");
            RaisePropertyChanged("FontPalettes");
            RaisePropertyChanged("FontWeightPalettes");
            RaisePropertyChanged("BorderStylePalettes");
            RaisePropertyChanged("BooleanStylePalettes");
            RaisePropertyChanged("AlignStylePalettes");
            RaisePropertyChanged("VerticalAlignStylePalettes");
        }

        public void DeletePalette(string paletteToDelete)
        {
            var list = this._styleModel.styles.FindAll(s => s.propertyValuesMap.Any(e => e.value.Replace("Palette.", "").Replace("%", "") == paletteToDelete));
            if (list.Count == 0)
            {
                this._styleModel.palette.RemoveAll(s => s.name == paletteToDelete);
                this.log_change();
            }
            else
            {
                string list_of = "\n";

                foreach (var a in list)
                {
                    list_of += " " + a.name + " \n";
                }
                System.Windows.MessageBox.Show("Palette used in the following styles: " + list_of, "Can not delete palette", System.Windows.MessageBoxButton.OK, System.Windows.MessageBoxImage.Error);
            }
            RaisePropertyChanged("Palettes");
        }

        public bool ToggleShowAllStyles()
        {
            this._showAllStyles = !this._showAllStyles;
            RaisePropertyChanged("Styles");
            this._selectedStyle = null;
            RaisePropertyChanged("SelectedStyle");
            RaisePropertyChanged("SelectedStylePallete");
            return this._showAllStyles;
        }

        #endregion Methods
    }
}