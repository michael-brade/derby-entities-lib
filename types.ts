import { App } from 'derby';

// import Api from './api';

import { Text } from './types/text';
import { Textarea } from './types/textarea';
import { Number } from './types/number';
import { Entity } from './types/entity';
import { Color } from './types/color';
import { Image } from './types/image';

export type SupportedTypeComponent =
  typeof Text |
  typeof Textarea |
  typeof Number |
  typeof Entity |
  typeof Color |
  typeof Image;


export const supportedTypeComponents: SupportedTypeComponent[] = [Text, Textarea, Number, Entity, Color, Image];

export default function(app: App) {
  supportedTypeComponents.forEach((type: SupportedTypeComponent) => {
    app.component(type);
  });
}
