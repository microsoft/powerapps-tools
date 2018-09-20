using System.Collections.Generic;

namespace Microsoft.PowerApps.Tools.AppChangeFinder
{
    public class DataModel
    {
        //Screen Name
        public string ScreenName { get; set; }

        private List<Controls> _controls = new List<Controls>();

        public List<Controls> Controls
        {
            get { return _controls; }
            set { _controls = value; }
        }
    }

    public class Controls
    {
        public string ControlName { get; set; }

        private List<Property> _properties = new List<Property>();

        public List<Property> Properties
        {
            get { return _properties; }
            set { _properties = value; }
        }
    }

    public class Property
    {
        public string PropertyName { get; set; }

        public string Comments { get; set; }

        private List<PropertyDetails> _properties = new List<PropertyDetails>();

        public List<PropertyDetails> Properties
        {
            get { return _properties; }
            set { _properties = value; }
        }
    }

    public class PropertyDetails
    {
        public string Name { get; set; }
        public string Value { get; set; }
        public bool IsBaseLine { get; set; }
    }
}