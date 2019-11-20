import { IInputs, IOutputs } from "./generated/ManifestTypes";

export class Base64Download implements ComponentFramework.StandardControl<IInputs, IOutputs> {

	// PCF framework delegate which will be assigned to this object which would be called whenever any update happens. 
	private _notifyOutputChanged: () => void;
	// Reference to the control container HTMLDivElement
	// This element contains all elements of our custom control example
	private _container: HTMLDivElement;
	// Reference to ComponentFramework Context object
	private _context: ComponentFramework.Context<IInputs>;
	// This element will be generated when the document body & filename properties are populated
	private downloadLink: HTMLAnchorElement;

	// class member defaults
	private defaultFontSize = "14";
	private defaultFontFamily = "Segoe UI";

	/**
	 * Empty constructor.
	 */
	constructor() {

	}

	/**
	 * Used to initialize the control instance. Controls can kick off remote server calls and other initialization actions here.
	 * Data-set values are not initialized here, use updateView.
	 * @param context The entire property bag available to control via Context Object; It contains values as set up by the customizer mapped to property names defined in the manifest, as well as utility functions.
	 * @param notifyOutputChanged A callback method to alert the framework that the control has new outputs ready to be retrieved asynchronously.
	 * @param state A piece of data that persists in one session for a single user. Can be set at any point in a controls life cycle by calling 'setControlState' in the Mode interface.
	 * @param container If a control is marked control-type='standard', it will receive an empty div element within which it can render its content.
	 */
	public init(context: ComponentFramework.Context<IInputs>, notifyOutputChanged: () => void, state: ComponentFramework.Dictionary, container: HTMLDivElement) {
		this._context = context;
		this._notifyOutputChanged = notifyOutputChanged;
		this._container = document.createElement("div");

		container.appendChild(this._container);
	}

	/**
	 * Called when any value in the property bag has changed. This includes field values, data-sets, global values such as container height and width, offline status, control metadata values such as label, visible, etc.
	 * @param context The entire property bag available to control via Context Object; It contains values as set up by the customizer mapped to names defined in the manifest, as well as utility functions
	 */
	public updateView(context: ComponentFramework.Context<IInputs>): void {
		if (context.parameters.base64DocumentBody !== null && context.parameters.base64DocumentBody.raw !== null
			&& context.parameters.base64DocumentBody.raw !== 'val'
			&& context.parameters.documentName !== null && context.parameters.documentName.raw !== null
			&& context.parameters.documentName.raw !== 'val') {
			const arrayBuffer = this.base64ToArrayBuffer(context.parameters.base64DocumentBody.raw);
			const fileName = context.parameters.documentName.raw;
			this.createDownloadLink(arrayBuffer, fileName);
		}
	}

	private base64ToArrayBuffer(base64: string) {
		const binaryString = window.atob(base64);
		const bytes = new Uint8Array(binaryString.length);
		return bytes.map((byte, i) => binaryString.charCodeAt(i));
	}

	private createDownloadLink(body: Uint8Array, filename: string) {
		const blob = new Blob([body]);
		const url = URL.createObjectURL(blob);
		this.downloadLink = document.createElement("a");
		this.downloadLink.id = "file-download";
		this.downloadLink.text = filename;
		this.downloadLink.setAttribute('href', url);
		this.downloadLink.setAttribute('download', filename);
		this.downloadLink.style.fontSize = `${this.getFontSize()}px`;
		this.downloadLink.style.fontFamily = this.getFontFamily();

		if (this._container.childNodes.length > 0) {
			this._container.replaceChild(this.downloadLink, this._container.childNodes[0]);
		} else {
			this._container.appendChild(this.downloadLink);
		}

	}

	private getFontSize(): string {
		return this._context.parameters.fontSize && this._context.parameters.fontSize.raw ? this._context.parameters.fontSize.raw  : this.defaultFontSize;
	}

	private getFontFamily(): string {
		return this._context.parameters.fontFamily && this._context.parameters.fontFamily.raw ? this._context.parameters.fontFamily.raw : this.defaultFontFamily;
	}
	

	/** 
	 * It is called by the framework prior to a control receiving new data. 
	 * @returns an object based on nomenclature defined in manifest, expecting object[s] for property marked as “bound” or “output”
	 */
	public getOutputs(): IOutputs {
		return {};
	}

	/** 
	 * Called when the control is to be removed from the DOM tree. Controls should use this call for cleanup.
	 * i.e. cancelling any pending remote calls, removing listeners, etc.
	 */
	public destroy(): void {
		// Add code to cleanup control if necessary
	}
}