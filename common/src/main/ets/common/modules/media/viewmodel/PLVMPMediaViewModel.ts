import {PLVMPMediaRepo} from '../model/PLVMPMediaRepo';
import {PLVMPMediaUseCases} from './usecase/PLVMPMediaUseCases';
import {
  MutableEvent,
  MutableState,
  PLVMediaBitRate,
  PLVMediaOutputMode,
  PLVMediaPlayerAutoContinueEvent,
  PLVMediaPlayerOnInfoEvent,
  PLVMediaPlayerOnPreparedEvent,
  PLVMediaPlayerOption,
  PLVMediaPlayerState,
  PLVMediaResource
} from '@polyvharmony/media-player-sdk';
import {PLVMPMediaPlayViewState} from './viewstate/PLVMPMediaPlayViewState';
import {PLVMPMediaInfoViewState} from './viewstate/PLVMPMediaInfoViewState';

export class PLVMPMediaViewModel {

  private readonly repo: PLVMPMediaRepo
  private readonly useCases: PLVMPMediaUseCases

  readonly mediaPlayViewState: MutableState<PLVMPMediaPlayViewState>
  readonly mediaInfoViewState: MutableState<PLVMPMediaInfoViewState>
  readonly networkPoorEvent: MutableEvent<number>
  readonly onChangeBitRateEvent: MutableEvent<PLVMediaBitRate>
  readonly onPreparedEvent: MutableEvent<PLVMediaPlayerOnPreparedEvent>
  readonly onAutoContinueEvent: MutableEvent<PLVMediaPlayerAutoContinueEvent>
  readonly onInfoEvent: MutableEvent<PLVMediaPlayerOnInfoEvent>
  readonly playerState: MutableState<PLVMediaPlayerState>

  constructor(
    repo: PLVMPMediaRepo,
    useCases: PLVMPMediaUseCases
  ) {
    this.repo = repo
    this.useCases = useCases
    this.mediaPlayViewState = this.useCases.updateMediaStateUseCase.mediaPlayViewState
    this.mediaInfoViewState = this.useCases.updateMediaStateUseCase.mediaInfoViewState
    this.networkPoorEvent = this.useCases.observeNetworkPoorUseCase.networkPoorEvent
    this.onChangeBitRateEvent = this.repo.onChangeBitRateEvent
    this.onPreparedEvent = this.repo.player.getEventListenerRegistry().onPrepared
    this.onAutoContinueEvent = this.repo.player.getBusinessListenerRegistry().onAutoContinueEvent
    this.onInfoEvent = this.repo.player.getEventListenerRegistry().onInfo
    this.playerState = this.repo.player.getStateListenerRegistry().playerState

    this.repo.mediator.mediaInfo = () => this.mediaInfoViewState.value
  }

  setMediaResource(mediaResource: PLVMediaResource) {
    this.repo.setMediaResource(mediaResource)
  }

  setXComponent(xComponent: any) {
    this.repo.setXComponent(xComponent)
  }

  setAutoContinue(autoContinue: boolean) {
    this.repo.setAutoContinue(autoContinue)
  }

  setPlayerOption(options: PLVMediaPlayerOption[]) {
    this.repo.setPlayerOption(options)
  }

  start() {
    this.repo.start()
  }

  pause() {
    this.repo.pause()
  }

  seekTo(position: number) {
    this.repo.seekTo(position)
  }

  restart() {
    this.repo.restart()
  }

  setSpeed(speed: number) {
    this.repo.setSpeed(speed)
  }

  changeBitRate(bitRate: PLVMediaBitRate) {
    this.repo.changeBitRate(bitRate)
  }

  changeMediaOutputMode(outputMode: PLVMediaOutputMode) {
    this.repo.changeMediaOutputMode(outputMode)
  }

}