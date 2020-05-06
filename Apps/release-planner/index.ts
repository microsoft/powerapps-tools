import { IInputs, IOutputs } from "./generated/ManifestTypes";
import * as $ from 'jquery';
import 'Bootstrap';
import 'block-ui';
import { encode, decode } from 'base64-arraybuffer';
var mime = require('mime-types')

interface Clipboard {
    writeText(newClipText: string): Promise<void>;
    // Add any other methods you need here.
}
interface NavigatorClipboard {
    // Only available in a secure context.
    readonly clipboard?: Clipboard;
}
interface Navigator extends NavigatorClipboard { }

class EntityReference {
    id: string;
    typeName: string;
    constructor(typeName: string, id: string) {
        this.id = id;
        this.typeName = typeName;
    }
}

class ImageDescription {
    annotationid: string;
    filename: string;
    body: string;

    msft_releaseplanattachmentid: string;
    msft_alttextname: string;
    msft_name: string;
    msft_imagecreated: boolean;
    createdon: string;

    constructor() {
    }
}


class PopupChanges {
    altname: string | null;
    filename: string | null;
    filecontent: string | null;
    original: ImageDescription;
    constructor() {
        this.altname = null;
        this.filename = null;
        this.filecontent = null;
    }
}

const loading_block_options: JQBlockUIOptions = {
    message: '<span style="display:block; margin:0 auto;">Loading </span><span class= "l-1" > </span><span class= "l-2" > </span>' +
        '<span class= "l-3" > </span><span class= "l-4" > </span><span class= "l-5" > </span><span class= "l-6" > </span>'
};

export class UploadImageToolV1 implements ComponentFramework.StandardControl<IInputs, IOutputs> {

    // Value of the field is stored and used inside the control 
    private _value: string | null;

    private _controlheight: number | null;

    private _controlwidth: number | null;

    private _imageheight: number | null;

    private _imagewidth: number | null;

    private _minCardWidth: number | null;

    private _maxCardWidth: number | null;

    private _isHorizontal: boolean = false; // default - vertical 


    private _isdebug: boolean = true;

    // PCF framework context, "Input Properties" containing the parameters, control metadata and interface functions.
    private _context: ComponentFramework.Context<IInputs>;

    // PCF framework delegate which will be assigned to this object which would be called whenever any update happens. 
    private _notifyOutputChanged: () => void;

    // Control's container
    private controlContainer: HTMLDivElement;

    // Info's container
    private infoContainer: HTMLDivElement;

    // button element created as part of this control
    private insertButton: HTMLButtonElement;

    // button element created as part of this control
    private refreshButton: HTMLButtonElement;



    // label element created as part of this control
    private errorLabelElement: HTMLLabelElement;

    // xrm form entity reference
    private entityReference: EntityReference;

    // image object shown
    private imageEntityList: ImageDescription[];


    private popupContaineer: HTMLDivElement;
    private popupimage: HTMLImageElement;
    private popupAlt: HTMLTextAreaElement;
    private popupChanges: PopupChanges;
    private popupTitle: HTMLHeadingElement;
    private popupFile: HTMLInputElement;
    private updateButton: HTMLButtonElement


    private popupDeleteContaineer: HTMLDivElement;






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
        // Add control initialization code
        this._context = context;
        this._notifyOutputChanged = notifyOutputChanged;
        this.controlContainer = document.createElement("div");
        this.controlContainer.setAttribute("class", "release-image-control");

        // default
        this._controlheight = 1500;
        this._controlwidth = 1500;
        if (context.parameters.maxcontrolheight) {
            this._controlheight = context.parameters.maxcontrolheight.raw;
        }

        if (context.parameters.maxcontrolwidth) {
            this._controlwidth = context.parameters.maxcontrolwidth.raw;
        }

        if (context.parameters.mincardwidth) {
            this._minCardWidth = context.parameters.mincardwidth.raw;
        }

        if (context.parameters.maxcardwidth) {
            this._maxCardWidth = context.parameters.maxcardwidth.raw;
        }


        if (context.parameters.maximageheight) {
            this._imageheight = context.parameters.maximageheight.raw;
        }

