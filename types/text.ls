require! {
    './type': { Type }
}

export class Text extends Type


    init: (model) !->
        super ...

        attr = @getAttribute 'attr'
        item = model.at 'item'

        if attr.i18n
            loc = @getAttribute("loc")
            if loc
                # item[attr.id][loc]
                model.ref "data", item.at(attr.id).at(loc)

                # model.start "text", "item", "attr.id", "loc", (item, attrId, loc) ~>
                #     item[attrId][loc]
            else
                # item[attr.id][l($locale)]
                model.start "data", "item", "attr.id", "$locale",
                    get: (item, attrId, $locale) ~>
                        loc = @model.root.get("$controller").l($locale)
                        item[attrId][loc]

                    set: (value, item, attrId, $locale) ->
                        console.error "no idea how to implement that!"
        else
            # item[attr.id]
            model.ref "data", item.at attr.id



    renderAttribute: (data, attr, locale) ->
        data
