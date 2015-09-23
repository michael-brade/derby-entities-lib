require! path

export class Color

    view: path.join __dirname, 'color.html'


    attribute: (item, attr) ->
        item[attr.id]


    renderAttribute: (item, attr, locale, parent) ->
        # if the arguments aren't given, take them from the model
        item ?= @getAttribute('item')
        attr ?= @getAttribute('attr')
        # parent is optional, so try to get it only in case of a component
        @getAttribute && parent ?= @getAttribute('parent')

        data = item[attr.id]

        if parent
            $(parent).css("background-color", data)
            return data

        "<span style='background-color: #{data}'>#{data}</span>"
