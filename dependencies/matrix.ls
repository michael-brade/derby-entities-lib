require! {
    'lodash': _
    './base': { EntityDependencies }
    'es6-iterator/for-of': forOf
}

require 'array.from'


# This class creates an object like this:
# {
#    packageNames: ['Main', 'A', 'B'],
#    matrix: [[0, 1, 1], // Main depends on A and B
#             [0, 0, 1], // A depends on B
#             [0, 0, 0]] // B doesn't depend on A or Main
# }
export class DependencyMatrix extends EntityDependencies

    (model) ->
        super ...
        @matrix = @model.at '_dependencyIdMatrix'   # first create matrix because init() calls @addDependency()


    # adds a dependency to the matrix
    addDependency: (sourceId, dependencyId) ->
        # console.log "dependency: #{sourceId} -> #{dependencyId}"

        @matrix.push sourceId, dependencyId

    # create and return the matrix
    data: ->
        @init!

        # TODO: there is an easier way - use a direct loop and .push the item name to itemNames
        itemNames = _.map Array.from(@itemMap.values!), (v) ~>
            @api.renderAsText v.item, v.entity.id, 'en' # TODO: locale!

        # create matrix
        matrix = []
        #while not (entry = keys.next!).done
        forOf @itemMap.keys!, (itemId) !~>     # rows
            r = []
            depIds = @matrix.get(itemId)
            forOf @itemMap.keys!, (depId) !~>     # columns
                if _.includes depIds, depId
                    r.push 1
                else
                    r.push 0

            matrix.push r

        {
            packageNames: itemNames
            matrix: matrix
        }
