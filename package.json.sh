#!/usr/local/bin/lsc -cj

name: 'derby-entities-lib'
description: 'Base library for derby-entity CRUD component and derby-entities-visualizations'
version: '1.2.0'

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
    'livescript': '1.5.x'
    'uglify-js': '2.7.x'

    # testing
    'browserify': '13.x'
    'browserify-livescript': '0.2.x'

    'derby': 'michael-brade/derby'

    'mocha': '3.x'
    'mocha-generators': '1.x'

    'nightmare': '2.x'

    'chai': '3.x'
    'chai-as-promised': '5.x'



scripts:
    ## building

    # make sure a stash will be created and stash everything not committed
    # beware: --all would be really correct, but it also removes node_modules, so use --include-untracked instead
    prebuild: 'npm run clean; touch .create_stash && git stash save --include-untracked "npm build stash";'

    # build the distribution under dist: create directory structure, compile to JavaScript, uglify
    build: "
        export DEST=dist;
        export ASSETS='.*\.css|.*\.html|./README\.md|./package\.json';

        find \\( -path './node_modules' -o -path \"./$DEST\" -o -path './test' \\) -prune -o -name '*.ls' -print0
        | xargs -n1 -P8 -0 sh -c '
            echo Compiling and minifying $0...;
            mkdir -p \"$DEST/`dirname $0`\";
            lsc -cp \"$0\" | uglifyjs - -cm -o \"$DEST/${0%.*}.js\";
        ';

        echo \"\033[01;32mCopying assets...\033[00m\";
        find \\( -path './node_modules' -o -path \"./$DEST\" -o -path './test' \\) -prune -o -regextype posix-egrep -regex $ASSETS -print0
        | xargs -n1 -0 sh -c '
            mkdir -p \"$DEST/`dirname \"$0\"`\";
            cp -a \"$0\" \"$DEST/$0\"
        ';

        echo \"\033[01;32mMinifying views...\033[00m\";
        find \"$DEST\" -name '*.html' -print0 | xargs -n1 -0 perl -i -p0e 's/\\n//g;s/ +/ /g;s/<!--.*?-->//g';

        echo \"\033[01;32mDone!\033[00m\";
    "
    # restore the original situation
    postbuild: 'git stash pop --index && rm .create_stash;'

    clean: "rm -rf dist;"   # the ; at the end is very important! otherwise "npm run clean ." would delete everything

    ## testing

    test: 'mocha test/_*.ls test/nightmare.js;'

    disttest: 'npm run build; TODO'  # find out how to run the tests using dist/*

    ## publishing: run "npm run build; cd dist; npm publish"

engines:
    node: '4.x || 5.x'

license: 'MIT'

bugs:
    url: 'https://github.com/michael-brade/derby-entities-lib/issues'

homepage: 'https://github.com/michael-brade/derby-entities-lib#readme'
