using Microsoft.PowerApps.Tools.Zipper;
using Newtonsoft.Json.Linq;
using PowerApps.Tools.Utilities.Constants;
using PowerApps.Tools.Utilities.Models;
using System;
using System.Collections.Generic;
using System.IO;
using System.IO.Compression;
using System.Linq;

namespace PowerApps.Tools.Utilities
{
    internal class Helper
    {
        #region Public Methods

        public AppData ExtractApp(string path)
        {
            var fileName = GetFileName(path);
            var tempPath = $"{Path.GetTempPath()}{ fileName}_{Guid.NewGuid()}";

            //Exteract
            Utility.ExtactApp(path, tempPath);

            //Load exteracted data
            var entity = GetEntity(Path.Combine(tempPath, AppFileName.Entities));
            var properties = GetProperty(Path.Combine(tempPath, AppFileName.Properties));
            var header = GetJObject(Path.Combine(tempPath, AppFileName.Header));
            var macroTable = GetJObject(Path.Combine(tempPath, AppFileName.MacroTable));
            var publishInfo = GetJObject(Path.Combine(tempPath, AppFileName.PublishInfo));
            var themes = GetJObject(Path.Combine(tempPath, AppFileName.Themes));
            var templates = GetTemplates(Path.Combine(tempPath, AppFileName.Entities));

            return new AppData
            {
                Templates = templates,
                Entities = entity,
                Properties = properties,
                Header = header,
                MacroTable = macroTable,
                PublishInfo = publishInfo,
                Themes = themes,
                FilePath = path,
                ExteractedAppPath = tempPath
            };
        }

        public void CopyAppFiles(string sourcePath, string destinationPath)
        {
            if (string.IsNullOrWhiteSpace(sourcePath) ||
                string.IsNullOrWhiteSpace(destinationPath))
                throw new ArgumentNullException("App path is null or empty.");

            var files = Directory.GetFiles(sourcePath)?.ToList();

            CreateDirectoryIfNotExist(destinationPath);

            files?.ForEach(r => File.Copy(r, Path.Combine(destinationPath, Path.GetFileName(r)), true));
        }

        public void CopyAppResources(string msAppPath, string sourcePath, string destinationPath)
        {
            if (string.IsNullOrWhiteSpace(sourcePath) ||
                string.IsNullOrWhiteSpace(destinationPath))
                throw new ArgumentNullException("App path is null or empty.");

            CreateDirectoryIfNotExist(destinationPath);

            var assetPath = Path.Combine(sourcePath, AppFileName.AssetsDirectoryName);

            if (Directory.Exists(assetPath))
            {
                var assetFilesPath = new List<string>();

                var directoryList = Directory.GetDirectories(assetPath)?.ToList() ?? new List<string>();
                directoryList.Add(assetPath);

                directoryList?.ForEach(r =>
                {
                    //  CreateDirectoryIfNotExist(r.Replace(sourcePath, destinationPath));
                    var filePath = Directory.GetFiles(r)?.ToList();
                    if (filePath != null && filePath.Count > 0)
                        assetFilesPath.AddRange(filePath);
                });

                foreach (string file in assetFilesPath)
                {
                    using (FileStream zipToOpen = new FileStream(msAppPath, FileMode.Open))
                    {
                        using (ZipArchive archive = new ZipArchive(zipToOpen, ZipArchiveMode.Update))
                        {
                            string entryName = file.Substring(file.IndexOf(AppFileName.AssetsDirectoryName));
                            ZipFileExtensions.CreateEntryFromFile(archive, file, entryName);
                        }
                    }
                }
            }
        }

        public void SaveAppFile(JObject jObject, string jsonFileName, string path)
        {
            if (!Directory.Exists(path))
                Directory.CreateDirectory(path);

            File.WriteAllText(Path.Combine(path, jsonFileName), jObject.ToString());
        }

        public void SetControlUniqueId(JArray entities)
        {
            var screens = entities?
                .Where(r => r["Template"] != null
                && (((string)r["Template"]["Name"])?.Equals("screen", StringComparison.InvariantCultureIgnoreCase) ?? false))?.ToList();

            int controlId = 1;
            SetUniqueId(screens, controlId);
        }

