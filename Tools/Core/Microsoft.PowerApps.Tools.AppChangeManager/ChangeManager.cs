using Microsoft.PowerApps.Tools.AppEntities;
using Microsoft.PowerApps.Tools.Zipper;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;

namespace Microsoft.PowerApps.Tools.AppChangeManager
{
    public class ChangeManager : IChangeManager
    {
        private const string AppInfoDefaultSetting = "DefaultSetting\\AppInfoDefaultSetting.json";
        private const string ControlDefaultSetting = "DefaultSetting\\ControlDefaultSetting.json";
        private const string DefaultAppSetting = "DefaultSetting\\DefaultApp.msapp";
        private const string ScreenDefaultSetting = "DefaultSetting\\ScreenDefaultSetting.json";
        private List<string> ExecludedScreenProperty = new List<string> { "Height", "Width" };
        private List<string> ExecludedControlProperty = new List<string> { "X", "Y", "ZIndex" };
        private static IEnumerable<Entity> defaultEntities;

        static ChangeManager()
        {
            defaultEntities = GetDefaultSetting(DefaultAppSetting);
        }


        public string GetAppTitle(string filePath)
        {

            var fileName = GetFileName(filePath);
            var extension = Path.GetExtension(filePath);
            var guid = new Guid();
            var tempPath = $"{Path.GetTempPath()}{ fileName}_{guid}";

            Utility.ExtactApp(filePath, tempPath);

            var properties = JsonConvert.DeserializeObject<PropertyData>(
                File.ReadAllText(Path.Combine(tempPath, Constants.AppFileName.Properties)));

            return properties.Name;
        }

        public List<ModifiedResult> GetModifiedControleList(string filePath)
        {
            var entityList = GetScreenList(filePath, new string[]
            {
                Constants.ControlType.AppInfo,
                Constants.ControlType.Screen
            });

            List<ModifiedResult> result = GetModifiedScreens(entityList);

            return result;
        }

        private List<ChangedControl> GetModifiedControle(Entity entityList)
        {
            var result = new List<ChangedControl>();

            foreach (var child in entityList.Children)
            {
                List<ExtendedScript> modifiedControl = VerifyControlProperty(child);
                if (modifiedControl?.Count > 0)
                {
                    result.Add(new ChangedControl
                    {
                        ControlName = child.Name,
                        Template = child.Template,
                        Parent = child.Parent,
                        Script = modifiedControl
                    });
                }

                foreach (var gChild in child.Children)
                {
                    modifiedControl = VerifyControlProperty(gChild);
                    if (modifiedControl?.Count > 0)
                    {
                        result.Add(new ChangedControl
                        {
                            ControlName = gChild.Name,
                            Template = gChild.Template,
                            Parent = gChild.Parent,
                            Script = modifiedControl
                        });
                    }
                }
            }

            return result;
        }

        private List<ExtendedScript> VerifyControlProperty(Entity child)
        {
            //var controlEntities = defaultEntities.Where(e => e.Type == "ControlInfo" && e.Template != null && e.Template.Name != "screen" && e.Template.Name != "appinfo").ToList();

            var controlEntities = defaultEntities.FirstOrDefault(e => e.Template != null && e.Template.Name == "screen").Children;

            var defaultSetting = controlEntities.Find(r => r.Template?.Name == child.Template?.Name);
            var result = new List<ExtendedScript>();

            if (defaultSetting == null)
                return result;

            var serializedDefaultSetting = JsonConvert.SerializeObject(defaultSetting);
            serializedDefaultSetting = serializedDefaultSetting.Replace("{ControlName}.", $"{child.Name}.");
            defaultSetting = JsonConvert.DeserializeObject<Entity>(serializedDefaultSetting);

            var designProperty = child.Rules?
                .Where(r => r.Category == Constants.PropertyCategory.Design
                && !ExecludedControlProperty.Contains(r.Property))
                .Select(r => r);

            var behaviorProperty = child.Rules?
                .Where(r => r.Category == Constants.PropertyCategory.Behavior)
                .Select(r => r);

            var dataProperty = child.Rules?
                .Where(r => r.Category == Constants.PropertyCategory.Data)
                .Select(r => r);

            foreach (var property in designProperty)
            {
                var propValue = defaultSetting.Rules.ToList().Find(r => r.Property == property.Property);
                if (!property.InvariantScript.Trim().ToUpper()
                    .Equals(propValue?.InvariantScript.Trim().ToUpper()))
                {
                    result.Add(new ExtendedScript
                    {
                        Property = property.Property,
                        InvariantScript = property.InvariantScript,
                        DefaultSetting = propValue?.InvariantScript
                    });
                }
            }

            foreach (var property in behaviorProperty)
            {
                if (!string.IsNullOrWhiteSpace(property.InvariantScript))
                {
                    result.Add(new ExtendedScript
                    {
                        Property = property.Property,
                        InvariantScript = property.InvariantScript
                    });
                }
            }

            foreach (var property in dataProperty)
            {
                if (!string.IsNullOrWhiteSpace(property.InvariantScript))
                {
                    result.Add(new ExtendedScript
                    {
                        Property = property.Property,
                        InvariantScript = property.InvariantScript
                    });
                }
            }

            return result;
        }

