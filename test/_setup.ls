'use strict'

require! {
    chai
}

chai.use require('chai-as-promised')

# global.assert = chai.assert
global.expect = chai.expect
global.test = it    # because livescript sees "it" as reserved variable
