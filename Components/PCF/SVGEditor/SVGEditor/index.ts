import { IInputs, IOutputs } from "./generated/ManifestTypes";

export class SVGEditor implements ComponentFramework.StandardControl<IInputs, IOutputs> {
	
	// PCF framework delegate which will be assigned to this object which would be called whenever any update happens. 
	private _notifyOutputChanged: () => void;
	// label element created as part of this control
	private labelElement: HTMLLabelElement;
	// input element that is used to create the range slider
	private inputElement: HTMLInputElement;
	// Reference to the control container HTMLDivElement
	// This element contains all elements of our custom control example
	private _container: HTMLDivElement;
	// Reference to ComponentFramework Context object
	private _context: ComponentFramework.Context<IInputs>;
	// Event Handler 'refreshData' reference
	private _refreshData: EventListenerOrEventListenerObject;

	private _svgElemFill: string;
	// Value of the field is stored and used inside the control 
	private _svgElemHTML: string;
	svgContainer: any;
	helloWorld: any;

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
		this.svgContainer = document.createElement("div");
		this.svgContainer.id = "svg-container";
		this._container.appendChild(this.svgContainer);
		container.appendChild(this._container);
	}
	
	/**
	 * Called when any value in the property bag has changed. This includes field values, data-sets, global values such as container height and width, offline status, control metadata values such as label, visible, etc.
	 * @param context The entire property bag available to control via Context Object; It contains values as set up by the customizer mapped to names defined in the manifest, as well as utility functions
	 */
	public updateView(context: ComponentFramework.Context<IInputs>): void {

		if (this._svgElemFill !== context.parameters.svgFill.raw) {
			this._svgElemFill = context.parameters.svgFill.raw ? context.parameters.svgFill.raw : "";
			const svgElem = this.svgContainer.innerHTML;

			this.svgContainer.setAttribute("fill", this._svgElemFill);
			let fillNodes = this.svgContainer.firstElementChild.querySelectorAll("[fill]");
			for (var i = 0; i < fillNodes.length; i++) {
				fillNodes[i].setAttribute("fill", this._svgElemFill);
			}
			this._notifyOutputChanged();
		}

		if (this._svgElemHTML !== context.parameters.svgElement.raw) {
			this._svgElemHTML = context.parameters.svgElement.raw ? context.parameters.svgElement.raw : "";

			if (this._svgElemHTML && this._svgElemHTML !== "val" && this.svgContainer && this.isValidSVG(this._svgElemHTML)) {
				this.svgContainer.innerHTML = this._svgElemHTML;
				this._notifyOutputChanged();
			}
		}
	}

	public isValidSVG(html: string): boolean {
		let doc = document.createElement('div');
		doc.innerHTML = html;
		return doc.firstChild instanceof SVGElement;
	}

	/** 
	 * It is called by the framework prior to a control receiving new data. 
	 * @returns an object based on nomenclature defined in manifest, expecting object[s] for property marked as “bound” or “output”
	 */
	public getOutputs(): IOutputs {
		return {
			svgElement: this._svgElemHTML
		};
	}

	/** 
	 * Called when the control is to be removed from the DOM tree. Controls should use this call for cleanup.
	 * i.e. cancelling any pending remote calls, removing listeners, etc.
	 */
	public destroy(): void {
		// Add code to cleanup control if necessary
	}


}