require! path

export class Textarea

    view: path.join __dirname, 'textarea.html'


    attribute: (item, attr) ->
        item[attr.id] ? ""


    renderAttribute: (item, attr, locale, parent) ->
        item[attr.id] ? ""
