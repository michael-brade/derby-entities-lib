require! path

export class Color

    view: path.join __dirname, 'color.html'

    renderAttribute: (data, attr, locale, parent) ->
        if parent
            $(parent).css("background-color", data)
            return data

        "<span style='background-color: #{data}'>#{data}</span>"
