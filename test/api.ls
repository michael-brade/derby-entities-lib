'use strict'

require! {
    '../api': EntitiesApi
    'racer/lib/Model'
}



# create the schema

testEntities =
    * id: 'people'
      attributes:
        * id:   'name'
        * id:   'description'
          type: 'textarea'
          i18n: true

    * id: 'company'
      attributes:
        * id:   'name'
        * id:   'employees'
          type: 'entity'
          entity: 'people'
          multi: true
          uniq: false       # same element several times -- default is true
          reference: true   # just store a reference vs. copying the whole object


    # TODO test referencing entity with display attribute (name) being i18n, or an entity itsel
    # * id: 'xx'

# create the data

model = new Model

model.set '_page.people', [
    * name: 'Max'
      description: 'nice guy'
    * name: 'Andy'
      description: 'hacker'
]


describe 'derby-entities-lib API tests', !->


    test 'API initialization', ->
        # not initialized yet
        expect EntitiesApi.instance .to.throw(Error)

        # initialize
        EntitiesApi.init(model, testEntities)

        expect EntitiesApi.instance!.model .to.equal model
        expect EntitiesApi.instance!.entities .to.equal testEntities

        # find API in model
        expect EntitiesApi.instance! .to.equal model.get('$entities._0')

        # don't allow change of initialization
        newEntities =
            * id: 'newEntity'
              attributes:
                * id:   'name'
                * id:   'whatever'
            ...

        EntitiesApi.init(model, newEntities)

        # still the old entities
        expect EntitiesApi.instance!.model .to.equal model
        expect EntitiesApi.instance!.entities .to.equal testEntities


    test 'API was globally initialized', ->
        expect EntitiesApi.instance! .to.exist


    test 'entities were indexed properly', ->
        idx = EntitiesApi.instance!.entitiesIdx

        expect idx .to.be.an 'object'
        expect idx.people .to.be.an 'object'
        expect idx.people.attributes .to.be.an 'object'

        expect EntitiesApi.instance!.entity('people') .to.have.property 'id', 'people'


    test 'query dependent entities', ->

    test 'query referencing entities', ->
