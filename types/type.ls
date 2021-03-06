require! {
    path
    'lodash/escape': _escape
    derby: { Component }
}

# This component base class provides code needed and shared by all type components.
# It especially conceals boilerplate code for attribute and renderAttribute.
#
# TODO: I guess all this effort is only needed because of jQuery DataTables...
# There is no need for renderAttribute otherwise, is there?
export class Type extends Component

    # CTOR
    (api) ->
        if @@@ == Type then throw new Error("Cannot instantiate abstract Type class!")

        @api = api


    renderAttributeData: -> throw new Error("renderAttributeData() unimplemented! Implement it in #{@@@displayName}!")


    # this is called by LiveScript inheritance before the subclass's prototype methods are assigned
    # it adds the html file (view name) to the view property
    @extended = (subclass) !->
        name = subclass.displayName.toLowerCase!
        subclass.view =
            is: name
            file: path.join __dirname, name


    # init() sets up "$locale" and "data" model paths. "data" points directly to the
    # proper value given by item, attr.id, loc or $locale. Thus, the views can simply
    # use "data" to get and set the value.
    init: (model) !->
        model.ref '$locale', model.root.at '$locale'

        @attr = @getAttribute 'attr'
        @item = model.at 'item' # @getAttribute 'item'
        @loc = @getAttribute 'loc'

        @setupRef 'data'


    # after calling this, pathFrom will be a reference to the given item attribute
    setupRef: (pathFrom) ->
        if @attr.i18n
            if @loc
                # pathFrom -> item[attr.id][loc]
                @model.ref pathFrom, @item.at(@attr.id).at(@loc)
            else
                # pathFrom -> item[attr.id][$locale.locale]
                @model.start pathFrom, 'item', 'attr.id', '$locale.locale', { copy: 'input' },
                    get: (item, attrId, loc) ->
                        item?[attrId]?[loc]

                    set: (value, item, attrId, loc) ->
                        item[attrId] ?= {}
                        item[attrId][loc] = value
                        [item]
        else
            # pathFrom -> item[attr.id]
            @model.ref pathFrom, @item.at(@attr.id)



    attribute: (item, attr, locale) ->
        data = @@attributeI18n item[attr.id] ? "", attr, locale

        # the implementation of @attributeData in subclasses is optional
        if @attributeData
            @attributeData data, attr, locale
        else
            data

    renderAttribute: (item, attr, locale, parent) ->
        data = @@attributeI18n item[attr.id] ? "", attr, locale

        if typeof data == 'string'
            data = _escape data

        @renderAttributeData data, attr, locale, parent



    ### UTILS

    @attributeI18n = (data, attr, locale) ->
        if !data || (attr.i18n && !data[locale])
            return ""

        if attr.i18n
            return data[locale]

        return data
