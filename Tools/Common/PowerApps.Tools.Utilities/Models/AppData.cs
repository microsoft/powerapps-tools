using Newtonsoft.Json.Linq;
using System.Collections.Generic;
using System.Linq;

namespace PowerApps.Tools.Utilities.Models
{
    public class AppData
    {
        public List<Template> Templates { get; set; }
        public List<Entity> Entities { get; set; }
        public Property Properties { get; set; }
        public JObject Header { get; set; }
        public JObject MacroTable { get; set; }
        public JObject PublishInfo { get; set; }
        public JObject Themes { get; set; }

        public List<string> Screens
        {
            get
            {
                return Entities?
                    .Where(r => r.Template.Name == "screen")
                    .Select(s => s.Name).ToList();
            }
        }

        public string FilePath { get; set; }
        public string ExteractedAppPath { get; set; }
    }
}