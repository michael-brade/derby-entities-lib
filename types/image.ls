require! path

export class Image

    view: path.join __dirname, 'image.html'


    init: (model) !->
        model.ref '$locale', model.root.at('$locale')


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


    # doesn't really make sense for an image, apart from maybe dumping the db
    attribute: (item, attr) ->
        item[attr.id]


    renderAttribute: (item, attr, locale, parent) ->
        # if the arguments aren't given, take them from the model
        item ?= @getAttribute('item')
        attr ?= @getAttribute('attr')

        data = item[attr.id] ? ''

        "<img src='#{data}' />"
