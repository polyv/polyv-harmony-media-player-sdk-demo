import {
  extendArray,
  LifecycleAwareDependComponent,
  MutableObserver,
  PLVMediaPlayerOnInfoEvent,
  seconds
} from '@polyvharmony/media-player-sdk';
import { PLVMPMediaRepo } from '../../model/PLVMPMediaRepo';

// <editor-fold defaultstate="collapsed" desc="常量">

// 计时：5秒卡顿进行一次提示
const INDICATE_BUFFERING_TIMEOUT = seconds(5).toMillis();
// 计次：计算10秒内卡顿次数
const INDICATE_COUNT_BUFFERING_DURATION = seconds(10).toMillis();
// 计次：2次卡顿进行一次提示
const INDICATE_BUFFERING_COUNT_TOO_MORE_THRESHOLD = 2;

// </editor-fold>

export class ObserveNetworkPoorUseCase implements LifecycleAwareDependComponent {

  private readonly repo: PLVMPMediaRepo
  private bufferingEvents: BufferingEventVO[] = []
  private lastSeekTimestamp: number = 0
  private isIndicatedNetworkPoor: boolean = false
  private observers: MutableObserver[] = []

  constructor(
    repo: PLVMPMediaRepo
  ) {
    this.repo = repo

    this.observePlayerEvent()
  }

  private observePlayerEvent() {
    this.repo.player.getEventListenerRegistry().onInfo.observe((onInfo: PLVMediaPlayerOnInfoEvent) => {
      if (onInfo.what === PLVMediaPlayerOnInfoEvent.MEDIA_INFO_BUFFERING_START) {
        this.onBufferingStart()
      }
      if (onInfo.what === PLVMediaPlayerOnInfoEvent.MEDIA_INFO_BUFFERING_END) {
        this.onBufferingEnd()
      }
    }).pushTo(this.observers)
    this.repo.player.getEventListenerRegistry().onSeekStartEvent.observe(() => {
      this.onSeekStart()
    }).pushTo(this.observers)
    this.repo.player.getEventListenerRegistry().onPrepared.observe(() => {
      this.reset()
    })
      .pushTo(this.observers)
  }

  private onBufferingStart() {
    const event = new BufferingEventVO()
    event.bySeek = Date.now() - this.lastSeekTimestamp < 500
    this.bufferingEvents.push(event)

    this.checkToShowIndicate()
    setTimeout(() => this.checkToShowIndicate(), INDICATE_BUFFERING_TIMEOUT)
  }

  private onBufferingEnd() {
    const event = extendArray(this.bufferingEvents).lastOrNull_ext()
    if (!event) {
      return
    }
    event.endTimestamp = Date.now()
  }

  private onSeekStart() {
    this.lastSeekTimestamp = Date.now()
  }

  private reset() {
    this.bufferingEvents = []
    this.isIndicatedNetworkPoor = false
    this.lastSeekTimestamp = 0
  }

  private checkToShowIndicate() {
    this.dropExpireBufferingCache()
    const isNetworkPoor = this.checkBufferTooLong() || this.checkBufferTooMore()
    if (isNetworkPoor && !this.isIndicatedNetworkPoor) {
      this.repo.mediator.networkPoorEvent.value = Date.now()
      this.isIndicatedNetworkPoor = true
    }
  }

  private dropExpireBufferingCache() {
    this.bufferingEvents = this.bufferingEvents
      .filter((event) => {
        return event.endTimestamp < 0 || event.startTimestamp > Date.now() - INDICATE_COUNT_BUFFERING_DURATION
      })
  }

  private checkBufferTooLong(): boolean {
    const event = extendArray(this.bufferingEvents).lastOrNull_ext()
    if (!event) {
      return false
    }
    if (event.endTimestamp < 0) {
      return event.startTimestamp < Date.now() - INDICATE_BUFFERING_TIMEOUT
    } else {
      return event.endTimestamp - event.startTimestamp > INDICATE_BUFFERING_TIMEOUT
    }
  }

  private checkBufferTooMore(): boolean {
    return this.bufferingEvents
      .filter((event) => !event.bySeek)
      .length >= INDICATE_BUFFERING_COUNT_TOO_MORE_THRESHOLD
  }

  onDestroy() {
    MutableObserver.disposeAll(this.observers)
    this.observers = []
  }

}

class BufferingEventVO {
  startTimestamp: number = Date.now()
  endTimestamp: number = -1
  bySeek: boolean = false
}