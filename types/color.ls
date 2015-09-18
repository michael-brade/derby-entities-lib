export class Color

    view: 'color.html'

    render: (data) -> #(data, attr, locale) ->
        #$(parent).css("background-color", data)
        #data

        "<span style='background-color: #{data}'>#{data}</span>"
