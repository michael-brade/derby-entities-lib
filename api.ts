import _ from 'lodash';
import { type ChildModel, type RootModel } from 'racer';

import { SupportedTypeComponent, supportedTypeComponents } from './types';


export default {

    //// Init the EntitiesApi for the given model.
    //
    // Only needs to be called once per model.
    init<T>(model: ChildModel<T>, entities: EntitiesJson[]): void {
        model.root.setNull('$entities.api', new EntitiesApiImpl<T>(model, entities));
    },

    //// Singleton instance getter.
    //
    //
    // export individually to avoid issues with circular dependencies and browserify exports
    // because this way exports the function first, then creates the EntitiesApi class,
    // requiring the circle:  this -> ./types/entity -> this
    instance(model: ChildModel): EntitiesApi {
        return model.root.get('$entities.api') || (() => {
            throw new Error("No instance: EntitiesApi has not been initialized for the given model yet!");
        })();
    }

}


export type AttrDefinition = {
    id: string;             // if type is an entity, the primary attribute-id *has* to be "name"
    type: string;           // entity, text, etc. (see types/*); default: text

    i18n?: boolean;

    entity?: string;        // only if type == entity: "bijas", "bhutas", ...
    multi?: boolean;
    uniq?: boolean;         // same element several times -- default is true
    reference?: boolean;    // just store a reference vs. copying the whole object
}

export class DisplayDefinition {
    constructor(
        public readonly attribute: string,    // default "name"
        public readonly layout: string,       // default "vertical", ... TODO, define possibilities
        public readonly decorate: string[]
    ) {}
}

export type EntityDefinition = {
    id: string;
    display: DisplayDefinition;
    attributes: {
        // attribute.id -> AttrDefinition
        [key: string]: AttrDefinition
    };
}

export type Entities = {
    // entity.id -> EntityDefinition
    [key: string]: EntityDefinition
}


export type EntityJson = {
    id: string;
    display?: Partial<DisplayDefinition>;
    attributes: AttrDefinition[];
}

export interface EntitiesApi {
    entitiesIdx: Entities;

    addType(type: SupportedTypeComponent): void

    item(itemId: string, entityId: string): any
    items(entityId: string): any[]

    render(item: any, entityId_or_attr: string | AttrDefinition, parent?: HTMLElement): string
    renderAsText(item: any, entityId_or_attr: string | AttrDefinition): string
}



// A class to accesss entities and items.
//
// the singleton class
class EntitiesApiImpl<T> implements EntitiesApi {

    public model: RootModel;
    public entitiesIdx: Entities;

    // Type/Component
    private types: { [key: string]: any };

    constructor(model: ChildModel<T>, entities: EntityJson[]) {
        // init API and index entities
        this.model = model.root;

        this.entitiesIdx = {};

        entities.forEach((entity) => {
            // set defaults
            let display = new DisplayDefinition(
                entity.display?.attribute || 'name',
                entity.display?.layout || 'vertical',
                entity.display?.decorate || []
            )

            let attributes: { [index: string]: AttrDefinition } = {}

            entity.attributes.forEach((attr) => {
                attr.type = attr.type || "text";
                attributes[attr.id] = attr;
            });

            this.entitiesIdx[entity.id] = {
                id: entity.id,
                display: display,
                attributes: attributes
            }
        });

        // this.entities = entities;

        this.types = {};
        supportedTypeComponents.forEach((type) => {
            this.addType(type);
        });
    }

    // do not serialize the API
    toJSON(): any {
        return undefined;
    }

    // plugin method to add a new or overwrite an existing type
    // The type object needs to be either a LiveScript class object or
    // define a name attribute and inherit from Type.
    //
    // TODO: need to add this as a component to derby as well -- pass Derby app to CTOR?
    addType(type: SupportedTypeComponent): void {
        if (type.displayName)
            this.types[type.displayName.toLowerCase()] = new type(this);
        else
            this.types[type.name.toLowerCase()] = new type(this);
    }

    // create array of queries for this entity as well as all dependent entites
    static queryDependentEntities(model: ChildModel, entity: EntityDefinition): any[] {
        return _.reduce(entity.attributes, (queries: any[], attr: AttrDefinition) => {
            if (attr.type === 'entity')
                queries.push(model.query(attr.entity, {}));

            return queries;
        }, [model.query(entity.id, {})]);
    }

    // create array of queries for all entities referencing the given entity
    queryReferencingEntities(entityId: string): any[] {
        const entities: string[] = [];
        for (const entity of Object.values(this.entitiesIdx)) {
            for (const attr of Object.values(entity.attributes)) {
                if (attr.type === 'entity' && attr.entity === entityId && attr.reference) {
                    entities.push(entity.id);
                }
            }
        }
        return _.map(_.uniq(entities), (entityId: string) => {
            return this.model.query(entityId, {});
        });
    }

    // find the indexed entity with the given id
    entity(entityId: string): EntityDefinition {
        return this.entitiesIdx[entityId];
    }

