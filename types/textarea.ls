require! {
    './type': { Type }
}

export class Textarea extends Type

    renderAttribute: (data, attr, locale, parent) ->
        data
