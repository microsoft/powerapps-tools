import * as azureMapsControl from "azure-maps-control";
import { MapsURL, SubscriptionKeyCredential, SearchURL, Aborter, SearchAddressResponse, WithGeojson, SearchGeojson } from "azure-maps-rest";
import * as _ from 'lodash';
import { IInputs, IOutputs } from "./generated/ManifestTypes";

export class azureMapsFieldControl implements ComponentFramework.StandardControl<IInputs, IOutputs> {
	//Define an HTML template for a custom popup content laypout.
	popupTemplate: string = '<div class="customInfobox"><div class="name">{name}</div>{description}</div>';
	// Cached context object for the latest updateView
	private contextObj: ComponentFramework.Context<IInputs>;

	// Div element created as part of this control's main container
	private mainContainer: HTMLDivElement;

	// framework delegate which will be assigned to this object which would be called whenever any update happens. 
	private _notifyOutputChanged: () => void;

	// Reference to ControlFramework Context object
	private _context: ComponentFramework.Context<IInputs>;

	private map: azureMapsControl.Map;

	private mapLoaded: boolean = false;

	private center: any;

	private popup: azureMapsControl.Popup;

	private controls: azureMapsControl.Control[] = [];

	private _alreadyLoadedControls: boolean = false;

	private defaultTheme = 'road';

	private defaultZoomLevel = 10;

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
	 * @param container If a control is marked control-type='starndard', it will receive an empty div element within which it can render its content.
	 */
	public init(context: ComponentFramework.Context<IInputs>, notifyOutputChanged: () => void, state: ComponentFramework.Dictionary, container: HTMLDivElement) {
		// Add control initialization code
		this._notifyOutputChanged = notifyOutputChanged;
		this._context = context;

		// Need to track container resize so that control could get the available width. The available height won't be provided even this is true
		context.mode.trackContainerResize(true);

		var controlHTML = '<div id="myMap" style="position:relative;width:100%;min-width:290px;height:600px;"></div>';
		// Adding the label and button created to the container DIV.
		container.innerHTML += controlHTML;
	}


	/**
	 * Called when any value in the property bag has changed. This includes field values, data-sets, global values such as container height and width, offline status, control metadata values such as label, visible, etc.
	 * @param context The entire property bag available to control via Context Object; It contains values as set up by the customizer mapped to names defined in the manifest, as well as utility functions
	 */
	public updateView(context: ComponentFramework.Context<IInputs>): void {
		// this.getMap(context.parameters.mapsubscriptionKey.raw, context.parameters.sampleDataSet);
		if (!this.mapLoaded && !this._alreadyLoadedControls) {
			this.getMap(context);
			this.addControls();
			this._alreadyLoadedControls = true;
		}
		this.updateMap(context);
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
		if (this.map.events) {
			this.map.events.remove('ready', this.onMapReady.bind(this));
			this.map.events.remove('click', this.symbolActivate.bind(this));
			this.map.events.remove('mousemove', this.symbolActivate.bind(this));
			this.map.events.remove('touchstart', this.symbolActivate.bind(this));
			this.map.events.remove('touchend', this.symbolActivate.bind(this));
		}
	}

	private getMap(context: ComponentFramework.Context<IInputs>) {
		this.map = new azureMapsControl.Map('myMap', {
			center: [-122.12, 47, 67],
			style: context.parameters.theme ? context.parameters.theme.raw : this.defaultTheme,
			zoom: context.parameters.zoomLevel ? context.parameters.zoomLevel.raw : this.defaultZoomLevel,
			autoResize: true,
			_authOptions: {
				authType: 'subscriptionKey',
				subscriptionKey: context.parameters.mapsubscriptionKey.raw
			},
			get authOptions() {
				return this._authOptions;
			},
			set authOptions(value) {
				this._authOptions = value;
			}

		});

		this.mapLoaded = true;
		this.map.events.add('ready', this.onMapReady.bind(this));
	}

	private updateMap(context: ComponentFramework.Context<IInputs>) {
		this.getCenterCoords(context).then((searchGetResp: SearchAddressResponse) => {
			this.center = searchGetResp.geojson.getFeatures().bbox;
			this.map.setCamera({
				center: [this.center[0], this.center[1]]
			});
			this.setMarkers();
		});
	}

	private getCenterCoords(context: ComponentFramework.Context<IInputs>): Promise<WithGeojson<SearchAddressResponse, SearchGeojson>> {
		let subscriptionKeyCredential = new SubscriptionKeyCredential(context.parameters.mapsubscriptionKey.raw);
		let pipeline = MapsURL.newPipeline(subscriptionKeyCredential, {
			retryOptions: { maxTries: 4 }
		});
		var searchUrl = new SearchURL(pipeline);

		return searchUrl.searchAddress(Aborter.timeout(10000), this.buildAddress(context));
	}

	private buildAddress(context: ComponentFramework.Context<IInputs>) {
		return `${context.parameters.sourceFieldStreet1.formatted || ""} ${context.parameters.sourceFieldStreet2.formatted || ""} ${context.parameters.sourceFieldCity.formatted || ""}, ${context.parameters.sourceFieldState.formatted || ""}`;
	}

	private setMarkers() {
		if (this.center) {
			this.map.markers.add(new azureMapsControl.HtmlMarker({
				htmlContent: "<div><div class='pin bounce'></div><div class='pulse'></div></div>",
				position: [this.center[0], this.center[1]],
				pixelOffset: [5, -18]
			}));
		}
	}

	private onMapReady() {
		if (this.mapLoaded) {
			this.addControls();
		}
	}

	private symbolActivate(e: any) {
		//Make sure the event occurred on a point feature.
		if (e.shapes && e.shapes.length > 0) {
			var content, coordinate;
			//Check to see if the first value in the shapes array is a Point Shape.
			if (e.shapes[0] instanceof azureMapsControl.Shape && e.shapes[0].getType() === 'Point') {
				var properties = e.shapes[0].getProperties();
				content = this.popupTemplate.replace(/{name}/g, properties.name).replace(/{description}/g, properties.description);
				coordinate = e.shapes[0].getCoordinates();
			} else if (e.shapes[0].type === 'Feature' && e.shapes[0].geometry.type === 'Point') {
				//Check to see if the feature is a cluster.
				if (e.shapes[0].properties.cluster) {
					content = '<div style="padding:10px;">Group of ' + e.shapes[0].properties.point_count + ' ' + 'Entities' + '</div>';
				} else {
					//Feature is likely from a VectorTileSource.
					content = this.popupTemplate.replace(/{name}/g, properties.name).replace(/{description}/g, properties.description);
				}

				coordinate = e.shapes[0].geometry.coordinates;
			}

			if (content && coordinate) {
				//Populate the popupTemplate with data from the clicked point feature.
				this.popup.setOptions({
					//Update the content of the popup.
					content: content,
					//Update the position of the popup with the symbols coordinate.
					position: coordinate
				});
				//Open the popup.
				this.popup.open(this.map);
			}
		}
	}

	private addControls() {
		//Remove all controls on the map.
		this.map.controls.remove(this.controls);
		this.controls = [];
		//Create a zoom control.
		this.controls.push(new azureMapsControl.control.ZoomControl());
		this.controls.push(new azureMapsControl.control.PitchControl());
		this.controls.push(new azureMapsControl.control.CompassControl());
		this.controls.push(new azureMapsControl.control.StyleControl());
		//Add controls to the map.
		this.map.controls.add(this.controls);
	}
}