        if (context.parameters.maximagewidth) {
            this._imagewidth = context.parameters.maximagewidth.raw;
        }

        if (context.parameters.isHorizontal) {
            this._isHorizontal = (context.parameters.isHorizontal.raw == 1) ? true : false;
        }

        this.entityReference = new EntityReference(
            (<any>context).page.entityTypeName,
            (<any>context).page.entityId
        )

        this.infoContainer = document.createElement("div");

        let contStyle: string = "";
        if (this._controlwidth) {
            contStyle += "max-width:" + this._controlwidth + "px;";
        }

        if (this._controlheight) {
            contStyle += "max-height:" + this._controlheight + "px;";
        }

        if (this._isHorizontal) {
            contStyle += "overflow-x: auto;";
        }
        else {
            contStyle += "overflow-y: auto;";
        }


        contStyle += "position: relative; zoom: 1;min-height: 150px; min-width: 150px;";

        this.infoContainer.setAttribute("style", contStyle);

        //Create a new  button to create new image
        this.insertButton = document.createElement("button");
        this.insertButton.classList.add("btn");
        this.insertButton.classList.add("btn-outline-primary");
        this.insertButton.innerHTML = "+ Create new image";
        // Adding the label and button created to the container DIV.
        this.controlContainer.appendChild(this.insertButton);
        this.insertButton.addEventListener("click", this.showCreateDialog.bind(this));


        //Create a new  button to create new image
        this.refreshButton = document.createElement("button");
        this.refreshButton.classList.add("btn");
        this.refreshButton.classList.add("btn-outline-primary");
        this.refreshButton.innerHTML = "Refresh";
        // Adding the label and button created to the container DIV.
        this.controlContainer.appendChild(this.refreshButton);
        this.refreshButton.addEventListener("click", this.refreshList.bind(this));

        this.controlContainer.appendChild(this.infoContainer);

        container.appendChild(this.controlContainer);

