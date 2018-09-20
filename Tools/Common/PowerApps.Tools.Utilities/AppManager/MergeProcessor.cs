using Microsoft.PowerApps.Tools.Zipper;
using Newtonsoft.Json.Linq;
using PowerApps.Tools.Utilities.Constants;
using PowerApps.Tools.Utilities.Models;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;

namespace PowerApps.Tools.Utilities.AppManager
{
    public class MergeProcessor
    {
        private Helper _helper = new Helper();

        #region Public Methods

        public AppData Extract(string path)
        {
            return _helper.ExtractApp(path);
        }

        public string MergeApps(List<MergeDetail> mergeDetail, string destinationPath)
        {
            if (mergeDetail == null || mergeDetail.Count < 1)
                throw new Exception("it's missing the merge detail.");

            List<string> mergedAppFileName = new List<string>();
            mergeDetail.ForEach(r => mergedAppFileName.Add(Helper.GetFileName(r.AppData?.FilePath)));
            var mergedAppDataPath = Path.Combine(Path.GetTempPath(), $"{string.Join("_", mergedAppFileName)}_{Guid.NewGuid()}");

            var mergedAppName = $"{string.Join("_", mergedAppFileName)}_Merged.msapp";

            //Move app data to merged app path
            _helper.CopyAppFiles(mergeDetail.First()?.AppData.ExteractedAppPath, mergedAppDataPath);

            //Update the app name
            UpdateAppName(mergeDetail.First()?.AppData, mergedAppDataPath, mergedAppName);

            //Merge the app data
            var entityJObject = MergeSelectedScreens(mergeDetail);

            //Save merged entity data
            _helper.SaveAppFile(entityJObject, AppFileName.Entities, mergedAppDataPath);

            //Compress the merged app
            var mergedAppPath = Path.Combine(destinationPath, $"{string.Join("_", mergedAppFileName)}_{Guid.NewGuid()}");
            Utility.ZipApp(mergedAppDataPath, destinationPath);

            // Move resource file to merged app path zip
            foreach (var detail in mergeDetail)
            {
                _helper.CopyAppResources(destinationPath, detail.AppData?.ExteractedAppPath, mergedAppDataPath);
            }

            return destinationPath;
        }

        #endregion Public Methods

        #region Private Methods

        private JObject MergeSelectedScreens(List<MergeDetail> mergeDetail)
        {
            List<Entity> dataEntities = new List<Entity>();
            List<Entity> screenEntities = new List<Entity>();
            List<Template> templates = new List<Template>();

            foreach (var appDetail in mergeDetail)
            {
                var screens = GetEntityScreen(appDetail);
                var data = GetEntityData(dataEntities, appDetail?.AppData);

                ValidateScreenName(screenEntities, screens);
                ValidateControlName(screenEntities, data, screens);

                if (screens?.Count > 0)
                    screenEntities.AddRange(screens);

                if (data?.Count > 0)
                    dataEntities.AddRange(data);

                AddTemplates(templates, appDetail.AppData?.Templates);
            }

            if (screenEntities?.Count > 0)
                dataEntities.AddRange(screenEntities);

            var entityJArray = new JArray();
            dataEntities?.ForEach(r => entityJArray.Add(r.EntityObject));

            //Set unique id for control
            _helper.SetControlUniqueId(entityJArray);

            //Reassign the screen index
            _helper.ReassignScreenIndex(entityJArray);

            var templateJArray = new JArray();
            templates?.ForEach(r => templateJArray.Add(r.TemplateObject));

            JObject jObject = new JObject();
            jObject["Entities"] = entityJArray;
            jObject["UsedTemplates"] = templateJArray;

            return jObject;
        }

        private void ValidateScreenName(List<Entity> screenEntities, List<Entity> screens)
        {
            if (screenEntities == null || screenEntities.Count < 1)
                return;

            List<string> screenNames = screenEntities.Select(r => r.Name)?.ToList();
            foreach (var screen in screens)
            {
                if (screenNames?.Contains(screen.Name) ?? false)
                {
                    var newName = _helper.GetNewName(screen.Name);
                    _helper.RenameControl(screen.EntityObject, newName);
                }
            }
        }

