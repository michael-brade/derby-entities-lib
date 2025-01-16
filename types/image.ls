require! {
    './type': { Type }
}

export class Image extends Type

    @view = Object.assign {}, @view,
        style: __dirname + "/image"


    create: (model, dom) ->
        return if @getAttribute('mode') != 'edit'

        @reader  = new FileReader
        @reader.onloadend = ~>
            @setData @reader.result


        @imgInput.onchange = ~>
            imgFile = @imgInput.files[0]
            if imgFile
                @reader.readAsDataURL(imgFile)
            else
                @removeImage


    removeImage: ->
        @imgInput.value = ""
        @setData undefined

    setData: (value) ->
        @imgPreview.src = value
        @model.set "data", value


    renderAttributeData: (data, attr, locale, parent) ->
        "<img src='#{data}' />"
