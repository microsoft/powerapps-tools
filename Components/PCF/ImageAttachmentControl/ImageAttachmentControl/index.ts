import { IInputs, IOutputs } from "./generated/ManifestTypes";

import * as Dropzone from "dropzone";
import * as toastr from "toastr";

class EntityReference {
	id: string;
	typeName: string;
	constructor(typeName: string, id: string) {
		this.id = id;
		this.typeName = typeName;
	}
}

class AttachedFile implements ComponentFramework.FileObject {
	annotationId: string;
	fileContent: string;
	fileSize: number;
	fileName: string;
	mimeType: string;
	constructor(annotationId: string, fileName: string, mimeType: string, fileContent: string, fileSize: number) {
		this.annotationId = annotationId
		this.fileName = fileName;
		this.mimeType = mimeType;
		this.fileContent = fileContent;
		this.fileSize = fileSize;
	}
}

export class ImageAttachmentControl implements ComponentFramework.StandardControl<IInputs, IOutputs> {

	private entityReference: EntityReference;

	private _context: ComponentFramework.Context<IInputs>;
	private _container: HTMLDivElement;

	private _divDropZone: HTMLDivElement;
	private _formDropZone: HTMLFormElement;
	private _imgUploadBtn: HTMLAnchorElement;

	private _brElement: HTMLBRElement;

	private _divMain: HTMLDivElement;
	private _imgElement: HTMLImageElement;
	private _deleteImgElement: HTMLImageElement;

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

		this._context = context;

		this.entityReference = new EntityReference(
			(<any>context).page.entityTypeName,
			(<any>context).page.entityId
		)

		this._container = document.createElement("div");
		this._brElement = document.createElement("br");

		this._imgUploadBtn = document.createElement("a");
		this._imgUploadBtn.setAttribute("class", "btn");
		this._imgUploadBtn.innerHTML = "Upload";
		this._imgUploadBtn.addEventListener("click", this.uploadImgonClick.bind(this));
		this._imgUploadBtn.appendChild(this._brElement);

		this._divDropZone = document.createElement("div");
		this._divDropZone.id = "dropzone";

		this._formDropZone = document.createElement("form");
		this._formDropZone.id = "upload_dropzone";
		this._formDropZone.setAttribute("method", "post");

		this._formDropZone.appendChild(this._imgUploadBtn);
		this._formDropZone.setAttribute("class", "dropzone needsclick");
		this._divDropZone.appendChild(this._formDropZone);

		this._divMain = document.createElement("div");

		this._container.appendChild(this._divDropZone);
		this._container.appendChild(this._divMain);
		container.appendChild(this._container);

		this.onload();
		this.onLoadAddAudio();

