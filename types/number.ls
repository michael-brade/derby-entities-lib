require! {
    './type': { Type }
}

export class Number extends Type

    renderAttribute: (data, attr, locale, parent) ->
        data
