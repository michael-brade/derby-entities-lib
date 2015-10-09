# Derby Entities Library

This library reads the entity schema definition and provides the API to access entities and their items.
It is the base library for [derby-entity](https://github.com/michael-brade/derby-entity).


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
        * id:   "email"  

        * id:   "photo"
          type: "image"

        * id:   "employer"
          type: "entity"
          multi: false
          reference: true
```

### Display

This property defines how to display an item of that entity if displayed as an attribute
of another item or in a select2 dropdown. It is the summary of that item, so to speak.

##### `attribute`, type: `string`, default: `name`

This sets the main display attribute of that item.

##### `decorate`, type: `array of strings`, default: none

`decorate` adds further information, like an image, a color, or just some additional text.
This works recursively, so the display attribute is rendered, that output is then input to
the attribute renderer for the `photo` attribute (to stay with the example above), which
then is passed to the `employer` renderer. (Actually, `entity` doesn't support decorations
yet, but whatever, you get the idea.)


### Attributes

Currently available attribute types:

Type      | Description
----------|--------------------------------------
text      | default type; a simple string, edited using `<input type="text">`
textarea  | also a simple string, but probably longer, thus edited with an automatically expanding textarea
number    | an integer, edited using `<input type="number">`
color     | a color, edited using `<input type="color">`
image     | an image, which will be converted to base64 and stored like a string
entity    | a nested structure, copy/reference the item of another entity type

Planned for the future are:

Type     | Description
---------|--------------------------------------
boolean  | enter a true/false value using a checkbox
password | enter and encrypt a password securely
object   | to allow for arbitrary data structures to be created and edited, essentially creating recursive forms
markdown | a markdown text field, edited using CodeMirror and a visual editor
svg      | instead of an image, use svg
image-upload | maybe; this would upload the image to the server and create a link to it so that it doesn't have to be stored in the MongoDB
file-upload | same, see above


All attributes must define at least one property: `id`. The following properties are available for all
attribute types:


##### `id`, type: `string`, default: none, mandatory

The id of the attribute to be defined. This will be the key used in the json structure for the value this attribute
holds.

##### `type`, type: `string`, default: `text`

The type of the attribute, as available under `types/`. See the [next](#attribute-types) section for details.


##### `i18n`, type: `boolean`, default: `false`

If `i18n` is `false`, the value for the key is stored directly, like

```
{
    <id>: value
}
```

If `i18n` is `true`, then the value for the key will be an object with each supported locale as keys:

```
{
    <id>: {
        en: <value-in-en>
        de: <value-in-de>
        fr: <value-in-fr>
        ...
    }
}
```



### Attribute Types

Each attribute type allows for certain properties to be set.

#### Color, number, text, textarea

These types don't take any special properties. Except for number, they all support decorations.

#### Image

A base64 image storage in the model. Supports decorations.

##### `max-size`, type: `number`, unit: `kB`, default: unlimited

(not implemented yet)

Since this is a base64 representation of the image, it should be possible to restrict the maximum size. The
given number is interpreted as kilobytes.


#### Entity

##### `entity`, type: `string`, default: none, mandatory

The entity type of which this attribute can select its item(s) from.

##### `reference`, type: `boolean`, default: `false`

Should the whole item be copied into this item's attribute (`reference==false`), or should this attribute just be a
reference to the other item (`reference==true`). Copying the item makes only sense if you want to keep the information just as it was
when this item was edited; then it is irrelevant if the copied item is changed or deleted later on.

If it is a reference on the other hand then all changes will be visible in this item and the referenced item may not
be deleted as long as this item exists in the database.


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

Right now, each attribute type consists of a controller (written in JavaScript/LiveScript/whatever) and a Derby view.
It is, in effect, a Derby component.


#### Controller

Each type class has to provide the following methods:

- `attribute: (item, attr, locale) ->`

    This returns the `item`'s attribute `attr` as plain text in the given `locale`.

- `renderAttribute: (item, attr, locale, parent) ->`

    This returns the `item`'s attribute `attr` as html in the given `locale`.

If the type extends the class `Type`, then `attribute` is optional, and instead of the whole `item`, just its attribute is provided as `data`. This is just so that some common boilerplate can be avoided.


#### View

The component view takes a parameter `mode`, which can be either `text`, `html`, or `edit`, and that determines
if the view should output plain text or html, or if the editor for that attribute should be rendered.

Consequently, each component should define three subviews: `<-text:>`, `<-html:>`, and `<-edit:>`. There is a leading
dash to make sure that views don't get confused with components, like `entity:text` vs `text`.

A type finally has to be registered in `EntitiesApi` (api.ls).


## License

MIT

Copyright (c) 2015 Michael Brade
