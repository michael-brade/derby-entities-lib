require! path

# This base class provides code needed and shared by all types.
# It especially conceals boilerplate code for attribute and renderAttribute.
#
# I guess all this effort is only needed because of jQuery DataTables... There
# is no need for renderAttribute otherwise, is there?
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


    init: (model) !->
        # needed because the passed $locale is apparently evaluated in component context (?!?)
        model.ref '$locale', model.root.at('$locale')


    function attribute(_attribute, item, attr, locale)
        # if the arguments aren't given, take them from the model
        item ?= @getAttribute('item')
        attr ?= @getAttribute('attr')
        locale ?= @getAttribute('loc')

        data = @attributeI18n item[attr.id] ? "", attr, locale

        # the implementation of @attribute in subclasses is optional
        if _attribute
            _attribute data, attr, locale
        else
            data

    function renderAttribute(_renderAttribute, item, attr, locale, parent)
        # if the arguments aren't given, take them from the model
        item ?= @getAttribute('item')
        attr ?= @getAttribute('attr')
        locale ?= @getAttribute('loc')
        # parent is optional, so try to get it only in case of a component
        @getAttribute && parent ?= @getAttribute('parent')

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
