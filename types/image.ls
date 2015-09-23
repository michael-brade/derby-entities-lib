require! path

export class Image

    view: path.join __dirname, 'image.html'


previewFile = ->
    preview = document.querySelector('img')
    file    = document.querySelector('input[type=file]').files[0]
    reader  = new FileReader!

    reader.onloadend = ->
        preview.src = reader.result


    if file
        reader.readAsDataURL(file)
    else
        preview.src = ""



    # doesn't really make sense for an image, apart from dumping the db
    attribute: (item, attr) ->
        item[attr.id]


    renderAttribute: (item, attr, locale, parent) ->
        # if the arguments aren't given, take them from the model
        item ?= @getAttribute('item')
        attr ?= @getAttribute('attr')

        data = item[attr.id]

        "<img src='#{data}' />"
