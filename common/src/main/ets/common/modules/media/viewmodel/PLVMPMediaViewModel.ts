import {PLVMPMediaRepo} from '../model/PLVMPMediaRepo';
import {PLVMPMediaUseCases} from './usecase/PLVMPMediaUseCases';
import {
  LifecycleAwareDependComponent,
  MutableEvent,
  MutableState,
  PLVMediaBitRate,
  PLVMediaOutputMode,
  PLVMediaPlayerAutoContinueEvent,
  PLVMediaPlayerOnCompletedEvent,
  PLVMediaPlayerOnInfoEvent,
  PLVMediaPlayerOnPreparedEvent,
  PLVMediaPlayerOption,
  PLVMediaPlayerState,
  PLVMediaResource,
  PLVMediaSubtitle,
  State
} from '@polyvharmony/media-player-sdk';
import {PLVMPMediaPlayViewState} from './viewstate/PLVMPMediaPlayViewState';
import {PLVMPMediaInfoViewState} from './viewstate/PLVMPMediaInfoViewState';
import {image} from '@kit.ImageKit';

export class PLVMPMediaViewModel implements LifecycleAwareDependComponent {

  private readonly repo: PLVMPMediaRepo
  private readonly useCases: PLVMPMediaUseCases

  readonly mediaPlayViewState: State<PLVMPMediaPlayViewState>
  readonly mediaInfoViewState: State<PLVMPMediaInfoViewState>
  readonly networkPoorEvent: MutableEvent<number>
  readonly onChangeBitRateEvent: MutableEvent<PLVMediaBitRate>
  readonly onPreparedEvent: MutableEvent<PLVMediaPlayerOnPreparedEvent>
  readonly onAutoContinueEvent: MutableEvent<PLVMediaPlayerAutoContinueEvent>
  readonly onInfoEvent: MutableEvent<PLVMediaPlayerOnInfoEvent>
  readonly onCompleteEvent: MutableEvent<PLVMediaPlayerOnCompletedEvent>
  readonly playerState: MutableState<PLVMediaPlayerState>

  onScreenshot: (() => Promise<image.PixelMap>) | null = null

  constructor(
    repo: PLVMPMediaRepo,
    useCases: PLVMPMediaUseCases
  ) {
    this.repo = repo
    this.useCases = useCases
    this.mediaPlayViewState = this.repo.mediator.mediaPlayViewState
    this.mediaInfoViewState = this.repo.mediator.mediaInfoViewState
    this.networkPoorEvent = this.repo.mediator.networkPoorEvent
    this.onChangeBitRateEvent = this.repo.mediator.onChangeBitRateEvent
    this.onPreparedEvent = this.repo.mediator.onPreparedEvent
    this.onAutoContinueEvent = this.repo.mediator.onAutoContinueEvent
    this.onInfoEvent = this.repo.mediator.onInfoEvent
    this.onCompleteEvent = this.repo.mediator.onCompleteEvent
    this.playerState = this.repo.mediator.playerState
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

  setShowSubtitles(subtitles: PLVMediaSubtitle[]) {
    this.repo.setShowSubtitles(subtitles)
  }

  onDestroy(): void {
    this.onScreenshot = null
  }

}