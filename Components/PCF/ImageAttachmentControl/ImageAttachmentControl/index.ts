import { IInputs, IOutputs } from "./generated/ManifestTypes";

import * as Dropzone from "dropzone";
import * as toastr from "toastr";

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
	private _imgSrc: string;
	private _notifyOutputChanged: () => void;
	private _context: ComponentFramework.Context<IInputs>;
	private _container: HTMLDivElement;

	private _divDropZone: HTMLDivElement;
	private _formDropZone: HTMLFormElement;
	private _imgUploadBtn: HTMLAnchorElement;

	private _divMain: HTMLDivElement;
	private _divImgContainer: HTMLDivElement;
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

		this._notifyOutputChanged = notifyOutputChanged;

		this._container = document.createElement("div");

		this._imgUploadBtn = document.createElement("a");
		this._imgUploadBtn.setAttribute("class", "btn");
		this._imgUploadBtn.innerHTML = "Upload";
		this._imgUploadBtn.addEventListener("click", this.uploadImgonClick.bind(this));

		var imgSizeLabel = document.createElement("p");
		imgSizeLabel.innerHTML = "Image size must be less than 768KB";

		this._divDropZone = document.createElement("div");
		this._divDropZone.id = "dropzone";

		this._formDropZone = document.createElement("form");
		this._formDropZone.id = "upload_dropzone";
		this._formDropZone.setAttribute("method", "post");

		this._formDropZone.appendChild(this._imgUploadBtn);
		this._formDropZone.appendChild(imgSizeLabel);
		this._formDropZone.setAttribute("class", "dropzone needsclick");
		this._divDropZone.appendChild(this._formDropZone);

		this._divMain = document.createElement("div");
		this._divImgContainer = document.createElement("div");

		this._container.appendChild(this._divDropZone);
		this._container.appendChild(this._divMain);
		container.appendChild(this._container);
		this._divMain.appendChild(this._divImgContainer);
		if (this._context.parameters.Image && this._context.parameters.Image.raw) {
			console.log(this._context.parameters.Image);
			this.addImgControl(this._context.parameters.Image.raw);
		}
		this.onload();

		toastr.options.closeButton = true;
		toastr.options.progressBar = true;
		toastr.options.positionClass = "toast-bottom-right";
	}

	private onload() {
		var thisRef = this;
		new Dropzone(this._formDropZone, {
			acceptedFiles: "image/*",
			url: "/",
			parallelUploads: 2,
			maxFilesize: 3,
			filesizeBase: 1000,
			addedfile: function (file: any) {
				let fileSize = file.upload.total;
				let fileName = file.upload.filename;
				let mimeType = file.type;
				var reader = new FileReader();
				reader.onload = function (event: any) {
					let fileContent = event.target.result;
					let imgFile = new AttachedFile("", fileName, mimeType, fileContent, fileSize);
					thisRef.addAttachments(imgFile);
				};
				reader.readAsDataURL(file);
			},
			dictDefaultMessage: ''
		});
	}

	addImgControl(imgSrc: string) {
		this._imgSrc = imgSrc;
		this._imgElement = document.createElement("img");
		this._imgElement.src = imgSrc;

		this._deleteImgElement = document.createElement("img");
		this._deleteImgElement.src = "https://cdn1.iconfinder.com/data/icons/travel-pack-filled-outlines-1/75/TRASH-512.png";
		this._deleteImgElement.setAttribute("class", "imgDelete");

		this._divImgContainer.id = "imgContainer";
		this._deleteImgElement.addEventListener("click", this.deleteImage.bind(this));

		this._divImgContainer.appendChild(this._imgElement);
		this._divImgContainer.appendChild(this._deleteImgElement);
		this.toggleShowUploadBtn();
		this._notifyOutputChanged();
	}

	private uploadImgonClick() {
		this._formDropZone.click();
	}

	private deleteImage() {
		this._imgSrc = '';
		this._imgElement.remove();
		this._deleteImgElement.remove();
		this.toggleShowUploadBtn();
		this._notifyOutputChanged();
	}

	private toggleShowUploadBtn() {
		this._divDropZone.style.display = this._divDropZone.style.display == "none" ? null : "none";
		this._imgUploadBtn.style.visibility = this._imgUploadBtn.style.visibility === "hidden" ? null : "hidden";
	}

	private addAttachments(file: AttachedFile): void {
		this.addImgControl(file.fileContent);
	}

	/**
	 * Called when any value in the property bag has changed. This includes field values, data-sets, global values such as container height and width, offline status, control metadata values such as label, visible, etc.
	 * @param context The entire property bag available to control via Context Object; It contains values as set up by the customizer mapped to names defined in the manifest, as well as utility functions
	 */
	public updateView(context: ComponentFramework.Context<IInputs>): void {
	}

	/** 
	 * It is called by the framework prior to a control receiving new data. 
	 * @returns an object based on nomenclature defined in manifest, expecting object[s] for property marked as “bound” or “output”
	 */
	public getOutputs(): IOutputs {
		return {
			Image: this._imgSrc
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