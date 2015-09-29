# Derby Entities Library

This library reads the entity schema definition and provides the API to access entities and their items.
It is the base library for [derby-entity](TODO).


## Terminology

* entity: in case of Derby: a MongoDB collection
* item: the actual instances of an entity, a MongoDB document, has at least an id and a name attribute
* attribute: an attribute of an entity

An analogy would be from the OO world: an entity is a class of which an item is an object.


## Schema Definition

Derby uses MongoDB in the background and that is currently the only option available. The structure of how
the data is store in the DB can be chosen quite freely with `derby-entity`. Basically, the components under
`types/` define how to read and write an attribute of an item, i.e., a document in a collection. Even though
MongoDB allows for arbitrary strutures, each item of one entity has to have the same structure. That means
all MongoDB documents have the same structure under a certain collection.


### Entities

An entity definition has the following structure:

```ls
entities =
    * id: "people"

      display:
          attribute: "name"
          decorate: ["photo", "employer"]

      attributes:
        * id:   "name"
          type: "text"

        * id:   "email"  
          type: "text"

        * id:   "photo"
          type: "image"

        * id:   "employer"
          type: "entity"
          multi: false
          reference: true
```

### Display

(not implemented yet)

This property defines how to display an item of that entity if displayed as an attribute
of another item or in a select2 dropdown. It is the summary of that item, so to speak.

* `attribute` sets the main attribute of that item (default: `name`)
* `decorate` adds further information, like an image, a color, or just some additional text.
  (default: empty)


### Attributes

All attributes must define at least two properties: `id` and `type`.


##### `id`, type: `string`

The id of the attribute to be defined. Each entity has to have one attribute with the id `name`.

##### `type`, type: `string`

The type of the attribute, as available under `types/`.


### Attribute Types

Each attribute type allows for certain properties to be set.

#### Color, image, number, text, textarea

These types don't take any properties.


#### Entity

##### `entity`, type: `string`, default: none, mandatory

The entity type of which this attribute can select its item(s) from.

##### `reference`, type: `boolean`, default: `false`

Should the whole item be copied into this item's attribute (`reference=false`), or should this attribute just be a reference to the other item.


##### `multi`, type: `boolean`, default: `false`

If this attribute holds just one value, set `multi` to `false`, if it holds an array of items, set
`multi` to `true`.

##### `uniq`, type: `boolean`, default: `true`

In case of `multi==true`, this determines if the same item can appear more than once (`uniq==false`), or
if each item has to be unique.


### Validation

I haven't yet spent much time thinking about validation. Just a very basic `uniqValidator` is implemented.
Maybe I will add a `validation` property to an attribute...


## Development

### Adding new Attribute Type Definitions

Each type class has to provide the following methods:

- `attribute: (item, attr, locale) ->`
- `renderAttribute: (item, attr, locale, parent) ->`

The component view takes a parameter `mode`, which can be either `text`, `html`, or `edit`, and that determines
if the view should output plain text or html, or if the editor for that attribute should be rendered.

Consequently, each component should define three subviews: `<text:>`, `<html:>`, and `<edit:>`.

A type finally has to be registered in `EntitiesApi` (api.ls).


## License

MIT

Copyright (c) 2015 Michael Brade
