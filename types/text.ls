export class Text

    view: 'text.html'

    render: (data, attr, locale) ->
        # TODO needs attr itself passed in! there is no @getEntity, entityId
        #attr = @getEntity(entityId).attributes[attrId]

        if !data || (attr.i18n && !data[locale])
            return ""

        if attr.i18n
            return data[locale]

        return data
