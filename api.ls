require! {
    'lodash': _
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
            # set display defaults for all entities
            entities.forEach (entity) ->
                entity.display ?= {}
                entity.display.attribute ?= 'name'
                entity.display.layout ?= 'vertical' # TODO: implement, document
                entity.display.decorate ?= []

            # init API and index entities
            @model = model.root
            @entities = entities
            @entitiesIdx = _.indexBy _.clone(entities, true), (entity) ->
                entity.attributes = _.indexBy(entity.attributes, 'id')  # because of this we need deep _.clone()
                return entity.id

            # put self into the model for access
            model.root.set '$entities._0', this


        # do not serialize the API
        toJSON: -> undefined


        fetchAllEntities: (cb) !->
            queries = []
            @entities.forEach (entity) !~>
                queries.push @model.query(entity.id, {})

            @model.fetch queries, (err) !-> cb(err)


        # query this entity as well as all dependent entites
        queryDependentEntities: (model, entity) ->
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


        # find the indexed entity with the given id
        entity: (entityId) ->
            @entitiesIdx[entityId]

        # get all items of the given entity, return an array
        items: (entityId) ->
            @model.at(entityId).filter(null).get!


        # Find the item of the given entity (or any entity if not) with the given ID. Needed to resolve references.
        item: (itemId, entityId) ->
            if not entityId
                throw Error 'not implemented yet, entityId needs to be provided!'

            item = @model.at(entityId).get(itemId)
            if not item
                console.error "#{entityId}: no item with id #{itemId}!"

            return item


        # check if this itemId is used/referenced by another item
        #   return: list of items that reference the given id, or null if the itemId is unused
        itemReferences: (itemId, entityId) ->
            @types.entity.itemReferences itemId, entityId

        # render
        #  - an item according to its "display" property if the second argument is an entityId
        #  - an attribute of an item if the second argument is an attribute object
        #
        # render returns an html fragment to display this type.
        # locale as in [de, en, ...]
        # parent is the dom parent (optional, could be used by a type plugin)
        render: (item, entityId_or_attr, locale, parent) ->
            if not item
                console.error "null item in API.render! entityId_or_attr: #{entityId_or_attr}"
                return ""

            if typeof entityId_or_attr === "string" # entityId given
                entity = @entity entityId_or_attr
                attr = entity.attributes[entity.display.attribute]
            else if typeof entityId_or_attr === "object" # attr given
                attr = entityId_or_attr
            else
                throw Error "render: wrong type of second argument: #{entityId_or_attr}"

            if not @types[attr.type]
                throw Error "render: entity type #{attr.type} is not supported!"

            renderedAttr = @types[attr.type].renderAttribute(item, attr, locale, parent)

            # TODO: is this the right place for this code?
            # Each type should have a decorate method that decorates a given string/html fragment
            # with that attribute's content
            if entity?.display.decorate[0] == 'color'
                # itemRendered = "<span style='background-color:#{subitem.color};padding:2px 0px'>#{itemRendered}</span>"
                "<span style='background-color:#{item.color};width:16px;height:16px;display:inline-block;margin-right:5px;vertical-align:text-bottom'></span><span>#{renderedAttr}</span>"
            else if entity?.display.decorate[0] == 'image'
                # CSS for image select2 results should be:
                # .select2-container--bootstrap .select2-results__option {
                #     display: inline-block;
                # }

                # TODO: need to think about which is the right order:
                # - put decorated text in the caption (currently done), or
                # - put decoration for an image in the caption
                "<div class='thumbnail'><img class='imgPreview' style='height:100px' src='#{item.image}'><div class='caption'>#{renderedAttr}</div></div>"
            else
                renderedAttr


        # render an item or attribute as plain text. See render() for argument explanation.
        renderAsText: (item, entityId_or_attr, locale) ->
            if not item
                console.error "null item in API.renderAsText! entityId_or_attr: #{entityId_or_attr}"
                return ""

            if typeof entityId_or_attr === "string" # entityId given
                entity = @entity entityId_or_attr
                attr = entity.attributes[entity.display.attribute]
            else if typeof entityId_or_attr === "object" # attr given
                attr = entityId_or_attr
            else
                throw Error "renderAsText: wrong type of second argument: #{entityId_or_attr}"

            if not @types[attr.type]
                throw Error "renderAsText: entity type #{attr.type} is not supported!"

            renderedAttr = @types[attr.type].attribute(item, attr, locale)

            # TODO: decoration needs to be applied



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

            return !_.find @items(entityId), (item) ->
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
