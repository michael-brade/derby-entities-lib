require! path

export class Text

    name: 'text'
    view: path.join __dirname, 'text.html'
    #style: 'text'

    #components: []

    init: (model) !->
        model.ref '$locale', model.root.at('$locale')


    renderAttribute: (data, attr, locale) ->
        @getAttribute && data ?= @getAttribute('attrData')
        attr ?= @getAttribute('attr')
        locale ?= @getAttribute('loc')
        #locale ?= 'en'

        if !data || (attr.i18n && !data[locale])
            return ""

        if attr.i18n
            return data[locale]

        return data
