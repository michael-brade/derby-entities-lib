import Api, { EntityDefinition, type AttrDefinition } from '../api';
import { Type } from './type';
import { PathLike, type ChildModel } from 'racer';
import { forEach, includes, uniqBy } from 'lodash';


interface EntityData {
}


export class Entity extends Type<EntityData> {

    // static view = {
    //     ...Entity.view,
    //     dependencies: [require('derby-select2/core').Select2]
    // };

    init(model: ChildModel<T>): void {
        const api: any = Api.instance(model);
        const attr = this.attr;
        // const entity = api.entity(this.attr.entity);

        model.set("select2conf", {
            theme: "bootstrap",
            multiple: attr.multi,
            duplicates: attr.multi && attr.uniq === false,
            normalizer: (item: any) => ({
                item: item,
                id: item.id,
                title: "",
                text: api.renderAsText(item, attr.entity)
            }),
            resultsTemplate: "entity:entity:edit-select2",
            selectionTemplate: "entity:entity:edit-select2",
            templateArgs: {
                attr: attr
            }
        });
    }

    setupRef(pathFrom: PathLike): void {
        const subitems: any = pathFrom;
        super.setupRef(pathFrom);
        this.model.ref("items", this.model.root.at(this.attr.entity).filter());

        if (this.attr.multi) {
            if (this.attr.reference) {
                this.model.refList("subitems", this.model.root.at(this.attr.entity), subitems);
            } else {
                this.model.ref("subitems", subitems);
            }
        } else {
            this.model.ref("_subitem.0", subitems);
            if (this.attr.reference) {
                this.model.refList("subitems", this.model.root.at(this.attr.entity), "_subitem");
            } else {
                this.model.ref("subitems", "_subitem");
            }
        }
    }

    attributeData(data: any, attr: AttrDefinition, locale: string): string {
        if (!data) {
            return '\n';
        }
        const separator: string = attr.id === 'name' ? " " : ", ";
        let result: string = "";

        if (!attr.multi) {
            data = [data];
        }

        for (let subitem of data) {
            if (attr.reference) {
                subitem = this.api.item(subitem, attr.entity);
            }
            result += this.api.renderAsText(subitem, attr.entity, locale);
            result += separator;
        }
        return result.slice(0, -separator.length);
    }

    renderAttributeData(data: any, attr: AttrDefinition, locale: string, parent?: HTMLElement): string {
        if (!data) {
            return '\n';
        }
        const separator: string = attr.id === 'name' ? " " : ", ";
        let result: string = "";

        if (!attr.multi)
            data = [data];


        for (let subitem of data) {
            if (attr.reference) {
                subitem = this.api.item(subitem, attr.entity);
            }
            result += this.api.render(subitem, attr.entity, locale, parent);
            result += separator;
        }
        return result.slice(0, -separator.length);
    }

    itemReferences(itemId: string, entityId: string): any[] | null {
        const references: {
            "entity": EntityDefinition,
            "item": any     // TODO
        }[] = [];

        for (const entity of Object.values(this.api.entitiesIdx)) {
            for (const attr of Object.values(entity.attributes)) {
                if (attr.type === 'entity' && attr.entity === entityId && attr.reference) {
                    forEach(this.api.items(entity.id), (referencingItem: any) => {
                        const elem: any = referencingItem[attr.id];
                        if (elem === itemId || (Array.isArray(elem) && includes(elem, itemId))) {
                            references.push({
                                "entity": entity,
                                "item": referencingItem
                            });
                        }
                    });
                }
            }
        }

        if (references.length === 0)
            return null;

        return uniqBy(references, (ref) => ref.entity.id + "--" + ref.item.id);
    }
}
