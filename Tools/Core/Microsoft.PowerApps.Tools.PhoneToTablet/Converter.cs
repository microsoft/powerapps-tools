using Microsoft.PowerApps.Tools.Zipper;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System;
using System.Collections.Generic;
using System.IO;

namespace Microsoft.PowerApps.Tools.PhoneToTablet
{
    public class Converter : IConverter
    {
        //Convert phone to tablet app
        public void Convert(string sourcePath, string newAppPath)
        {
            var fileName = GetFileName(sourcePath);
            var extension = Path.GetExtension(sourcePath);
            var rules = new ConversionRule().GetRules();
            var tempPath = Path.GetTempPath();

            Utility.ExtactApp(sourcePath, Path.Combine(tempPath, fileName));
            string popertiesFile = Path.Combine(tempPath, fileName, "Properties.json");
            Microsoft.PowerApps.Tools.AppEntities.PropertyModel prop = JsonConvert.DeserializeObject<Microsoft.PowerApps.Tools.AppEntities.PropertyModel>(File.ReadAllText(popertiesFile));

            prop.DocumentLayoutWidth = 1366.0f;
            prop.DocumentLayoutHeight = 768.0f;
            prop.DocumentLayoutOrientation = "landscape";
            prop.DocumentAppType = "DesktopOrTablet";

            File.WriteAllText(Path.Combine(tempPath, fileName, "Properties.json"), JsonConvert.SerializeObject(prop));
            Utility.ZipApp(Path.Combine(tempPath, fileName), newAppPath);
        }

        private static string GetFileName(string sourcePath)
        {
            var fileName = Path.GetFileName(sourcePath);
            var extension = Path.GetExtension(sourcePath);

            return fileName?.Replace(extension, "");
        }

        public static void ReplaceNodeValue(List<NodeDetails> nodeDetails, string filePath)
        {
            var jObject = JObject.Parse(File.ReadAllText(filePath));

            int intValue;
            foreach (var detail in nodeDetails)
            {
                var node = detail.NodePath.First;
                if (jObject[node.Value] != null)
                {
                    Int32.TryParse(detail.Value, out intValue);
                    jObject[node.Value] = intValue == 0 && detail.Value != intValue.ToString() ? detail.Value : intValue;
                }
            }

            File.WriteAllText(filePath, jObject.ToString());
        }
    }
}