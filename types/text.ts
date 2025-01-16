import { Type } from './type';
import { AttrDefinition } from '../api';


interface TextProps {

}


export class Text extends Type<TextProps> {

  // static name = 'Text';

  renderAttributeData(data: any, attr: AttrDefinition, locale: string): any {
    return data;
  }

}
