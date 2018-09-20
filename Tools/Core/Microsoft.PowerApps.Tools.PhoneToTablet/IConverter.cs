namespace Microsoft.PowerApps.Tools.PhoneToTablet
{
    public interface IConverter
    {
        void Convert(string sourcePath, string newAppPath);
    }
}