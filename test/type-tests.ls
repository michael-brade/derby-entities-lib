require! {
    path
    fs
    derby
    browserify
    'browserify-livescript': liveify
}



describe 'testing the type views', !->

    before "setup the derby standalone bundle" (done) ->

        bundlePath = path.join(__dirname, 'derby')

        ## serialize the views

        typesTest = derby.createApp('typeTestsApp', __filename)
        typesTest.loadViews(path.join __dirname, 'types')

        viewsSource = typesTest._viewsSource({server: false})
        fs.writeFileSync(path.join(bundlePath, 'serialized-views.js'), viewsSource, 'utf8')


        ## create standalone browser bundle

        browserify {
            basedir: process.cwd!
            extensions: <[ .js .ls ]>
            # paths: ['./types', '.']
        }   .add path.join(bundlePath, 'derby-standalone.ls')
            .require './types/type', { expose: 'types/type' }
            .require './types/text', { expose: 'types/text' }
            .require './test/types', { expose: 'test/types' }
            .transform liveify
            .bundle (err, code) ->
                return done(err) if err
                fs.writeFile(path.join(bundlePath, 'derby-standalone.js'), code, done)



    test '- text: edit mode', (done) ->
        onePlusOne = 1 + 1;
        expect onePlusOne .to.be.equal(2)

        done!
