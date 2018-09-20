using System.Collections.Generic;
using System.Xml.Linq;

namespace Microsoft.PowerApps.Tools.PhoneToTablet
{
    public class ConversionRule : IConversionRule
    {
        public List<NodeDetails> GetRules()
        {
            var xml = XDocument.Load("PhoneToTabletRule.xml");
            var xElement = xml.Element("PhoneToTablet");
            var result = new List<NodeDetails>();

            if (xElement != null)
            {
                foreach (var child in xElement.Elements())
                {
                    var linkedList = new LinkedList<string>();
                    linkedList.AddFirst(child.Name.LocalName);
                    result.Add(new NodeDetails
                    {
                        NodePath = linkedList,
                        Value = child.Value
                    });
                }
            }

            return result;
        }
    }
}