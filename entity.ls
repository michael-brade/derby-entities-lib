
export class Entity


    getItemName: (item) ->
        #entity = _.find(@entities, (entity) -> entity.id == entityId)
        entity = @itemMap.get(item.id).entity
        if entity.type == 'entity'
            if entity.attributes.name.i18n
            else
        else if entity.i18n
            # TODO locale: item.name[l(@model.get($locale))]
            return item.name.en
        else
            return item.name


    # get all items of the given entity, return an array
    getItems: (entityId) ->
        @model.root.at(entityId).filter(null).get!
