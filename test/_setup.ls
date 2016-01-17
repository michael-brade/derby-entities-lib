require! {
    fs
    path
    chai
    browserify
    'browserify-livescript': liveify
}

chai.use require('chai-as-promised')

global.expect = chai.expect
global.test = it    # because livescript sees "it" as reserved variable


before "setup the derby standalone bundle" (done) ->
    derby = path.join(__dirname, 'derby')

    browserify!
        .add(path.join(derby, "derby-standalone.ls"))
        .transform(liveify)
        .bundle (err, code) ->
            return done(err) if err
            fs.writeFile(path.join(derby, 'derby-standalone.js'), code, done)
