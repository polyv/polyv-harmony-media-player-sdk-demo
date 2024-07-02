import {PLVMPMediaRepo} from '../../model/PLVMPMediaRepo';
import {
  DerivedState,
  LifecycleAwareDependComponent,
  PLVMediaOutputMode,
  PLVMediaPlayerPlayingState,
  PLVMediaPlayerState,
  Rect
} from '@polyvharmony/media-player-sdk';
import {PLVMPMediaPlayViewState} from '../viewstate/PLVMPMediaPlayViewState';
import {PLVMPMediaInfoViewState} from '../viewstate/PLVMPMediaInfoViewState';
import {UpdateBufferingSpeedUseCase} from "./UpdateBufferingSpeedUseCase";

export class UpdateMediaStateUseCase implements LifecycleAwareDependComponent {

  private readonly repo: PLVMPMediaRepo
  private readonly updateBufferingSpeedUseCase: UpdateBufferingSpeedUseCase

  readonly mediaPlayViewState: DerivedState<PLVMPMediaPlayViewState>;
  readonly mediaInfoViewState: DerivedState<PLVMPMediaInfoViewState>;

  constructor(
    repo: PLVMPMediaRepo,
    updateBufferingSpeedUseCase: UpdateBufferingSpeedUseCase
  ) {
    this.repo = repo
    this.updateBufferingSpeedUseCase = updateBufferingSpeedUseCase

    this.mediaPlayViewState = new DerivedState(() => {
      const viewState = new PLVMPMediaPlayViewState();
      viewState.currentProgress = this.repo.player.getStateListenerRegistry().progressState.value ?? 0
      viewState.duration = this.repo.player.getStateListenerRegistry().durationState.value ?? 0
      viewState.isPlaying = this.repo.player.getStateListenerRegistry().playingState.value === PLVMediaPlayerPlayingState.PLAYING
      viewState.playerState = this.repo.player.getStateListenerRegistry().playerState.value ?? PLVMediaPlayerState.STATE_IDLE
      viewState.isBuffering = this.repo.player.getStateListenerRegistry().isBuffering.value ?? false
      viewState.bufferingSpeed = this.updateBufferingSpeedUseCase.bufferingSpeed.value ?? 0
      viewState.speed = this.repo.player.getStateListenerRegistry().speed.value ?? 1
      return viewState;
    })

    this.mediaInfoViewState = new DerivedState(() => {
      const viewState = new PLVMPMediaInfoViewState();
      viewState.title = this.repo.player.getBusinessListenerRegistry().vodVideoJson.value?.title ?? ""
      viewState.videoSize = this.repo.player.getStateListenerRegistry().videoSize.value ?? new Rect()
      viewState.bitRate = this.repo.player.getBusinessListenerRegistry().currentMediaBitRate.value ?? null
      viewState.supportBitRates = this.repo.player.getBusinessListenerRegistry().supportMediaBitRates.value ?? []
      viewState.outputMode = this.repo.player.getBusinessListenerRegistry().currentMediaOutputMode.value ?? PLVMediaOutputMode.AUDIO_VIDEO
      viewState.supportOutputModes = this.repo.player.getBusinessListenerRegistry().supportMediaOutputModes.value ?? []
      viewState.progressPreviewImage = this.repo.player.getBusinessListenerRegistry().vodVideoJson.value?.progressImage ?? null
      viewState.progressPreviewImageInterval = this.repo.player.getBusinessListenerRegistry().vodVideoJson.value?.progressImageInterval?.toSeconds() ?? -1
      viewState.audioModeCoverImage = this.repo.player.getBusinessListenerRegistry().vodVideoJson.value?.first_image ?? null
      return viewState;
    })
  }

  onDestroy() {
    this.mediaPlayViewState.destroy()
    this.mediaInfoViewState.destroy()
  }

}