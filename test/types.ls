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

        typesTest = derby.createApp('typesTest', __filename)
        typesTest.loadViews(path.join __dirname, 'types')

        viewsSource = typesTest._viewsSource({server: false})
        fs.writeFileSync(path.join(bundlePath, 'serialized-views.js'), viewsSource, 'utf8')


        ## create standalone bundle

        browserify!
            .add(path.join(bundlePath, "derby-standalone.ls"))
            .transform(liveify)
            .bundle (err, code) ->
                return done(err) if err
                fs.writeFile(path.join(bundlePath, 'derby-standalone.js'), code, done)



    test 'should add 1+1 correctly', (done) ->
        onePlusOne = 1 + 1;
        expect onePlusOne .to.be.equal(2)

        done!
