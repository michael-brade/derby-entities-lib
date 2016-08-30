require! {
    path

    './data/schema': { schema }
    './data/model': { model }
}

export class TypesTest

    name: 'types'
    view: path.join __dirname, 'types.html'

    components:
        require '../types/text' .Text

    init: (model) !->
