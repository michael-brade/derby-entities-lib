require! {
    'lodash': _
}

# A class to accesss entities and items.
#
# make it a singleton? call it Repository
export class Entities

    model: null
    entities: null
    entitiesIdx: null

    # This CTOR loads all given entities into the model.
    # TODO: Could add a third parameter "entity" for a current entity?
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

    instance: ->
        @

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

        item = @model.root.at(entityId).get(itemId)
        if not item
            console.warn "item with id #{itemId} not found!"
        return item


    # find the indexed entity with the given id
    getEntity: (entityId) ->
        @entitiesIdx[entityId]

    # return the attribute of the given item as string
    getItemAttr: (item, attrId, entityId, locale = 'en') ->
        return if not item
        
        attr = @getEntity(entityId).attributes[attrId]
        itemAttr = item[attrId]

        if attr.type == 'entity'
            return '\n' if not itemAttr

            result = ""

            if not attr.multi
                itemAttr = [itemAttr]

            for subitem in itemAttr
                if attr.reference
                    subitem = @getItem subitem, attr.entity

                result += @getItemAttr subitem, 'name', attr.entity, locale

            return result + '\n'
        else if !itemAttr || (attr.i18n && !itemAttr[locale])
            return ' '
        else if attr.i18n
            return itemAttr[locale] + ' '
        else
            return itemAttr + ' '
