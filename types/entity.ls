require! {
    path
    '../entity': Entities
}

export class Entity

    # private static

    # public
    view: path.join __dirname, 'entity.html'

    entities: null

    init: (model) !->
        # needed because the passed $locale is apparently evaluated in component context (?!?)
        model.ref '$locale', model.root.at('$locale')


    # get all subitems -- and dereference them if needed
    items: (data, attr) ->
        data ?= @getAttribute('attrData')
        return [] if not data

        attr ?= @getAttribute('attr')

        if not attr.multi
            data = [data]

        if not attr.reference
            return data

        # LiveScript automatically returns an array of these
        for subitem in data
            Entities.instance!.getItem subitem, attr.entity

    entityAttributes: (attr) ->
        attr ?= @getAttribute('attr')
        Entities.instance!.getEntity(attr.entity).attributes


    # @param: data is already the attr of the item
    renderAttribute: (data, attr, locale) ->
        @getAttribute && data ?= @getAttribute('attrData')
        attr ?= @getAttribute('attr')
        locale ?= @getAttribute('loc')

        return '\n' if not data

        # if the name of an entity is made up of other entities, don't put a comma in there
        separator = if attr.id == 'name' then " " else ", "
        result = ""

        if not attr.multi
            data = [data]

        nameAttr = Entities.instance!.getEntity(attr.entity).attributes.name

        for subitem in data
            if attr.reference
                subitem = Entities.instance!.getItem subitem, attr.entity

            result += Entities.instance!.renderAttribute subitem.name, nameAttr, locale
            result += separator

        return result.slice(0, -separator.length)
