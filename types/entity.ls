export class Entity

    # private
    _entityModel = null

    # public
    view: 'entity.html'

    (entityModel) ->
        _entityModel = entityModel


    # @param: data is already the attr of the item
    render: (data, attr, locale) ->
        return '\n' if not data

        # if the name of an entity is made up of other entities, don't put a comma in there
        separator = if attr.id == 'name' then " " else ", "
        result = ""

        if not attr.multi
            data = [data]

        nameAttr = _entityModel.getEntity(attr.entity).attributes.name

        for subitem in data
            if attr.reference
                subitem = _entityModel.getItem subitem, attr.entity

            result += _entityModel.render subitem.name, nameAttr, locale
            result += separator

        return result.slice(0, -separator.length)
