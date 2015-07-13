require! {
    'lodash': _
}

# A class to accesss entities and items.
export class Entities

    model: null
    entities: null
    entitiesIdx: null

    # This CTOR loads all given entities into the model.
    (model, entities) ->
        @model = model
        @entities = entities
        @entitiesIdx = _.indexBy _.clone(entities, true), (entity) ->
            entity.attributes = _.indexBy(entity.attributes, 'id')  # because of this we need deep _.clone()
            return entity.id

        # ret = @model.evaluate('path arg 1', 'path arg 2', 'fnname')
        #   can only use model paths as arguments!
        #@model.fn 'getItems', @getItems         # "this" cannot be bound here....
        #@model.fn 'getItemName', @getItemName


    get: ->
        @entities

    getIdx: ->
        @entitiesIdx

    # get all items of the given entity, return an array
    getItems: (entityId) ->
        @model.root.at(entityId).filter(null).get!


    # Find the item of the given entity (or any entity if not) with the given ID. Needed to resolve references.
    getItem: (itemId, entityId) ->
        if not entityId
            throw Error 'unimplemented'
        else
            return @model.root.at(entityId).get(itemId)


    # find the indexed entity with the given id
    getEntity: (entityId) ->
        @entitiesIdx[entityId]

    # return the attribute of the given item as string
    getItemAttr: (item, attrId, entityId, locale = 'en') ->
        #entity = _.find(@entities, (entity) -> entity.id == entityId)
        #entity = @itemMap.get(item.id).entity

        attr = @getEntity(entityId).attributes[attrId]

        if attr.type == 'entity'
            result = ""
            for subitem in item[attrId]        # if attr.multi, only then item[attrId] is an array
                if attr.reference
                    subitem = @getItem subitem, attr.entity

                result += @getItemAttr subitem, 'name', attr.entity, locale

            return result + '\n' # TODO: maybe return a list of lines?
        else if attr.i18n
            return (item[attrId])[locale] + ' '
        else
            return item[attrId] + ' '
