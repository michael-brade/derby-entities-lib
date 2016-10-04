require! {
    '../api': Api
    './type': { Type }
}

_ = {
    map: require('lodash/map')
    uniq: require('lodash/uniq')
    forEach: require('lodash/forEach')
    includes: require('lodash/includes')
}

export class Entity extends Type

    # private static

    # public
    components:
        require('derby-select2/core').Select2
        ...

    init: (model) ->
        super ...

        api = Api.instance(model)

        attr = @attr
        entity = api.entity @attr.entity

        # select2 configuration, available in the templates under "options"
        model.set "select2conf",
            theme: "bootstrap"

            multiple: attr.multi
            duplicates: attr.multi && attr.uniq == false # duplicate selections possible - makes only sense with multiple

            normalizer:
                if attr.reference
                then
                    (item) -> {
                        item: item
                        id: item
                        title: ""
                        # if item is a reference, it needs to be resolved for renderAsText()
                        text: api.renderAsText(api.item(item, attr.entity), attr.entity)
                    }
                else
                    (item) -> {
                        item: item
                        id: item.id
                        title: ""
                        text: api.renderAsText(item, attr.entity)
                    }

            resultsTemplate: "entity:-edit-select2"
            selectionTemplate:  "entity:-edit-select2"

            # used by -edit-select2 view/template
            templateArgs:
                entity: attr.entity



    # after calling this, pathFrom will be a reference to the given item attribute
    # pathFrom is a model path
    setupRef: (pathFrom) !->
        super ...

        # all items of this entity under "items" - as array of ids or full items
        if @attr.reference
            @model.ref "itemsResolved", @model.root.at(@attr.entity)
            @model.start "items", "itemsResolved", (items) ->
                _.map items, (item) -> item.id
        else
            @model.ref "items", @model.root.at(@attr.entity).filter()


        # after super, pathFrom is already a reference to the subitems,
        # which now also have to be dereferenced

        subitems = pathFrom

        if @attr.multi
            if @attr.reference
                # subitems contains array of references -> resolve them
                @model.refList "subitems", "itemsResolved", subitems
            else
                # subitems contains array of items -> use that
                @model.ref "subitems", subitems
        else
            # subitems consists of either a single reference or a single item
            # -> put it in an array with only one element
            @model.ref "_subitem.0", subitems

            if @attr.reference
                #  resolve item reference
                @model.refList "subitems", "itemsResolved", "_subitem"
            else
                # use item directly
                @model.ref "subitems", "_subitem"



    # get the plain text of the attr(ibute) of the given item
    attributeData: (data, attr, locale) ->
        return '\n' if not data

        # if the name of an entity is made up of other entities, don't put a comma in there
        separator = if attr.id == 'name' then " " else ", "
        result = ""

        if not attr.multi
            data = [data]

        for subitem in data
            if attr.reference
                subitem = @api.item subitem, attr.entity

            result += @api.renderAsText subitem, attr.entity, locale
            result += separator

        # remove the last separator
        return result.slice(0, -separator.length)


    # render the attribute attr of item
    renderAttributeData: (data, attr, locale, parent) ->
        return '\n' if not data

        # if the name of an entity is made up of other entities, don't put a comma in there
        separator = if attr.id == 'name' then " " else ", "
        result = ""

        if not attr.multi
            data = [data]

        for subitem in data
            if attr.reference
                subitem = @api.item subitem, attr.entity

            result += @api.render subitem, attr.entity, locale, parent
            result += separator

        return result.slice(0, -separator.length)

    # TODO: probably need a  _render: (item, attr, locale, parent, escape) method to share code above



    # check if this itemId is used/referenced by another item
    #   return: list of items that reference the given id, or null if the itemId is unused
    itemReferences: (itemId, entityId) ->
        references = []
        # go through all entities and their attributes and check those that match entityId
        for , entity of @api.entitiesIdx
            for , attr of entity.attributes
                # does the current entity have an attribute that references entityId?
                if attr.type == 'entity' and attr.entity == entityId and attr.reference
                    # then go through all of its items and check if itemId is in it
                    _.forEach @api.items(entity.id), (referencingItem) ~>
                        elem = referencingItem[attr.id]
                        if (elem == itemId) or (typeof! elem == 'Array' and _.includes(elem, itemId))
                            references.push {
                                "entity": entity
                                "item": referencingItem
                            }

        return null if references.length == 0
        return _.uniq references, (ref) -> ref.entity.id + "--" + ref.item.id
