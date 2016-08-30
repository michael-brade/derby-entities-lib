require! './api': { Api }

# This is a convenience to import all entity attribute type
# components at once. Usage:
#    derby.use require('derby-entities-lib/types')

export supportedTypeComponents =
    require './types/text'     .Text
    require './types/textarea' .Textarea
    require './types/number'   .Number
    require './types/entity'   .Entity
    require './types/color'    .Color
    require './types/image'    .Image

export (app) !->
    supportedTypeComponents.forEach (type) !->
        app.component type
