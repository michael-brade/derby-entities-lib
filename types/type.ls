require! path

# This component base class provides code needed and shared by all type components.
# It especially conceals boilerplate code for attribute and renderAttribute.
#
# TODO: I guess all this effort is only needed because of jQuery DataTables...
# There is no need for renderAttribute otherwise, is there?
export class Type

    # CTOR
    ->
        if (@@@ == Type)
             throw new Error("Can't instantiate abstract Type class!");

        @@@::view = path.join __dirname, @@@.displayName.toLowerCase! + '.html'

        _attribute = @attribute
        @attribute = attribute.bind @, _attribute?.bind @

        _renderAttribute = @renderAttribute
        @renderAttribute = renderAttribute.bind @, _renderAttribute.bind @


    # init() sets up "$locale" and "data" model paths. "data" points directly to the
    # proper value given by item, attr.id, loc or $locale. Thus, the views can simply
    # use "data" to get and set the value.
    init: (model) !->
        model.ref '$locale', model.root.at('$locale')

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



    function attribute(_attribute, item, attr, locale)
        data = @attributeI18n item[attr.id] ? "", attr, locale

        # the implementation of @attribute in subclasses is optional
        if _attribute
            _attribute data, attr, locale
        else
            data

    function renderAttribute(_renderAttribute, item, attr, locale, parent)
        data = @escapeMarkup @attributeI18n item[attr.id] ? "", attr, locale

        _renderAttribute data, attr, locale, parent



    ### UTILS

    attributeI18n: (data, attr, locale) ->
        if !data || (attr.i18n && !data[locale])
            return ""

        if attr.i18n
            return data[locale]

        return data


    escapeMarkup: (text) ->
        return text if typeof text != 'string'

        replaceMap =
            '\\': '&#92;'
            '&': '&amp;'
            '<': '&lt;'
            '>': '&gt;'
            '"': '&quot;'
            '\'': '&#39;'
            '/': '&#47;'

        String(text).replace //[&<>"'\/\\]//g, (_match) -> replaceMap[_match]
