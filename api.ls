require! {
    'lodash': _
    path
}


class SingletonWrapper

    # private static
    _instance = null


    # public static

    ## Init the EntitiesApi singleton.
    #
    # Only needs to be called once.
    export @init = (model, entities) ->
        _instance ?:= new EntitiesApi(model, entities)


    ## Singleton instance getter.
    #
    #
    # export individually to avoid issues with circular dependencies and browserify exports
    # because this way exports the function first, then creates the EntitiesApi class,
    # requiring the circle:  this -> ./types/entity -> this
    export @instance = ->
        _instance || console.error "No instance: EntitiesApi has not been initialized yet!"


    # A class to accesss entities and items.
    #
    # the singleton class
    class EntitiesApi

        # public
        id: "_0"

        model: null
        entities: null
        entitiesIdx: null

        types: {
            text: new (require './types/text').Text()
            textarea: new (require './types/textarea').Textarea()
            number: new (require './types/number').Number()
            entity: new (require './types/entity').Entity()
            color: new (require './types/color').Color()
            image: new (require './types/image').Image()
        }


        # CTOR
        (model, entities) ->
            # server already put it in the model - cannot use that yet because types
            # are missing and __proto__ is Object instead of EntitiesApi
            #if model.root.get("$entities._0")
            #    return that

            @model = model.root
            @entities = entities
            @entitiesIdx = _.indexBy _.clone(entities, true), (entity) ->
                entity.attributes = _.indexBy(entity.attributes, 'id')  # because of this we need deep _.clone()
                return entity.id

            # put self into the model for access (TODO: really neccessary?)
            # this causes the circular structure: model -> entities -> model
            model.root.set '$entities._0', this

            # ret = @model.evaluate('path arg 1', 'path arg 2', 'fnname')
            #   can only use model paths as arguments!
            #@model.fn 'getItems', @getItems         # "this" cannot be bound here....
            #@model.fn 'getItemName', @getItemName


        # TODO: call it list
        get: ->
            @entities

        # TODO: call it map or indexed -- where is this needed at all??
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


        # query this entity as well as all dependent entites
        queryDependentEntities: (model, entity) ->
            console.log "models equal: ", model.root == @model

            _.reduce entity.attributes, (queries, attr) ~>
                if attr.type == 'entity'
                    queries.push model.query(attr.entity, {})
                return queries
            , [model.query(entity.id, {})]


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
            @model.at(entityId).filter(null).get!


        # Find the item of the given entity (or any entity if not) with the given ID. Needed to resolve references.
        # TODO: call it item
        getItem: (itemId, entityId) ->
            if not entityId
                throw Error 'unimplemented'

            item = @model.at(entityId).get(itemId)
            if not item
                console.error "#{entityId}: no item with id #{itemId}!"
            return item

        # render returns an html fragment to display this type.
        # locale as in [de, en, ...]
        # parent is the dom parent (optional, could be used by a type plugin)
        renderAttribute: (item, attr, locale, parent) ->
            if not @types[attr.type]
                console.error "Entity type #{attr.type} is not supported!"
                return

            if not item
                console.error "null item in API.renderAttribute! attr: #{attr}"
                return ""

            @types[attr.type].renderAttribute(item, attr, locale, parent)


        # check if this itemId is used/referenced by another item
        #   return: list of items that reference the given id, or null if the itemId is unused
        itemReferences: (itemId, entityId) ->
            @types.entity.itemReferences itemId, entityId



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