        private void ValidateControlName(List<Entity> screenEntities, List<Entity> data, List<Entity> screens)
        {
            if (screenEntities == null || screenEntities.Count < 1)
                return;

            List<string> controlNames = new List<string>();
            GetControlName(controlNames, screenEntities.Where(r => r.Children?.Count > 0).SelectMany(r => r.Children)?.ToList());

            List<Tuple<string, string>> changedControlNames = new List<Tuple<string, string>>();
            foreach (var screen in screens)
            {
                RenameControlIfNotUnique(controlNames, changedControlNames, screen.EntityObject);
            }

            foreach (var changedControlName in changedControlNames)
            {
                ReplaceControlReference(data, changedControlName);
                ReplaceControlReference(screens, changedControlName);
            }
        }

        private void ReplaceControlReference(List<Entity> entities, Tuple<string, string> changedControlName)
        {
            foreach (var entity in entities)
            {
                entity.EntityObject =
                     _helper.ReplaceControlReference(entity.EntityObject, changedControlName.Item1, changedControlName.Item2);
            }
        }

        private void RenameControlIfNotUnique(List<string> controlNames, List<Tuple<string, string>> changedControlName, JToken jToken)
        {
            if (jToken == null)
                return;

            var children = jToken["Children"]?.Select(r => r)?.ToList();

            foreach (var child in children)
            {
                var name = (string)child["Name"];
                if (controlNames.Contains(name))
                {
                    var newName = _helper.GetNewName(name);
                    _helper.RenameControl(child, newName);
                    changedControlName.Add(new Tuple<string, string>(name, newName));
                }

                if (child["Children"]?.Select(r => r)?.ToList().Count > 0)
                    RenameControlIfNotUnique(controlNames, changedControlName, child);
            }

            var childrenJArray = new JArray();
            children?.ForEach(r => { childrenJArray.Add(r); });

            jToken["Children"] = childrenJArray;
        }

        private void GetControlName(List<string> controlNames, List<Entity> controlEntities)
        {
            if (controlEntities == null || controlEntities.Count < 1)
                return;

            List<string> names = controlEntities.Select(r => r.Name)?.ToList();

            if (names?.Count > 0)
                controlNames.AddRange(names);

            GetControlName(controlNames, controlEntities.Where(r => r.Children?.Count > 0).SelectMany(r => r.Children)?.ToList());
        }

        private void AddTemplates(List<Template> parentTemplates, List<Template> templates)
        {
            if (templates == null)
                return;

            foreach (var template in templates)
            {
                var tempTemplate = parentTemplates
                    .Where(r => (r.Name.Equals(template.Name, StringComparison.InvariantCultureIgnoreCase)
                     && r.Version.Equals(template.Version, StringComparison.InvariantCultureIgnoreCase)));

                if (tempTemplate != null && tempTemplate.Count() > 0)
                    continue;

                parentTemplates.Add(template);
            }
        }

        private List<Entity> GetEntityScreen(MergeDetail mergeDetail)
        {
            var screens = mergeDetail?.AppData?.Entities?
                   .Where(r => (r.TemplateName?.Equals("screen", StringComparison.InvariantCultureIgnoreCase) ?? false)
                   && (mergeDetail.SelectedScreens?.Contains(r.Name) ?? false))?.ToList();

            return screens;
        }

        private List<Entity> GetEntityData(List<Entity> parentEntities, AppData appData)
        {
            var entities = appData?.Entities?
                    .Where(r => string.IsNullOrWhiteSpace(r.TemplateName)
                    || (!r.TemplateName?.Equals("screen", StringComparison.InvariantCultureIgnoreCase) ?? false))?.ToList();
            var entityData = new List<Entity>();

            foreach (var entity in entities)
            {
                var tempEntity = parentEntities
                    .Where(r => (r.Name.Equals(entity.Name, StringComparison.InvariantCultureIgnoreCase)
                     && r.Type.Equals(entity.Type, StringComparison.InvariantCultureIgnoreCase))
                     || ((entity.TemplateName?.Equals("appinfo", StringComparison.InvariantCultureIgnoreCase) ?? false)
                     && (r.TemplateName?.Equals("appinfo", StringComparison.InvariantCultureIgnoreCase) ?? false)));

                if (tempEntity != null && tempEntity.Count() > 0)
                    continue;

                entityData.Add(entity);
            }

            return entityData;
        }

        private void UpdateAppName(AppData appData, string mergedAppDataPath, string mergedAppName)
        {
            var propertyJObject = appData?.Properties?.PropertyObject;
            propertyJObject["Name"] = mergedAppName;

            _helper.SaveAppFile(propertyJObject, AppFileName.Properties, mergedAppDataPath);
        }

        #endregion Private Methods
    }
}