		toastr.options.closeButton = true;
		toastr.options.progressBar = true;
		toastr.options.positionClass = "toast-bottom-right";
	}

	private onload() {
		var thisRef = this;
		new Dropzone(this._formDropZone, {
			// todo: change
			acceptedFiles: "image/*",
			url: "/",
			parallelUploads: 2,
			maxFilesize: 3,
			filesizeBase: 1000,
			addedfile: function (file: any) {
				// todo: remove
				// if (file.type != "audio/mp3") { return; }
				let fileSize = file.upload.total;
				let fileName = file.upload.filename;
				let mimeType = file.type;
				var reader = new FileReader();
				reader.onload = function (event: any) {
					let fileContent = event.target.result;
					let notesEntity = new AttachedFile("", fileName, mimeType, fileContent, fileSize);
					thisRef.addAttachments(notesEntity);
				};
				reader.readAsDataURL(file);
			},
			dictDefaultMessage: ''
		});
	}

	private onLoadAddAudio() {
		this.getAttachments(this.entityReference);
	}

	addImgControl(imgFile: AttachedFile) {
		this._imgElement = document.createElement("img");
		this._imgElement.id = "img_" + imgFile.annotationId;
		this._imgElement.src = imgFile.fileContent;

		this._deleteImgElement = document.createElement("img");
		this._deleteImgElement.src = "https://cdn1.iconfinder.com/data/icons/travel-pack-filled-outlines-1/75/TRASH-512.png";
		this._deleteImgElement.setAttribute("class", "imgDelete");
		var _divImgContainer = document.createElement("div");
		_divImgContainer.id = "imgContainer";
		this._deleteImgElement.addEventListener("click", this.deleteImage.bind(this, "imgContainer", imgFile.annotationId));
		
		_divImgContainer.appendChild(this._imgElement);
		_divImgContainer.appendChild(this._deleteImgElement);
		_divImgContainer.appendChild(this._brElement.cloneNode());
		this.toggleShowUploadBtn();
		this._divMain.appendChild(_divImgContainer);
	}

	private generateSrcUrl(datatype: string, fileType: string, fileContent: string): string {
		return "data:" + datatype + "/" + fileType + ";base64, " + fileContent;
	}

	private uploadImgonClick() {
		this._formDropZone.click();
	}

	private deleteImage(value: string, id: string) {
		this._context.webAPI.deleteRecord("annotation", id).then((resp) => {
			toastr.error("Removed image file");
			let _deleteImgElement: any = document.getElementById(value);
			_deleteImgElement.remove();
			this.toggleShowUploadBtn();
		}).catch((err) => {
			console.log(err);
		});
	}

	private toggleShowUploadBtn() {
		this._divDropZone.style.display = this._divDropZone.style.display == "none" ? null : "none";
		this._imgUploadBtn.style.visibility = this._imgUploadBtn.style.visibility === "hidden" ? null : "hidden";
	}

	private async getAttachments(ref: EntityReference): Promise<AttachedFile[]> {

		let attachmentType = ref.typeName == "email" ? "activitymimeattachment" : "annotation";

		let fetchXml =
			"<fetch>" +
			"  <entity name='" + attachmentType + "'>" +
			"    <filter>" +
			"      <condition attribute='objectid' operator='eq' value='" + ref.id + "'/>" +
			"    </filter>" +
			"  </entity>" +
			"</fetch>";

		let query = '?fetchXml=' + encodeURIComponent(fetchXml);

		try {
			const result = await this._context.webAPI.retrieveMultipleRecords(attachmentType, query);
			let items: any[] = [];
			for (let i = 0; i < result.entities.length; i++) {
				let record = result.entities[i];
				let mimeType = <string>record["mimetype"];
				if (mimeType.includes("image")) {
					let annotationId = <string>record["annotationid"];
					let fileName = <string>record["filename"];
					let content = <string>record["body"] || <string>record["documentbody"];
					let fileSize = <number>record["filesize"];
					let file = new AttachedFile(annotationId, fileName, mimeType, content, fileSize);
				items.push(file);
				// todo: figure this out
					let imgToSrcUrl = this.generateSrcUrl(mimeType.split('/')[0], mimeType.split('/')[1], file.fileContent);
					file.fileContent = imgToSrcUrl;
					this.addImgControl(file);
				}
			}
			return items;
		}
		catch (error) {
			console.log(error);
			return [];
		}
	}

	private addAttachments(file: AttachedFile): void {
		var notesEntity: any = {}

		var fileContent = file.fileContent.replace("data:image/png;base64,", "");
		if (fileContent != null || "" || undefined && file.fileName != null || "" || undefined) {
			notesEntity["documentbody"] = fileContent;
			notesEntity["filename"] = file.fileName;
			notesEntity["filesize"] = file.fileSize;
			notesEntity["mimetype"] = file.mimeType;
		}
		notesEntity["subject"] = file.fileName.replace(".png", "");
		notesEntity["notetext"] = "Audio Attachment";
		notesEntity["objecttypecode"] = this.entityReference.typeName;
		notesEntity[`objectid_${this.entityReference.typeName}@odata.bind`] = `/${this.CollectionNameFromLogicalName(this.entityReference.typeName)}(${this.entityReference.id})`;
		let thisRef = this;

		// Invoke the Web API to creat the new record
		this._context.webAPI.createRecord("annotation", notesEntity).then
			(
				function (response: ComponentFramework.EntityReference) {
					// Get the ID of the new record created
					notesEntity["annotationId"] = response.id;
					notesEntity["fileContent"] = file.fileContent;
					notesEntity["fileName"] = notesEntity["filename"];
					toastr.success("uploaded audio file successfully");
					thisRef.addImgControl(notesEntity);
				},
				function (errorResponse: any) {
					// Error handling code here - record failed to be created
					console.log(errorResponse);
					toastr.error("unable to uploaded audio file");
				}
			);
	}

	private CollectionNameFromLogicalName(entityLogicalName: string): string {
		if (entityLogicalName[entityLogicalName.length - 1] != 's') {
			return `${entityLogicalName}s`;
		} else {
			return `${entityLogicalName}es`;
		}
	}

	/**
	 * Called when any value in the property bag has changed. This includes field values, data-sets, global values such as container height and width, offline status, control metadata values such as label, visible, etc.
	 * @param context The entire property bag available to control via Context Object; It contains values as set up by the customizer mapped to names defined in the manifest, as well as utility functions
	 */
	public updateView(context: ComponentFramework.Context<IInputs>): void {
		// Add code to update control view
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