import {PLVMPMediaRepo} from '../../model/PLVMPMediaRepo';
import {
  LifecycleAwareDependComponent,
  MutableObserver,
  MutableState,
  PLVMediaPlayerPlayingState
} from '@polyvharmony/media-player-sdk';
import {PLVMPMediaPlayViewState} from '../viewstate/PLVMPMediaPlayViewState';
import {PLVMPMediaInfoViewState} from '../viewstate/PLVMPMediaInfoViewState';
import {UpdateBufferingSpeedUseCase} from "./UpdateBufferingSpeedUseCase";

export class UpdateMediaStateUseCase implements LifecycleAwareDependComponent {

  private readonly repo: PLVMPMediaRepo
  private readonly updateBufferingSpeedUseCase: UpdateBufferingSpeedUseCase

  readonly mediaPlayViewState: MutableState<PLVMPMediaPlayViewState> = new MutableState<PLVMPMediaPlayViewState>(new PLVMPMediaPlayViewState())
  readonly mediaInfoViewState: MutableState<PLVMPMediaInfoViewState> = new MutableState<PLVMPMediaInfoViewState>(new PLVMPMediaInfoViewState())

  private observers: MutableObserver[] = []

  constructor(
    repo: PLVMPMediaRepo,
    updateBufferingSpeedUseCase: UpdateBufferingSpeedUseCase
  ) {
    this.repo = repo
    this.updateBufferingSpeedUseCase = updateBufferingSpeedUseCase

    this.observePlayerState()
    this.observeBufferingSpeed()
  }

  private observePlayerState() {
    this.repo.player.getStateListenerRegistry().progressState.observe((progress) => {
      this.mediaPlayViewState.mutate({
        currentProgress: progress
      })
    }).pushTo(this.observers)

    this.repo.player.getStateListenerRegistry().durationState.observe((duration) => {
      this.mediaPlayViewState.mutate({
        duration: duration
      })
    }).pushTo(this.observers)

    this.repo.player.getStateListenerRegistry().playingState.observe((playingState) => {
      this.mediaPlayViewState.mutate({
        isPlaying: playingState === PLVMediaPlayerPlayingState.PLAYING
      })
    }).pushTo(this.observers)

    this.repo.player.getStateListenerRegistry().isBuffering.observe((isBuffering) => {
      this.mediaPlayViewState.mutate({
        isBuffering: isBuffering
      })
    }).pushTo(this.observers)

    this.repo.player.getStateListenerRegistry().speed.observe((speed) => {
      this.mediaPlayViewState.mutate({
        speed: speed
      })
    }).pushTo(this.observers)

    this.repo.player.getStateListenerRegistry().videoSize.observe((size) => {
      this.mediaInfoViewState.mutate({
        videoSize: size
      })
    }).pushTo(this.observers)

    this.repo.player.getBusinessListenerRegistry().currentMediaBitRate.observe((bitRate) => {
      this.mediaInfoViewState.mutate({
        bitRate: bitRate
      })
    }).pushTo(this.observers)

    this.repo.player.getBusinessListenerRegistry().supportMediaBitRates.observe((supportBitRates) => {
      this.mediaInfoViewState.mutate({
        supportBitRates: supportBitRates
      })
    }).pushTo(this.observers)

    this.repo.player.getBusinessListenerRegistry().currentMediaOutputMode.observe((outputMode) => {
      this.mediaInfoViewState.mutate({
        outputMode: outputMode
      })
    }).pushTo(this.observers)

    this.repo.player.getBusinessListenerRegistry().supportMediaOutputModes.observe((supportOutputModes) => {
      this.mediaInfoViewState.mutate({
        supportOutputModes: supportOutputModes
      })
    }).pushTo(this.observers)

    this.repo.player.getBusinessListenerRegistry().vodVideoJson.observe((videoJson) => {
      this.mediaInfoViewState.mutate({
        title: videoJson?.title ?? "",
        progressPreviewImage: videoJson?.progressImage ?? null,
        progressPreviewImageInterval: videoJson?.progressImageInterval?.toSeconds() ?? -1,
        audioModeCoverImage: videoJson?.first_image ?? null
      })
    }).pushTo(this.observers)
  }

  private observeBufferingSpeed() {
    this.updateBufferingSpeedUseCase.bufferingSpeed.observe((speed) => {
      this.mediaPlayViewState.mutate({
        bufferingSpeed: speed
      })
    }).pushTo(this.observers)
  }

  onDestroy() {
    this.observers.forEach((observer) => {
      observer.dispose()
    })
    this.observers = []
  }

}