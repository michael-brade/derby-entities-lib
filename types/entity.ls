require! {
    path
    '../api': Api
}

export class Entity

    # private static

    # public
    view: path.join __dirname, 'entity.html'


    init: (model) !->
        # needed because the passed $locale is apparently evaluated in component context (?!?)
        model.ref '$locale', model.root.at('$locale')


    # get all subitems in item.attr -- and dereference them if needed
    items: (item, attr) ->
        item ?= @getAttribute('item')
        attr ?= @getAttribute('attr')

        data = item[attr.id]
        return [] if not data

        if not attr.multi
            data = [data]

        if not attr.reference
            return data

        # LiveScript automatically returns an array of these
        for subitem in data
            Api.instance!.getItem subitem, attr.entity

    # get the indexed version of all attributes for this attribute's subitems
    entityAttributes: (attr) ->
        attr ?= @getAttribute('attr')
        
        Api.instance!.getEntity(attr.entity).attributes


    # get the plain text of the attr(ibute) of the given item
    attribute: (item, attr, locale) ->
        item ?= @getAttribute('item')
        attr ?= @getAttribute('attr')
        locale ?= @getAttribute('loc')

        data = item[attr.id]

        return '\n' if not data

        # if the name of an entity is made up of other entities, don't put a comma in there
        separator = if attr.id == 'name' then " " else ", "
        result = ""

        if not attr.multi
            data = [data]

        nameAttr = Api.instance!.getEntity(attr.entity).attributes.name

        for subitem in data
            if attr.reference
                subitem = Api.instance!.getItem subitem, attr.entity

            # TODO: use attribute here!
            result += Api.instance!.renderAttribute subitem, nameAttr, locale
            result += separator

        return result.slice(0, -separator.length)


    # render the attribute attr of item - ATM it is the plain text version
    renderAttribute: (item, attr, locale) ->
        @attribute ...