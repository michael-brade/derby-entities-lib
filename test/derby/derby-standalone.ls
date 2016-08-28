'use strict'

DerbyStandalone = require('derby/lib/DerbyStandalone')
derbyTemplates = require('derby-templates')
serializedViews = require('./serialized-views')

# include template and expression parsing
require 'derby-parsing'

global.derby = module.exports = new DerbyStandalone()

module.exports.App.prototype.registerViews = ->
    serializedViews(derbyTemplates, @views)

# module.exports.App.prototype.registerViews = (selector) ->
#   selector || (selector = 'script[type="text/template"]')
#   templates = document.querySelectorAll(selector)
#   for template in templates
#       @views.register(template.id, template.innerHTML, template.dataset)
