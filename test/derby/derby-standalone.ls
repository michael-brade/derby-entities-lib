'use strict'

DerbyStandalone = require('derby/lib/DerbyStandalone')
global.derby = module.exports = new DerbyStandalone()

module.exports.App.prototype.registerViews = (selector) ->
  selector || (selector = 'script[type="text/template"]')
  templates = document.querySelectorAll(selector)
  for template in templates
      @views.register(template.id, template.innerHTML, template.dataset)


# include template and expression parsing
require 'derby-parsing'
