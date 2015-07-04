require! {
    'lodash': _
    './base': { EntityDependencies }
}

require '../../polyfills'


# This class creates an object like this:
# {
#    packageNames: ['Main', 'A', 'B'],
#    matrix: [[0, 1, 1], // Main depends on A and B
#             [0, 0, 1], // A depends on B
#             [0, 0, 0]] // B doesn't depend on A or Main
# }
export class DependencyMatrix extends EntityDependencies

    (model, entities) ->
        super ...
        @matrix = @model.at '_dependencyIdMatrix'   # first create matrix because init() calls @addDependency()
        @init!


    # adds a dependency to the matrix
    addDependency: (sourceId, dependencyId) ->
        console.log "dependency: #{sourceId} -> #{dependencyId}"

        @matrix.push sourceId, dependencyId

    # return the matrix
    data: ->
        itemNames = _.map Array.from(@itemMap.values!), (v) ~>
            @entities.getItemName v.item, v.entity

        console.log "DATA:", itemNames

        data = {
            packageNames: itemNames
            matrix: ""
        }
