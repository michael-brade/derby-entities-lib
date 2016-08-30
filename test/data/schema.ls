# the schema

export schema =
    * id: 'people'
      attributes:
        * id:   'name'
        * id:   'description'
          type: 'textarea'
          i18n: true

    * id: 'company'
      attributes:
        * id:   'name'
        * id:   'employees'
          type: 'entity'
          entity: 'people'
          multi: true
          uniq: false       # same element several times -- default is true
          reference: true   # just store a reference vs. copying the whole object


    # TODO test referencing entity with display attribute (name) being i18n, or an entity itsel
    # * id: 'xx'
