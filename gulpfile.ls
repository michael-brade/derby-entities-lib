require! {
    gulp
    'gulp-livescript':  lsc
    'gulp-plumber':     plumber
    'gulp-gitignore':   gitignore
    'gulp-uglify':      uglify
    'gulp-notify':      notify
}


## files

const SOURCES = [
    'api.ls'
    'types.ls'
    'item/*.ls'
    'types/*.ls'
]

const ASSETS = [
    '**/*.html'
    'README.md'
]

const DEST = 'dist/'


## tasks

# make a release:
#  - use conventional-changelog
#  - use e.g. "npm version minor"
#  - use https://gist.github.com/stevemao/280ef22ee861323993a0



# TODO: lazypipe to put plumber and gitignore in already

# compile LiveScript sources to dist
gulp.task 'transpile', ->
    gulp.src(SOURCES, { base: "." })
        .pipe plumber!
        .pipe gitignore!
        .pipe lsc { bare: true }
        .on 'error' -> throw it
        .pipe uglify!
        .pipe gulp.dest DEST
        .pipe notify { message: 'transpile complete', onLast: true }

# copy assets to dist
gulp.task 'copy-assets', ->
    gulp.src(ASSETS)
        .pipe plumber!
        .pipe gitignore!
        .pipe gulp.dest DEST
        .pipe notify { message: 'copy-assets complete', onLast: true }


# build a distribution
gulp.task 'build', <[ transpile copy-assets ]>
