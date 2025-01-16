import path from 'path';
import _escape from 'lodash/escape';

import { Component, ComponentViewDefinition, Context } from 'derby';
import { PathLike, type ChildModel } from 'racer';
import { type AttrDefinition, type EntitiesApi } from '../api';



// This component base class provides code needed and shared by all type components.
// It especially conceals boilerplate code for attribute and renderAttribute.
//
// TODO: I guess all this effort is only needed because of jQuery DataTables...
//       There is no need for renderAttribute otherwise, is there?
export abstract class Type<T extends object> extends Component<T>
{
    api: EntitiesApi;

    protected attr!: AttrDefinition;
    protected item!: ChildModel;
    protected loc!: string;

    constructor(api: EntitiesApi, context: Context, data: Record<string, unknown>) {
        super(context, data);
        this.api = api;
    }

    // return text
    attributeData?(data: any, attr: AttrDefinition, locale: string): string;

    // return html
    abstract renderAttributeData(data: any, attr: AttrDefinition, locale: string, parent?: HTMLElement): string;

    static view: ComponentViewDefinition = Object.assign({}, Type.view, {
        style: __dirname + "/color",
        is: subclass.name.toLowerCase(),
        file: path.join(__dirname, subclass.name.toLowerCase())
    });

    init(model: ChildModel<T>): void {
        model.ref('$locale', model.root.at('$locale'));
        this.attr = this.getAttribute('attr');
        this.item = model.at('item');
        this.loc = this.getAttribute<string>('loc');
        this.setupRef('data');
    }

    setupRef(pathFrom: PathLike): void {
        if (this.attr.i18n) {
            if (this.loc) {
                this.model.ref(pathFrom, this.item.at(this.attr.id).at(this.loc));
            } else {
                this.model.start(pathFrom, 'item', 'attr.id', '$locale.locale', {
                    copy: 'input'
                }, {
                    get: (item: any, attrId: string, loc: string) => {
                        return item != null ? (item[attrId] != null ? item[attrId][loc] : undefined) : undefined;
                    },
                    set: (value: any, item: any, attrId: string, loc: string) => {
                        item[attrId] == null && (item[attrId] = {});
                        item[attrId][loc] = value;
                        return [item];
                    }
                });
            }
        } else {
            this.model.ref(pathFrom, this.item.at(this.attr.id));
        }
    }

    attribute(item: any, attr: AttrDefinition, locale: string): string {
        const data = Type.attributeI18n((item[attr.id] != null ? item[attr.id] : ""), attr, locale);
        if (this.attributeData) {
            return this.attributeData(data, attr, locale);
        } else {
            return data;
        }
    }

    renderAttribute(item: any, attr: AttrDefinition, locale: string, parent?: HTMLElement): any {
        let data: any = Type.attributeI18n((item[attr.id] != null ? item[attr.id] : ""), attr, locale);
        if (typeof data === 'string') {
            data = _escape(data);
        }
        return this.renderAttributeData(data, attr, locale, parent);
    }

    static attributeI18n(data: any | string, attr: AttrDefinition, locale: string): string {
        if (!data || (attr.i18n && !data[locale])) {
            return "";
        }
        if (attr.i18n) {
            return data[locale];
        }
        return data;
    }
}