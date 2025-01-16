import { Type } from './type';
import { AttrDefinition } from '../api';


interface NumberProps {

}

export class Number extends Type<NumberProps> {

    renderAttributeData(data: any, attr: AttrDefinition, locale: string, parent: any): string {
        return data;
    }

}