    // get all items of the given entity, return an array
    items(entityId: string): any[] {
        return this.model.at(entityId).filter(null).get();
    }

    // Find the item of the given entity (or any entity if not) with the given ID. Needed to resolve references.
    item(itemId: string, entityId: string): any {
        if (!entityId) {
            throw new Error('API::item(itemId): not implemented yet, entityId needs to be provided!');
        }
        const item = this.model.at(entityId).get(itemId);
        if (!item) {
            console.error(this.model.get(entityId));
            console.error(`${entityId}: no item with id ${itemId}!`);
        }
        return item;
    }

    // check if this itemId is used/referenced by another item
    //   return: list of items that reference the given id, or null if the itemId is unused
    itemReferences(itemId: string, entityId: string): any {
        return this.types.entity.itemReferences(itemId, entityId);
    }

    // render
    //  - an item according to its "display" property if the second argument is an entityId
    //  - an attribute of an item if the second argument is an attribute object
    //
    // render returns an html fragment to display this type.
    // parent is the dom parent (optional, could be used by a type plugin)
    render(item: any, entityId_or_attr: string | AttrDefinition, parent?: HTMLElement): string {
        if (!item) {
            console.error(`null item in API.render! entityId_or_attr: ${entityId_or_attr}`);
            return "";
        }

        let attr: AttrDefinition
        let entity: EntityDefinition | undefined

        if (typeof entityId_or_attr === "string") {
            entity = this.entity(entityId_or_attr);
            attr = entity.attributes[entity.display.attribute];
        } else if (typeof entityId_or_attr === "object")
            attr = entityId_or_attr;
        else
            throw new Error(`render: wrong type of second argument: ${entityId_or_attr}`);


        if (!this.types[attr.type])
            throw new Error(`render: entity type ${attr.type} is not supported!`);


        let locale = this.model.get<string>("$locale.locale");
        let renderedAttr: string = this.types[attr.type].renderAttribute(item, attr, locale, parent);

        // TODO: is this the right place for this code?
        // Each type should have a decorate method that decorates a given string/html fragment
        // with that attribute's content
        if (entity?.display.decorate[0] === 'color') {
            // itemRendered = "<span style='background-color:#{subitem.color};padding:2px 0px'>#{itemRendered}</span>"
            return `<span class='color' style='background-color:${item.color}'></span><span>${renderedAttr}</span>`;
        } else if (entity?.display.decorate[0] === 'image') {
            // CSS for image select2 results should be:
            // .select2-container--bootstrap .select2-results__option {
            //     display: inline-block;
            // }

            // TODO: need to think about which is the right order:
            // - put decorated text in the caption (currently done), or
            // - put decoration for an image in the caption
            return `<div class='thumbnail'><img class='imgPreview' style='height:100px' src='${item.image}'><div class='caption'>${renderedAttr}</div></div>`;
        } else {
            return renderedAttr;
        }
    }

    // render an item or an attribute of an item as plain text. See render() for argument explanation.
    renderAsText(item: any, entityId_or_attr: string | AttrDefinition): string {
        let entity: any, attr: any, renderedAttr: string;
        if (!item) {
            console.error(`null item in API.renderAsText! entityId_or_attr: ${entityId_or_attr}`);
            return "";
        }
        if (typeof entityId_or_attr === "string") {         // entityId given
            entity = this.entity(entityId_or_attr);
            attr = entity.attributes[entity.display.attribute];
        } else if (typeof entityId_or_attr === "object") {  // attr given
            attr = entityId_or_attr;
        } else {
            throw new Error(`renderAsText: wrong type of second argument: ${entityId_or_attr}`);
        }

        if (!this.types[attr.type])
            throw new Error(`renderAsText: entity type ${attr.type} is not supported!`);

        let locale = this.model.get("$locale.locale");
        return renderedAttr = this.types[attr.type].attribute(item, attr, locale);
        // TODO: decoration needs to be applied
    }

    getValidator(attr: any, entityId: string, locale?: string): ((id: string, value: any) => boolean) | undefined {
        let validatorFn: ((id: string, value: any, attr: any, entityId: string, locale?: string) => boolean) | null = null;
        if (attr.id === 'name') {
            validatorFn = uniqValidator;
        }
        if (!validatorFn) {
            return;
        }
        return (id: string, value: any): boolean => {
            return validatorFn.call(this, id, value, attr, entityId, locale);
        };
    }
}

const uniqValidator = function(id: string, value: any, attr: any, entityId: string, locale?: string): boolean {
    let path: string = attr.id;
    if (locale) {
        path += `.${locale}`;
    }
    if (!value) {
        return true;
    }
    return !_.find(this.items(entityId), (item: any) => {
        return item.id !== id && _.isEqual(_.get(item, path), value, (a: any, b: any) => {
            if (_.isString(a) && _.isString(b)) {
                return a.toUpperCase().trim() === b.toUpperCase().trim();
            }
        });
    });
};

const stringValidator = function(id: string, value: any, attr: any, entityId: string, locale?: string): boolean {
    return true;
};