import {
  LifecycleAwareDependComponent,
  MutableObserver,
  PLVMediaBitRate,
  PLVMediaOutputMode,
  PLVMediaPlayer,
  PLVMediaPlayerOption,
  PLVMediaPlayerPlayingState,
  PLVMediaResource,
  PLVMediaSubtitle
} from '@polyvharmony/media-player-sdk';
import { PLVMPMediaMediator } from '../mediator/PLVMPMediaMediator';

export class PLVMPMediaRepo implements LifecycleAwareDependComponent {

  readonly mediator: PLVMPMediaMediator
  readonly player: PLVMediaPlayer = new PLVMediaPlayer()

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
    this.player.getEventListenerRegistry().onPrepared.relayTo(this.mediator.onPreparedEvent).pushTo(this.observers)
    this.player.getBusinessListenerRegistry().onAutoContinueEvent.relayTo(this.mediator.onAutoContinueEvent).pushTo(this.observers)
    this.player.getEventListenerRegistry().onInfo.relayTo(this.mediator.onInfoEvent).pushTo(this.observers)
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
    this.player.pause()
  }

  seekTo(position: number) {
    this.player.seek(position)
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

  changeMediaOutputMode(outputMode: PLVMediaOutputMode) {
    this.player.changeMediaOutputMode(outputMode)
  }

  setShowSubtitles(subtitles: PLVMediaSubtitle[]) {
    this.player.setShowSubtitles(subtitles)
  }

  onDestroy(): void {
    this.player.destroy()
    MutableObserver.disposeAll(this.observers)
    this.observers = []
  }

}