require! {
    './type': { Type }
}

export class Textarea extends Type

    style: __dirname + "/textarea"


    init: (model) !->
        super ...

        attr = @getAttribute 'attr'
        item = model.at 'item'

        if attr.i18n
            loc = @getAttribute("loc")
            if loc
                # item[attr.id][loc]
                model.ref "text", item.at(attr.id).at(loc)

                # model.start "text", "item", "attr.id", "loc", (item, attrId, loc) ~>
                #     item[attrId][loc]
            else
                # item[attr.id][l($locale)]
                model.start "text", "item", "attr.id", "$locale",
                    get: (item, attrId, $locale) ~>
                        loc = @model.root.get("$controller").l($locale)
                        item[attrId][loc]

                    set: (value, item, attrId, $locale) ->
                        console.error "no idea how to implement that!"
        else
            # item[attr.id]
            model.ref "text", item.at attr.id


    create: (model, dom) ->
        @expandingTextarea?.className += " active"


    emitSomething: (ev, el) ->
        @emit "keydown", ev, el


    renderAttribute: (data, attr, locale, parent) ->
        data
