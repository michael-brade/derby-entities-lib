require! {
    './type': { Type }
}

export class Color extends Type

    @view = Object.assign {}, @view,
        style: __dirname + "/color"


    renderAttributeData: (data, attr, locale, parent) ->
        if parent
            $(parent).css("background-color", data)
            return data

        "<span class='color' style='background-color:#{data}'></span>
        <span>#{data}</span>"
