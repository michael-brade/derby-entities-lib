require! {
    gulp
    'gulp-util':        gutil

    'gulp-livescript':  lsc
    'gulp-plumber':     plumber
    'gulp-rename':      rename
    'gulp-gitignore':   gitignore
    'gulp-notify':      notify
    'gulp-sequence':    sequence

    # possible: 'gulp-load-plugins' instead

    child_process:      { exec }
}


## files

const SOURCES = [
    'types/*.ls'
    'package.json.sh'
]

const ASSETS = [
    './**/*.html'
    'README.md'
]

const DEST = './dist/'


# works as gulp --compact true
#compact = gutil.env.compact == 'true'


## tasks

# # make a release:
# gulp.task 'release', ['build'], ->
#     # TODO
#     gulp.src distFiles
#         .pipe gulp-conventional-changelog!
#         .pipe gulp.dest '.'
#
# # needs gulp-util, gulp-bump
# gulp.task 'bump' ->
#     gulp.src 'package.json.sh'
#         .pipe bump util.env {type or 'patch'}
#         .pipe gulp.dest '.'
#


global.need_stash = null

#  check if stashing is needed
gulp.task 'check-stash', (cb) ->
    exec 'git status --porcelain', (err, stdout, stderr) ->
        global.need_stash = !!stdout
        console.log(stdout)
        console.log(stderr)
        cb(err)

gulp.task 'save-stash', (cb) ->
    if need_stash
        exec 'git stash save --include-untracked "gulp build stash"', (err, stdout, stderr) ->
            console.log(stdout)
            console.log(stderr)
            cb(err)
    else
        cb!

gulp.task 'pop-stash', (cb) ->
    if need_stash
        exec 'git stash pop --index', (err, stdout, stderr) ->
            console.log(stdout)
            console.log(stderr)
            cb(err)
    else
        cb!


# TODO: lazypipe to put plumber and gitignore in already

# compile LiveScript sources to dist
gulp.task 'transpile', ->
    gulp.src(SOURCES)
        .pipe plumber!
        .pipe gitignore!
        .pipe lsc { bare: true }
        .on 'error' -> throw it
        .pipe rename (filepath) ->
            if filepath.basename == 'package.json.sh'
                filepath.basename = 'package'
                filepath.extname = '.json'
        .pipe gulp.dest DEST
        .pipe notify { message: 'transpile complete', onLast: true }

# copy assets to dist
gulp.task 'copy-assets', ->
    gulp.src(ASSETS)
        .pipe plumber!
        .pipe gitignore!
        .pipe gulp.dest DEST
        .pipe notify { message: 'copy-assets complete', onLast: true }


gulp.task 'build-core', <[ transpile copy-assets ]>


# build a distribution
#   * stash everything not comitted away (test -n "$(git status --porcelain)" && git stash save --include-untracked)
#     beware: --all would be really correct, but it also removes node_modules, so use --include-untracked instead
#   * build the dist
#   * pop stash if there were any changes (git stash pop --index)
#
gulp.task 'build', sequence 'check-stash', 'save-stash', 'build-core', 'pop-stash'
