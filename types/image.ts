import { ComponentViewDefinition } from 'derby';
import { Type } from './type';
import { AttrDefinition } from '../api';
import assert from 'assert';


interface ImageData {
}

export class Image extends Type<ImageData> {

    static view: ComponentViewDefinition = Object.assign({}, Image.view, {
        style: __dirname + "/image"
    });


    private reader!: FileReader;
    private imgInput!: HTMLInputElement;
    private imgPreview!: HTMLImageElement;


    create(): void {
        if (this.getAttribute('mode') !== 'edit')
            return;

        this.reader = new FileReader();
        this.reader.onloadend = () => {
            this.setData(this.reader.result);
        };
        this.imgInput.onchange = () => {
            const imgFile = this.imgInput.files ? this.imgInput.files[0] : undefined;
            if (imgFile)
                this.reader.readAsDataURL(imgFile);
            else
                this.removeImage();
        };
    }

    removeImage(): void {
        this.imgInput.value = "";
        this.setData(undefined);
    }

    setData(value: string | ArrayBuffer | null | undefined): void {
        assert(Object.prototype.toString.call(value) != '[object ArrayBuffer]')

        this.imgPreview.src = value as string | null | undefined || '';
        this.model.set("data", value);
    }

    renderAttributeData(data: string, attr: AttrDefinition, locale: string, parent?: HTMLElement): string {
        return `<img src='${data}' />`;
    }
}
