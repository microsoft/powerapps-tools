using System.Collections.Generic;

namespace Microsoft.PowerApps.Tools.AppChangeManager
{
    public class ScannedResult
    {
        public string EntityName { get; set; }
        public List<ScreenName> ScreenList { get; set; }
    }

    public class ScreenName
    {
        public string Scr_Name { get; set; }
        public string ControlName { get; set; }
        public List<Script> Script { get; set; }
    }

    public class ModifiedResult
    {
        public string ScreenName { get; set; }
        public List<ChangedControl> ControlList { get; set; }
    }

    public class ChangedControl
    {
        public string ControlName { get; set; }
        public string Parent { get; set; }
        public List<ExtendedScript> Script { get; set; }
    }

    public class Script
    {
        public string Property { get; set; }
        public string InvariantScript { get; set; }
    }

    public class ExtendedScript : Script
    {
        public string DefaultSetting { get; set; }
    }
}