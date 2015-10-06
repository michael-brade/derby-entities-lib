require! {
    '../api': Api
    './type': { Type }
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
        require('derby-entity-select2')
        ...


    # get all subitems in item.attr -- and dereference them if needed
    subitems: (item, attr) ->
        data = item[attr.id]
        return [] if not data

        if not attr.multi
            data = [data]

        if not attr.reference
            return data

        # LiveScript automatically returns an array of these
        for subitem in data
            Api.instance!.item subitem, attr.entity

    # get the indexed version of all attributes for this attribute's subitems
    entityAttributes: (attr) ->
        Api.instance!.entity(attr.entity).attributes


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
