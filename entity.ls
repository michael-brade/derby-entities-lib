require! {
    'lodash': _
    path
}

# A class to accesss entities and items.
#
# make it a singleton? call it Repository
export class Entities

    # private static

    # public
    model: null
    entities: null
    entitiesIdx: null
    types: {
        text: require './types/text' .Text
        entity: require './types/entity' .Entity
        color: require './types/color' .Color
    }


    # CTOR
    (app, model, entities) ->
        @model = model
        @entities = entities
        @entitiesIdx = _.indexBy _.clone(entities, true), (entity) ->
            entity.attributes = _.indexBy(entity.attributes, 'id')  # because of this we need deep _.clone()
            return entity.id

        #@types = new Types(@app, this)

        for key, type of @types
            # load the type
            type = @types[key] = new type(this)

            # register view
            console.log path.join __dirname, 'types', type.view
            app.loadViews path.join __dirname, 'types', type.view


        console.log "CTOR Entities"

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

    # find the indexed entity with the given id
    # TODO: call it entity
    getEntity: (entityId) ->
        @entitiesIdx[entityId]

    fetchAllEntities: (cb) !->
        queries = []
        @entities.forEach (entity) !~>
            queries.push @model.query(entity.id, {})

        @model.fetch queries, (err) !-> cb(err)

    fetchAllReferencingEntities: (entityId, cb) !->
        entities = []
        for , entity of @entitiesIdx
            for , attr of entity.attributes
                if attr.type == 'entity' and attr.entity == entityId and attr.reference
                    entities.push entity.id

        queries = _.map _.uniq(entities), (entityId) ~> @model.query(entityId, {})
        @model.fetch queries, (err) !-> cb(err)


    # get all items of the given entity, return an array
    # TODO: call it items
    getItems: (entityId) ->
        @model.root.at(entityId).filter(null).get!


    # Find the item of the given entity (or any entity if not) with the given ID. Needed to resolve references.
    # TODO: call it item
    getItem: (itemId, entityId) ->
        if not entityId
            throw Error 'unimplemented'

        item = @model.root.at(entityId).get(itemId)
        if not item
            console.error "#{entityId}: no item with id #{itemId}!"
        return item

    # render returns an html fragment to display this type
    # locale != $locale!! (de, en)
    render: (data, attribute, locale) ->
        @types[attribute.type].render(data, attribute, locale)

    # render: (type, data, parent) ->
    #     types[type](data, parent)



    # check if this itemId is used/referenced by another item
    #   return: list of items that reference the given id, or null if the itemId is unused
    itemReferences: (itemId, entityId) ->
        references = []
        # go through all entities and their attributes and check those that match entityId
        for , entity of @entitiesIdx
            for , attr of entity.attributes
                # does the current entity have an attribute that references entityId?
                if attr.type == 'entity' and attr.entity == entityId and attr.reference
                    # then go through all of its items and check if itemId is in it
                    _.forEach @getItems(entity.id), (item) ~>
                        elem = item[attr.id]
                        if (elem == itemId) or (typeof! elem == 'Array' and _.includes(elem, itemId))
                            references.push {
                                "entity": entity.id
                                "item": @render item.name, entity.attributes.name, 'en' #,  TODO: $locale!!
                            }

        return null if references.length == 0
        return _.uniq references, (ref) -> ref.entity + "--" + ref.item




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
