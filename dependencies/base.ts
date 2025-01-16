import _ from 'lodash';
import EntitiesApi from '../api';

export interface Entity {
  id: string;
  attributes: Record<string, any>;
}

export interface Item {
  id: string;
  [key: string]: any;
}

export interface EntityDependenciesConstructor {
  new(model: any): EntityDependencies;
}

export interface EntityDependencies {
  model: any;
  api: any;
  itemMap: Map<string, { entity: Entity; item: Item }>;
  ranges: Map<string, { from: number; to: number }>;
  rangeCur: number;
  init(): void;
  addDependency(sourceId: string, dependencyId: string): void;
  data(): any;
  addItem(entity: Entity, item: Item): void;
  addRange(entityId: string, count: number): void;
  allDependencyIds(item: Item, attr: any): string[];
}

export const EntityDependencies: EntityDependenciesConstructor = (function () {
  EntityDependencies.displayName = 'EntityDependencies';
  const prototype = EntityDependencies.prototype;
  prototype.model = null;
  prototype.api = null;
  prototype.itemMap = new Map<string, { entity: Entity; item: Item }>();
  prototype.ranges = new Map<string, { from: number; to: number }>();
  prototype.rangeCur = 0;

  function EntityDependencies(model: any) {
    if (this.constructor === EntityDependencies) {
      throw new Error("Can't instantiate abstract class!");
    }
    this.model = model;
    this.api = EntitiesApi.instance(model);
    this.ranges = new Map();
    this.itemMap = new Map();
  }

  prototype.init = function (): void {
    for (const key in this.api.entitiesIdx) {
      this.processEntity(key, this.api.entitiesIdx[key]);
    }
  };

  prototype.processEntity = function (key: string, entity: Entity): void {
    const items: Item[] = this.api.items(entity.id);
    this.addRange(entity.id, items.length);
    for (const item of items) {
      this.processItem(entity, item);
    }
  };

  prototype.processItem = function (entity: Entity, item: Item): void {
    this.addItem(entity, item);
    for (const attrId in entity.attributes) {
      this.processAttribute(entity, item, attrId, entity.attributes[attrId]);
    }
  };

  prototype.processAttribute = function (entity: Entity, item: Item, attrId: string, attr: any): void {
    const dependencyIds: string[] = this.allDependencyIds(item, attr);
    for (const id of dependencyIds) {
      this.addDependency(item.id, id);
    }
  };

  prototype.addDependency = function (sourceId: string, dependencyId: string): void {
    throw new Error("addDependency must be implemented in subclasses!");
  };

  prototype.data = function (): any {
    throw new Error("data must be implemented in subclasses!");
  };

  prototype.addItem = function (entity: Entity, item: Item): void {
    this.itemMap.set(item.id, {
      entity: entity,
      item: item
    });
  };

  prototype.addRange = function (entityId: string, count: number): void {
    this.ranges.set(entityId, {
      from: this.rangeCur,
      to: this.rangeCur + count
    });
    this.rangeCur += count;
  };

  prototype.allDependencyIds = function (item: Item, attr: any): string[] {
    const ids: string[] = [];
    if (attr.type !== 'entity' || !item[attr.id]) {
      return ids;
    }
    for (const dep of item[attr.id]) {
      if (attr.reference) {
        ids.push(dep);
      } else {
        ids.push(dep.id);
      }
    }
    return ids;
  };

  return EntityDependencies;
}());