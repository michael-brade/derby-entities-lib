require! {
    'lodash': _
}

# A class to accesss entities and items.
export class Entities

    model: null
    entities: null
    entitiesIdx: null

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


    # find the item of any entity with the given ID - needed for references
    getItem: (itemId) ->
        ...

    # find the indexed entity with the given id
    getEntity: (entityId) ->
        @entitiesIdx[entityId]

    getItemName: (item, entity, locale = 'en') ->
        #entity = _.find(@entities, (entity) -> entity.id == entityId)
        #entity = @itemMap.get(item.id).entity
        console.log "getIteme", arguments

        if entity.attributes.name.type == 'entity'
            subentityId = entity.attributes.name.entity
            name = ""
            for subitem in item.name
                name += @getItemName subitem, @getEntity(subentityId), locale
            return name + '\n' # TODO: maybe return a list of lines?
        else if entity.attributes.name.i18n
            return item.name[locale] + ' '
        else if not item.name
            console.warn "getItemName: item.name is undefined!!"
            return item
        else
            return item.name + ' '
