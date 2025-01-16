import { ComponentViewDefinition } from 'derby';
import { AttrDefinition } from '../api';
import { Type } from './type';


interface TextareaProps {

}

export class Textarea extends Type<TextareaProps> {

  static displayName: string = 'Textarea';

  static view: ComponentViewDefinition = Object.assign({}, Textarea.view, {
    style: __dirname + "/textarea"
  });

  // set by derby due to as=
  public expandingTextarea!: HTMLElement

  create(): void {
    if (this.expandingTextarea)
      this.expandingTextarea.className += " active";
    else
      console.warn("no this.expandingTextarea set!!");  // TODO just for debugging
  }

  emitSomething(ev: any, el: any): void {
    this.emit("keydown", ev, el);
  }

  renderAttributeData(data: any, attr: AttrDefinition, locale: string, parent?: HTMLElement): any {
    return data;
  }
}