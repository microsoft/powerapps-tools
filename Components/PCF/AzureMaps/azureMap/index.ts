import DataSetInterfaces = ComponentFramework.PropertyHelper.DataSetApi;
import * as azureMapsControl from "azure-maps-control";
import { IInputs, IOutputs } from "./generated/ManifestTypes";

type DataSet = ComponentFramework.PropertyTypes.DataSet;

export class azureMap implements ComponentFramework.StandardControl<IInputs, IOutputs> {
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

  private dataSource: azureMapsControl.source.DataSource;

  private popup: azureMapsControl.Popup;

  private controls: azureMapsControl.Control[] = [];

  private _alreadyLoadedControls: boolean = false;

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
    if(!context.parameters.sampleDataSet.loading && !this._alreadyLoadedControls) {
      if (context.parameters.mapsubscriptionKey.raw && context.parameters.mapsubscriptionKey.raw.length === 43) {
        // Add code to update control view
        this.getMap(context.parameters.mapsubscriptionKey.raw, context.parameters.sampleDataSet);
      }
      else
        this.getMap("9A-fGWw5MYwV-q2LAJDrgnndT5wVGSKb9QbsUJVVzLE", context.parameters.sampleDataSet);//comment this - hemant 

      //add map controls
      this.addControls();
      this._alreadyLoadedControls = true;
    } else {
      console.log("loading...");
    }
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
      this.map.events.remove('ready', this.onMapReady.bind(this, this._context.parameters.sampleDataSet));
      this.map.events.remove('click', this.symbolActivate.bind(this));
      this.map.events.remove('mousemove', this.symbolActivate.bind(this));
      this.map.events.remove('touchstart', this.symbolActivate.bind(this));
      this.map.events.remove('touchend', this.symbolActivate.bind(this));
    }
  }

  private getMap(authKey: string, dataSet:DataSet) {
    this.map = new azureMapsControl.Map('myMap', {
      center: [-122.33, 47.6],
      zoom: 10,
      _authOptions: {
        authType: 'subscriptionKey',
        subscriptionKey: authKey
      },
      get authOptions() {
        return this._authOptions;
      },
      set authOptions(value) {
        this._authOptions = value;
      },

    });

    this.map.events.add('ready', this.onMapReady.bind(this, dataSet));
  }

  private onMapReady(dataSet:DataSet) {
    debugger;
    //Create a data source and add it to the map.
    this.dataSource = new azureMapsControl.source.DataSource("newID", { //hemant  - null
      cluster: true
    });
    this.map.sources.add(this.dataSource);

    let dataPoints:azureMapsControl.data.Feature<azureMapsControl.data.Point, {}>[] = [];

    //Create three point features on the map and add some metadata in the properties which we will want to display in a popup.
    dataPoints.push(
      new azureMapsControl.data.Feature(new azureMapsControl.data.Point([-122.33, 47.61]), {
        name: 'Convention center',
        description: 'Washington State Convention Center'
      })
    );
    if (dataSet.sortedRecordIds.length >0) {
      for (let currentRecordId of dataSet.sortedRecordIds) {
        let lat = <number>dataSet.records[currentRecordId].getValue("Latitude");
        let long = <number>dataSet.records[currentRecordId].getValue("Longitude");
        if (lat && long) {
          dataPoints.push(
            new azureMapsControl.data.Feature(new azureMapsControl.data.Point([long, lat]), {
              id: currentRecordId,
              name: dataSet.records[currentRecordId].getFormattedValue("name"),
              description: dataSet.records[currentRecordId].getFormattedValue("description")
            })
          );
        }
      }
    }

    //Add the symbol to the data source.
    this.dataSource.add(dataPoints);
    //Add a layer for rendering point data as symbols.
    var symbolLayer = new azureMapsControl.layer.SymbolLayer(this.dataSource);
    this.map.layers.add(symbolLayer);
    //Create a popup but leave it closed so we can update it and display it later.
    this.popup = new azureMapsControl.Popup({
      position: [0, 0],
      pixelOffset: [0, -18]
    });
    //Add a click event to the symbol layer.
    this.map.events.add('click', symbolLayer, this.onClick.bind(this));
    /**
    * Open the popup on mouse move or touchstart on the symbol layer.
    * Mouse move is used as mouseover only fires when the mouse initially goes over a symbol. 
    * If two symbols overlap, moving the mouse from one to the other won't trigger the event for the new shape as the mouse is still over the layer.
    */
    this.map.events.add('mousemove', symbolLayer, this.symbolActivate.bind(this));
    this.map.events.add('touchstart', symbolLayer, this.symbolActivate.bind(this));
    //Close the popup on mouseout or touchend.
    this.map.events.add('mouseout', symbolLayer, this.closePopup.bind(this));
    this.map.events.add('touchend', this.closePopup.bind(this));

    //Create a HTML marker and add it to the map.
    this.map.markers.add(new azureMapsControl.HtmlMarker({
      htmlContent: "<div><div class='pin bounce'></div><div class='pulse'></div></div>",
      position: [-122.33, 47.61],//seattle convention center 
      pixelOffset: [5, -18]
    }));
  };

  private closePopup(e: any) {
    this.popup.close();
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

  private onClick(e:any) {
    //Make sure the event occurred on a point feature.
    if (e.shapes && e.shapes.length > 0) {
      let content, coordinate;
      let properties = e.shapes[0].getProperties();

      //Check to see if the first value in the shapes array is a Point Shape.
      if (e.shapes[0] instanceof azureMapsControl.Shape && e.shapes[0].getType() === 'Point') {
        this._context.navigation.openForm(
          {
            entityName: this._context.parameters.sampleDataSet.getTargetEntityType(),
            entityId: properties.id
          }
        );
      } else if (e.shapes[0].type === 'Feature' && e.shapes[0].geometry.type === 'Point') {
        //Check to see if the feature is a cluster.
        if (!e.shapes[0].properties.cluster) {
          this._context.navigation.openForm(
            {
              entityName: this._context.parameters.sampleDataSet.getTargetEntityType(),
              entityId: properties.id
            }
          );
        }
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
