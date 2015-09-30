require! path

export class Textarea

    view: path.join __dirname, 'textarea.html'


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


    renderAttribute: (item, attr, locale, parent) ->
        @attribute ...  # TODO: escapeMarkup
