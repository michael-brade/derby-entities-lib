import _ from 'lodash';
import { EntityDependencies } from './base';
import forOf from 'es6-iterator/for-of';
import 'array.from';

export class DependencyMatrix extends EntityDependencies {
  matrix: any[];

  constructor(model: any) {
    super(model);
    this.matrix = this.model.at('_dependencyIdMatrix');
  }

  addDependency(sourceId: string, dependencyId: string): void {
    this.matrix.push(sourceId, dependencyId);
  }

  data(): { packageNames: string[], matrix: number[][] } {
    const itemNames: string[] = [];
    const matrix: number[][] = [];
    this.init();

    itemNames.push(..._.map(Array.from(this.itemMap.values()), (v: any) => {
      return this.api.renderAsText(v.item, v.entity.id, 'en');
    }));

    forOf(this.itemMap.keys(), (itemId: string) => {
      const r: number[] = [];
      const depIds: string[] = this.matrix.get(itemId);
      forOf(this.itemMap.keys(), (depId: string) => {
        if (_.includes(depIds, depId)) {
          r.push(1);
        } else {
          r.push(0);
        }
      });
      matrix.push(r);
    });

    return {
      packageNames: itemNames,
      matrix: matrix
    };
  }
}
