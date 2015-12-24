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
    'livescript': "1.4.x"
    'uglify-js': '2.6.x'

scripts:
    ## building

    # make sure a stash will be created and stash everything not committed
    # beware: --all would be really correct, but it also removes node_modules, so use --include-untracked instead
    prebuild: 'npm run clean; touch .create_stash && git stash save --include-untracked "npm build stash";'

    # build the distribution under dist: create directory structure, compile to JavaScript, uglify
    build: "
        export DEST=dist;
        export ASSETS='.*\.css|.*\.html|./README\.md|./package\.json';

        find -path './node_modules*' -prune -o -name '*.ls' -print0
        | xargs -n1 -0 sh -c '
            echo Compiling and minifying $0...;
            DEST_PATH=\"$DEST/`dirname $0`\";
            mkdir -p \"$DEST_PATH\";
            lsc -cp \"$0\" | uglifyjs - -cm -o \"$DEST_PATH/`basename -s .ls \"$0\"`\".js;
        ';

        echo \"\033[01;32mCopying assets...\033[00m\";
        find \\( -path './node_modules*' -o -path \"./$DEST/*\" \\) -prune -o -regextype posix-egrep -regex $ASSETS -print0
        | xargs -n1 -0 sh -c '
            mkdir -p \"$DEST/`dirname \"$0\"`\";
            cp -a \"$0\" \"$DEST/$0\"
        ';

        echo \"\033[01;32mDone!\033[00m\";
    "
    # restore the original situation
    postbuild: 'git stash pop --index && rm .create_stash;'

    clean: "rm -rf dist;"   # the ; at the end is very important! otherwise "npm run clean ." would delete everything

    ## testing

    test: "echo \"TODO: no tests specified yet\" && exit 1;"

    ## publishing - run as "npm run publish"

    prepublish: "npm run clean; npm run build;"
    publish: "npm publish dist;"

engines:
    node: '4.x || 5.x'

license: 'MIT'

bugs:
    url: 'https://github.com/michael-brade/derby-entities-lib/issues'

homepage: 'https://github.com/michael-brade/derby-entities-lib#readme'
