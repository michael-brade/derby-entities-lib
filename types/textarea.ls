require! {
    './type': { Type }
}

export class Textarea extends Type

    @view = Object.assign {}, @view,
        style: __dirname + "/textarea"


    create: (model, dom) ->
        @expandingTextarea?.className += " active"


    emitSomething: (ev, el) ->
        @emit "keydown", ev, el


    renderAttributeData: (data, attr, locale, parent) ->
        data
