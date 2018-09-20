using Newtonsoft.Json.Linq;

namespace PowerApps.Tools.Utilities.Models
{
    public class Template
    {
        public string Name { get; set; }
        public string Version { get; set; }
        public JToken TemplateObject { get; set; }
    }
}