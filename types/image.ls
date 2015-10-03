require! {
    './type': { Type }
}

export class Image extends Type

    # view: path.join __dirname, 'image.html'


    create: (model, dom) ->
        @reader  = new FileReader!
        @reader.onloadend = ~>
            @imgPreview.src = @reader.result
            @setAttribute(null, null, @reader.result)


        @imgInput.onchange = ~>
            imgFile = @imgInput.files[0]
            if imgFile
                @reader.readAsDataURL(imgFile)
            else
                @imgPreview.src = ""
                @setAttribute!


    removeImage: ->
        @imgInput.value = ""
        @setAttribute!


    setAttribute: (item, attr, value) ->
        attr ?= @getAttribute('attr')

        # Derby BUG: this doesn't work!
        #@model.set("item[attr.id]", value)

        @model.at("item").set(attr.id, value)


    renderAttribute: (data, attr, locale, parent) ->
        "<img src='#{data}' />"
