using GalaSoft.MvvmLight;
using PowerApps_Theme_Editor.Model;

namespace PowerApps_Theme_Editor.ViewModel
{
    /// <summary>
    /// This class contains properties that a View can data bind to.
    /// </summary>
    public class PaletteViewModel : ViewModelBase
    {
        public Palette Palette { get; set; }

        private string _name;
        private string _value;
        private string _type;
        private string _phoneValue;

        public string name
        {
            get
            {
                return this._name;
            }
            set
            {
                Set(ref this._name, value);
                this.Palette.name = value;
            }
        }

        public string value
        {
            get
            {
                return this._value;
            }
            set
            {
                Set(ref this._value, value);
                this.Palette.value = value;
            }
        }

        public string type
        {
            get
            {
                return this._type;
            }
            set
            {
                Set(ref this._type, value);
                this.Palette.type = value;
            }
        }

        public string phoneValue
        {
            get
            {
                return this._phoneValue;
            }
            set
            {
                Set(ref this._phoneValue, value);
                this.Palette.phoneValue = value;
            }
        }

        /// <summary>
        /// Initializes a new instance of the PaletteViewModel class.
        /// </summary>
        public PaletteViewModel(Palette palette)
        {
            this.Palette = palette;
            this._name = palette.name;
            this._phoneValue = palette.phoneValue;
            this._value = palette.value;
            this._type = palette.type;
        }
    }
}