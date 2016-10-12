require! {
    '../api': EntitiesApi

    './data/schema': { schema }
    './data/model': { model }
}



describe 'derby-entities-lib API tests', !->

    test 'API throws when not initialized', !->
        expect EntitiesApi.instance .to.throw(Error)
        expect ->
            EntitiesApi.instance(model)
        .to.throw(Error)


    test 'API initialization', !->

        # initialize
        EntitiesApi.init model, schema

        expect EntitiesApi.instance(model).model .to.equal model
        expect EntitiesApi.instance(model).entities .to.equal schema


    test 'API was initialized for model', !->
        expect EntitiesApi.instance(model) .to.exist

        # find API in model
        expect EntitiesApi.instance(model) .to.equal model.get('$entities.api')


    test 'API re-initialization', !->
        # don't allow change of initialization
        newEntities =
            * id: 'newEntity'
              attributes:
                * id:   'name'
                * id:   'whatever'
            ...

        EntitiesApi.init model, newEntities

        # still the old entities
        expect EntitiesApi.instance(model).model .to.equal model
        expect EntitiesApi.instance(model).entities .to.equal schema


    test 'entities were indexed properly', !->
        idx = EntitiesApi.instance(model).entitiesIdx

        expect idx .to.be.an 'object'
        expect idx.people .to.be.an 'object'
        expect idx.people.attributes .to.be.an 'object'

        expect EntitiesApi.instance(model).entity('people') .to.have.property 'id', 'people'


    test 'query dependent entities', !->

    test 'query referencing entities', !->
