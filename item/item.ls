require! {
    '../api': Api
    path
    derby: { Component }
}

export class Item extends Component

    @view =
        file: path.join __dirname, 'item.html'

    init: (model) !->
        model.ref '$locale', model.root.at('$locale')

        entity = @getAttribute('entity')
        if typeof entity == "string"        # entity id given, resolve to entity object
            entity = Api.instance(model).entity(entity)
        else                                # page entity object, change to indexed object
            entity = Api.instance(model).entity(entity.id)


        item = model.get('item')   # TODO: @getAttribute('item') returns undefined

        model.set "displayAttr", entity.attributes[entity.display.attribute]

        # this is an array of the resolved attribute ids, i.e., display.decorate might say "photo", with is
        # an attribute of type image, so this array holds the image attr object
        model.set "decorationAttrs", []

        for attrId in entity.display.decorate
            model.push "decorationAttrs", entity.attributes[attrId]

    focus: ->
        $(@form).find(':input[type!=hidden]').first().focus()

    done: (item) ->
        @emit "done", item
