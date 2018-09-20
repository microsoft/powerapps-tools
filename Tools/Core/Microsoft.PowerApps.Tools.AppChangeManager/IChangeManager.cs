using System.Collections.Generic;

namespace Microsoft.PowerApps.Tools.AppChangeManager
{
    public interface IChangeManager
    {
        List<ModifiedResult> GetModifiedControleList(string filePath);
    }
}