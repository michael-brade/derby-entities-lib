import path from 'path';

import Api, { EntityDefinition } from '../api';
import { Component } from 'derby';
import { type ChildModel } from 'racer';


interface ItemData {
  entity: string | { id: string };
}

export class Item extends Component<ItemData> {

  static view = {
    file: path.join(__dirname, 'item.html')
  };

  init(model: ChildModel<ItemData>): void {
    model.ref('$locale', model.root.at('$locale'));

    let entity = this.getAttribute<EntityDefinition>('entity');
    if (typeof entity === "string")
      entity = Api.instance(model).entity(entity);
    else
      entity = Api.instance(model).entity(entity.id);

    let item = model.get('item'); // TODO unsused?!?

    model.set("displayAttr", entity.attributes[entity.display.attribute]);
    model.set("decorationAttrs", []);
    for (let i = 0; i < entity.display.decorate.length; i++) {
      let attrId = entity.display.decorate[i];
      model.push("decorationAttrs", entity.attributes[attrId]);
    }
  }

  focus(): void {
    $(this.form).find(':input[type!=hidden]').first().focus();
  }

  done(item: any): void {
    this.emit("done", item);
  }
}
