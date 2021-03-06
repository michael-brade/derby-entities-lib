'use strict'

require! {
    path
    'lodash': _
    './types': { supportedTypeComponents }
}



## Init the EntitiesApi for the given model.
#
# Only needs to be called once per model.
export init = (model, entities) ->
    model.root.setNull '$entities.api', new EntitiesApi(model, entities)


## Singleton instance getter.
#
#
# export individually to avoid issues with circular dependencies and browserify exports
# because this way exports the function first, then creates the EntitiesApi class,
# requiring the circle:  this -> ./types/entity -> this
export instance = (model) ->
    model.root.get('$entities.api') || throw new Error "No instance: EntitiesApi has not been initialized for the given model yet!"


# A class to accesss entities and items.
#
# the singleton class
class EntitiesApi

    # public
    model: null
    entities: null
    entitiesIdx: null

    # CTOR
    (model, entities) ->
        # set display defaults for all entities
        entities.forEach (entity) ->
            entity.display ?= {}
            entity.display.attribute ?= 'name'
            entity.display.layout ?= 'vertical' # TODO: implement, document
            entity.display.decorate ?= []

            entity.attributes.forEach (attr) ->
                attr.type ?= "text"


        # init API and index entities
        @model = model.root
        @entities = entities
        @entitiesIdx = _.keyBy _.cloneDeep(entities), (entity) ->
            entity.attributes = _.keyBy(entity.attributes, 'id')  # because of this we need deep _.clone()
            return entity.id


        # add (and instantiate) type classes
        @types = {}
        supportedTypeComponents.forEach (type) ~> @addType type


    # do not serialize the API
    toJSON: -> undefined

    # plugin method to add a new or overwrite an existing type
    # The type object needs to be either a LiveScript class object or
    # define a name attribute and inherit from Type.
    #
    # TODO: need to add this as a component to derby as well -- pass Derby app to CTOR?
    addType: (type) !->
        if type.displayName
            @types[type.displayName.toLowerCase!] = new type(this)
        else
            @types[type.name.toLowerCase!] = new type(this)



    # static: create array of queries for this entity as well as all dependent entites
    export @queryDependentEntities = (model, entity) ->
        _.reduce entity.attributes, (queries, attr) ->
            if attr.type == 'entity'
                queries.push model.query(attr.entity, {})
            return queries
        , [model.query(entity.id, {})]


    # create array of queries for all entities referencing the given entity
    queryReferencingEntities: (entityId) ->
        entities = []
        for , entity of @entitiesIdx
            for , attr of entity.attributes
                if attr.type == 'entity' and attr.entity == entityId and attr.reference
                    entities.push entity.id

        _.map _.uniq(entities), (entityId) ~> @model.query(entityId, {})


    # find the indexed entity with the given id
    entity: (entityId) ->
        @entitiesIdx[entityId]

    # get all items of the given entity, return an array
    items: (entityId) ->
        @model.at(entityId).filter(null).get!


    # Find the item of the given entity (or any entity if not) with the given ID. Needed to resolve references.
    item: (itemId, entityId) ->
        if not entityId
            throw new Error 'API::item(itemId): not implemented yet, entityId needs to be provided!'

        item = @model.at(entityId).get(itemId)
        if not item
            console.error @model.get(entityId)
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
    # parent is the dom parent (optional, could be used by a type plugin)
    render: (item, entityId_or_attr, parent) ->
        if not item
            console.error "null item in API.render! entityId_or_attr: #{entityId_or_attr}"
            return ""

        if typeof entityId_or_attr == "string" # entityId given
            entity = @entity entityId_or_attr
            attr = entity.attributes[entity.display.attribute]
        else if typeof entityId_or_attr == "object" # attr given
            attr = entityId_or_attr
        else
            throw new Error "render: wrong type of second argument: #{entityId_or_attr}"

        if not @types[attr.type]
            throw new Error "render: entity type #{attr.type} is not supported!"

        locale = @model.get("$locale.locale")
        renderedAttr = @types[attr.type].renderAttribute(item, attr, locale, parent)

        # TODO: is this the right place for this code?
        # Each type should have a decorate method that decorates a given string/html fragment
        # with that attribute's content
        if entity?.display.decorate[0] == 'color'
            # itemRendered = "<span style='background-color:#{subitem.color};padding:2px 0px'>#{itemRendered}</span>"
            "<span class='color' style='background-color:#{item.color}'></span><span>#{renderedAttr}</span>"
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


    # render an item or an attribute of an item as plain text. See render() for argument explanation.
    renderAsText: (item, entityId_or_attr) ->
        if not item
            console.error "null item in API.renderAsText! entityId_or_attr: #{entityId_or_attr}"
            return ""

        if typeof entityId_or_attr == "string" # entityId given
            entity = @entity entityId_or_attr
            attr = entity.attributes[entity.display.attribute]
        else if typeof entityId_or_attr == "object" # attr given
            attr = entityId_or_attr
        else
            throw new Error "renderAsText: wrong type of second argument: #{entityId_or_attr}"

        if not @types[attr.type]
            throw new Error "renderAsText: entity type #{attr.type} is not supported!"

        locale = @model.get("$locale.locale")

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
