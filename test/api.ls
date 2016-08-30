'use strict'

require! {
    '../api': EntitiesApi

    './data/schema': { schema }
    './data/model': { model }
}



describe 'derby-entities-lib API tests', !->


    test 'API initialization', ->
        # not initialized yet
        expect EntitiesApi.instance .to.throw(Error)

        # initialize
        EntitiesApi.init model, schema

        expect EntitiesApi.instance!.model .to.equal model
        expect EntitiesApi.instance!.entities .to.equal schema

        # find API in model
        expect EntitiesApi.instance! .to.equal model.get('$entities._0')

        # don't allow change of initialization
        newEntities =
            * id: 'newEntity'
              attributes:
                * id:   'name'
                * id:   'whatever'
            ...

        EntitiesApi.init model, newEntities

        # still the old entities
        expect EntitiesApi.instance!.model .to.equal model
        expect EntitiesApi.instance!.entities .to.equal schema


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
