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

    # check if this itemId is used/referenced by another item
    #   return: list of items that reference the given id, or null if the itemId is unused
    itemReferences: (itemId, entityId) ->
        references = []
        # go through all entities and their attributes and check those that match entityId
        for , entity of @entitiesIdx
            for , attr of entity.attributes
                if attr.type == 'entity' and attr.entity == entityId and attr.reference
                    _.forEach @getItems(entity.id), (item) ~>
                        elem = item[attr.id]
                        if (elem == itemId) or (typeof! elem == 'Array' and _.includes(elem, itemId))
                            references.push {
                                "entity": entity.id
                                "item": @getItemAttr(item, 'name', entity.id)
                            }

        if references.length == 0
            return null

        return references


    # find the indexed entity with the given id
    getEntity: (entityId) ->
        @entitiesIdx[entityId]

    # return the attribute of the given item as string
    getItemAttr: (item, attrId, entityId, locale = 'en') ->
        return "" if not item

        attr = @getEntity(entityId).attributes[attrId]
        itemAttr = item[attrId]

        if attr.type == 'entity'
            return '\n' if not itemAttr

            # if the name of an entity is made up of other entities, don't put a comma in there
            separator = if attrId == 'name' then " " else ", "
            result = ""

            if not attr.multi
                itemAttr = [itemAttr]

            for subitem in itemAttr
                if attr.reference
                    subitem = @getItem subitem, attr.entity

                result += @getItemAttr subitem, 'name', attr.entity, locale
                result += separator

            return result.slice(0, -separator.length) + '\n'
        else if !itemAttr || (attr.i18n && !itemAttr[locale])
            return ""
        else if attr.i18n
            return itemAttr[locale]
        else
            return itemAttr


    ### VALIDATION

    # TODO: make it a class hierarchy: Validator::validate/accept as interface, other validators inherit it

    # arguments:
    #   id:         item id
    #   value:      value of the attribute to validate
    #   entityId:   entity id
    #   locale:     if the attribute has i18n, the locale to verify
    # return:
    #   true if the validation is ok
    uniqValidator = (id, value, attr, entityId, locale) ->
        path = attr.id
        path += "." + locale if locale

        return true if not value    # TODO: only if required field?

        return !_.find @getItems(entityId), (item) ->
            item.id != id && _.isEqual(_.get(item, path), value, (a, b) -> if _.isString(a) && _.isString(b) then a.toUpperCase().trim() == b.toUpperCase().trim())


    stringValidator = (id, value, attr, entityId, locale) ->
        return true


    # return the validator function for the attribute of an entity
    getValidator: (attr, entityId, locale) ->
        validatorFn = null
        _this = this

        if attr.id == 'name'
            validatorFn = uniqValidator

        return if not validatorFn

        (id, value) -> validatorFn.call _this, id, value, attr, entityId, locale
