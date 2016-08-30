'use strict'

Model = require 'racer/lib/Model'


# create the data

export model = new Model

model.set '_page.people', [
    * name: 'Max'
      description: 'nice guy'
    * name: 'Andy'
      description: 'hacker'
]
