require! {
    'lodash': _
    './base': { EntityDependencies }
}

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
        @matrix = @model.at '_dependencyIdMatrix'
        @initMatrix!


    # adds a dependency to the matrix
    addDependency: (sourceId, dependencyId) ->
        console.log "dependency: #{sourceId} -> #{dependencyId}"

        @matrix.push sourceId, dependencyId

    # return the matrix
    data: ->
        itemNames = _.map(Array.from @itemMap.values!, (item) ~>
            @getItemName item
        )

        console.log "DATA:", itemNames

        data = {
            packageNames: Array.from @itemMap.values!
            matrix: ""
        }
