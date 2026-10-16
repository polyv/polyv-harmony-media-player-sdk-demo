import {
  logger,
  extendNumber,
  IPLVMediaPlayer,
  LifecycleAwareDependComponent,
  MutableObserver,
  MutableState,
  PLVMediaBitRate,
  PLVMediaOutputMode,
  PLVMediaPlayer,
  PLVMediaPlayerHttpDns,
  PLVMediaPlayerOption,
  PLVMediaPlayerPlayingState,
  PLVMediaRoute,
  PLVMediaResource,
  PLVMediaSubtitle
} from '@polyvharmony/media-player-sdk';
import { PLVMediaPlayerAddonBusinessManager } from '@polyvharmony/media-player-sdk-addon-business';
import { PLVMPMediaMediator } from '../mediator/PLVMPMediaMediator';

const TAG = 'PLVBackgroundPlayback'

export class PLVMPMediaRepo implements LifecycleAwareDependComponent {

  readonly mediator: PLVMPMediaMediator
  readonly player: PLVMediaPlayer = new PLVMediaPlayer()
  readonly httpDnsEnabled = new MutableState<boolean>(PLVMediaPlayerHttpDns.getInstance().enable)

  private observers: MutableObserver[] = []

  constructor(
    mediator: PLVMPMediaMediator
  ) {
    this.mediator = mediator

    this.mediator.start = () => this.start()
    this.mediator.pause = () => this.pause()
    this.mediator.seekTo = (position: number) => this.seekTo(position)
    this.mediator.getSpeed = () => this.player.getStateListenerRegistry().speed.value ?? 1
    this.mediator.setSpeed = (speed: number) => this.setSpeed(speed)
    this.mediator.isPlaying = () => this.player.getStateListenerRegistry().playingState.value === PLVMediaPlayerPlayingState.PLAYING
    this.mediator.getVolume = () => this.player.getStateListenerRegistry().volume.value ?? 100
    this.mediator.setVolume = (volume: number) => this.setVolume(volume)
    this.mediator.bindAuxiliaryPlayer = (auxiliaryPlayer) => this.player.bindAuxiliaryPlayer(auxiliaryPlayer)
    this.mediator.unbindAuxiliaryPlayer = (auxiliaryPlayer) => this.player.unbindAuxiliaryPlayer(auxiliaryPlayer)
    this.mediator.addonBusinessManager =
      () => PLVMediaPlayerAddonBusinessManager.of(this.player as any as IPLVMediaPlayer)
    this.player.getEventListenerRegistry().onPrepared.relayTo(this.mediator.onPreparedEvent).pushTo(this.observers)
    this.player.getBusinessListenerRegistry().onAutoContinueEvent.relayTo(this.mediator.onAutoContinueEvent).pushTo(this.observers)
    this.player.getEventListenerRegistry().onInfo.relayTo(this.mediator.onInfoEvent).pushTo(this.observers)
    this.player.getEventListenerRegistry()
      .onSeekCompleteEvent
      .relayTo(this.mediator.onSeekCompleteEvent)
      .pushTo(this.observers)
    this.player.getEventListenerRegistry().onCompleted.relayTo(this.mediator.onCompleteEvent).pushTo(this.observers)
    this.player.getStateListenerRegistry().playingState.relayTo(this.mediator.playingState).pushTo(this.observers)
    this.player.getStateListenerRegistry().playerState.relayTo(this.mediator.playerState).pushTo(this.observers)
    this.player.getBusinessListenerRegistry().businessErrorState.relayTo(this.mediator.businessErrorState).pushTo(this.observers)
  }

  setMediaResource(mediaResource: PLVMediaResource) {
    this.player.setMediaResource(mediaResource)
    this.mediator.mediaResource.value = mediaResource
  }

  setXComponent(xComponent: any) {
    this.player.setXComponent(xComponent)
  }

  setAutoContinue(autoContinue: boolean) {
    this.player.setAutoContinue(autoContinue)
  }

  setPlayerOption(options: PLVMediaPlayerOption[]) {
    this.player.setPlayerOption(options)
  }

  start() {
    this.player.start()
  }

  pause() {
    // 只在显式暂停时输出调用栈，便于区分生命周期、音频焦点、投屏和用户操作。
    logger.info(TAG, `[player] pause requested, playing=${this.player.getStateListenerRegistry().playingState.value}, stack=${new Error('pause requested').stack}`)
    this.player.pause()
  }

  seekTo(position: number) {
    const duration = this.player.getStateListenerRegistry().durationState.value ?? 0
    const nextPosition = extendNumber(position).coerceIn_ext(0, duration)
    this.player.seek(nextPosition)
    if (nextPosition < duration) {
      this.player.start()
    } else {
      this.player.pause()
    }
  }

  restart() {
    this.player.restart()
  }

  setSpeed(speed: number) {
    this.player.setSpeed(speed)
  }

  setVolume(volume: number) {
    this.player.setVolume(volume)
  }

  changeBitRate(bitRate: PLVMediaBitRate) {
    this.player.changeBitRate(bitRate)
    this.mediator.onChangeBitRateEvent.value = bitRate
  }

  changeRoute(route: PLVMediaRoute) {
    this.player.changeRoute(route)
  }

  changeHttpDns(enable: boolean) {
    PLVMediaPlayerHttpDns.getInstance().enable = enable
    this.httpDnsEnabled.value = enable
    this.player.reload()
  }

  changeMediaOutputMode(outputMode: PLVMediaOutputMode) {
    this.player.changeMediaOutputMode(outputMode)
  }

  setShowSubtitles(subtitles: PLVMediaSubtitle[]) {
    this.player.setShowSubtitles(subtitles)
  }

  onDestroy(): void {
    PLVMediaPlayerAddonBusinessManager.of(this.player as any as IPLVMediaPlayer).destroy()
    this.player.destroy()
    MutableObserver.disposeAll(this.observers)
    this.observers = []
  }

}
