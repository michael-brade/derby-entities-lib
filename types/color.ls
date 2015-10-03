require! {
    './type': { Type }
}

export class Color extends Type

    renderAttribute: (data, attr, locale, parent) ->
        if parent
            $(parent).css("background-color", data)
            return data

        "<span style='background-color: #{data}'>#{data}</span>"
