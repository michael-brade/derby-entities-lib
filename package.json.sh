#!/usr/local/bin/lsc -cj

name: 'derby-entities-lib'
description: 'Base library for derby-entity CRUD component and derby-entities-visualizations'
version: '1.1.3'

main: 'api.ls'

author:
    name: 'Michael Brade'
    email: 'brade@kde.org'

keywords:
    'derby'
    'entity'
    'crud'


repository:
    type: 'git'
    url: 'michael-brade/derby-entities-lib'

dependencies:
    # utils
    'lodash': '3.x'

devDependencies:
    'livescript': "1.4"
    'gulp': "3.x"
    'gulp-plumber': "1.x"
    'gulp-livescript': "3.x"
    'gulp-uglify': "1.x"
    'gulp-notify': "2.x"
    'gulp-gitignore': "*"



scripts:
    ## building

    # make sure a stash will be created and stash everything not committed
    # beware: --all would be really correct, but it also removes node_modules, so use --include-untracked instead
    prebuild: 'touch .create_stash && git stash save --include-untracked "npm build stash"'
    # build the distribution
    build: "gulp build && ./package.json.sh && cp package.json dist"
    # restore the original situation
    postbuild: 'git stash pop --index && rm .create_stash'

    clean: "rm -rf dist"

    ## testing

    test: "echo \"TODO: no tests specified yet\" && exit 1"

engines:
    node: '4.x'

license: 'MIT'

bugs:
    url: 'https://github.com/michael-brade/derby-entities-lib/issues'

homepage: 'https://github.com/michael-brade/derby-entities-lib#readme'
