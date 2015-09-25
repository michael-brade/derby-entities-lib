require! path

export class Number

    view: path.join __dirname, 'number.html'


    attribute: (item, attr) ->
        item[attr.id] ? ""


    renderAttribute: (item, attr, locale, parent) ->
        item[attr.id] ? ""
