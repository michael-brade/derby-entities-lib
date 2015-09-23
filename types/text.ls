require! path

export class Text

    view: path.join __dirname, 'text.html'
    #style: 'text'


    init: (model) !->
        model.ref '$locale', model.root.at('$locale')


    attribute: (item, attr, locale) ->
        item ?= @getAttribute('item')
        attr ?= @getAttribute('attr')
        locale ?= @getAttribute('loc')

        data = item[attr.id]

        if !data || (attr.i18n && !data[locale])
            return ""

        if attr.i18n
            return data[locale]

        return data


    renderAttribute: (item, attr, locale) ->
        @attribute ...
