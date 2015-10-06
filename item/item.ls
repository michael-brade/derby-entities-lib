require! {
    '../api': Api
    path
}

export class Item

    view: path.join __dirname, 'item.html'

    entity: null
    displayAttr: null

    init: (model) !->
        model.ref '$locale', model.root.at('$locale')

    create: (model, dom) ->
        # @entity = @getAttribute('entity')
        #
        # if typeof @entity == "string" # entityId given
        #     @entity = Api.instance!.entity(entity)
        #
        # model.set "displayAttr", @entity.attributes[@entity.display.attribute]

        # TODO: instead of @entity, could set decorations into model
        # model.set "displayAttr", @entity.attributes[@entity.display.attribute]

        # if not @types[attr.type]
        #     throw Error "Entity type #{attr.type} is not supported!"


    decorations: (index) ->
        # do this in init by model.ref
        @entity = @getAttribute('entity')

        if typeof @entity == "string" # entityId given
            @entity = Api.instance!.entity(@entity)

        @model.set "displayAttr", @entity.attributes[@entity.display.attribute]

        if @entity.display.decorate.length > index
            @entity.attributes[@entity.display.decorate[index]]