        private List<ModifiedResult> GetModifiedScreens(List<Entity> entityList)
        {
            var result = new List<ModifiedResult>();

            var appInfo = entityList?
                .Where(r => r.Template?.Name == Constants.ControlType.AppInfo)
                .Select(r => r).FirstOrDefault();

            var changedControl = new ChangedControl
            {
                ControlName = appInfo?.Name,
                Script = new List<ExtendedScript>()
            };

            appInfo?.Rules?.ForEach(
                r =>
                {
                    changedControl.Script.Add(
                        new ExtendedScript
                        {
                            Property = r.Property,
                            InvariantScript = r.InvariantScript
                        });
                });

            if (changedControl.Script.Count > 0)
            {
                result.Add(new ModifiedResult
                {
                    ScreenName = appInfo.Name,
                    ControlList = new List<ChangedControl> { changedControl }
                });
            }

            var screenDefault = defaultEntities.FirstOrDefault(e => e.Template != null && e.Template.Name == "screen");
            var screens = entityList?
                .Where(r => r.Template?.Name == Constants.ControlType.Screen)
                .Select(r => r);

            foreach (var screen in screens)
            {
                var modifiedResult = new ModifiedResult
                {
                    ScreenName = screen.Name,
                    ControlList = new List<ChangedControl>()
                };

                List<ExtendedScript> modifiedScreen = VerifyScreenProperty(screen, screenDefault);

                if (modifiedScreen.Count > 0)
                {
                    modifiedResult.ControlList.Add(
                        new ChangedControl
                        {
                            ControlName = screen.Name,
                            Parent = screen.Name,
                            Script = modifiedScreen
                        });
                }

                var controlChange = GetModifiedControle(screen);

                if (controlChange?.Count > 0)
                {
                    modifiedResult.ControlList.AddRange(controlChange);
                }

                if (modifiedResult.ControlList.Count > 0)
                {
                    result.Add(modifiedResult);
                }
            }

            return result;
        }

        private List<ExtendedScript> VerifyScreenProperty(Entity screen, Entity screenDefault)
        {
            var result = new List<ExtendedScript>();

            var designProperty = screen.Rules?
                .Where(r => r.Category == Constants.PropertyCategory.Design
                && !ExecludedScreenProperty.Contains(r.Property))
                .Select(r => r);

            var behaviorProperty = screen.Rules?
                .Where(r => r.Category == Constants.PropertyCategory.Behavior)
                .Select(r => r);

            foreach (var property in designProperty)
            {
                var propValue = screenDefault.Rules.Find(r => r.Property == property.Property);
                if (propValue != null && !property.InvariantScript.Trim().ToUpper()
                    .Equals(propValue?.InvariantScript.Trim().ToUpper()))
                {
                    result.Add(new ExtendedScript
                    {
                        Property = property.Property,
                        InvariantScript = property.InvariantScript,
                        DefaultSetting = propValue.InvariantScript
                    });
                }
            }

            foreach (var property in behaviorProperty)
            {
                if (!string.IsNullOrWhiteSpace(property.InvariantScript))
                {
                    result.Add(new ExtendedScript
                    {
                        Property = property.Property,
                        InvariantScript = property.InvariantScript
                    });
                }
            }

            return result;
        }

        private static IEnumerable<Entity> GetDefaultSetting(string settingFile)
        {
            if (!File.Exists(settingFile))
                throw new FileNotFoundException();

            var fileName = GetFileName(settingFile);
            var guid = new Guid();
            var tempPath = $"{Path.GetTempPath()}{ fileName}_{guid}";

            Utility.ExtactApp(settingFile, tempPath);
            var entityData = JsonConvert.DeserializeObject<EntityData>(
                File.ReadAllText(Path.Combine(tempPath, Constants.AppFileName.Entities)));

            return entityData.Entities;
        }

        private List<Entity> GetScreenList(string filePath, string[] controlTypes)
        {
            if (controlTypes == null)
            {
                throw new Exception("Invalid Input parameter, ControlTypes can't be null");
            }

            var fileName = GetFileName(filePath);
            var extension = Path.GetExtension(filePath);
            var guid = new Guid();
            var tempPath = $"{Path.GetTempPath()}{ fileName}_{guid}";

            Utility.ExtactApp(filePath, tempPath);

            var controls = Directory.GetFiles(Path.Combine(tempPath, "Controls"));

            JsonSerializerSettings jsonSerializerSettings = new JsonSerializerSettings()
            {
                Error = (se, ev) => {
                    ev.ErrorContext.Handled = true;
                }
            };

            var entities = new List<Entity>();

            foreach (var control in controls)
            {
                var controlData = File.ReadAllText(control);
                var entityData = JsonConvert.DeserializeObject<EntityData>(controlData, jsonSerializerSettings);
                var entity = entityData.TopParent;
                entities.Add(entity);
            }

            var screenList = entities?
                .Where(e => controlTypes.Contains(e.Template?.Name))
                .Select(r => r);

            return screenList?.ToList();
        }

        public void HandleDeserializationError(ErrorEventArgs errorArgs)
        {
            //var currentError = errorArgs.ErrorContext.Error.Message;
            //errorArgs.ErrorContext.Handled = true;
        }

        private static string GetFileName(string sourcePath)
        {
            var fileName = Path.GetFileName(sourcePath);
            var extension = Path.GetExtension(sourcePath);

            return fileName?.Replace(extension ?? "", "");
        }
    }
}