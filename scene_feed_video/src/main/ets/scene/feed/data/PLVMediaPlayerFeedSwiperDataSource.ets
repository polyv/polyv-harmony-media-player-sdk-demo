import { extendArray, PLVMediaResource, runCatching } from '@polyvharmony/media-player-sdk';
import { getDisplayWindowHeight } from 'media-player-common';
import { IPLVMediaPlayerFeedResourceDataSource } from './IPLVMediaPlayerFeedResourceDataSource';

export class PLVMediaPlayerFeedSwiperDataSource implements IDataSource {
  private readonly upstreamDataSource: IPLVMediaPlayerFeedResourceDataSource;
  private readonly data: PLVMediaResource[] = [];
  private readonly dataChangeListeners: DataChangeListener[] = [];
  private loadDataPromise: Promise<void> | null = null;
  private lastSwipeEvent: SwipeEvent | null = null;

  constructor(
    upstreamDataSource: IPLVMediaPlayerFeedResourceDataSource,
    initialDataSources?: PLVMediaResource[]
  ) {
    this.upstreamDataSource = upstreamDataSource
    if (initialDataSources) {
      this.data.push(...initialDataSources)
    }
    this.tryLoadMoreData(0)
  }

  totalCount(): number {
    return this.data.length;
  }

  getData(index: number): PLVMediaResource {
    return this.data[index];
  }

  registerDataChangeListener(listener: DataChangeListener): void {
    this.dataChangeListeners.push(listener);
  }

  unregisterDataChangeListener(listener: DataChangeListener): void {
    extendArray(this.dataChangeListeners).remove_ext(listener);
  }

  onGestureSwipe(index: number, event: SwiperAnimationEvent) {
    this.lastSwipeEvent = new SwipeEvent(index, event)
  }

  onAnimationEnd(index: number, event: SwiperAnimationEvent) {
    this.tryRefreshData()
    this.tryLoadMoreData(index)
    this.lastSwipeEvent = null;
  }

  private shouldRefreshFeedResource(swipeEvent: SwipeEvent | null): boolean {
    if (swipeEvent === null) {
      return false;
    }
    const topOverScroll = swipeEvent.index === 0 && swipeEvent.event.currentOffset > 0
    if (!topOverScroll) {
      return false;
    }
    return swipeEvent.event.currentOffset > getDisplayWindowHeight().vp * 0.2
  }

  private shouldLoadMoreFeedResource(swipeEvent: SwipeEvent | null, currentPage: number, count: number): boolean {
    const bottomOverScroll = swipeEvent !== null && swipeEvent.index === count - 1 && swipeEvent.event.currentOffset < 0
    return bottomOverScroll || currentPage > count - 5
  }

  private async tryLoadMoreData(accessIndex: number): Promise<void> {
    if (!this.shouldLoadMoreFeedResource(this.lastSwipeEvent, accessIndex, this.totalCount())) {
      return;
    }
    if (this.loadDataPromise !== null) {
      return;
    }
    this.loadDataPromise = this.loadDataFromIndex(this.data.length)
    await this.loadDataPromise
    this.loadDataPromise = null
  }

  private async loadDataFromIndex(index: number): Promise<void> {
    const loadResult = await runCatching(this.upstreamDataSource.onLoadMoreData(index))
    if (loadResult.success && loadResult.data.length > 0) {
      this.data.push(...loadResult.data);
      this.dataChangeListeners.forEach(listener => listener.onDataAdd(index));
    }
  }

  private async tryRefreshData(): Promise<void> {
    if (!this.shouldRefreshFeedResource(this.lastSwipeEvent)) {
      return;
    }
    if (this.loadDataPromise !== null) {
      return;
    }
    this.loadDataPromise = this.refreshData()
    await this.loadDataPromise
    this.loadDataPromise = null
  }

  private async refreshData(): Promise<void> {
    const loadResult = await runCatching(this.upstreamDataSource.onLoadMoreData(0))
    if (loadResult.success && loadResult.data.length > 0) {
      this.data.length = 0
      this.data.push(...loadResult.data);
      this.dataChangeListeners.forEach(listener => listener.onDataReloaded());
    }
  }
}

class SwipeEvent {
  readonly index: number
  readonly event: SwiperAnimationEvent

  constructor(
    index: number,
    event: SwiperAnimationEvent
  ) {
    this.index = index
    this.event = event
  }
}