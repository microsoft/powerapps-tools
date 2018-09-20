using System.IO;
using System.IO.Compression;

namespace Microsoft.PowerApps.Tools.Zipper
{
    public class Utility
    {
        public const string EntitiesFile = "Entities.json";
        public const string ThemeFile = "Themes.json";
        public const string PropertiesFile = "Properties.json";

        public static void ExtactApp(string appPath, string destinationFolder)
        {
            if (Directory.Exists(destinationFolder))
                Directory.Delete(destinationFolder, true);

            ZipFile.ExtractToDirectory(appPath, destinationFolder);
        }

        public static void ZipApp(string appFolder, string destinationPath)
        {
            if (File.Exists(destinationPath))
                File.Delete(destinationPath);

            ZipFile.CreateFromDirectory(appFolder, destinationPath);
        }
    }
}