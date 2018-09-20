using System;

namespace PowerApps_Theme_Editor.Model
{
    public interface IDataService
    {
        void GetData(string path, Action<ThemeModel, Exception> callback);
    }
}