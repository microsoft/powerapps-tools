namespace Microsoft.PowerApps.Tools.AppEntities
{
    public class PropertyModel
    {
        public string Author { get; set; }
        public string Name { get; set; }
        public string Id { get; set; }
        public string FileID { get; set; }
        public string LocalConnectionReferences { get; set; }
        public string[] AppPreviewFlagsKey { get; set; }
        public double DocumentLayoutWidth { get; set; }
        public double DocumentLayoutHeight { get; set; }
        public string DocumentLayoutOrientation { get; set; }
        public bool DocumentLayoutMaintainAspectRatio { get; set; }
        public bool DocumentLayoutLockOrientation { get; set; }
        public string OriginatingVersion { get; set; }
        public string DocumentAppType { get; set; }
        public string AppCreationSource { get; set; }
        public string AppDescription { get; set; }
        public float LastControlUniqueId { get; set; }
        public float DefaultConnectedDataSourceMaxGetRowsCount { get; set; }
    }
}