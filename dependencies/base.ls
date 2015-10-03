require! {
    'lodash': _
    '../api': EntitiesApi
}

# Numbers: there are T entity types and E(type) entity items for each type.
#
# Algorithm:
#   - each of the entity types gets a number iT, from 0 to T-1. Order is determined by entities.ls
#   - each of the items of each entity type gets a number iE(type), from 0 to E(type)-1
#
# The outer loop is over the entity types, order of increasing iT.
# The inner loop collects all items for that entity type and then determines all dependencies for each item.
#
#  for t as nextEntityType
#
# TODO: make those reactive model functions
#    prepend all model paths with _entityDependencies.* and/or _entityDependencies.matrix.*
#
export class EntityDependencies

    model: null # I don't actually need the model in here....?!
    api: null
    itemMap: null
    ranges: null
    rangeCur: 0

    # CTOR
    (model) ->
        if (@constructor == EntityDependencies)
             throw new Error("Can't instantiate abstract class!");

        @model = model
        @api = EntitiesApi.instance!

        # entityId -> range object
        @ranges = new Map()

        # itemId -> entityId
        @itemMap = new Map()

    init: ->
        # for each entity... (@entities is an array)
        for let key, entity of @api.entitiesIdx
            items = @api.items(entity.id)

            @addRange entity.id, items.length  # entity.id is the name like "bijas"

            # # before we can use getItems, they need to be loaded
            # entity.attributes.forEach (attr) ~>
            #     if (attr.type == 'entity')
            #         @model.query(attr.entity, {}).subscribe (err) ->
            #             return next err if err


            # ...go through all its items
            for let item in items
                @addItem entity, item

                # ...and find their dependencies
                for let attrId, attr of entity.attributes
                    for let id in @allDependencyIds(item, attr)
                        @addDependency item.id, id

    # adds a dependency to the matrix
    addDependency: (sourceId, dependencyId) ->
        throw new Error("addDependency must be implemented in subclasses!")

    # get the final data
    data: ->
        throw new Error("data must be implemented in subclasses!")

    addItem: (entity, item) ->
        # store which entity this item id belongs to
        @itemMap.set item.id, {
            entity: entity
            item: item
            # TODO: could add itemName right here!? more efficient, with all i18ns?
        }

    # store the range for each entity
    addRange: (entityId, count) !->
        # console.log "range for #{entityId} is #{@rangeCur} - #{@rangeCur + count}"
        @ranges.set entityId, { from: @rangeCur, to: @rangeCur + count }
        @rangeCur += count


    # # find the item of any entity with the given ID
    # getItem: (itemId) ->
    #     ...


    # get all dependency ids for this item
    allDependencyIds: (item, attr) ->
        ids = []

        if attr.type != 'entity' or not item[attr.id]
            return ids

        for let dep in item[attr.id]
            if attr.reference
                ids.push dep
            else
                ids.push dep.id

        return ids
