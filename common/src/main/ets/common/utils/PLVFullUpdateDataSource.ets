import { extendArray } from '@polyvharmony/media-player-sdk';

export class PLVFullUpdateDataSource<T> implements IDataSource {
  private readonly datas: T[] = []
  private readonly listeners: DataChangeListener[] = []

  totalCount(): number {
    return this.datas.length;
  }

  getData(index: number): T {
    return this.datas[index];
  }

  registerDataChangeListener(listener: DataChangeListener): void {
    this.listeners.push(listener);
  }

  unregisterDataChangeListener(listener: DataChangeListener): void {
    extendArray(this.listeners).remove_ext(listener);
  }

  update(newDatas: T[]) {
    this.datas.length = 0;
    this.datas.push(...newDatas);
    this.listeners.forEach(it => it.onDataReloaded());
  }
}