        public JToken ReplaceControlReference(JToken jToken, string oldName, string newName)
        {
            JToken result = jToken;
            var jTokenString = jToken.ToString();

            if (!string.IsNullOrWhiteSpace(jTokenString))
                result = JToken.Parse(jTokenString.Replace($"{oldName.Trim()}.", $"{newName.Trim()}."));

            return result;
        }

        public void RenameControl(JToken jToken, string newName)
        {
            jToken["Name"] = newName;

            var children = jToken["Children"]?.Select(r => r)?.ToList();
            if (children?.Count > 0)
            {
                var childrenJArray = new JArray();
                children?.ForEach(r =>
                {
                    r["Parent"] = newName;
                    childrenJArray.Add(r);
                });

                jToken["Children"] = childrenJArray;
            }
        }

        public string GetNewName(string name)
        {
            return $"{name}_{Guid.NewGuid().ToString().Replace('-', '_')}";
        }

        public void ReassignScreenIndex(JArray entities)
        {
            var screens = entities?
                .Where(r => r["Template"] != null
                && (((string)r["Template"]["Name"])?.Equals("screen", StringComparison.InvariantCultureIgnoreCase) ?? false))?.ToList();

            int screenIndex = screens?.Count ?? 0;

            foreach (var screen in screens)
            {
                if (screen["Index"] != null)
                {
                    screen["Index"] = screenIndex;
                    screenIndex += 1;
                }
            }
        }

        public static string GetFileName(string sourcePath)
        {
            var fileName = Path.GetFileName(sourcePath);
            var extension = Path.GetExtension(sourcePath);

            return fileName?.Replace(extension ?? "", "");
        }

        #endregion Public Methods

        #region Private Methods

        private JObject GetJObject(string path)
        {
            var data = File.ReadAllText(path);

            var temp = JObject.Parse(data);

            return string.IsNullOrWhiteSpace(data) ? null : JObject.Parse(data);
        }

        private Property GetProperty(string path)
        {
            var propertyObject = GetJObject(path);

            return new Property
            {
                DocumentAppType = (string)propertyObject["DocumentAppType"],
                Name = (string)propertyObject["Name"],
                DocumentLayoutHeight = (float)propertyObject["DocumentLayoutHeight"],
                DocumentLayoutWidth = (float)propertyObject["DocumentLayoutWidth"],
                PropertyObject = propertyObject
            };
        }

        private List<Entity> GetEntity(string path)
        {
            var entityObject = GetJObject(path);

            return entityObject["Entities"]?
                           .Select(s => new Entity
                           {
                               Name = (string)s["Name"],
                               EntityObject = s,
                               Type = (string)s["Type"],
                               TemplateName = s["Template"] == null ? "" : (string)s["Template"]["Name"],
                               Children = GetChildren(s)
                           }).ToList();
        }

        private List<Template> GetTemplates(string path)
        {
            var entityObject = GetJObject(path);

            return entityObject["UsedTemplates"]?
                           .Select(s => new Template
                           {
                               Name = (string)s["Name"],
                               TemplateObject = s,
                               Version = (string)s["Version"]
                           }).ToList();
        }

        private List<Entity> GetChildren(JToken jToken)
        {
            return jToken["Children"]?
                           .Select(s => new Entity
                           {
                               Name = (string)s["Name"],
                               EntityObject = s,
                               Type = (string)s["Type"],
                               TemplateName = s["Template"] == null ? "" : (string)s["Template"]["Name"],
                               Children = s["Children"] == null ? null : GetChildren(s)
                           }).ToList();
        }

        private int SetUniqueId(List<JToken> screens, int controlId)
        {
            foreach (var screen in screens)
            {
                controlId += 1;
                screen["ControlUniqueId"] = $"{controlId}";
                if (screen["Children"] != null)
                    controlId = SetUniqueId(screen["Children"].ToList(), controlId);
            }

            return controlId;
        }

        private void CreateDirectoryIfNotExist(string path)
        {
            if (!Directory.Exists(path))
                Directory.CreateDirectory(path);
        }

        #endregion Private Methods
    }
}