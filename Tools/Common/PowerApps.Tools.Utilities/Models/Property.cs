using Newtonsoft.Json.Linq;

namespace PowerApps.Tools.Utilities.Models
{
    public class Property
    {
        public string Name { get; set; }
        public float DocumentLayoutWidth { get; set; }
        public float DocumentLayoutHeight { get; set; }
        public string DocumentAppType { get; set; }
        public JObject PropertyObject { get; set; }
    }
}