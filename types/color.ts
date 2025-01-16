import { ComponentViewDefinition } from 'derby';
import $ from 'jquery'

import { AttrDefinition } from '../api';
import { Type } from './type';


interface ColorProps {

}

export class Color extends Type<ColorProps> {

    static view: ComponentViewDefinition = Object.assign({}, Color.view, {
        style: __dirname + "/color"
    });

    renderAttributeData(data: string, attr: AttrDefinition, locale: string, parent?: HTMLElement): string {
        if (parent) {
            $(parent).css("background-color", data);
            return data;
        }
        return `<span class='color' style='background-color:${data}'></span><span>${data}</span>`;
    }

}
