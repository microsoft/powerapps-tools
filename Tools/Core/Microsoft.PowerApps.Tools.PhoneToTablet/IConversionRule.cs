using System.Collections.Generic;

namespace Microsoft.PowerApps.Tools.PhoneToTablet
{
    public interface IConversionRule
    {
        List<NodeDetails> GetRules();
    }
}