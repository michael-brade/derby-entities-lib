require! {
    './type': { Type }
}

export class Text extends Type

    #style: 'text'

    renderAttribute: (data, attr, locale) ->
        data