        //check for image
        this.LoadImages();


    }

    private refreshList(): void {
        setTimeout(() => { this.LoadImages(); }, 500);
    }

    public LoadImages(): void {
        $(this.infoContainer).scrollLeft(0);

        $(this.infoContainer).block(loading_block_options);

        if (this.entityReference.id) {

            this.insertButton.removeAttribute("disabled");
            this.refreshButton.removeAttribute("disabled");

            let fetchXml: string = '<fetch top="20" no-lock="true" >' +
                '<entity name="msft_releaseplanattachment" >' +
                '<attribute name="msft_releaseplanid" />' +
                '<attribute name="msft_releaseplanattachmentid" />' +
                '<attribute name="createdon" />' +
                '<attribute name="msft_releaseplanidname" />' +
                '<attribute name="msft_alttextname" />' +
                '<attribute name="msft_name" />' +
                '<attribute name="msft_imagecreated" />' +
                '<filter>' +
                '<condition attribute="statuscode" operator="eq" value="1" />' +
                '<condition attribute="msft_releaseplanid" operator="eq" value="' + this.entityReference.id + '" />' +
                '</filter>' +
                '<link-entity name="annotation" from="objectid" to="msft_releaseplanattachmentid"  link-type="outer" >' +
                '<attribute name="filename" />' +
                '<attribute name="annotationid" />' +
                '<attribute name="documentbody" />' +
                '</link-entity>' +
                '</entity>' +
                '</fetch>';

            // store reference to 'this' so it can be used in the callback method
            var thisRef = this;
            // we set it to zero anyway - if something happend - we don't whatn to show stale data
            thisRef.imageEntityList = [];

            // Invoke the Web API RetrieveMultipleRecords method to calculate the aggregate value
            this._context.webAPI.retrieveMultipleRecords("msft_releaseplanattachment", "?fetchXml=" + fetchXml).then
                (
                    function (response: ComponentFramework.WebApi.RetrieveMultipleResponse) {
                        if (response.entities.length) {

                            thisRef.imageEntityList = [];

                            for (let i = 0; i < response.entities.length; i++) {
                                var imageEntity = new ImageDescription();
                                imageEntity.msft_name = response.entities[i]["msft_name"];
                                imageEntity.msft_imagecreated = response.entities[i]["msft_imagecreated"];
                                imageEntity.msft_alttextname = response.entities[i]["msft_alttextname"];
                                imageEntity.msft_releaseplanattachmentid = response.entities[i]["msft_releaseplanattachmentid"];
                                imageEntity.createdon = response.entities[i]["createdon"];

                                let fileName: string = response.entities[i]["annotation1.filename"];
                                let fileExtension: string | undefined;
                                if (fileName) fileExtension = fileName.split('.').pop();

                                if (fileExtension) {
                                    imageEntity.annotationid = response.entities[i]["annotation1.annotationid"];
                                    imageEntity.filename = response.entities[i]["annotation1.filename"];
                                    imageEntity.body = response.entities[i]["annotation1.documentbody"];
                                }
                                else {
                                    // todo create
                                    imageEntity.annotationid = "create";
                                }
                                thisRef.imageEntityList.push(imageEntity);
                            }

                            // update other attributes
                            thisRef.updateControls();
                        }
                        else {
                            //show no images?
                            // anyway update just in case we need to remove last image
                            thisRef.updateControls();
                        }
                        $(thisRef.infoContainer).unblock();
                    },
                    function (errorResponse: any) {
                        // Error handling code here
                        let errorHTML: string = "Error with Web API call:";
                        errorHTML += "<br />"
                        errorHTML += errorResponse.message;
                        thisRef.errorLabelElement.innerHTML = errorHTML;
                        $(thisRef.infoContainer).unblock();
                    }
                );
        }
        else {
            this.insertButton.setAttribute("disabled", "disabled");
            this.refreshButton.setAttribute("disabled", "disabled");
            $(this.infoContainer).unblock();
        }
    }

    public showDialog(card: HTMLElement, item: ImageDescription): void {
        if (this.popupChanges) delete (this.popupChanges);


        this.popupChanges = new PopupChanges();
        this.popupChanges.original = item;

        this.doModal("Edit Item");

        var imgs = card.getElementsByTagName("img");
        if (imgs.length && this.popupimage) {
            this.popupimage.src = (<HTMLImageElement>imgs[0]).src;
        }

        if (this.popupAlt)
            this.popupAlt.value = item.msft_alttextname;
    }

    public showCreateDialog(): void {

        if (this.popupChanges) delete (this.popupChanges);

        this.popupChanges = new PopupChanges();
        this.popupChanges.original = new ImageDescription();
        this.popupChanges.original.annotationid = "create";
        this.popupChanges.original.msft_releaseplanattachmentid = "create";

        this.doModal("Create Item");
    }


    public updateControls(): void {
        // Add code to update control view
        if (this.imageEntityList && this.imageEntityList.length > 0) {
            this.infoContainer.innerHTML = "";

            var cardcont = document.createElement("div");
            cardcont.classList.add("card-deck");
            if (this._isHorizontal) {
                cardcont.setAttribute("style", "flex-wrap: nowrap;");
            }

            for (let i = 0; i < this.imageEntityList.length; i++) {
                let imageEntity: ImageDescription = this.imageEntityList[i];
                var s: string = '';
                let fileExtension: string | undefined;
                if (imageEntity.filename) {
                    fileExtension = imageEntity.filename.split('.').pop();
                }

                let carddiv: HTMLDivElement = document.createElement("div");
                carddiv.className = "card";

                let cardStyle: string = "";
                if (this._minCardWidth) {
                    cardStyle += "min-width: " + this._minCardWidth + "px;";
                }

                if (this._maxCardWidth) {
                    cardStyle += "max-width: " + this._maxCardWidth + "px";
                }

                if (cardStyle) {
                    carddiv.setAttribute("style", cardStyle);
                }

                cardcont.appendChild(carddiv);

                if (fileExtension) {
                    let imageUrl: string = this.generateImageSrcUrl(fileExtension, imageEntity.body);
                    let imageEl: HTMLImageElement = <HTMLImageElement>document.createElement("img");
                    imageEl.src = imageUrl;
                    imageEl.className = "card-img-top";
                    imageEl.alt = imageEntity.msft_alttextname;

                    let imgStyle: string = "";
                    if (this._imagewidth) {
                        imgStyle += "max-width:" + this._imagewidth + "px;";
                    }

                    if (this._imageheight) {
                        imgStyle += "max-height:" + this._imagewidth + "px;";
                    }

                    imgStyle += "margin:0 auto;";

                    if (imgStyle) {
                        imageEl.setAttribute("style", imgStyle);
                    }

                    carddiv.appendChild(imageEl);
                }

                let cardBodyDiv: HTMLDivElement = document.createElement("div");
                cardBodyDiv.className = "card-body";
                carddiv.appendChild(cardBodyDiv);

                let cardtitle: HTMLHeadingElement = document.createElement("h5");
                cardtitle.className = "card-title";
                cardtitle.textContent = imageEntity.msft_name;
                cardBodyDiv.appendChild(cardtitle);

                let cardFields: HTMLUListElement = document.createElement("ul");
                cardFields.className = "list-group list-group-flush";

                let liEl: HTMLLIElement = document.createElement("li");
                liEl.className = "list-group-item";
                liEl.innerHTML = " Alt Text: " + imageEntity.msft_alttextname;
                cardFields.appendChild(liEl);

                liEl = document.createElement("li");
                liEl.className = "list-group-item";
                if (imageEntity.msft_imagecreated) {
                    liEl.innerHTML = '<b>![' + imageEntity.msft_alttextname + '](media/' + imageEntity.msft_name + ' "' + imageEntity.msft_alttextname + '")</b>&nbsp;';
                    let copytoClip: HTMLButtonElement = document.createElement("button");
                    copytoClip.className = "btn btn-primary btn-sm";
                    copytoClip.type = "button";
                    copytoClip.innerHTML = "Copy to Clipboard";
                    copytoClip.addEventListener("click", this.copyToClipboard.bind(this, imageEntity));
                    liEl.appendChild(copytoClip);
                    cardFields.appendChild(liEl);

                }

                cardBodyDiv.appendChild(cardFields);

                let cardFooter: HTMLDivElement = document.createElement("div");
                cardFooter.className = "card-footer";
                carddiv.appendChild(cardFooter);

                let editBtn: HTMLButtonElement = document.createElement("button");
                editBtn.className = "btn btn-primary";
                editBtn.type = "button";
                editBtn.setAttribute("data-target", "#releaseplanimage_editItemPopup");
                editBtn.innerHTML = "EDIT";
                editBtn.addEventListener("click", this.showDialog.bind(this, carddiv, imageEntity));

                let deleteBtn: HTMLButtonElement = document.createElement("button");
                deleteBtn.className = "btn btn-primary";
                deleteBtn.type = "button";
                deleteBtn.innerHTML = "DELETE";
                deleteBtn.addEventListener("click", this.deleteItem.bind(this, carddiv, imageEntity));

                cardFooter.appendChild(editBtn);
                cardFooter.append(" ");
                cardFooter.appendChild(deleteBtn);
            }

            this.infoContainer.appendChild(cardcont);
        }
        else {
            this.infoContainer.innerHTML = "";
        }
    }

    private copyToClipboard(imageEntity: ImageDescription): void {
        ///

        if ((navigator as Navigator).clipboard)
            (navigator as Navigator).clipboard!.writeText("![" + imageEntity.msft_alttextname + "](media/" + imageEntity.msft_name + " \"" + imageEntity.msft_alttextname + "\")").then(
                function () { alert("clipboard saved"); }
            );
    }


    private deleteItem(card: HTMLElement, item: ImageDescription): void {
        // get txn id from current table row
        var heading = 'Confirm Item Delete';
        var question = 'Do you want to delete this image? You can\'t undo this action. If you have included this image markdown text in the “Feature detail(in markdown format) ” field, you need to manually remove the text.';
        var cancelButtonTxt = 'Cancel';
        var okButtonTxt = 'Confirm';

        var thisRef = this;

        var callback = function () {
            $(thisRef.popupDeleteContaineer).block(loading_block_options);
            thisRef._context.webAPI.deleteRecord("msft_releaseplanattachment", item.msft_releaseplanattachmentid).then(
                function (response: ComponentFramework.EntityReference) {
                    console.log("removed  msft_releaseplanattachment"); console.dir(response);
                    $(thisRef.popupDeleteContaineer).unblock();
                    $(thisRef.popupDeleteContaineer).modal('hide');

                    thisRef.refreshList();

                },
                function (errorResponse: any) {
                    console.log("Error updaing msft_releaseplanattachment:"); console.dir(errorResponse);
                    $(thisRef.popupDeleteContaineer).modal("hide");
                    $(thisRef.popupDeleteContaineer).block(loading_block_options);

                    thisRef.refreshList();
                });
        }

        this.confirmDialog(heading, question, cancelButtonTxt, okButtonTxt, callback);

    }

	/**
	 * Called when any value in the property bag has changed. This includes field values, data-sets, global values such as container height and width, offline status, control metadata values such as label, visible, etc.
	 * @param context The entire property bag available to control via Context Object; It contains values as set up by the customizer mapped to names defined in the manifest, as well as utility functions
	 */
    public updateView(context: ComponentFramework.Context<IInputs>): void {
        // Add code to update control view
        this._context = context;

        // if entity has been created
        if (!this.entityReference.id) {
            this.entityReference.id = (<any>context).page.entityId;
            this.LoadImages();
        }
    }


	/** 
	 * It is called by the framework prior to a control receiving new data. 
	 * @returns an object based on nomenclature defined in manifest, expecting object[s] for property marked as “bound” or “output”
	 */
    public getOutputs(): IOutputs {
        // return outputs
        let result: IOutputs =
        {
            value: '',
        };
        return result;
    }

	/** 
	 * Called when the control is to be removed from the DOM tree. Controls should use this call for cleanup.
	 * i.e. cancelling any pending remote calls, removing listeners, etc.
	 */
    public destroy(): void {
        // Add code to cleanup control if necessary
    }


    /**
     * 
     * @param altmessage
     */
    private updateAltMessage(altmessage: string | null, item: ImageDescription): Promise<boolean> {
        if (altmessage) {
            //update entity
            var data: any = {};
            data["msft_alttextname"] = altmessage;

            if (item.msft_releaseplanattachmentid == "create") {

                data["msft_releaseplanid@odata.bind"] = "/msft_releaseplans(" + this.entityReference.id + ")";
                data["msft_imagecreated"] = false;
                data["msft_name"] = (item && item.msft_name) ? item.msft_name : altmessage;

                return this._context.webAPI.createRecord("msft_releaseplanattachment", data).then(
                    function (response: ComponentFramework.EntityReference) {
                        item.msft_alttextname = altmessage;
                        item.msft_releaseplanattachmentid = response.id as unknown as string;
                        console.log("created msft_releaseplanattachment");
                        console.dir(response);
                        return true;
                    },
                    function (errorResponse: any) {
                        console.log("Error creating msft_releaseplanattachment:");
                        console.dir(errorResponse);
                        return false;
                    }
                );
            }
            else {
                return this._context.webAPI.updateRecord("msft_releaseplanattachment", item.msft_releaseplanattachmentid, data).then(
                    function (response: ComponentFramework.EntityReference) {
                        item.msft_alttextname = altmessage;
                        console.log("updated msft_releaseplanattachment"); console.dir(response);
                        return true;
                    },
                    function (errorResponse: any) {
                        console.log("Error updaing msft_releaseplanattachment:"); console.dir(errorResponse);
                        return false;
                    }
                );
            }
        }
        else {
            return new Promise((resolve) => { resolve(false); });
        }
    }

    private updateAttachment(filename: string | null, filecontent: string | null, item: ImageDescription): Promise<boolean> {
        //update entity
        if (item.annotationid && item.annotationid != "create" && filename && filecontent) {

            var data: any = {};
            data["documentbody"] = filecontent;
            data["filename"] = filename;

            //update entity
            return this._context.webAPI.updateRecord("annotation", item.annotationid, data).then(
                function (response: ComponentFramework.EntityReference) {
                    item.filename = filename;
                    item.body = filecontent;
                    console.log("Updated annotation"); console.dir(response);
                    return true;
                },
                function (errorResponse: any) {
                    console.log("Error udpating annotation:"); console.dir(errorResponse);
                    return false;
                }
            );
        }
        else if (item.annotationid == "create" && filename && filecontent) {
            //create

            var data: any = {};
            data["documentbody"] = filecontent;
            data["filename"] = filename;
            data["objectid_msft_releaseplanattachment@odata.bind"] = "/msft_releaseplanattachments(" + item.msft_releaseplanattachmentid + ")";
            data["mimetype"] = mime.lookup(filename);

            return this._context.webAPI.createRecord("annotation", data).then(
                function (response: ComponentFramework.EntityReference) {
                    item.filename = filename;
                    item.body = filecontent;
                    item.annotationid = response.id as unknown as string;
                    console.log("created annotation"); console.dir(response);
                    return true;
                },
                function (errorResponse: any) {
                    console.log("Error creatingannotation:"); console.dir(errorResponse);
                    return false;
                }
            );
        }
        else {
            return new Promise((resolve) => { resolve(); });
        }
    }

    /**
     * Set the Image content
     * @param shouldUpdateOutput indicate if needs to inform the infra of the change
     * @param fileType file extension name like "png", "gif", "jpg"
     * @param fileContent file content, base64 format
     */
    private setImage(shouldUpdateOutput: boolean, fileType: string, fileContent: string): void {
        let imageUrl: string = this.generateImageSrcUrl(fileType, fileContent);
        //this.imgElement.src = imageUrl;

        if (shouldUpdateOutput) {
            //this.controlContainer.classList.remove(ShowErrorClassName);
            this._value = imageUrl;
            this._notifyOutputChanged();
        }
    }

    /**
     * Genereate Image Element src url
     * @param fileType file extension
     * @param fileContent file content, base 64 format
     */
    private generateImageSrcUrl(fileType: string, fileContent: string): string {
        return "data:image/" + fileType + ";base64, " + fileContent;
    }

    /** 
		 *  Show Error Message
		 */
    private showError(): void {
        this.errorLabelElement.innerText = this._context.resources.getString("PCF_ImageUploadControl_Can_Not_Find_File");
        // this.controlContainer.classList.add(ShowErrorClassName);
    }


    /**
     * HELPER Function to show confirm dialog
     * @param heading
     * @param question
     * @param cancelButtonTxt
     * @param okButtonTxt
     * @param callback
     */
    private confirmDialog(heading: string, question: string, cancelButtonTxt: string, okButtonTxt: string, callback: () => void) {
        // this is popup dialog
        // it will be a long story to create it dynamically, so we create it as inner HTML and get required controls to deal with
        let dialogHTML: string = '<div class="modal fade release-image-control" id="releaseplanimage_deleteItemPopup" tabindex="-1" role="dialog"  aria-hidden="true">' +
            '  <div class="modal-dialog" role="document">' +
            '    <div class="modal-content">' +
            '      <div class="modal-header">' +
            '        <h5 class="modal-title" id="releaseplanimage_deleteItemTitle">' + heading + '</h5>' +
            '        <button type="button" class="close" data-dismiss="modal" aria-label="Close">' +
            '          <span aria-hidden="true">&times;</span>' +
            '        </button>' +
            '      </div>' +
            '      <div class="modal-body">' +
            '       <div class="row">' +
            '        <div class="col-md-12" > ' +
            '          <p>' + question + '</p>' +
            '        </div>' +
            '        <div class="col-md-6">' +
            '        </div>' +
            '      </div>' +
            '      <div class="modal-footer">' +
            '        <button type="button" class="btn btn-secondary" data-dismiss="modal">' + cancelButtonTxt + '</button>' +
            '        <button type="button" class="btn btn-primary" id="releaseplanimage_deletefromModal">' + okButtonTxt + '</button>' +
            '      </div>' +
            '    </div>' +
            '  </div>' +
            '</div>';

        $('body').append(dialogHTML);

        // get variables for live time
        this.popupDeleteContaineer = <HTMLDivElement>document.getElementById("releaseplanimage_deleteItemPopup");
        let deleteButton = <HTMLButtonElement>document.getElementById("releaseplanimage_deletefromModal");

        $(this.popupDeleteContaineer).modal();
        $(this.popupDeleteContaineer).modal('show');

        var thisRef = this;

        $('#releaseplanimage_deleteItemPopup').on('hidden.bs.modal', function (e) {
            $('#releaseplanimage_deleteItemPopup').remove(); // this modal and all event handlers
            //delete (deleteButton);
        });

        deleteButton.addEventListener("click", x => {
            callback();
        });
    }

    /**
     * Helper Function to Show Modal Dialog (BOOTSTRAP)
     * It has code to destroy dialog once it closed
     * @param heading
     * @param formContent
     */
    private doModal(heading: string): void {

        // this is popup dialog
        // it will be a long story to create it dynamically, so we create it as inner HTML and get required controls to deal with
        let dialogHTML: string = '<div class="modal fade release-image-control" id="releaseplanimage_editItemPopup" tabindex="-1" role="dialog" aria-labelledby="exampleModalLabel" aria-hidden="true">' +
            '  <div class="modal-dialog" role="document">' +
            '    <div class="modal-content">' +
            '      <div class="modal-header">' +
            '        <h5 class="modal-title" id="releaseplanimage_editItemTitle">' + heading + '</h5>' +
            '        <button type="button" class="close" data-dismiss="modal" aria-label="Close">' +
            '          <span aria-hidden="true">&times;</span>' +
            '        </button>' +
            '      </div>' +
            '      <div class="modal-body">' +
            '       <div class="row">' +
            '        <div class="col-md-6" > ' +
            '          <img class="img-fluid" id="releaseplanimage_imagePopup" > ' +
            '        </div>' +
            '       <div class="col-md-6">' +
            '        <form class="needs-validation" novalidate>' +
            '          <div class="form-group">' +
            '            <label for="releaseplanimage_alttext_text" class="col-form-label">Alt Text:<span style="color: #a94442;"> *</span></label>' +
            '            <textarea rows="5" class="form-control" id="releaseplanimage_alttext_text" required></textarea>' +
            '           <div class="invalid-feedback">Please provide a value.</div>' +
            '          </div>' +
            '          <div class="form-group">' +
            '           <div class="input-group mb-3"> ' +
            '             <!--div class="input-group-prepend" > ' +
            '                <span class="input-group-text" id="releaseplanimage_inputGroupFileAddon01">Upload</span>' +
            '             </div--> ' +
            '             <div class="custom-file" > ' +
            '              <input type="file" class="custom-file-input" id="releaseplanimage_imageFilemodal" aria-describedby="releaseplanimage_inputGroupFileAddon01" ' + (heading.startsWith('Create') ? 'required' : '') + '>' +
            '              <label class="custom-file-label overflow-hidden" for="">Choose file</label>' +
            '              <div class="invalid-feedback">Please provide a file.</div>' +
            '             </div>' +
            '            </div>' +
            '          </div>' +
            '        </form>' +
            '      </div></div>' +
            '      </div>' +
            '      <div class="modal-footer">' +
            '        <button type="button" class="btn btn-secondary" data-dismiss="modal">Close</button>' +
            '        <button type="button" class="btn btn-primary" id="releaseplanimage_updatefromModal">' + (heading.startsWith('Create') ? 'Create' : 'Update') + '</button>' +
            '      </div>' +
            '    </div>' +
            '  </div>' +
            '</div>';

        $('body').append(dialogHTML);

        // get variables for live time

        this.popupContaineer = <HTMLDivElement>document.getElementById("releaseplanimage_editItemPopup");
        this.popupimage = <HTMLImageElement>document.getElementById("releaseplanimage_imagePopup");
        this.popupAlt = <HTMLTextAreaElement>document.getElementById("releaseplanimage_alttext_text");
        this.popupTitle = <HTMLHeadingElement>document.getElementById("releaseplanimage_editItemTitle");
        this.updateButton = <HTMLButtonElement>document.getElementById("releaseplanimage_updatefromModal");
        this.popupFile = <HTMLInputElement>document.getElementById("releaseplanimage_imageFilemodal");

        if (this.popupChanges.original.annotationid != "create") {
            // update scenario
            // hide edit image control
            $(".custom-file").hide();
        }

        $(this.popupContaineer).modal();
        $(this.popupContaineer).modal('show');

        var thisRef = this;

        $('#releaseplanimage_editItemPopup').on('hidden.bs.modal', function (e) {
            $('#releaseplanimage_editItemPopup').remove(); // this modal and all event handlers
            delete (thisRef.popupimage);
            delete (thisRef.popupAlt);
            delete (thisRef.popupTitle);
            delete (thisRef.popupContaineer);
            delete (thisRef.updateButton);
            delete (thisRef.popupFile);
        });

        // update popupChanges object
        this.popupAlt.addEventListener("change", function (e) {
            thisRef.popupChanges.altname = thisRef.popupAlt.value;
            if (thisRef._isdebug) console.log("Popup alt value changed to: " + thisRef.popupAlt.value);
        });

        this.updateButton.addEventListener("click", function (e) {
            let form: HTMLFormElement = <HTMLFormElement>document.getElementsByClassName('needs-validation')[0];
            if (form.checkValidity() === false) {
                e.preventDefault();
                e.stopPropagation();
                form.classList.add('was-validated');
                return;
            }
            form.classList.add('was-validated');

            if (thisRef.popupChanges) {
                if (thisRef.popupChanges.altname || thisRef.popupChanges.filename) {
                    // we have changes - updating
                    $(thisRef.popupimage).parent().parent().block(loading_block_options);

                    let item1: boolean, item2: boolean;
                    let is_creation = false;

                    if (thisRef.popupChanges.original.msft_releaseplanattachmentid == "create") is_creation = true;

                    thisRef.updateAltMessage(thisRef.popupChanges.altname, thisRef.popupChanges.original).then((res) => {
                        item1 = res;
                        return thisRef.updateAttachment(thisRef.popupChanges.filename, thisRef.popupChanges.filecontent, thisRef.popupChanges.original)
                    }).then((res) => {
                        item2 = res;
                        if (item1 || item2) {
                            if (is_creation) {
                                //reload copletely
                                thisRef.LoadImages();
                            }
                            else {
                                thisRef.updateControls();
                            }
                        }
                        $(thisRef.popupimage).parent().parent().unblock();
                    }).catch(() => {
                        // show error message
                        $(thisRef.popupimage).parent().parent().unblock();
                    }).then(() => { $(thisRef.popupContaineer).modal("hide"); });

                }
            }
        });

        this.popupFile.addEventListener("change", function (e) {
            var files = thisRef.popupFile.files;
            var label = <HTMLLabelElement>thisRef.popupFile.nextElementSibling;
            if (files && files.length) {
                var f: File = files[0];
                var name = f.name.split('\\').pop();
                let fileExtension: string | undefined;
                if (f && f.name) {
                    fileExtension = f.name.split('.').pop();
                }

                if (f && f.name && f.name.length > 50) {
                    alert("Use image file with name less or equal than 50 chracters. Please lower the name length and try again.");
                }
                else if (f.size && (f.size / (1024 * 1024) > 5)) {
                    // console.log(`File size : ${f.size} in Kb - ${f.size / 1024} in Mb - ${f.size/(1024*1024)}`);
                    alert("This control doesn't support image files more than 5 MB. Please lower the size and try again");
                }
                else if (fileExtension) {

                    var fileReader: FileReader = new FileReader();
                    fileReader.onload = () => {
                        var base64file: string | ArrayBuffer | null = null;
                        base64file = fileReader.result;
                        if (base64file && base64file instanceof ArrayBuffer) {
                            let base64String = encode(base64file);
                            let imageUrl: string = thisRef.generateImageSrcUrl(fileExtension!, base64String);
                            if (name) { label.innerHTML = name; }
                            $(thisRef.popupimage).parent().parent().unblock();

                            thisRef.popupimage.src = imageUrl;
                            thisRef.popupChanges.filecontent = base64String;
                            thisRef.popupChanges.filename = f.name;

                            thisRef.popupChanges.original.msft_name = f.name;
                        }
                    };

                    fileReader.onerror = () => { $(thisRef.popupimage).parent().parent().unblock(); };
                    fileReader.readAsArrayBuffer(f);


                    $(thisRef.popupimage).parent().parent().block(loading_block_options);
                }
            }
            else
                label.innerHTML = "Choose file";
        });

    }

}