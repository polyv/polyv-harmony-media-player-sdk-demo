import {
  LifecycleAwareDependComponent,
  MutableEvent,
  PLVMediaBitRate,
  PLVMediaOutputMode,
  PLVMediaPlayer,
  PLVMediaPlayerOption,
  PLVMediaPlayerPlayingState,
  PLVMediaResource
} from '@polyvharmony/media-player-sdk';
import {PLVMPMediaMediator} from '../mediator/PLVMPMediaMediator';

export class PLVMPMediaRepo implements LifecycleAwareDependComponent {

  readonly mediator: PLVMPMediaMediator
  readonly player: PLVMediaPlayer = new PLVMediaPlayer()

  readonly onChangeBitRateEvent = new MutableEvent<PLVMediaBitRate>()

  constructor(
    mediator: PLVMPMediaMediator
  ) {
    this.mediator = mediator

    this.mediator.seekTo = (position: number) => this.seekTo(position)
    this.mediator.onInfoEvent = this.player.getEventListenerRegistry().onInfo
    this.mediator.getSpeed = () => this.player.getStateListenerRegistry().speed.value ?? 1
    this.mediator.setSpeed = (speed: number) => this.setSpeed(speed)
    this.mediator.isPlaying = () => this.player.getStateListenerRegistry().playingState.value === PLVMediaPlayerPlayingState.PLAYING
    this.mediator.getVolume = () => this.player.getStateListenerRegistry().volume.value ?? 100
    this.mediator.setVolume = (volume: number) => this.setVolume(volume)
    this.mediator.businessErrorState = this.player.getBusinessListenerRegistry().businessErrorState
    this.mediator.playingState = this.player.getStateListenerRegistry().playingState
    this.mediator.playerState = this.player.getStateListenerRegistry().playerState
  }

  setMediaResource(mediaResource: PLVMediaResource) {
    this.player.setMediaResource(mediaResource)
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
    this.onChangeBitRateEvent.value = bitRate
  }

  changeMediaOutputMode(outputMode: PLVMediaOutputMode) {
    this.player.changeMediaOutputMode(outputMode)
  }

  onDestroy(): void {
    this.player.destroy()
  }

}