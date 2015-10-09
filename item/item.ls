require! {
    '../api': Api
    path
}

export class Item

    view: path.join __dirname, 'item.html'

    init: (model) !->
        model.ref '$locale', model.root.at('$locale')


        @entity = @getAttribute('entity')
        if typeof @entity == "string"       # entityId given, resolve to entity object
            @entity = Api.instance!.entity(@entity)
        else                                # page entity object, change to indexed object
            @entity = Api.instance!.entity(@entity.id)


        model.set "displayAttr", @entity.attributes[@entity.display.attribute]

        # this is an array of the resolved attribute ids, i.e., display.decorate might say "photo", with is
        # an attribute of type image, so this array holds the image attr object
        model.set "decorationAttrs", []

        for attrId in @entity.display.decorate
            model.push "decorationAttrs", @entity.attributes[attrId]

        # console.log "init ", @entity.id, @getAttribute('item').name, "decorationAttrs: ", model.get('decorationAttrs')


    # TODO: either this:
    # done: ->
    #     @emit "done"

    # or supply a page.done() method.
