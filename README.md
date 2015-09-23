# Derby Entities Library

This library reads the entity schema definition and provides the API to access entities and their items.
It is the base library for [derby-entity](TODO).

## Schema Definition


## Attribute Types



## Development

### Adding New Attribute Type Definitions


Each type class has to provide the following methods:

    - `attribute: (item, attr, locale) ->`
    - `renderAttribute: (item, attr, locale, parent) ->`

The component view takes a parameter `mode`, which can be either `text` or `html`, and that determines
if the view should output plain text or html.

A type finally has to be registered in `EntitiesApi` (api.ls).


## License

MIT, (c) 2015 Michael Brade
