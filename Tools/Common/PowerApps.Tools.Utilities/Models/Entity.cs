using Newtonsoft.Json.Linq;
using System.Collections.Generic;

namespace PowerApps.Tools.Utilities.Models
{
    public class Entity
    {
        public string Name { get; set; }
        public string Type { get; set; }
        public string TemplateName { get; set; }
        public JToken EntityObject { get; set; }
        public List<Entity> Children { get; set; }
    }
}