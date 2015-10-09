require! {
    './type': { Type }
}

export class Image extends Type

    style: __dirname + "/image"


    create: (model, dom) ->
        return if @getAttribute('mode') != 'edit'

        @reader  = new FileReader!
        @reader.onloadend = ~>
            @setData "data", @reader.result


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


    renderAttribute: (data, attr, locale, parent) ->
        "<img src='#{data}' />"
