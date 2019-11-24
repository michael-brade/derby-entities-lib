#!/usr/local/bin/lsc -cj

name: 'derby-entities-lib'
description: 'Base library for derby-entity CRUD component and derby-entities-visualizations'
version: '1.2.4'

main: 'api.ls'

author:
    name: 'Michael Brade'
    email: 'brade@kde.org'

keywords:
    'derby'
    'component'
    'entity'
    'crud'

repository:
    type: 'git'
    url: 'michael-brade/derby-entities-lib'

dependencies:
    # utils
    'lodash': '4.x'
    'derby-select2': '0.2.x'

devDependencies:
    # building
    'livescript': '1.6.x'
    'uglify-js': '3.x'
    'html-minifier': '3.x'

    # testing
    'browserify': '16.x'
    'browserify-livescript': '0.2.x'

    'derby': 'michael-brade/derby'

    'mocha': '6.x'
    'mocha-generators': '2.x'

    'nightmare': '3.x'

    'chai': '4.x'
    'chai-as-promised': '7.x'



scripts:
    ## building

    # make sure a stash will be created and stash everything not committed
    # beware: --all would be really correct, but it also removes node_modules, so use --include-untracked instead
    prebuild: '
        npm run clean;
        touch .create_stash && git stash save --include-untracked "npm build stash";
        npm test || { npm run postbuild; exit 1; };
    '

    # build the distribution under dist: create directory structure, compile to JavaScript, uglify
    build: "
        set -e;
        export DEST=dist;
        export SOURCES='*.ls';
        export VIEWS='*.html';
        export ASSETS='.*\.css|./README\.md|./package\.json';
        export IGNORE=\"./$DEST|./test|./node_modules\";

        echo \"\033[01;32mCompiling and minifying...\033[00m\";
        find -regextype posix-egrep -regex $IGNORE -prune -o -name \"$SOURCES\" -print0
        | xargs -n1 -P8 -0 bash -c '
            set -e; set -o pipefail;
            echo $0...;
            mkdir -p \"$DEST/`dirname $0`\";
            lsc -cp \"$0\" | uglifyjs -cm -o \"$DEST/${0%.*}.js\" || exit 255;
        ';

        echo \"\033[01;32mMinifying views...\033[00m\";
        find -regextype posix-egrep -regex $IGNORE -prune -o -name \"$VIEWS\" -print0
        | xargs -n1 -P8 -0 sh -c '
            echo \"$0 -> $DEST/$0\";
            mkdir -p \"$DEST/`dirname $0`\";
            html-minifier --config-file .html-minifierrc -o \"$DEST/$0\" \"$0\" || exit 255'
        | column -t -c 3;

        echo \"\033[01;32mCopying assets...\033[00m\";
        find -regextype posix-egrep -regex $IGNORE -prune -o -regex $ASSETS -print0
        | xargs -n1 -0 sh -c '
            echo \"$0 -> $DEST/$0\";
            mkdir -p \"$DEST/`dirname \"$0\"`\";
            cp -a \"$0\" \"$DEST/$0\" || exit 255'
        | column -t -c 3;

        echo \"\033[01;32mDone!\033[00m\";
    "
    # restore the original situation
    postbuild: 'git stash pop --index && rm .create_stash;'

    clean: "rm -rf dist;"   # the ; at the end is very important! otherwise "npm run clean ." would delete everything

    ## testing

    test: 'mocha test/_*.ls test/api.ls;'

    disttest: 'cd dist; npm run test;'  # TODO

    ## publishing
    release: "npm run build && cd dist && npm publish;"

engines:
    node: '4.x || 5.x'

license: 'MIT'

bugs:
    url: 'https://github.com/michael-brade/derby-entities-lib/issues'

homepage: 'https://github.com/michael-brade/derby-entities-lib#readme'
