require! {
    '../api': Api
    './type': { Type }
    'derby-entity-select2/select2/data/model': ModelAdapter
}

_ = {
    uniq: require('lodash/array/uniq')
    forEach: require('lodash/collection/forEach')
    includes: require('lodash/collection/includes')
}

export class Entity extends Type

    # private static

    # public
    components:
        require('derby-entity-select2/select2/core')
        ...

    init: (model) ->
        super ...

        attr = @attr
        entity = Api.instance!.entity @attr.entity

        # select2 configuration, available in the templates under "options"
        @model.set "select2conf",
            theme: "bootstrap"

            multiple: @attr.multi

            sorter: (a, b) ->
                displayAttrId = entity.display.attribute
                a[displayAttrId].localeCompare(b[displayAttrId])

            dataAdapter: class EntityAdapter extends ModelAdapter
                # params.data is the item that was selected
                select: (params) ->
                    if attr.reference
                        params.data = params.data.id

                    super params


            #selectionAdapter: if attr.multi then 'multiple' else 'single'

            resultsTemplate: "entity:-edit-select2"
            selectionTemplate:  "entity:-edit-select2"

            # used by -edit-select2 view/template
            templateArgs:
                entity: attr.entity



    # after calling this, modelFrom will be a reference to the given item attribute
    setupRef: (modelFrom) ->
        super ...

        # all items of this entity
        @model.ref("items", @model.root.at(@attr.entity))

        # after super, modelFrom is already a reference to the subitems,
        # which now also have to be dereferenced

        subitems = modelFrom

        if @attr.multi
            if @attr.reference
                # subitems contains array of references -> resolve them
                @model.refList "subitems", "items", subitems
            else
                # subitems contains array of items -> use that
                @model.ref "subitems", subitems
        else
            # subitems consists of either a single reference or a single item
            # -> put it in an array with only one element
            @model.ref "_subitem.0", subitems

            if @attr.reference
                #  resolve item reference
                @model.refList "subitems", "items", "_subitem"
            else
                # use item directly
                @model.ref "subitems", "_subitem"



    # get the plain text of the attr(ibute) of the given item
    attribute: (data, attr, locale) ->
        return '\n' if not data

        # if the name of an entity is made up of other entities, don't put a comma in there
        separator = if attr.id == 'name' then " " else ", "
        result = ""

        if not attr.multi
            data = [data]

        for subitem in data
            if attr.reference
                subitem = Api.instance!.item subitem, attr.entity

            result += Api.instance!.renderAsText subitem, attr.entity, locale
            result += separator

        return result.slice(0, -separator.length)


    # render the attribute attr of item
    renderAttribute: (data, attr, locale, parent) ->
        return '\n' if not data

        # if the name of an entity is made up of other entities, don't put a comma in there
        separator = if attr.id == 'name' then " " else ", "
        result = ""

        if not attr.multi
            data = [data]

        for subitem in data
            if attr.reference
                subitem = Api.instance!.item subitem, attr.entity

            result += Api.instance!.render subitem, attr.entity, locale, parent
            result += separator

        return result.slice(0, -separator.length)

    # TODO: probably need a  _render: (item, attr, locale, parent, escape) method to share code above



    # check if this itemId is used/referenced by another item
    #   return: list of items that reference the given id, or null if the itemId is unused
    itemReferences: (itemId, entityId) ->
        references = []
        # go through all entities and their attributes and check those that match entityId
        for , entity of Api.instance!.entitiesIdx
            for , attr of entity.attributes
                # does the current entity have an attribute that references entityId?
                if attr.type == 'entity' and attr.entity == entityId and attr.reference
                    # then go through all of its items and check if itemId is in it
                    _.forEach Api.instance!.items(entity.id), (referencingItem) ~>
                        elem = referencingItem[attr.id]
                        if (elem == itemId) or (typeof! elem == 'Array' and _.includes(elem, itemId))
                            references.push {
                                "entity": entity
                                "item": referencingItem
                            }

        return null if references.length == 0
        return _.uniq references, (ref) -> ref.entity.id + "--" + ref.item.id
