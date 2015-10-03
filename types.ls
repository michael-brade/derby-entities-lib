# This is a convenience to import all entity attribute type
# components at once. Use with derby.use(require(...))
#
module.exports = (app) ->
    app.component(require './types/number')
    app.component(require './types/text')
    app.component(require './types/textarea')
    app.component(require './types/entity')
    app.component(require './types/color')
    app.component(require './types/image')
